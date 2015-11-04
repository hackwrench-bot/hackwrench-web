
class TrelloService
  def self.card_url(short_link)
    "https://trello.com/c/#{short_link}"
  end
end