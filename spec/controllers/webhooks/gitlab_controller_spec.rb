require 'rails_helper'

describe Webhooks::GitlabController do
  after :each do
    cleanup_db
  end

  describe 'callback' do

    it 'handles push' do
      chat_id = 'github_controller_ni24n19'
      Chat.create! chat_id: chat_id

      body = load_file('gitlab_controller_push.json')

      expected_msg = 'Diaspora: John Smith pushed 4 commits http://example.com/mike/diaspora/compare/95790bf891e76fee5e1747ab589903a6a1f80f22...da1560886d4f094c3e6c9ef40349f7d38b5d27d7'
      allow_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)
    end

    it 'handles issue' do
      chat_id = 'github_controller_1ss8234'
      Chat.create! chat_id: chat_id

      body = load_file('gitlab_controller_issue.json')

      expected_msg = 'Gitlab Test: issue opened by Administrator http://example.com/diaspora/issues/23'
      allow_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)
    end

    it 'handles merge request' do
      chat_id = 'github_controller_1ssdfa34'
      Chat.create! chat_id: chat_id

      body = load_file('gitlab_controller_merge_request.json')

      expected_msg = 'awesome_project: merge request opened by Administrator http://example.com/diaspora/merge_requests/1'
      allow_any_instance_of(ChatService).to receive(:send_update).with(an_instance_of(Chat), expected_msg)

      post :callback, body, chat_id: chat_id

      expect(response.status).to eq(200)
    end
  end

  def load_file(file_name)
    File.open(File.join(File.dirname(__FILE__), file_name)).read
  end
end