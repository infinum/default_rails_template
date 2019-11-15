require 'mina/rails'
require 'mina/git'
require 'mina/secrets'
require 'mina/infinum'

set :application_name, 'awesome_app'
set :repository, 'git://...'
set :system_manager, :systemd
# set :background_worker, 'dj' / 'sidekiq'

task :staging do
  set :domain, 'staging.com'
  set :deploy_to, '/home/$USERNAME/www/...'
  set :user, '$USERNAME'
  set :rails_env, 'staging'
  set :branch, 'staging'
end

task :production do
  set :domain, 'production.com'
  set :deploy_to, '/home/$USERNAME/www/...'
  set :user, '$USERNAME'
  set :rails_env, 'production'
  set :branch, 'master'

end

task :deploy do
  invoke :'git:ensure_pushed'
  deploy do
    invoke :'git:clone'
    invoke :'secrets:pull'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :restart_application
      # invoke :'background_workers:restart'
    end
  end
end
