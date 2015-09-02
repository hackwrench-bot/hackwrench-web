class ChatService
  def create_chat(telegram_msg)
    telegram_user_id = telegram_msg['from']['id']
    chat = telegram_msg['chat']
    telegram_chat_id = chat['id']
    chat_title = chat['title'] || chat['username'] || chat['first_name']
    chat = Chat.create!(title: chat_title, telegram_user_id: telegram_user_id, telegram_chat_id: telegram_chat_id)

    chat
  end

  def configure_url(chat)
    Rails.application.routes.url_helpers.client_chats_configure_url(chat_id: chat.chat_id,
                                                                    host: Rails.configuration.web_app_hostname)
  end
end