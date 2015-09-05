# Overrides login page so the user is sent to GitHub straight away
class SessionsController < Devise::SessionsController
  def new
    # send them straight to GitHub
    redirect_to omniauth_authorize_path(:user, 'github')
  end
end