def api_only?
  builder.options.api
end

def html_app?
  !api_only?
end

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

# Add Pry Rails
append_to_file 'Gemfile', "  gem 'pry-rails'\n", after: "gem 'byebug', platform: :mri\n"

gem_group :staging, :production do
  gem 'bugsnag'
end

run 'bundle install'

git :init

GITIGNORED_FILES = <<-HEREDOC.strip_heredoc
  .sass-cache
  powder
  public/system
  dump.rdb
  logfile
  .DS_Store
HEREDOC

append_file '.gitignore', GITIGNORED_FILES
