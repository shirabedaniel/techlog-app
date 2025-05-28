require 'rails_helper'

RSpec.describe 'Homes', type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'トップページの検証' do
    it 'TechLogという文字例を表示される' do
      visit '/'

      expect(page).to have_content('TechLog')
    end
  end

  describe 'ナビゲーションバーの検証' do
    context 'ログインしてない場合' do
      before { visit '/' }

      it 'ユーザー登録リンクを表示する' do
        expect(page).to have_link('ユーザー登録', href: '/users/sign_up')
      end

      it 'ログインリンクを表示する' do
        expect(page).to have_link('ログイン', href: '/users/sign_in')
      end

      it 'ログ投稿リンクを表示しない' do
        expect(page).not_to have_link('ログ投稿', href: '/posts/new')
      end

      it 'ログアウトリンクは表示しない' do
        expect(page).not_to have_content('ログアウト')
      end
    end

    context 'ログインしている場合' do
      before do
        user = create(:user)
        sign_in user
        visit '/'
      end

      it 'ユーザー登録リンクは表示しない' do
        expect(page).not_to have_link('ユーザー登録', href: '/users/sign_up')
      end

      it 'ログインリンクは表示しない' do
        expect(page).not_to have_link('ログイン', href: '/users/sign_in')
      end

      it 'ログ投稿リンクを表示する' do
        expect(page).to have_link('ログ投稿', href: '/posts/new')
      end

      it 'ログアウトリンクを表示する' do
        expect(page).to have_content('ログアウト')
      end

      it 'ログアウトリンクが機能する' do
        click_button 'ログアウト'

        expect(page).to have_link('ユーザー登録', href: '/users/sign_up')
        expect(page).to have_link('ログイン', href: '/users/sign_in')
        expect(page).not_to have_button('ログアウト')
      end
    end
  end
end
