class Webhooks::TrelloController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    render nothing: true
  end
end