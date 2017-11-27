require 'net/http'

# Readme.md
README_MD = <<-HEREDOC.strip_heredoc
# README

## Dependencies
### Projects
  * [Single sign-on service](https://github.com/infinum/accounts)

### System
  * node, eslint

## Setup
Before:
  * clone and setup single sign on service using pow
  * ensure you have read permissions for vault

Run:
```bash
./bin/setup
```

Run after each git pull:
```bash
./bin/update
```

## Test suite
Run:
```bash
rspec
```

## Environments
  * staging <stg>: [staging](https://staging.com)
  * production <prod>: [production](https://production.com)

## Deployment
[Semaphore](https://semaphoreci.com)

HEREDOC

create_file 'README.md', README_MD, force: true

# Staging environment config
create_file 'config/environments/staging.rb', "require_relative 'production'"

DB_CONFIG = <<-HEREDOC.strip_heredoc
  default: &default
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    host: <%= Rails.application.secrets.database[:host] %>
    database: <%= Rails.application.secrets.database[:database] %>
    username: <%= Rails.application.secrets.database[:username] %>
    password: <%= Rails.application.secrets.database[:password] %>

  development:
    <<: *default

  test:
    <<: *default

  staging:
    <<: *default

  production:
    <<: *default
HEREDOC

create_file 'config/database.yml', DB_CONFIG, force: true

# bin scripts
BIN_SETUP = <<-HEREDOC.strip_heredoc
  #!/usr/bin/env ruby
  require 'pathname'

  APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)

  Dir.chdir APP_ROOT do
    puts '== Installing dependencies =='
    system 'gem install bundler --conservative'
    system 'bundle check || bundle install'

    # puts '== Installing node modules =='
    # system 'npm install'

    puts "== Installing overcommit =="
    system 'overcommit --install'

    puts '== Pulling secrets =='
    system 'secrets pull'

    puts '== Preparing database =='
    system 'bin/rake db:setup'

    puts '== Removing old logs and tempfiles =='
    system 'rm -f log/*'
    system 'rm -rf tmp/cache'
  end
HEREDOC
create_file 'bin/setup', BIN_SETUP, force: true

BIN_UPDATE = <<-HEREDOC.strip_heredoc
  #!/usr/bin/env ruby
  require 'pathname'

  APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)

  Dir.chdir APP_ROOT do
    puts '== Installing dependencies =='
    system 'gem install bundler --conservative'
    system 'bundle check || bundle install'

    # puts '== Installing node modules =='
    # system 'npm install'

    # puts '== Building frontend =='
    # system 'npm run build'

    puts '== Pulling secrets =='
    system 'secrets pull'

    puts '== Preparing database =='
    system 'bin/rake db:migrate'
  end
HEREDOC
create_file 'bin/update', BIN_UPDATE, force: true

# bugsnag
BUGSNAG_CONFIG = <<-HEREDOC.strip_heredoc
  Bugsnag.configure do |config|
    config.api_key = Rails.application.secrets.bugsnag['api_key']
    config.notify_release_stages = %w(production staging)
  end
HEREDOC
create_file 'config/initializers/bugsnag.rb', BUGSNAG_CONFIG

# Remove gems we don't use.
%w(coffee-rails jbuilder tzinfo-data byebug).each do |unwanted_gem|
  gsub_file('Gemfile', /gem '#{unwanted_gem}'.*\n/, '')
end

# Remove comments from the Gemfile
gsub_file('Gemfile', /^\s*#+.*\n/, '')

# Add gems
append_to_file 'Gemfile', after: /gem 'rails'.*\n/ do
  <<-HEREDOC.strip_heredoc
    gem 'bugsnag'
    gem 'figaro'
    gem 'pry-rails'
  HEREDOC
end

append_to_file 'Gemfile', after: "group :development, :test do\n" do
  <<-HEREDOC
  gem 'pry-byebug'
  gem 'rspec-rails'
  HEREDOC
end

append_to_file 'Gemfile', after: "group :development do\n" do
  <<-HEREDOC
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'bundler-audit', require: false
  gem 'letter_opener'
  gem 'mina-infinum', require: false
  gem 'overcommit', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'secrets_cli', require: false
  HEREDOC
end

append_to_file 'config/environments/development.rb', after: 'Rails.application.configure do' do
  <<-HEREDOC

  config.action_mailer.delivery_method = :letter_opener

  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
  HEREDOC
end

# Secrets
SECRETS_YML_FILE = <<-HEREDOC.strip_heredoc
  default: &default
    secret_key_base: <%= Figaro.env.secret_key_base! %>
    database:
      database: <%= Figaro.env.database_database! %>
      username: <%= Figaro.env.database_username! %>
      password: <%= Figaro.env.database_password! %>
      host: <%= Figaro.env.database_host! %>
    bugsnag:
      api_key: <%= Figaro.env.bugsnag_api_key! %>

  development:
    <<: *default

  test:
    <<: *default

  staging:
    <<: *default

  production:
    <<: *default
HEREDOC

create_file 'config/secrets.yml', SECRETS_YML_FILE, force: true

FIGARO_FILE = <<-HEREDOC.strip_heredoc
  database_host: localhost
  database_username: postgres
  database_password: ""
  bugsnag_api_key: ADD_IT_HERE

  development:
    secret_key_base: #{SecureRandom.hex(64)}
    database_database: #{app_name}_development
  test:
    secret_key_base: #{SecureRandom.hex(64)}
    database_database: #{app_name}_test
HEREDOC

create_file 'config/application.yml', FIGARO_FILE

# Rubocop
RUBOCOP_CONFIG_URL = 'https://raw.githubusercontent.com/infinum/default_rails_template/master/.rubocop.yml'.freeze
create_file '.rubocop.yml', Net::HTTP.get(URI(RUBOCOP_CONFIG_URL))

# Mina
MINA_DEPLOY_URL = 'https://raw.githubusercontent.com/infinum/default_rails_template/master/mina_deploy.rb'.freeze
create_file 'config/deploy.rb', Net::HTTP.get(URI(MINA_DEPLOY_URL))

# Overcommit
OVERCOMMIT_YML_FILE = <<-HEREDOC.strip_heredoc
CommitMsg:
  HardTabs:
    enabled: true

PreCommit:
  BundleAudit:
    enabled: true

  BundleCheck:
    enabled: true

  RuboCop:
    enabled: true
    on_warn: fail

  RailsSchemaUpToDate:
    enabled: true

  TrailingWhitespace:
    enabled: true
    exclude:
      - '**/db/structure.sql'

  HardTabs:
    enabled: true
HEREDOC
create_file '.overcommit.yml', OVERCOMMIT_YML_FILE

# .gitignore
GITIGNORED_FILES = <<-HEREDOC.strip_heredoc
  .sass-cache
  powder
  public/system
  dump.rdb
  logfile
  .DS_Store
  # Ignore application configuration
  config/application*.yml
HEREDOC

append_file '.gitignore', GITIGNORED_FILES

# Finish
run 'bundle install'

run 'bundle exec secrets init'

run 'bundle exec rails generate rspec:install'

if yes?('Install spring? [No]', :green)
  append_to_file 'Gemfile', after: "group :development, :test do\n" do
    <<-HEREDOC
    gem 'spring-commands-rspec'
    HEREDOC
  end
  run 'spring binstub --all'
end

git :init

run 'overcommit --install'
run 'overcommit --sign'
