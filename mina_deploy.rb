require 'mina/rails'
require 'mina/git'
require 'mina/secrets'
require 'mina/infinum'

set :repository, 'git://...'
set :user, 'deploy'

def staging
  set :domain, 'staging.com'
  set :deploy_to, '/home/deploy/www/...'
  set :rails_env, 'staging'
  set :branch, 'develop'
end

def production
  set :domain, 'production.com'
  set :deploy_to, '/home/deploy/www/...'
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
    end
  end
end
