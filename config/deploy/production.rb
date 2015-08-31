set :scm, :copy

set :rails_env, 'production'
set :deploy_to, "/home/teng/apps/#{fetch(:application)}/#{fetch(:rails_env)}"

set :nginx_domains, 'teng.henadzit.com'
set :nginx_redirected_domains, 'www.teng.henadzit.com'
set :app_server, true
set :app_server_socket, "#{shared_path}/tmp/sockets/puma.sock"

server 'teng.henadzit.com', user: 'teng', roles: %w{app db web}


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
