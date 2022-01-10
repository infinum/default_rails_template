require 'mina/rails'
require 'mina/git'
require 'mina/secrets'
require 'mina/infinum'

set :application_name, 'awesome_app'
set :repository, 'git://...'
set :service_manager, :systemd
set :bundle_withouts, 'development test ci deploy'
# set :background_worker, 'dj' / 'sidekiq'

task :staging do
  set :domain, 'staging.com'
  set :deploy_to, '/home/$USERNAME/www/...'
  set :user, '$USERNAME'
  set :rails_env, 'staging'
  # set :secrets_env, 'staging'
  set :branch, 'staging'
end

task :production do
  set :domain, 'production.com'
  set :deploy_to, '/home/$USERNAME/www/...'
  set :user, '$USERNAME'
  set :rails_env, 'production'
  # set :secrets_env, 'production'
  set :branch, 'master'
end

task :deploy do
  invoke :'git:ensure_pushed'
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install_gem'
    invoke :'bundle:install'
    command 'yarn install'
    invoke :'secrets:pull'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :restart_application
      # invoke :'background_workers:restart'
      # invoke :link_sidekiq_assets
    end
  end
end
