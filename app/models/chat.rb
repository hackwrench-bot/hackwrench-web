require 'digest'

class Chat
  include Mongoid::Document

  before_create :generate_chat_id

  has_and_belongs_to_many :users
  embeds_many :github_repos

  field :chat_id, type: String
  # user or group chat id
  field :telegram_chat_id, type: Integer
  # the user who invited the bot
  field :telegram_user_id, type: Integer
  field :title, type: String
  field :private, type: Boolean

  index({ chat_id: 1 }, { unique: true })
  index({ telegram_chat_id: 1 }, { unique: true })

  def find_github_repo(name)
    github_repos.detect {|r| r.name == name}
  end

  def append_github_repo(github_repo)
    repo = find_github_repo github_repo.name

    if repo
      raise "#{github_repo.name} github repo already added"
    end

    github_repos.push github_repo
    save!
  end

  def github_repo_enabled?(github_repo_name)
    repo = find_github_repo github_repo_name

    return repo && (not repo.disabled)
  end

  protected

  def generate_chat_id
    if self.chat_id.nil?
      self.chat_id = Digest::MD5.hexdigest([Time.now, telegram_chat_id, rand].join)
    end
  end
end