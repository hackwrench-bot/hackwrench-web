class ChatStat
  include Mongoid::Document

  embedded_in :chat

  field :github_events, type: Integer
  field :msgs_sent, type: Integer
end