require 'rails_helper'

describe 'User', type: :system do
  before { driven_by :rack_test }

  let(:email) { 'test@example.com' }
  let(:nickname) { 'テスト太郎' }
  let(:password) { 'password' }
  let(:password_confirmation) { password }

  describe 'ユーザー登録機能の検証' do
    before { visit '/users/sign_up' }

    subject do
      fill_in 'user_nickname', with: nickname
      fill_in 'user_email', with: email
      fill_in 'user_password', with: password
      fill_in 'user_password_confirmation', with: password_confirmation
      click_button 'ユーザー登録'
    end

    context '正常系' do
      it 'ユーザーを作成する' do
        expect { subject }.to change(User, :count).by(1)
        expect(current_path).to eq('/')
      end
    end

    context '異常系' do
      context 'nicknameが空の場合' do
        let(:nickname) { '' }
        it 'ユーザーを作成せず, エラーメッセージを表示する' do
          expect { subject }.not_to change(User, :count)
          expect(page).to have_content('ニックネーム が入力されていません。')
        end
      end

      context 'nicknameが20文字を超える場合' do
        let(:nickname) { 'あ' * 21 }
        it 'ユーザーを作成せず, エラーメッセージを表示する' do
          expect { subject }.not_to change(User, :count)
          expect(page).to have_content('ニックネーム は20文字以下に設定して下さい。')
        end
      end

      context 'emailが空の場合' do
        let(:email) { '' }
        it 'ユーザーを作成せず, エラーメッセージを表示する' do
          expect { subject }.not_to change(User, :count)
          expect(page).to have_content('メールアドレス が入力されていません。')
        end
      end

      context 'passwordが空の場合' do
        let(:password) { '' }
        it 'ユーザーを作成せず, エラーメッセージを表示する' do
          expect { subject }.not_to change(User, :count)
          expect(page).to have_content('パスワード が入力されていません。')
        end
      end

      context 'passwordが6文字未満の場合' do
        let(:password) { 'a' * 5 }
        it 'ユーザーを作成せず, エラーメッセージを表示する' do
          expect { subject }.not_to change(User, :count)
          expect(page).to have_content('パスワード は6文字以上に設定して下さい。')
        end
      end

      context 'passwordが128文字を超える場合' do
        let(:password) { 'a' * 129 }
        it 'ユーザーを作成せず, エラーメッセージを表示する' do
          expect { subject }.not_to change(User, :count)
          expect(page).to have_content('パスワード は128文字以下に設定して下さい。')
        end
      end

      context 'passwordとpassword_confirmationが一致しない場合' do
        let(:password_confirmation) { "#{password}hoge" }
        it 'ユーザーを作成せず, エラーメッセージを表示する' do
          expect { subject }.not_to change(User, :count)
          expect(page).to have_content('確認用パスワード が一致していません。')
        end
      end
    end
  end

  describe 'ログイン機能の検証' do
    before do
      create(:user, nickname: nickname, email: email, password: password, password_confirmation: password)

      visit '/users/sign_in'
      fill_in 'user_email', with: email
      fill_in 'user_password', with: 'password'
      click_button 'ログイン'
    end

    context '正常系' do
      it 'ログインに成功し、トップページにリダイレクトする' do
        expect(current_path).to eq('/')
      end

      it 'ログイン成功時のフラッシュメッセージを表示する' do
        expect(page).to have_content('ログインしました')
      end
    end

    context '異常系' do
      let(:password) { 'NGpassword' }
      it 'ログインに失敗し、ページ遷移しない' do
        expect(current_path).to eq('/users/sign_in')
      end

      it 'ログイン失敗時のフラッシュメッセージを表示する' do
        expect(page).to have_content('メールアドレスまたはパスワードが違います。')
      end
    end

    describe 'ログアウト機能の検証' do
      before do
        click_button 'ログアウト'
      end

      it 'トップページにリダイレクトする' do
        expect(current_path).to eq('/')
      end

      it 'ログアウト時のフラッシュメッセージを表示する' do
        expect(page).to have_content('ログアウトしました。')
      end
    end
  end

  describe 'ユーザーページの検証' do
    before do
      @user = create(:user)
      @post = create(:post, title: "テスト投稿", content: "ユーザーページ表示テスト", user: @user)

      visit "/users/#{@user.id}"
    end

    it 'ユーザー情報が表示される' do
      expect(page).to have_content(@user.nickname)
      expect(page).to have_content("投稿数: 1件")
    end

    it '投稿一覧が表示される' do
      expect(page).to have_content('テスト投稿')
      expect(page).to have_content('ユーザーページ表示テスト')
    end

    it '投稿の詳細ページへのリンクが機能する' do
      click_link 'テスト投稿'
      expect(current_path).to eq("/posts/#{@post.id}")
    end
  end
end
