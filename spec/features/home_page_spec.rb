require 'rails_helper'

describe 'home page' do
  it 'renders landing page' do
    visit '/'

    expect(page).to have_title(I18n.t('hackwrench.home_page.title'))

    expect(page).to have_content(I18n.t('hackwrench.home_page.product_name'))
    expect(page).to have_content(I18n.t('hackwrench.home_page.heading'))

    expect(page).to have_content(Rails.configuration.bot_name)
  end
end