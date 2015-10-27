require 'rails_helper'

describe 'chat configure link' do
  before :each do
    cleanup_db

    @user = User.create!(email: 'test_user@hackwrench.us', password: '_' * 8)
    login_as(@user, scope: :user)
  end

  it 'grants access to the user who opened the link' do
    c = Chat.create!(title: 'Test Chat')

    config_url = ChatService.configure_url(c)
    path = URI.parse(config_url).path

    visit path

    expect(current_path).to eq('/client')

    c.reload
    expect(c.users.length).to eq(1)
    expect(c.users.first.id).to eq(@user.id)
  end
end