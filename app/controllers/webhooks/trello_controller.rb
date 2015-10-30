class Webhooks::TrelloController < ApplicationController
  protect_from_forgery with: :null_session

  # Trello sends HEAD request on webhook creation for checking the URL
  def callback_get
    render nothing: true
  end

  def callback
    chat = Chat.find_by(chat_id: params[:chat_id])

    body = JSON.parse(request.body.read())
    event_type = body['type']

    case event_type
      when 'createCard'
        card_created chat, body
      else
        Rails.logger.info 'Undefined trello webhook type'
    end

    render nothing: true
  end

  def card_created(chat, body)
    # TODO: add link
    msg = "#{body['memberCreator']['username']} created card '#{card_name body}' on '#{board_name body}'"

    ChatService.new.send_update chat, msg
  end

  private

  def card_name(body)
    body['data']['card']['name']
  end

  def board_name(body)
    body['data']['board']['name']
  end
end