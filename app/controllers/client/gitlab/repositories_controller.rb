class Client::Gitlab::RepositoriesController < ClientController
  before_action :load_chat

  def index
    @repos = @chat.gitlab_repos
    @callback_url = GitlabService.callback_url @chat
  end
end