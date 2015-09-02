class Webhooks::GithubController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    event_type = request.headers['X-GitHub-Event']
    guid = request.headers['X-GitHub-Delivery']
    body = JSON.parse(request.body.read())

    Rails.logger.info "github callback event_type=#{event_type} guid=#{guid} body=#{body}"



    render nothing: true
  end
end