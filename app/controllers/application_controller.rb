class ApplicationController < ActionController::Base
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :rescue_mongoid_not_found
  layout :get_layout

  protected

  def get_layout
    if devise_controller?
      'home'
    end
  end

  def rescue_mongoid_not_found
    raise ActionController::RoutingError.new('Mongoind: not Found')
  end
end
