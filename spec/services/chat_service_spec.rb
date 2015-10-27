require 'rails_helper'
require 'telegram/bot'

describe ChatService do
  after :each do
    cleanup_db
  end

  describe 'create_chat' do
    it 'creates a Chat from group_chat_created msg' do
      msg = {
          'date' => 1440808288,
          'group_chat_created' => true,
          'from' => {'first_name' => 'Henadzi', 'id' => 107399311},
          'message_id' => 6,
          'chat' => {'id' => -19463090, 'title' => 'Testing engineerrobot'}
      }
      msg = Telegram::Bot::Types::Message.new(msg)

      chat = ChatService.new.create_chat msg
      expect(chat.chat_id).not_to be_nil
      expect(chat.telegram_chat_id).to eq(msg['chat']['id'])
      expect(chat.title).to eq(msg['chat']['title'])
    end
  end

  describe 'configure_url' do
    it 'returns correct configure URL' do
      chat = Chat.new(chat_id: 'abc', telegram_chat_id: 2, title: 'title')

      configure_url = ChatService.configure_url chat

      expect(configure_url).to eq("http://#{Rails.configuration.web_app_hostname}/client/chats/configure/abc")
    end
  end
end