require 'rails_helper'

describe 'github webhook howto page' do
  before :each do
    cleanup_db

    @user = User.create!(email: 'test_user@hackwrench.us', password: '_' * 8)
    login_as(@user, scope: :user)
  end

  it 'shows page for chat' do
    c = Chat.create!(title: 'Test Chat')

    visit client_chat_github_setup_webhook_howto_path(c.chat_id)

    expect(page).to have_content(webhooks_github_path(c.chat_id))
  end
end