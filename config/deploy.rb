# config valid only for current version of Capistrano
lock '3.8.1'

set :application, 'openkg'
set :repo_url, 'https://github.com/SyncedPSI/openkg.git'
set :user, 'www'
set :puma_threads, [0, 16]
set :puma_workers, 1
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :use_sudo,        false
set :deploy_via,      :remote_cache

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :assets_roles, []

set :pty,             false
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}_#{fetch(:stage)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true # Change to true if using ActiveRecord

set :init_system, :systemd

# DB tasks
set :db_local_clean, false
set :db_remote_clean, true
set :disallow_pushing, true

## Linked Files & Directories (Default None):
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/shared]
