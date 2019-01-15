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

set :sidekiq_config, 'config/sidekiq.yml'
set :init_system, :systemd

# DB tasks
set :db_local_clean, false
set :db_remote_clean, true
set :disallow_pushing, true
# set :assets_dependencies, %w(app/assets app/frontend lib/assets vendor/assets config/webpack)

## Linked Files & Directories (Default None):
set :linked_files,  %w[.env]
set :linked_dirs,   %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/shared public/system public/uploads public/data public/wp-content public/.well-known]

set :assets_dir,    'public/assets'
set :origin_assets, %w[frontend/ app/assets/ yarn.lock config/webpacker.yml config/webpack/]

# Precompile files locally for _much_ faster deployment.
Rake::Task["deploy:compile_assets"].clear
Rake::Task["deploy:set_linked_dirs"].clear
Rake::Task["deploy:rollback_assets"].clear

namespace :deploy do
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        warn "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        warn 'Sync changes before deploy.'
        exit
      end
    end
  end

  before :starting, :check_revision

  desc 'Compile assets'
  task compile_assets: [:set_rails_env] do
    need_generate = false

    on roles(:app) do
      fetch(:origin_assets).each do |assets|
        need_generate ||= !capture("diff -Nr #{current_path}/#{assets} #{release_path}/#{assets}", raise_on_non_zero_exit: false).empty?
      end
    end

    if need_generate
      invoke 'deploy:assets:precompile_local'
      invoke 'deploy:assets:backup_compiled_assets'
    else
      invoke 'deploy:assets:restore_compiled_asset'
    end
  end

  namespace :assets do
    desc 'Precompile assets locally and then rsync to web servers'
    task :precompile_local do
      run_locally do
        execute 'rake assets:clobber'
        execute "RAILS_ENV=#{fetch(:stage)} bundle exec rake assets:precompile"

        # Rsync to each server
        execute "#{fetch(:rsync_cmd)} ./#{fetch(:assets_dir)}/ #{fetch(:user)}@#{fetch(:server_name)}:#{release_path}/#{fetch(:assets_dir)}/"
      end
    end

    task :backup_compiled_assets do
      on release_roles :all do
        source = release_path.join(fetch(:assets_dir))
        target = shared_path.join('public')

        execute :rsync, '-av', '--delete', source, target
      end
    end

    task :restore_compiled_asset do
      on release_roles :all do
        source = shared_path.join(fetch(:assets_dir))

        execute :cp, '-rf', source, release_path.join('public')
      end
    end
  end
end
