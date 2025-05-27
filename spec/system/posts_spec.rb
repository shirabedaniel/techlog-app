require 'rails_helper'

RSpec.describe "Posts", type: :system do
  before do
    driven_by :rack_test
    @user = create(:user)
    @post = create(:post, title: 'RSpec学習完了', content: 'System Specを作成した', user_id: @user.id)
  end

  let(:title) { 'テストタイトル' }
  let(:content) { 'テスト本文' }

  describe 'ログ投稿機能の検証' do
    subject do
      fill_in 'post_title', with: title
      fill_in 'post_content', with: content
      click_button 'ログを記録'
    end

    context 'ログインしていない場合' do
      before { visit '/posts/new' }
      it 'ログインページへリダイレクトする' do
        expect(current_path).to eq('/users/sign_in')
        expect(page).to have_content('ログインしてください。')
      end
    end

    context 'ログインしている場合' do
      before do
        sign_in @user
        visit '/posts/new'
      end

      it 'ログインページへリダイレクトしない' do
        expect(current_path).not_to eq('/users/sign_in')
      end

      context 'パラメータが正常な場合' do
        it 'Postを作成できる' do
          expect { subject }.to change(Post, :count).by(1)
          expect(page).to have_content('投稿しました')
        end
      end

      context 'パラメータが異常な場合' do
        let(:title) { nil }
        it 'Postを作成できない' do
          expect { subject }.not_to change(Post, :count)
          expect(page).to have_content('投稿に失敗しました')
        end

        it '入力していた内容は維持される' do
          subject
          expect(page).to have_field('post_content', with: content)
        end
      end
    end
  end

  describe 'ログ詳細機能の検証' do
    before { visit "/posts/#{@post.id}" }

    it 'Postの詳細が表示される' do
      expect(page).to have_content('RSpec学習完了')
      expect(page).to have_content('System Specを作成した')
      expect(page).to have_content(@user.nickname)
    end
  end

  describe 'ログ一覧機能の検証' do
    before do
      @post2 = create(:post, title: 'RSpec学習完了 2', content: 'System Specを作成した 2', user_id: @user.id)
      visit '/posts'
    end

    it '1件目のPostの詳細が表示される' do
      expect(page).to have_content('RSpec学習完了')
      expect(page).to have_content('System Specを作成した')
      expect(page).to have_content(@user.nickname)
    end

    it '2件目のPostの詳細が表示される' do
      expect(page).to have_content('RSpec学習完了 2')
      expect(page).to have_content('System Specを作成した 2')
      expect(page).to have_content(@user.nickname)
    end

    it '投稿タイトルをクリックすると詳細ページへ遷移する' do
      click_link 'RSpec学習完了'
      expect(current_path).to eq("/posts/#{@post.id}")
    end
  end

  describe 'ログ削除機能の検証' do
    context '投稿したユーザーでログインしている場合' do
      before do
        sign_in @user
        visit "/posts/#{@post.id}"
      end

      it '削除ボタンを表示する' do
        expect(page).to have_button('削除')
      end

      it '削除ボタンをクリックすると削除できる' do
        expect do
          click_button '削除'
        end.to change(Post, :count).by(-1)

        expect(current_path).to eq('/posts')
        expect(page).to have_content('投稿が削除されました')
        expect(page).not_to have_content('RSpec学習完了')
      end
    end

    context '投稿したユーザーでログインしていない場合' do
      it '削除ボタンを表示しない' do
        visit "/posts/#{@post.id}"
        expect(page).not_to have_button('削除')
      end

      it '直接リクエストを投げても削除されない' do
        expect do
          delete post_path(@post)
        end.not_to change(Post, :count)
      end
    end
  end
end
