require 'digest'

class Chat
  include Mongoid::Document

  before_create :generate_chat_id

  has_and_belongs_to_many :users
  embeds_one :chat_stat
  embeds_many :github_repos
  embeds_many :gitlab_repos

  field :chat_id, type: String
  # user or group chat id
  field :telegram_chat_id, type: Integer
  # the user who invited the bot
  field :telegram_user_id, type: Integer
  field :title, type: String
  field :private, type: Boolean

  index({ chat_id: 1 }, { unique: true })
  index({ telegram_chat_id: 1 }, { unique: true })

  # github

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

  # gitlab

  def find_gitlab_repo(name)
    gitlab_repos.detect {|r| r.name == name}
  end

  def append_gitlab_repo(gitlab_repo)
    repo = find_gitlab_repo gitlab_repo.name

    if repo
      raise "#{gitlab_repo.name} github repo already added"
    end

    gitlab_repos.push gitlab_repo
    save!
  end

  def gitlab_repo_enabled?(gitlab_repo_name)
    repo = find_gitlab_repo gitlab_repo_name

    return repo && (not repo.disabled)
  end

  # stats

  def increment_github_events(events_count=1)
    get_chat_stat.inc(github_events: events_count)
  end

  def increment_gitlab_events(events_count=1)
    get_chat_stat.inc(gitlab_events: events_count)
  end

  def increment_msgs_sent(messages_count=1)
    get_chat_stat.inc(msgs_sent: messages_count)
  end

  protected

  def get_chat_stat
    self.chat_stat = ChatStat.new if self.chat_stat.nil?
    self.chat_stat
  end

  def generate_chat_id
    if self.chat_id.nil?
      self.chat_id = Digest::MD5.hexdigest([Time.now, telegram_chat_id, rand].join)
    end
  end
end