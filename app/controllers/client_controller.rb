class ClientController < ApplicationController
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :setup_github_client

  protected

  def after_sign_in_path_for(resource)
    session['user_return_to'] || client_path
  end

  # def after_sign_in_path_for(resource)
  #   blacklist = [new_user_session_path, new_user_registration_path]
  #   last_url = session['user_return_to']
  #   if blacklist.include?(last_url)
  #     client_path
  #   else
  #     last_url
  #   end
  # end

  def setup_github_client
    @github_service = GithubService.new(current_user.github_token)
  end

end