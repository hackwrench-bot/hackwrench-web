
class GitlabRepo
  include Mongoid::Document

  embedded_in :chat

  field :name, type: String
  field :url, type: String
  field :disabled, type: Boolean, default: false
end