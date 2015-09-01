class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    @user = User.from_omniauth(request.env['omniauth.auth'])
    @user.save

    sign_in @user, :event => :authentication # this will throw if @user is not activated
    flash[:success] = 'Thanks for joining us!!'

    redirect_to client_path
  end

  alias_method :github, :all
end