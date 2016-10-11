require 'rails_helper'

describe Webhooks::TrelloController do
  before :each do
    cleanup_db
  end

  subject { post :callback, body, chat_id: chat_id }

  let! (:chat) { Chat.create! chat_id: chat_id }

  before {
    expect_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)
  }

  describe 'card creation' do
    let (:chat_id) { 'trello_controller_aj22mr' }
    let (:body) { read_local_file 'controllers/webhooks/trello_controller_createCard.json' }
    let (:expected_msg) { 'fiatjaf created card \'hello.\' on \'This is a Site\' https://trello.com/c/0N7Yrpro' }

    it { is_expected.to be_success }
  end

  describe 'card move to a list' do
    let (:chat_id) { 'trello_controller_hoh23ab7' }
    let (:body) { read_local_file 'controllers/webhooks/trello_controller_card_moved_to_list.json' }
    let (:expected_msg) { 'hendzitsaryk moved \'Testing card\' to \'In Progress\' on \'Hackwrench Development\' https://trello.com/c/3R8o1PJF' }

    it { is_expected.to be_success }
  end

  describe 'comment' do
    let (:chat_id) { 'trello_controller_pqka2a39' }
    let (:body) { read_local_file 'controllers/webhooks/trello_controller_card_comment.json' }
    let (:expected_msg) { 'hendzitsaryk commented on \'Testing card 2\' (\'Hackwrench Development\'): \'new comment\' https://trello.com/c/bEUse9KD' }

    it { is_expected.to be_success }
  end

  describe 'email card' do
    let (:chat_id) { 'trello_controller_s2jdhg8' }
    let (:body) { read_local_file 'controllers/webhooks/trello_controller_emailCard.json' }
    let (:expected_msg) { 'hendzitsaryk created card \'New Email Card 2\' on \'Hackwrench Development\' https://trello.com/c/zj2iu3DB' }

    it { is_expected.to be_success }
  end
end