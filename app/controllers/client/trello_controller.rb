class Client::TrelloController < ClientController
  before_action :load_chat

  def index
  end

  def webhook_enabled
    board_name = params[:board_name]

    ChatService.new.send_update @chat, t('hackwrench.messaging.trello.notifications_enabled', board_name: board_name)

    render nothing: true
  end

  def webhook_disabled
    board_name = params[:board_name]

    ChatService.new.send_update @chat, t('hackwrench.messaging.trello.notifications_disabled', board_name: board_name)

    render nothing: true
  end
end