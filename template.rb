### Rails app generator template. Run it:
### rails new _app_name_ -m https://gist.githubusercontent.com/DamirSvrtan/28a28e50d639b9445bbc/raw/app_template.rb

def api_only?
  builder.options.api
end

def html_app?
  !api_only?
end

create_file 'README.md', 'Development: run ./bin/setup', force: true
create_file 'config/environments/staging.rb', "require_relative 'production'"

database_type = ask('Do you want to use postgres or mysql?', limited_to: ['pg', 'mysql'])

adapter = if database_type == 'pg'
  gem 'pg'
  'postgresql'
else
  gem 'mysql2'
  'mysql2'
end

database_file = <<-FILE
default: &default
  adapter: <%= adapter %>
  pool: 5
  timeout: 5000
  host: localhost
  username: root
development:
  <<: *default
  database: <%= @app_name %>_development
  password:
test:
  <<: *default
  database: <%= @app_name %>_test
staging:
  <<: *default
  database: <%= @app_name %>_staging
production:
  <<: *default
  database: <%= @app_name %>_production
FILE

create_file 'config/database.yml', ERB.new(database_file).result(binding), force: true

# Remove unwanted gems. spring will be added later in the development group of gems
%w(spring coffee-rails sqlite3).each do |unwanted_gem|
  gsub_file('Gemfile', /gem '#{unwanted_gem}'.*\n/, '')
end

if html_app?
  run 'mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss'

  # Replace erb layout file with slim layout file
  layout_file = <<-FILE
  doctype html
  html
    head
      title <%= @app_name.titleize %>
      = stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true
      = javascript_include_tag 'application', 'data-turbolinks-track' => true
      = csrf_meta_tags
    body
      = yield
  FILE

  remove_file 'app/views/layouts/application.html.erb'
  create_file 'app/views/layouts/application.html.slim', ERB.new(layout_file).result(binding)
end

# remove commented lines
gsub_file('Gemfile', /#.*\n/, '')
# remove double newlines
gsub_file('Gemfile', /^\n\n/, '')

gem_group :development do
  gem 'spring'
  gem 'pry-rails'

  if html_app?
    gem 'slim-rails'
    gem 'better_errors'
    gem 'binding_of_caller'
  end
end

run 'bundle install'

git :init
%w(.sass-cache powder public/system dump.rdb logfile .DS_Store).each do |gitignored|
  append_file '.gitignore', gitignored
end

git add: '.', commit: "-m 'Initial commit'"
