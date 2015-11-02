require 'rails_helper'
require 'ostruct'

describe GithubService do
  after :each do
    cleanup_db
  end

  describe 'create_hook' do
    it 'creates a hook' do
      chat = Chat.create! chat_id: 'GithubService_a11dfnk2o'
      repo = "henadzit/#{chat.chat_id}"

      allow_any_instance_of(Octokit::Client).to receive(:create_hook)
      allow_any_instance_of(ChatService).to receive(:send_update)

      expect(GithubService.new('123').create_hook(repo, chat)).to eq(true)

      chat = Chat.find_by chat_id: chat.chat_id
      github_repo = chat.find_github_repo repo
      expect(github_repo).not_to be_nil
      expect(github_repo.disabled).to eq(false)
      expect(github_repo.created_on_webhook).to eq(false)
      expect(github_repo.name).to eq(repo)
    end
  end

  describe 'delete_hook' do
    it 'deletes a hook' do
      chat_id = 'GithubService_ia1h33nab'
      github_repo = GithubRepo.new name: "henadzit/#{chat_id}"
      chat = Chat.create! chat_id: chat_id, github_repos: [github_repo]

      hook_response = [OpenStruct.new({
          id: 1,
          config: OpenStruct.new({
              url: 'http://localhost'
          })
      })]
      allow_any_instance_of(Octokit::Client).to receive(:hooks).and_return(hook_response)
      allow_any_instance_of(Octokit::Client).to receive(:remove_hook)
      allow_any_instance_of(ChatService).to receive(:send_update)

      expect(GithubService.new('123').delete_hook(github_repo.name, chat)).to eq(true)

      chat = Chat.find_by chat_id: chat_id
      github_repo = chat.find_github_repo github_repo.name
      expect(github_repo).not_to be_nil
      expect(github_repo.disabled).to eq(true)
      expect(github_repo.created_on_webhook).to eq(false)
    end
  end
end