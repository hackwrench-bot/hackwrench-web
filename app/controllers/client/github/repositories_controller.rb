class Client::Github::RepositoriesController < ClientController

  def index
    @repos = @github.repositories
  end

  def show
    @id = params[:id]
    @our_hook = get_hook @id
    @enabled = (not @our_hook.nil?)
  end

  def update
    @id = params[:id]
    hook = get_hook @id

    if hook.nil? and params[:enabled]
      @github.create_hook(
          @id,
          'web',
          {
              :url => "http://#{Rails.configuration.github_webhook_hostname}/webhook",
              :content_type => 'json'
          },
          {
              :events => ['push', 'pull_request', 'issues', 'issue_comment'],
              :active => true
          }
      )

      flash[:success] = 'Created web hook!'
    elsif hook and not params[:enabled]
      @github.remove_hook(@id, hook.id)
      flash[:success] = 'Removed web hook!'
    end

    redirect_to action: 'show'
  end

  protected

  # def repository_params
  #   params.require(:repository).permit(:full_name, :enabled)
  # end

  def get_hook(full_name)
    hooks = @github.hooks full_name

    our_hook = hooks.select {|h|
      (not h.config.url.nil?) and h.config.url.include?(Rails.configuration.github_webhook_hostname)
    }
    our_hook[0]
  end
end