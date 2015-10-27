class Client::ChatsController < ClientController
  def configure
    chat_id = params[:chat_id]
    chat = Chat.find_by(chat_id: chat_id)

    chat.grant_access(current_user)

    redirect_to(action: 'index')
  end

  def index
    @chats = Chat.where(user_ids: current_user.id)
  end

end