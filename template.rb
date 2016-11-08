def api_only?
  builder.options.api
end

def html_app?
  !api_only?
end

create_file 'README.md', 'Development: run ./bin/setup', force: true
create_file 'config/environments/staging.rb', "require_relative 'production'"

STAGING_DB_CONFIG = <<~HEREDOC
  staging:
    <<: *default
    database: <%= @app_name %>_staging
HEREDOC

append_to_file 'config/database.yml', STAGING_DB_CONFIG, after: "database: #{@app_name}_test\n\n"

# Remove unwanted gems. spring will be added later in the development group of gems
%w(coffee-rails jbuilder tzinfo-data).each do |unwanted_gem|
  gsub_file('Gemfile', /gem '#{unwanted_gem}'.*\n/, '')
end

# Remove comments from the Gemfile
gsub_file('Gemfile', /^\s*#+.*\n/, '')

# Add Pry Rails
append_to_file 'Gemfile', "  gem 'pry-rails'\n", after: "gem 'byebug', platform: :mri\n"

run 'bundle install'

git :init

GITIGNORED_FILES = <<~HEREDOC
  .sass-cache
  powder
  public/system
  dump.rdb
  logfile
  .DS_Store
HEREDOC

append_file '.gitignore', GITIGNORED_FILES
