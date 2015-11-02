require 'rails_helper'

describe Webhooks::TrelloController do
  before :each do
    cleanup_db
  end

  describe 'webhook' do
    it 'handles card creation' do
      body = read_local_file 'controllers/trello_controller_createCard.json'

      chat_id = 'trello_controller_aj22mr'
      Chat.create! chat_id: chat_id

      expected_msg = 'fiatjaf created card \'hello.\' on \'This is a Site\''
      expect_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id
      expect(response.status).to eq(200)
    end

    it 'handles card move to list' do
      body = read_local_file 'controllers/trello_controller_card_moved_to_list.json'

      chat_id = 'trello_controller_hoh23ab7'
      Chat.create! chat_id: chat_id

      expected_msg = 'hendzitsaryk moved \'Testing card\' to \'In Progress\' on \'Hackwrench Development\''
      expect_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id
      expect(response.status).to eq(200)
    end

    it 'handles comment on card' do
      body = read_local_file 'controllers/trello_controller_card_comment.json'

      chat_id = 'trello_controller_pqka2a39'
      Chat.create! chat_id: chat_id

      expected_msg = 'hendzitsaryk commented on \'Testing card 2\' (\'Hackwrench Development\'): \'new comment\''
      expect_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id
      expect(response.status).to eq(200)
    end
  end
end