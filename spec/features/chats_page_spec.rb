require 'rails_helper'

describe 'chats page' do
  before :each do
    cleanup_db

    @user = User.create!(email: 'test_user@hackwrench.us', password: '_' * 8)
    login_as(@user, scope: :user)
  end

  it 'render the page when there are no chats' do
    visit '/'

    # root should authenticated redirect users to /client namespace
    expect(current_path).to eq('/client')

    # in the text about adding chats
    expect(page).to have_content(Rails.configuration.bot_name)

    expect(page).to have_content(I18n.t('hackwrench.chats_page.no_chats'))
  end

  it 'shows one chat with no repos enabled' do
    c = Chat.create!(title: 'Test Chat')
    c.grant_access @user

    visit '/client'

    expect(page).to have_content(c.title)
    expect(page).to have_content(I18n.t('hackwrench.chats_page.github_repos_count_tag', count: 0))
    expect(page).to have_content(I18n.t('hackwrench.chats_page.gitlab_repos_count_tag', count: 0))
    expect(page).not_to have_content(I18n.t('hackwrench.chats_page.private_tag'))
  end

  it 'shows one chat with 1 gitlab and 1 github repo' do
    c = Chat.create!(title: 'Test Chat')
    c.grant_access @user

    c.create_github_repo 'github/repo'
    c.create_gitlab_repo 'gitlab/repo', 'http://gitlab.hackwrench.us/gitlab/repo'

    visit '/client'

    expect(page).to have_content(c.title)
    expect(page).to have_content(I18n.t('hackwrench.chats_page.github_repos_count_tag', count: 1))
    expect(page).to have_content(I18n.t('hackwrench.chats_page.gitlab_repos_count_tag', count: 1))
    expect(page).not_to have_content(I18n.t('hackwrench.chats_page.private_tag'))
  end

  it 'shows private chat' do
    c = Chat.create!(title: 'Test Chat', private: true)
    c.grant_access @user

    visit '/client'

    expect(page).to have_content(c.title)
    expect(page).to have_content(I18n.t('hackwrench.chats_page.github_repos_count_tag', count: 0))
    expect(page).to have_content(I18n.t('hackwrench.chats_page.gitlab_repos_count_tag', count: 0))
    expect(page).to have_content(I18n.t('hackwrench.chats_page.private_tag'))
  end
end