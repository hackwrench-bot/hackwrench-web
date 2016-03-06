
class Webhooks::GitlabController < ApplicationController
  protect_from_forgery with: :null_session

  GITLAB_COMPARE_URL = '%{homepage}/compare/%{before}...%{after}'

  def callback
    chat = Chat.find_by(chat_id: params[:chat_id])

    body = JSON.parse(request.body.read())
    event_type = body['object_kind']

    case event_type
      when 'push'
        push_event chat, body
      when 'issue'
        issue_event chat, body
      when 'merge_request'
        merge_request chat, body
    end

    render nothing: true
  end

  protected

  def push_event(chat, body)
    create_repo_if_needed chat, body['repository']['name'], body['repository']['url']

    if body['total_commits_count'] > 1
      msg = '%s pushed %d commits %s'
    else
      msg = '%s pushed %d commit %s'
    end

    url = GITLAB_COMPARE_URL % {homepage: body['repository']['homepage'], before: body['before'], after: body['after']}

    msg = msg % [body['user_name'], body['total_commits_count'], url]
    msg = repo_msg body, msg
    ChatService.new.send_update chat, msg
  end

  def issue_event(chat, body)
    create_repo_if_needed chat, body['repository']['name'], body['repository']['url']

    msg = repo_msg(body, "issue \"#{body['object_attributes']['title']}\" #{body['object_attributes']['action']}ed by #{body['user']['name']} #{body['object_attributes']['url']}")
    ChatService.new.send_update chat, msg
  end

  def merge_request(chat, body)
    create_repo_if_needed chat, body['object_attributes']['target']['name'], body['object_attributes']['url']

    msg = "#{body['object_attributes']['target']['name']}: merge request #{body['object_attributes']['action']}ed by #{body['user']['name']} #{body['object_attributes']['url']}"
    ChatService.new.send_update chat, msg
  end

  def repo_msg(body, msg)
    return "#{body['repository']['name']}: #{msg}"
  end

  def create_repo_if_needed(chat, name, url)
    if name.nil?
      return
    end

    chat.create_gitlab_repo name, url
  end
end