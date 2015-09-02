require 'digest'

class Chat
  include Mongoid::Document

  before_create :generate_chat_id

  has_and_belongs_to_many :users

  field :chat_id, type: String
  # user or group chat id
  field :telegram_chat_id, type: Integer
  # the user who invited the bot
  field :telegram_user_id, type: Integer
  field :title, type: String

  field :github_repos, type: Array

  index({ chat_id: 1 }, { unique: true })
  index({ telegram_chat_id: 1 }, { unique: true })

  protected

  def generate_chat_id
    self.chat_id = Digest::MD5.hexdigest([Time.now, telegram_chat_id, rand].join)
  end
end