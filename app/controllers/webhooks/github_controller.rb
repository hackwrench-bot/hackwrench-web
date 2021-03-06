class Webhooks::GithubController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    chat = Chat.find_by(chat_id: params[:chat_id])

    event_type = request.headers['X-GitHub-Event']
    guid = request.headers['X-GitHub-Delivery']
    body = request.body.read()
    body = body.blank? ? {} : JSON.parse(body)

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

    chat.increment_github_events

    render nothing: true
  end

  protected

  def push_event(chat, body)
    if body['commits'].length > 1
      msg = '%s pushed %d commits to %s %s'
    else
      msg = '%s pushed %d commit to %s %s'
    end

    branch = body['ref'].split('/').last

    msg = msg % [body['pusher']['name'], body['commits'].length, branch, body['compare']]
    body['commits'].each do |commit|
      title = commit['message'].split("\n",2).first
      msg += "\n%s - %s" % [commit['id'][0..5], title]
    end
    msg = repo_msg(body, msg)

    ChatService.new.send_update(chat, msg)
  end

  def issues_event(chat, body)
    msg = repo_msg(body, "issue \"#{body['issue']['title']}\" #{body['action']} by #{body['sender']['login']} #{body['issue']['html_url']}")
    ChatService.new.send_update chat, msg
  end

  def comment_issue(chat, body)
    # do not send it for now
  end

  def pull_request(chat, body)
    msg = repo_msg(body, "pull request #{body['action']} by #{body['sender']['login']} #{body['pull_request']['html_url']}")
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

    repo_name = repo['full_name']

    if chat.find_github_repo(repo_name).nil?
      chat.create_github_repo(repo_name, created_on_webhook: true)
      # GitHub sends ping event to webhook on creation, let's notify the chat about newly
      # added repository
      GithubService.webhook_enabled(chat, repo_name)
    end
  end
end