require 'rails_helper'

describe Client::TrelloController do
  before :each do
    cleanup_db

    sign_in User.create!(email: 'test@hackwrench.com', password: '_' * 8)
  end

  describe 'webhook_enabled' do
    it 'sends notifications to chat' do
      chat_id = 'github_controller_b23d9ha'
      Chat.create! chat_id: chat_id

      msg = I18n.t('hackwrench.messaging.trello.notifications_enabled', board_name: 'test')
      expect_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), msg)

      post :webhook_enabled, chat_id: chat_id, board_name: 'test'

      expect(response.status).to eq(200)
    end
  end

  describe 'webhook_disabled' do
    it 'sends notifications to chat' do
      chat_id = 'github_controller_o4nain4d'
      Chat.create! chat_id: chat_id

      msg = I18n.t('hackwrench.messaging.trello.notifications_disabled', board_name: 'test')
      expect_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), msg)

      post :webhook_disabled, chat_id: chat_id, board_name: 'test'

      expect(response.status).to eq(200)
    end
  end
end