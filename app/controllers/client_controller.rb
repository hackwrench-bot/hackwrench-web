class ClientController < ApplicationController
  before_filter :authenticate_user!
end