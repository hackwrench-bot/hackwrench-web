class Client::Github::RepositoriesController < ClientController
  before_action :load_chat

  def index
    @repos = @github_service.github_client.repositories
  end

  def show
    @id = params[:id]
  end

  def update
    @id = params[:id]
    enabled = @chat.github_repo_enabled? @id

    if not enabled and params[:enabled]
      @github_service.create_hook @id, @chat

      flash[:success] = 'Web hook created!'
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