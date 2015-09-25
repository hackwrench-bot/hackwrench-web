require 'telegram/bot'

class ChatService
  def initialize
    @telegram_api = Telegram::Bot::Api.new(Rails.application.secrets[:telegram_bot_token])
  end

  def bot_id
    @telegram_api.getMe()['result']['id']
  end

  def bot_name
    Rails.configuration.bot_name
  end

  def create_chat(telegram_msg)
    telegram_user_id = telegram_msg.from.id
    telegram_chat = telegram_msg.chat
    telegram_chat_id = telegram_chat.id
    chat_title = telegram_chat.try(:title) || telegram_chat.try(:username) || telegram_chat.try(:first_name)

    chat = Chat.find_or_initialize_by(telegram_chat_id: telegram_chat_id)
    # update it always so title changes get synced
    chat.title = chat_title

    if chat.new_record?
      chat.telegram_user_id = telegram_user_id
      chat.private = (telegram_chat.try(:username) || telegram_chat.try(:first_name)) ? true : false
    end

    chat.save!

    chat
  end

  def configure_url(chat)
    Rails.application.routes.url_helpers.client_chats_configure_url(chat_id: chat.chat_id,
                                                                    host: Rails.configuration.web_app_hostname)
  end

  def send_update(chat, msg)
    @telegram_api.sendMessage(chat_id: chat.telegram_chat_id, text: msg)

    chat.increment_msgs_sent
  end
end