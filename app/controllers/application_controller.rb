class ApplicationController < ActionController::Base
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :rescue_mongoid_not_found

  def rescue_mongoid_not_found
    raise ActionController::RoutingError.new('Mongoind: not Found')
  end
end
