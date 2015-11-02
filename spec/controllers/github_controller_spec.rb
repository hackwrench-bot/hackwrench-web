require 'rails_helper'

describe Webhooks::GithubController do
  after :each do
    cleanup_db
  end

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

      expected_msg = 'baxterthehacker/public-repo: issue opened by baxterthehacker https://github.com/baxterthehacker/public-repo/issues/2'
      allow_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)

      chat = Chat.find_by chat_id: chat_id
      expect(chat.chat_stat.github_events).to eq(1)
    end

    it 'handles push event' do
      chat_id = 'github_controller_a81'
      Chat.create! chat_id: chat_id

      request.headers['X-GitHub-Event'] = 'push'
      body = load_file('github_controller_push_event.json')

      expected_msg = "baxterthehacker/public-repo: baxterthehacker pushed 1 commit https://github.com/baxterthehacker/public-repo/compare/9049f1265b7d...0d1a26e67d8f\n0d1a26 - Update README.md"
      allow_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg, false)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)

      chat = Chat.find_by chat_id: chat_id
      expect(chat.chat_stat.github_events).to eq(1)
    end

    it 'handles issue_comment event' do
      chat_id = 'github_controller_b9b'
      Chat.create! chat_id: chat_id

      request.headers['X-GitHub-Event'] = 'issue_comment'
      body = load_file('github_controller_issue_comment_event.json')

      allow_any_instance_of(ChatService).to receive(:send_update)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)

      chat = Chat.find_by chat_id: chat_id
      expect(chat.chat_stat.github_events).to eq(1)
    end

    it 'handles pull_request event' do
      chat_id = 'github_controller_lo1a'
      Chat.create! chat_id: chat_id

      request.headers['X-GitHub-Event'] = 'pull_request'
      body = load_file('github_controller_pull_request_event.json')

      expected_msg = 'baxterthehacker/public-repo: pull request opened by baxterthehacker https://github.com/baxterthehacker/public-repo/pull/1'
      allow_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)

      chat = Chat.find_by chat_id: chat_id
      expect(chat.chat_stat.github_events).to eq(1)
    end

    it 'persists a new repo object on a ping event' do
      chat_id = 'github_controller_pqumd2'
      Chat.create! chat_id: chat_id

      request.headers['X-GitHub-Event'] = 'ping'
      body = load_file('github_controller_ping_event.json')

      post :callback, body, chat_id: chat_id
      expect(response.status).to eq(200)

      body_json = JSON.parse body
      chat = Chat.find_by chat_id: chat_id

      github_repo = chat.find_github_repo body_json['repository']['full_name']
      expect(github_repo).not_to be_nil
      expect(github_repo.name).to eq(body_json['repository']['full_name'])
      expect(github_repo.created_on_webhook).to eq(true)

      expect(chat.chat_stat.github_events).to eq(1)
    end

    it 'handles ping event when repo object already exists' do
      request.headers['X-GitHub-Event'] = 'ping'
      body = load_file('github_controller_ping_event.json')
      body_json = JSON.parse body

      chat_id = 'github_controller_pqusdf12'
      github_repo = GithubRepo.new name: body_json['repository']['full_name']
      Chat.create! chat_id: chat_id, github_repos: [github_repo]

      post :callback, body, chat_id: chat_id
      expect(response.status).to eq(200)

      chat = Chat.find_by chat_id: chat_id

      github_repo = chat.find_github_repo body_json['repository']['full_name']
      expect(github_repo).not_to be_nil
      expect(github_repo.name).to eq(body_json['repository']['full_name'])
      expect(github_repo.created_on_webhook).to eq(false)

      expect(chat.chat_stat.github_events).to eq(1)
    end

    it 'github_events stat get incremented' do
      request.headers['X-GitHub-Event'] = 'ping'
      body = load_file('github_controller_ping_event.json')
      body_json = JSON.parse body

      chat_id = 'github_controller_as2po11f12'
      github_repo = GithubRepo.new name: body_json['repository']['full_name']
      Chat.create! chat_id: chat_id, github_repos: [github_repo]

      # 1
      post :callback, body, chat_id: chat_id
      expect(response.status).to eq(200)

      # 2
      post :callback, body, chat_id: chat_id
      expect(response.status).to eq(200)

      chat = Chat.find_by chat_id: chat_id
      expect(chat.chat_stat.github_events).to eq(2)
    end

    def load_file(file_name)
      File.open(File.join(File.dirname(__FILE__), file_name)).read
    end
  end
end