class GithubService
  attr_accessor :github_client

  def initialize(github_token)
    @github_client = Octokit::Client.new(access_token: github_token)
  end

  def callback_url(chat)
    Rails.application.routes.url_helpers.webhooks_github_url(chat_id: chat.chat_id,
                                                             host: Rails.configuration.web_app_hostname)
  end

  def create_hook(repo_full_name, chat)
    @github_client.create_hook(
        repo_full_name,
        'web',
        {
            :url => callback_url(chat),
            :content_type => 'json'
        },
        {
            :events => ['push', 'pull_request', 'issues', 'issue_comment'],
            :active => true
        }
    )

    # TODO not transactional
    chat.append_github_repo repo_full_name
    chat.save!
  end

  def delete_hook(repo_full_name, chat)
    github_hooks = @github_client.hooks repo_full_name

    github_hook_url = callback_url(chat)
    github_hook = github_hooks.select {|h|
      h.config.url.present? and h.config.url == github_hook_url
    }
    github_hook = github_hook[0]

    @github_client.remove_hook(repo_full_name, github_hook.id)

    # TODO this should rollback hook deletion if fails
    chat.github_repos.delete repo_full_name
    chat.save!
  end
end