require 'net/http'

# Readme.md
README_MD = <<-HEREDOC.strip_heredoc
[![Maintainability](https://api.codeclimate.com/v1/badges/4149506cc9736f8ae8b7/maintainability)](https://codeclimate.com/repos/55f5e5f26956802431004c66/maintainability)
[![Build Status](https://semaphoreci.com/api/v1/projects/dcaf37ba-7b17-4653-9bf1-67c5a4755d14/866843/badge.svg)](https://semaphoreci.com/infinum/web)
[![Test Coverage](https://api.codeclimate.com/v1/badges/4149506cc9736f8ae8b7/test_coverage)](https://codeclimate.com/repos/55f5e5f26956802431004c66/test_coverage)
[![Issue Count](https://codeclimate.com/repos/56bcf5c3461848007e001c25/badges/4149506cc9736f8ae8b7/issue_count.svg)](https://codeclimate.com/repos/4149506cc9736f8ae8b7/feed)
# README

## Dependencies

### System
  * yarn, eslint

## Setup
Before:
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
    host: <%= Rails.application.secrets.fetch(:database_host) %>
    port: <%= Rails.application.secrets.fetch(:database_port) %>
    database: <%= Rails.application.secrets.fetch(:database_name) %>
    username: <%= Rails.application.secrets.fetch(:database_username) %>
    password: <%= Rails.application.secrets.fetch(:database_password) %>

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
    config.api_key = Rails.application.secrets.fetch(:bugsnag_api_key)
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
    database_name: <%= Figaro.env.database_name! %>
    database_username: <%= Figaro.env.database_username! %>
    database_password: <%= Figaro.env.database_password! %>
    database_host: <%= Figaro.env.database_host! %>
    database_port: <%= Figaro.env.database_port! %>
    bugsnag_api_key: <%= Figaro.env.bugsnag_api_key! %>

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
  database_port: "5432"
  bugsnag_api_key: ADD_IT_HERE

  development:
    secret_key_base: #{SecureRandom.hex(64)}
    database_name: #{app_name}_development
  test:
    secret_key_base: #{SecureRandom.hex(64)}
    database_name: #{app_name}_test
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

# set latest ruby version as local
run 'rbenv local $(rbenv global)'

## Bundle install
run 'bundle install'

## Initializes secrets_cli
run 'bundle exec secrets init'

## Initialize rspec
run 'bundle exec rails generate rspec:install'

## Initialize spring
if yes?('Install spring? [No]', :green)
  append_to_file 'Gemfile', after: "group :development, :test do\n" do
    <<-HEREDOC
    gem 'spring-commands-rspec'
    HEREDOC
  end
  run 'bundle exec spring binstub --all'
end

## Initialize git
git :init

## Overcommit install and sign
run 'overcommit --install'
run 'overcommit --sign'
