require 'net/http'

create_file 'README.md', 'Development: run ./bin/setup', force: true
create_file 'config/environments/staging.rb', "require_relative 'production'"

STAGING_DB_CONFIG = <<-HEREDOC.strip_heredoc
  staging:
    <<: *default
    database: <%= @app_name %>_staging
HEREDOC

append_to_file 'config/database.yml', STAGING_DB_CONFIG, after: "database: #{@app_name}_test\n\n"

BUGSNAG_CONFIG = <<-HEREDOC.strip_heredoc
  Bugsnag.configure do |config|
    config.api_key = Rails.application.secrets.bugsnag['api_key']
    config.notify_release_stages = %w(production staging)
  end
HEREDOC

create_file 'config/initializers/bugsnag.rb', BUGSNAG_CONFIG

# Remove gems we don't use.
%w(coffee-rails jbuilder tzinfo-data).each do |unwanted_gem|
  gsub_file('Gemfile', /gem '#{unwanted_gem}'.*\n/, '')
end

# Remove comments from the Gemfile
gsub_file('Gemfile', /^\s*#+.*\n/, '')

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
  HEREDOC
end

append_to_file 'Gemfile', after: "group :development do\n" do
  <<-HEREDOC
  gem 'rubocop', require: false
  gem 'overcommit', require: false
  HEREDOC
end

SECRETS_YML_FILE = <<-HEREDOC.strip_heredoc
  default: &default
    secret_key_base: <%= Figaro.env.secret_key_base! %>
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
  bugsnag_api_key: ''

  development:
    secret_key_base: #{SecureRandom.hex(64)}
  test:
    secret_key_base: #{SecureRandom.hex(64)}
HEREDOC

create_file 'config/application.yml', FIGARO_FILE

RUBOCOP_CONFIG_URL = 'https://raw.githubusercontent.com/infinum/default_rails_template/master/.rubocop.yml'.freeze
create_file '.rubocop.yml', Net::HTTP.get(URI(RUBOCOP_CONFIG_URL))

run 'bundle install'

git :init

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
