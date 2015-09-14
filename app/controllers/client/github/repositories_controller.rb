class Client::Github::RepositoriesController < ClientController
  before_action :load_chat

  def index
    @user_repos = @github_service.user_repos
    @org_repos = @github_service.org_repos

    repo_names = @org_repos.map {|x| x.full_name }
    repo_names += @user_repos.map {|x| x.full_name }

    # add ones we know about but which wasn't returned by Github
    @org_repos += @chat.github_repos.select {|gr|
      not (repo_names.include? gr.name)
    }
  end

  def show
    @id = params[:id]
    @github_repo = @chat.find_github_repo @id
  end

  def update
    @id = params[:id]
    enabled = @chat.github_repo_enabled? @id

    if not enabled and params[:enabled]
      if @github_service.create_hook @id, @chat
        flash[:success] = 'Web hook created!'
      else
        flash[:error] = 'You need to grant access to Hackwrench Bot on this repo or organization on GitHub.'
      end

    elsif enabled and not params[:enabled]
      @github_service.delete_hook @id, @chat

      flash[:success] = 'Web hook removed.'
    end

    redirect_to action: 'show'
  end

  protected

  def load_chat
    @chat = Chat.find_by(chat_id: params[:chat_id])
  end
end