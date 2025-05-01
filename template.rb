BASE_URL = 'https://raw.githubusercontent.com/infinum/default_rails_template/master'.freeze

# Readme.md
README_MD = <<-HEREDOC.strip_heredoc
[![Build Status](https://docs.semaphoreci.com/essentials/status-badges/)](https://semaphoreci.com/infinum/APP)
![Health score](https://revisor.infinum.com/api/v1/badges/add-project-key?type=health_score)
![CVE count](https://revisor.infinum.com/api/v1/badges/add-project-key?type=cve_count)

# README

## [Technical Documentation](docs/README.md)

## Dependencies

### System
  * Ruby (defined in .ruby-version file)
  * Node.js (defined in [package.json](https://classic.yarnpkg.com/en/docs/package-json/#toc-engines))
  * Yarn (defined in [package.json](https://classic.yarnpkg.com/en/docs/package-json/#toc-engines))

## Setup

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
bundle exec rspec
```

## PR Workflow

### Commits

Guidelines for writing commit messages are outlined in [this](https://infinum.com/handbook/rails/workflows/git/branches#other-important-notes-on-using-git) handbook chapter.

### Branches

Our branch naming conventions are documented in [this](https://infinum.com/handbook/rails/workflows/git/branches) handbook chapter.

### Pull Requests

See [this](https://infinum.com/handbook/rails/workflows/git/pull-requests) handbook chapter for pull requests guidelines.

#### Labels

We're using labels on PRs to visually mark the different states of the PRs. Some are self-explanatory, others have an
additional description on GitHub.

[TODO] Add list and descriptions of project-specific labels here.

#### Solving Change Requests

See [this](https://infinum.com/handbook/rails/workflows/git/clean-changes#solving-change-requests) handbook chapter for best practices on solving change requests.

### Integration methodology

Check [this](https://infinum.com/handbook/rails/workflows/git/clean-changes#merging) handbook chapter for the integration methodology we use on the project.

[TODO] Document any project-specific integration methodology if it differs from the one described in the handbook, or if the project includes additional environments.
HEREDOC

create_file 'README.md', README_MD, force: true

# Technical documentation
[
  'docs/README.md',
  'docs/architecture.md',
  'docs/development_workflow.md'
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

    puts '== Copy sample secrets =='
    system 'cp config/application.example.yml config/application.yml'

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

    puts '== Copy sample secrets =='
    system 'cp config/application.example.yml config/application.yml'

    puts '== Preparing database =='
    system 'bin/rake db:migrate'
  end
HEREDOC
create_file 'bin/update', BIN_UPDATE, force: true

BIN_PREPARE_CI = <<~HEREDOC.strip_heredoc
  #!/usr/bin/env bash
  set -o errexit
  set -o pipefail
  set -o nounset

  echo "=========== pull secrets ==========="
  bundle exec secrets pull -e development -y
HEREDOC
create_file 'bin/prepare_ci', BIN_PREPARE_CI, force: true
chmod 'bin/prepare_ci', 0755, verbose: false

BIN_AUDIT = <<~HEREDOC.strip_heredoc
  #!/usr/bin/env bash

  set -o errexit
  set -o pipefail
  set -o nounset

  echo "=========== bundle audit ==========="
  time bundle exec bundle-audit update --quiet
  time bundle exec bundle-audit check

  echo "=========== brakeman ==========="
  time bundle exec brakeman -q --color
HEREDOC
create_file 'bin/audit', BIN_AUDIT, force: true
chmod 'bin/audit', 0755, verbose: false

BIN_LINT = <<~HEREDOC.strip_heredoc
  #!/usr/bin/env bash

  set -o errexit
  set -o pipefail
  set -o nounset

  echo "=========== zeitwerk check ==========="
  time bundle exec rails zeitwerk:check

  echo "=========== rubocop  ==========="
  time bundle exec rubocop --format simple --format github --color --parallel
HEREDOC
create_file 'bin/lint', BIN_LINT, force: true
chmod 'bin/lint', 0755, verbose: false

BIN_TEST = <<~HEREDOC.strip_heredoc
  #!/usr/bin/env bash

  set -o errexit
  set -o pipefail
  set -o nounset

  echo "=========== rails db:test:prepare ==========="
  time RAILS_ENV=test bundle exec rails db:test:prepare

  echo "=========== rspec ==========="
  time bundle exec rspec --force-color
HEREDOC
create_file 'bin/test', BIN_TEST, force: true
chmod 'bin/test', 0755, verbose: false

# bundler config
BUNDLER_CI_BUILD_CONFIG = <<~HEREDOC.strip_heredoc
  ---
  BUNDLE_DEPLOYMENT: "true"
  BUNDLE_WITHOUT: "development deploy"
HEREDOC
create_file '.bundle/ci-build/config', BUNDLER_CI_BUILD_CONFIG, force: true

BUNDLER_CI_DEPLOY_CONFIG = <<~HEREDOC.strip_heredoc
  ---
  BUNDLE_DEPLOYMENT: "true"
  BUNDLE_WITHOUT: "development test ci"
  # use line below when using dox
  # BUNDLE_WITHOUT: "development"
HEREDOC
create_file '.bundle/ci-deploy/config', BUNDLER_CI_DEPLOY_CONFIG, force: true

# bugsnag
BUGSNAG_CONFIG = <<-HEREDOC.strip_heredoc
  Bugsnag.configure do |config|
    config.api_key = Rails.application.secrets.fetch(:bugsnag_api_key)
    config.notify_release_stages = %w(production staging)
  end
HEREDOC
create_file 'config/initializers/bugsnag.rb', BUGSNAG_CONFIG

# Remove gems we don't use.
%w(jbuilder tzinfo-data byebug web-console importmap-rails brakeman rubocop-rails-omakase turbo-rails stimulus-rails).each do |unwanted_gem|
  gsub_file('Gemfile', /gem "#{unwanted_gem}".*\n/, '')
end

# Remove comments from the Gemfile
gsub_file('Gemfile', /^\s*#+.*\n/, '')

# Add gems
append_to_file 'Gemfile', after: /gem "rails".*\n/ do
  <<-HEREDOC.strip_heredoc

    gem 'bugsnag'
    gem 'figaro'
    gem 'pry-byebug'
    gem 'pry-rails'
    gem 'strong_migrations'
  HEREDOC
end

append_to_file 'Gemfile', after: "group :development do\n" do
  <<-HEREDOC
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'overcommit', require: false
  HEREDOC
end
# end

append_to_file 'Gemfile' do
  <<-HEREDOC.strip_heredoc

    group :test do
      gem 'rspec-rails'
    end
  HEREDOC
end

append_to_file 'Gemfile' do
  <<-HEREDOC.strip_heredoc

    group :ci do
      gem 'brakeman', require: false
      gem 'bundler-audit', require: false
      gem 'rubocop-infinum', require: false
    end
  HEREDOC
end

environment <<~HEREDOC, env: 'development'
  config.action_mailer.delivery_method = :letter_opener

  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end
HEREDOC

# Flipper

flipper_storage_adapter = ask('Will you use ActiveRecord or Redis storage adapter for Flipper? [Default: ActiveRecord]', :green)

flipper_storage_adapter = 'ActiveRecord' unless flipper_storage_adapter == 'Redis'

append_to_file 'Gemfile', after: /gem "rails".*\n/ do
  if flipper_storage_adapter == 'ActiveRecord'
    <<~HEREDOC.strip_heredoc

      gem 'flipper-active_record'
    HEREDOC
  else
    <<~HEREDOC.strip_heredoc

      gem 'flipper-redis'
    HEREDOC
  end
end

FLIPPER_CONFIG_FILE = <<-HEREDOC.strip_heredoc
  Rails.application.configure do
    config.flipper.memoize = false # for some reason webhook requests are being called twice without this, more on this link: https://github.com/flippercloud/flipper/pull/523

    config.after_initialize do # if we are using webhooks, this will make sure our flags are synchronized upon initialization
      Flipper.sync
    end
  end
HEREDOC

create_file 'config/flipper.rb', FLIPPER_CONFIG_FILE, force: true

# Suppress Puma SignalException
append_to_file 'config/puma.rb', after: /pidfile ENV.*\n/ do
  <<~RUBY

  # Suppress SignalException when SIGTERM is received
  #
  raise_exception_on_sigterm false
  RUBY
end

# Stop crawlers
append_to_file 'public/robots.txt' do
  <<-HEREDOC.strip_heredoc
  # no bot may crawl
  User-agent: *
  Disallow: /
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

    redis_url: <%= Figaro.env.redis_url! %>

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
   database_password: ''
   database_name: ''
   database_port: '5432'

   bugsnag_api_key: ''

   redis_url: 'redis://localhost:6379'

   FLIPPER_CLOUD_TOKEN: ''
   FLIPPER_CLOUD_SYNC_SECRET: ''

   development:
     secret_key_base: #{SecureRandom.hex(64)}

   test:
     secret_key_base: #{SecureRandom.hex(64)}
 HEREDOC

create_file 'config/application.example.yml', FIGARO_FILE

# Rubocop
get("#{BASE_URL}/.rubocop.yml", '.rubocop.yml')

# Overcommit
OVERCOMMIT_YML_FILE = <<-HEREDOC.strip_heredoc
gemfile: Gemfile

CommitMsg:
  HardTabs:
    enabled: true

PreCommit:
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
  config/application.yml
HEREDOC

append_file '.gitignore', GITIGNORED_FILES

# remove bundler ci config folders from gitignore
append_to_file '.gitignore', "/*\n!/.bundle/ci-build\n!/.bundle/ci-deploy", after: '/.bundle'

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
# * @github_username1 @github_username2
HEREDOC

create_file '.github/CODEOWNERS', CODEOWNERS_FILE

# .github/dependabot.yml
DEPENDABOT_FILE = <<-HEREDOC.strip_heredoc
version: 2
updates:
  - package-ecosystem: "bundler"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 2

  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 2
HEREDOC

create_file '.github/dependabot.yml', DEPENDABOT_FILE

# Ignore rubocop warnings in db/seeds.rb
SEEDS_DISABLE_IGNORE = <<-HEREDOC.strip_heredoc
# rubocop:disable Layout/LineLength
HEREDOC

SEEDS_ENABLE_IGNORE = <<-HEREDOC.strip_heredoc
# rubocop:enable Layout/LineLength

HEREDOC

prepend_file 'db/seeds.rb', SEEDS_DISABLE_IGNORE
append_file 'db/seeds.rb', SEEDS_ENABLE_IGNORE

## Ask about default PR reviewers
default_reviewers = ask('Who are default pull request reviewers (defined in .github/CODEOWNERS)? E.g.: @github_username1 @github_username2. Default reviewers:', :green)
append_to_file '.github/CODEOWNERS' do
  <<~HEREDOC
    * #{default_reviewers}
  HEREDOC
end

get("#{BASE_URL}/build.yml", '.github/workflows/build.yml')
get("#{BASE_URL}/delete-cache.yml", '.github/workflows/delete-cache.yml')

## Docker
if no?('Will this application use Docker? [Yes]', :green)
  # Mina
  get("#{BASE_URL}/mina_deploy.rb", 'config/deploy.rb')
  append_to_file 'Gemfile' do
    <<~HEREDOC.strip_heredoc

      group :deploy do
        gem 'mina-infinum', require: false
      end
    HEREDOC
  end

  BIN_DEPLOY = <<~HEREDOC.strip_heredoc
    #!/usr/bin/env bash

    set -o errexit
    set -o pipefail
    set -o nounset

    echo "=========== setting env variables ==========="
    environment=$1

    echo "=========== mina deploy =============="
    time bundle exec mina $environment ssh_keyscan_domain
    time bundle exec mina $environment setup
    time bundle exec mina $environment deploy
  HEREDOC
  create_file 'bin/deploy', BIN_DEPLOY, force: true
  chmod 'bin/deploy', 0755, verbose: false

  BIN_PUBLISH_DOCS = <<~HEREDOC.strip_heredoc
    #!/usr/bin/env bash

    set -o errexit
    set -o pipefail
    set -o nounset

    echo "=========== setting env variables ==========="
    environment=$1

    echo "=========== rails db:test:prepare ==========="
    time bundle exec rails db:test:prepare

    echo "=========== mina dox publish ==========="
    time bundle exec mina "$environment" ssh_keyscan_domain
    time bundle exec mina "$environment" dox:publish
  HEREDOC
  create_file 'bin/publish_docs', BIN_PUBLISH_DOCS, force: true
  chmod 'bin/publish_docs', 0755, verbose: false

  get("#{BASE_URL}/deploy-staging.yml", '.github/workflows/deploy-staging.yml')
  get("#{BASE_URL}/deploy-production.yml", '.github/workflows/deploy-production.yml')

  ## Users allowed to manually trigger deploys
  staging_deployers = ask('Who can manually trigger a deploy to staging? (Example: @username1 @username2)', :green)
  gsub_file('.github/workflows/deploy-staging.yml', 'DEPLOY USERS GO HERE', staging_deployers)

  production_deployers = ask('Who can manually trigger a deploy to production? (Example: @username1 @username2)', :green)
  gsub_file('.github/workflows/deploy-production.yml', 'DEPLOY USERS GO HERE', production_deployers)
else
  # remove push trigger for build workflow, the build-image workflow will be used instead
  gsub_file '.github/workflows/build.yml', /\n\s*push:\n.*$/, ''

  get "#{BASE_URL}/docker/build-image.yml", '.github/workflows/build-image.yml'
  get "#{BASE_URL}/docker/extract_params", 'bin/extract_params'
  chmod 'bin/extract_params', 0755, verbose: false
  get "#{BASE_URL}/docker/connect_to_container", 'bin/connect_to_container'
  chmod 'bin/connect_to_container', 0755, verbose: false

  inside '.docker' do
    get "#{BASE_URL}/docker/.docker/Aptfile", 'Aptfile'
    run 'touch .psqlrc'
  end
  get "#{BASE_URL}/docker/.dockerignore", '.dockerignore'
  get "#{BASE_URL}/docker/docker-compose.yml", 'docker-compose.yml'

  require 'bundler'
  gsub_file 'docker-compose.yml', 'placeholder-app', app_name
  gsub_file 'docker-compose.yml', 'RUBY_VERSION: 3.1.1', "RUBY_VERSION: #{RUBY_VERSION}"
  gsub_file 'docker-compose.yml', 'BUNDLER_VERSION: 2.3.7', "BUNDLER_VERSION: #{Bundler::VERSION}"

  if yes?('Will this application need Node runtime? [No]', :green)
    get "#{BASE_URL}/docker/Dockerfile.with_node", 'Dockerfile'
    node_version = `node -v`.chomp.sub('v', '')
    node_major = node_version.scan(/^[[:digit:]]+/).first
    append_to_file 'docker-compose.yml', <<-HEREDOC.chomp, after: /BUNDLER_VERSION: .*$/
\n        NODE_MAJOR: #{node_major}
        NODE_VERSION: #{node_version}
    HEREDOC
  else
    get "#{BASE_URL}/docker/Dockerfile", 'Dockerfile'
  end
end

## Frontend
uses_frontend = yes?('Will this application have a frontend? [No]', :green)
if uses_frontend
  append_to_file 'Gemfile', after: "gem 'pry-rails'\n" do
    <<~HEREDOC
      gem 'slim'
      gem 'jsbundling-rails'
      gem 'cssbundling-rails'
      gem 'view_component'
      gem 'stimulus-rails'
      gem 'turbo-rails'
    HEREDOC
  end

  append_to_file 'Gemfile', after: " gem 'rubocop-infinum', require: false\n" do
    "  gem 'slim_lint', require: false\n"
  end

  get("#{BASE_URL}/.slim-lint.yml", '.slim-lint.yml')

  node_version = `node -v`.chomp.sub('v', '')

  create_file '.node-version', node_version

  PACKAGE_JSON_FILE = <<~HEREDOC
    {
      "name": "#{app_name}",
      "private": true,
      "version": "0.1.0",
      "scripts": {
        "lint-css": "stylelint",
        "lint-js": "eslint"
      },
      "stylelint": {
        "extends": "@infinumrails/stylelint-config-scss"
      },
      "eslintConfig": {
        "extends": "@infinumrails/eslint-config-js"
      },
      "engines": {
        "node": "#{node_version}"
      }
    }
  HEREDOC

  create_file 'package.json', PACKAGE_JSON_FILE

  append_to_file '.overcommit.yml', after: "command: ['bundle', 'exec', 'rubocop']\n" do
    <<-HEREDOC

  SlimLint:
    enabled: true
    on_warn: fail
    command: ['bundle', 'exec', 'slim-lint']

  EsLint:
    enabled: true
    on_warn: fail
    required_executable: 'yarn'
    command: ['yarn', 'lint-js']

  Stylelint:
    enabled: true
    on_warn: fail
    required_executable: 'node_modules/.bin/stylelint'
    command: ['node_modules/.bin/stylelint']
    HEREDOC
  end

  append_to_file '.gitignore' do
    <<~HEREDOC
      node_modules
    HEREDOC
  end

  STYLELINTIGNORE_FILE = <<~HEREDOC
    *.*
    !app/assets/**/*.css
    !app/assets/**/*.scss
  HEREDOC

  create_file '.stylelintignore', STYLELINTIGNORE_FILE

  append_to_file 'bin/lint' do
    <<~HEREDOC

      echo "=========== slim lint ==========="
      time bundle exec slim-lint app/views

      echo "=========== JS lint ==========="
      time yarn lint-js app

      echo "=========== CSS lint ==========="
      time yarn lint-css --allow-empty-input app
    HEREDOC
  end

  run 'yarn add --dev @infinumrails/eslint-config-js @infinumrails/stylelint-config-scss eslint postcss stylelint'

  gsub_file('.github/workflows/build.yml', /^.*use_node: false.*\n/, '')
end

# Finish

# enable Rails.application.secrets
application <<~HEREDOC
  def secrets
    config_for(:secrets)
  end

HEREDOC

## Bundle install
run 'bundle install'

## Add ruby to PLATFORMS to enable bundle install on CI
run 'bundle lock --add-platform ruby'

## Needed by the rails_command that follow
run 'cp config/application.example.yml config/application.yml'

## Initialize rspec
rails_command 'generate rspec:install'
run 'bundle binstubs rspec-core'

## add annotate task file and ignore its rubocop violations
rails_command 'generate annotate:install'
ANNOTATE_TASK_FILE = 'lib/tasks/auto_annotate_models.rake'
prepend_file ANNOTATE_TASK_FILE, "# frozen_string_literal: true\n\n"
append_to_file ANNOTATE_TASK_FILE, after: "its thing in production.\n" do
  "# rubocop:disable Metrics/BlockLength, Rails/RakeEnvironment\n"
end
append_file ANNOTATE_TASK_FILE,
            "# rubocop:enable Metrics/BlockLength, Rails/RakeEnvironment\n"

## add strong migrations config
rails_command 'generate strong_migrations:install'

## Overcommit install and sign
run 'overcommit --install'
run 'overcommit --sign'
run 'overcommit --sign pre-push'

# Install frontend gems
if uses_frontend
  rails_command 'javascript:install:esbuild'
  rails_command 'css:install:tailwind'
  rails_command 'turbo:install'
  rails_command 'stimulus:install'
end

if flipper_storage_adapter == 'ActiveRecord'
  run 'rails g flipper:setup'
end

# Fix default rubocop errors
run 'bundle exec rubocop -A'
