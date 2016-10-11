class Webhooks::TrelloController < ApplicationController
  protect_from_forgery with: :null_session

  # Trello sends HEAD request on webhook creation for checking the URL
  def callback_get
    render nothing: true
  end

  def callback
    chat = Chat.find_by(chat_id: params[:chat_id])

    body = JSON.parse(request.body.read())
    action = body['action']
    event_type = action['type']

    begin
      case event_type
        when 'createCard', 'emailCard'
          card_created chat, body
        when 'updateCard'
          if action['data'].has_key?('listBefore') && action['data'].has_key?('listAfter')
            card_moved_to_list chat, body
          else
            raise UndefinedEvent
          end
        when 'commentCard'
          card_comment chat, body
        else
          raise UndefinedEvent
      end
    rescue UndefinedEvent
      Rails.logger.info "Undefined trello webhook type #{event_type}, body: #{body.to_s}"
    end

    render nothing: true
  end

  private

  def card_created(chat, body)
    msg = "#{body['action']['memberCreator']['username']} created card '#{card_name body}' on '#{board_name body}' #{card_link body}"

    ChatService.new.send_update chat, msg
  end

  def card_moved_to_list(chat, body)
    action = body['action']
    msg = "#{username body} moved '#{card_name body}' to '#{action['data']['listAfter']['name']}' on '#{board_name body}' #{card_link body}"

    ChatService.new.send_update chat, msg
  end

  def card_comment(chat, body)
    msg = "#{username body} commented on '#{card_name body}' ('#{board_name body}'): '#{body['action']['data']['text']}' #{card_link body}"

    ChatService.new.send_update chat, msg
  end

  def card_name(body)
    body['action']['data']['card']['name']
  end

  def card_link(body)
    TrelloService.card_url body['action']['data']['card']['shortLink']
  end

  def board_name(body)
    body['action']['data']['board']['name']
  end

  def username(body)
    body['action']['memberCreator']['username']
  end

  class UndefinedEvent < Exception
  end
end