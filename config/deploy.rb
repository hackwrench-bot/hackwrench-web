# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'telegram-engineer-app'

set :linked_dirs, %w{log tmp/pids public/assets tmp/cache tmp/sockets vendor/bundle public/system }
set :linked_files, fetch(:linked_files, []).push('config/mongoid.yml', 'config/secrets.yml')

set :keep_releases, 5

set :rbenv_ruby, '2.2.2'

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

# Puma settings
set :puma_threads, [0, 16]
set :puma_workers, 0
set :puma_worker_timeout, nil