class Client::ChatsController < ClientController
  def configure
    chat_id = params[:chat_id]
    chat = Chat.find_by(chat_id: chat_id)

    chat.users.push(current_user)
    chat.save

    redirect_to(action: 'index')
  end

  def index
    @chats = Chat.where(user_ids: current_user.id)
  end

  def setup_webhook_howto
    @chat = Chat.find_by chat_id: params[:chat_id]
    @callback_url = GithubService.new(current_user.github_token).callback_url @chat
  end
end