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

  def append_github_repo(github_repo_full_name)
    if github_repos.nil?
      self.github_repos = []
    end

    if not github_repos.include? github_repo_full_name
      github_repos.push github_repo_full_name
    end
  end

  def remove_github_repo(github_repo_full_name)
    if github_repos.nil?
      return
    end

    github_repos.delete github_repo_full_name
  end

  def github_repo_enabled?(github_repo_full_name)
    return false if github_repos.nil?

    return github_repos.include? github_repo_full_name
  end

  protected

  def generate_chat_id
    self.chat_id = Digest::MD5.hexdigest([Time.now, telegram_chat_id, rand].join)
  end
end