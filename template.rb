BASE_URL = 'https://raw.githubusercontent.com/infinum/default_rails_template/master'.freeze

# Readme.md
README_MD = <<-HEREDOC.strip_heredoc
[![Build Status](https://docs.semaphoreci.com/essentials/status-badges/)](https://semaphoreci.com/infinum/APP)
# README

## [Technical Documentation](docs/README.md)

## Dependencies

### System
  * Ruby (defined in .ruby-version file)
  * Node.js (defined in [package.json](https://classic.yarnpkg.com/en/docs/package-json/#toc-engines))
  * Yarn (defined in [package.json](https://classic.yarnpkg.com/en/docs/package-json/#toc-engines))

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

HEREDOC

create_file 'README.md', README_MD, force: true

# Technical documentation
[
  'docs/README.md',
  'docs/architecture/README.md',
  'docs/architecture/production.md',
  'docs/architecture/staging.md',
  'docs/architecture/environment_variables.md',
  'docs/architecture/services.md'
].each do |filename|
  get("#{BASE_URL}/#{filename}", filename)
end

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
    database: #{app_name}_development

  test:
    <<: *default
    database: #{app_name}_test

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

    # puts '== Installing JS dependencies =='
    # system 'yarn install'

    puts "== Installing overcommit =="
    system 'overcommit --install'

    puts '== Pulling secrets =='
    system 'bundle exec secrets pull'

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

    # puts '== Installing JS dependencies =='
    # system 'yarn install'

    puts '== Pulling secrets =='
    system 'bundle exec secrets pull'

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
    gem 'secrets_cli', require: false
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
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'bundler-audit', require: false
  gem 'letter_opener'
  gem 'mina-infinum', require: false
  gem 'overcommit', require: false
  gem 'rubocop-infinum', require: false
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
  database_name: ""
  database_port: "5432"
  bugsnag_api_key: ADD_IT_HERE

  development:
    secret_key_base: #{SecureRandom.hex(64)}

  test:
    secret_key_base: #{SecureRandom.hex(64)}
HEREDOC

create_file 'config/application.yml', FIGARO_FILE

# Rubocop
get("#{BASE_URL}/.rubocop.yml", '.rubocop.yml')

# Mina
get("#{BASE_URL}/mina_deploy.rb", 'config/deploy.rb')

# Overcommit
OVERCOMMIT_YML_FILE = <<-HEREDOC.strip_heredoc
gemfile: Gemfile

CommitMsg:
  HardTabs:
    enabled: true

PreCommit:
  BundleAudit:
    enabled: true
    flags: ['--update']
    on_warn: fail
    command: ['bundle', 'exec', 'bundle-audit']

  BundleCheck:
    enabled: true

  RuboCop:
    enabled: true
    on_warn: fail
    command: ['bundle', 'exec', 'rubocop']

  RailsSchemaUpToDate:
    enabled: true

  TrailingWhitespace:
    enabled: true
    exclude:
      - '**/db/structure.sql'

  HardTabs:
    enabled: true

PrePush:
  Brakeman:
    enabled: true
    command: ['bundle', 'exec', 'brakeman']

  ZeitwerkCheck:
    enabled: true
    description: 'Checks project structure for Zeitwerk compatibility'
    command: ['bundle', 'exec', 'rails zeitwerk:check']
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

# .github/PULL_REQUEST_TEMPLATE.md
PULL_REQUEST_TEMPLATE_FILE = <<-HEREDOC.strip_heredoc
Task: [#__TASK_NUMBER__](__ADD_URL_TO_PRODUCTIVE_TASK__)

#### Aim


#### Solution


HEREDOC

create_file '.github/PULL_REQUEST_TEMPLATE.md', PULL_REQUEST_TEMPLATE_FILE

# .github/CODEOWNERS
CODEOWNERS_FILE = <<-HEREDOC.strip_heredoc
# For more info about the file read https://help.github.com/en/articles/about-code-owners

# Set default PR reviewers. For example:
# * @d4be4st @melcha @nikone
HEREDOC

create_file '.github/CODEOWNERS', CODEOWNERS_FILE

# .git-hooks/pre_push/zeitwerk_check.rb
ZEITWERK_CHECK_FILE = <<-HEREDOC.strip_heredoc
# frozen_string_literal: true

module Overcommit
  module Hook
    module PrePush
      class ZeitwerkCheck < Base
        def run
          result = execute(command)
          return :pass if result.success?

          extract_messages result.stderr.split("\\n"),
                           /^expected file (?<file>[[:alnum:]].*\.rb)/
        end
      end
    end
  end
end
HEREDOC

create_file '.git-hooks/pre_push/zeitwerk_check.rb', ZEITWERK_CHECK_FILE

# Ignore rubocop warnings in db/seeds.rb
SEEDS_DISABLE_IGNORE = <<-HEREDOC.strip_heredoc
# rubocop:disable Metrics/LineLength
HEREDOC

SEEDS_ENABLE_IGNORE = <<-HEREDOC.strip_heredoc
# rubocop:enable Metrics/LineLength

HEREDOC

prepend_file 'db/seeds.rb', SEEDS_DISABLE_IGNORE
append_file 'db/seeds.rb', SEEDS_ENABLE_IGNORE

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
  run 'bundle install'
  run 'bundle exec spring binstub --all'
end

## Ask about default PR reviewers
default_reviewers = ask('Who are default pull request reviewers (defined in .github/CODEOWNERS)? E.g.: @d4be4st @melcha @nikone. Default reviewers:', :green)
append_to_file '.github/CODEOWNERS' do
  <<~HEREDOC
  * #{default_reviewers}
  HEREDOC
end

## Initialize git
git :init

## Overcommit install and sign
run 'overcommit --install'
run 'overcommit --sign'
run 'overcommit --sign pre-push'

# Fix default rubocop errors
run 'bundle exec rubocop -a'
