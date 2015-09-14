class Webhooks::GithubController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    chat = Chat.find_by(chat_id: params[:chat_id])

    event_type = request.headers['X-GitHub-Event']
    guid = request.headers['X-GitHub-Delivery']
    body = JSON.parse(request.body.read())

    Rails.logger.info "github callback telegram_chat_id=#{chat.telegram_chat_id} event_type=#{event_type} guid=#{guid} body=#{body}"

    create_repo_if_needed chat, body

    case event_type
      when 'push'
        push_event chat, body
      when 'issues'
        issues_event chat, body
      when 'issue_comment'
        comment_issue chat, body
      when 'pull_request'
        pull_request chat, body
    end

    render nothing: true
  end

  protected

  def push_event(chat, body)
    if body['commits'].length > 1
      msg = '%s pushed %d commits %s'
    else
      msg = '%s pushed %d commit %s'
    end

    msg = msg % [body['pusher']['name'], body['commits'].length, body['compare']]
    msg = repo_msg(body, msg)

    ChatService.new.send_update chat, msg
  end

  def issues_event(chat, body)
    msg = repo_msg(body, "#{body['action']} issue by #{body['sender']['login']} #{body['issue']['html_url']}")
    ChatService.new.send_update chat, msg
  end

  def comment_issue(chat, body)
    # do not send it for now
  end

  def pull_request(chat, body)
    msg = repo_msg(body, "#{body['action']} pull request by #{body['sender']['login']} #{body['pull_request']['html_url']}")
    ChatService.new.send_update chat, msg
  end

  def repo_msg(body, msg)
    return "#{body['repository']['full_name']}: #{msg}"
  end

  # if webhook set up manually, we aren't aware of repo yet
  def create_repo_if_needed(chat, body)
    repo = body['repository']

    if repo.nil?
      return
    end

    github_repo = chat.find_github_repo repo['full_name']

    if github_repo.nil?
      github_repo = GithubRepo.new(name: repo['full_name'], created_on_webhook: true)
      chat.append_github_repo github_repo
    end
  end
end