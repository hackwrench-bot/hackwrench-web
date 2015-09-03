class Webhooks::GithubController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    chat = Chat.find_by(chat_id: params[:chat_id])

    event_type = request.headers['X-GitHub-Event']
    guid = request.headers['X-GitHub-Delivery']
    body = JSON.parse(request.body.read())

    Rails.logger.info "github callback telegram_chat_id=#{chat.telegram_chat_id} event_type=#{event_type} guid=#{guid} body=#{body}"

    case event_type
      when 'push'
        push_event chat, body
      when 'issues'
        issues_event chat, body
    end

    render nothing: true
  end

  protected

  def push_event(chat, body)

  end

  def issues_event(chat, body)
    msg = "#{body['repository']['full_name']}: #{body['action']} issue by #{body['issue']['user']['login']} #{body['issue']['html_url']}"

    ChatService.new.send_update chat, msg
  end
end