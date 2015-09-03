class ClientController < ApplicationController
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :setup_github_client

  protected
  def setup_github_client
    @github_service = GithubService.new(current_user.github_token)
  end
end