class GithubService
  attr_accessor :github_client

  def initialize(github_token)
    @github_client = Octokit::Client.new(access_token: github_token)
  end

  def user_repos
    @github_client.repositories nil, {type: 'owner'}
  end

  def org_repos
    @github_client.repositories nil, {affiliation: 'organization_member'}

    # orgs = @github_client.organizations
    #
    # repos = []
    # orgs.each do |org|
    #   repos.concat @github_client.org_repositories(org.login)
    # end
    #
    # repos
  end

  def callback_url(chat)
    Rails.application.routes.url_helpers.webhooks_github_url(chat_id: chat.chat_id,
                                                             host: Rails.configuration.web_app_hostname)
  end

  def create_hook(repo_full_name, chat)
    github_repo = chat.find_github_repo repo_full_name

    if github_repo and github_repo.created_on_webhook
      raise 'Action is not allowed'
    end

    begin
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

      if github_repo
        github_repo.disabled = false
        chat.save!
      else
        github_repo = GithubRepo.new name: repo_full_name
        chat.append_github_repo github_repo
      end


      true
    rescue Octokit::NotFound
      false
    end
  end

  def delete_hook(repo_full_name, chat)
    github_repo = chat.find_github_repo repo_full_name

    if github_repo and github_repo.created_on_webhook
      raise 'Action is not allowed'
    end

    begin
      github_hooks = @github_client.hooks repo_full_name

      github_hook_url = callback_url(chat)
      github_hook = github_hooks.select {|h|
        h.config.url.present? and h.config.url == github_hook_url
      }
      github_hook = github_hook[0]

      if github_hook
        @github_client.remove_hook(repo_full_name, github_hook.id)
      end
    rescue Octokit::NotFound
      Rails.logger.warn "Got 404 on hook deletion chat_id=#{chat.chat_id} repo_name=#{repo_full_name}"
    end

    # TODO this should rollback hook deletion if fails
    github_repo.disabled = true
    chat.save!
  end
end