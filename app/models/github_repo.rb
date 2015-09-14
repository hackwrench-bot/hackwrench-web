
class GithubRepo
  include Mongoid::Document

  embedded_in :chat

  field :name, type: String
  field :created_on_webhook, type: Boolean, default: false
  field :disabled, type: Boolean, default: false

  def full_name
    name
  end
end