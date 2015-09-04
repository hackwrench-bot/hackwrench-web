require 'rails_helper'

describe Webhooks::GithubController do
  describe 'callback' do
    it 'returns 404 if no chat found' do
      expect {
        post :callback, chat_id: '__does_not_exist__'
      }.to raise_error(ActionController::RoutingError)
    end

    it 'handles issues event' do
      chat_id = 'github_controller_i2d'
      Chat.create! chat_id: chat_id

      request.headers['X-GitHub-Event'] = 'issues'
      body = load_file('github_controller_issue_event.json')

      allow_any_instance_of(ChatService).to receive(:send_update)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)
    end

    it 'handles push event' do
      chat_id = 'github_controller_a81'
      Chat.create! chat_id: chat_id

      request.headers['X-GitHub-Event'] = 'push'
      body = load_file('github_controller_push_event.json')

      allow_any_instance_of(ChatService).to receive(:send_update)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)
    end

    def load_file(file_name)
      File.open(File.join(File.dirname(__FILE__), file_name)).read
    end
  end
end