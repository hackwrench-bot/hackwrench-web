class GitlabService
  def self.callback_url(chat)
    Rails.application.routes.url_helpers.webhooks_gitlab_url(chat_id: chat.chat_id,
                                                             host: Rails.configuration.web_app_hostname)
  end
end