BASE_URL = 'https://raw.githubusercontent.com/infinum/default_rails_template/master'.freeze

# Readme.md
README_MD = <<-HEREDOC.strip_heredoc
[![build](https://github.com/infinum/project-name/actions/workflows/build.yml/badge.svg)](https://github.com/infinum/project-name/actions/workflows/build.yml)
![Health score](https://revisor.infinum.com/api/v1/badges/add-project-key?type=health_score)
![CVE count](https://revisor.infinum.com/api/v1/badges/add-project-key?type=cve_count)

# README

# Table of Contents

- [Prerequisites](#prerequisites)
   - [Organizational Access](#organizational-access)
   - [Development Access](#development-access)
- [Architecture](#architecture)
- [Development setup](#development-setup)
- [Environments](#environments)
- [Deployment](#deployment)
- [Console Access](#console-access)
  - [Staging](#staging)
  - [Production](#production)
- [Workflow](#workflow)
  - [Commits](#commits)
  - [Branches](#branches)
    - [Type](#types)
  - [Pull Requests](#pull-requests)
    - [Labels](#labels)
    - [Solving Change Requests](#solving-change-requests)
  - [Merging](#merging)
    - [Staging](#staging-1)
      - [Merge Methodology](#merge-methodology)
    - [Production] (#production-1)
      - [Merge Methodology](#merge-methodology)
- [Test Suite]

## Prerequisites

Before you start working on the project, you need to get access to project-related items and install system
dependencies.

### Organizational Access

Ask the project manager to give you access to:

* project in the project management software (productive, jira, etc) **LINK-TO-PROJECT** <!-- https://app.productive.io/path-to-project --> <!-- DEVELOPER -->
* project Slack channels **LINK-TO-SLACK-CHANNELS** <!-- https://infinum.slack.com/path-to-project --> <!-- DEVELOPER -->
* project Google Drive **LINK-TO-GOOGLE-DRIVE** <!-- https://drive.google.com//path-to-project --> <!-- DEVELOPER -->
* project design (Figma, Sketch, etc) **LINK-TO-DESIGN** <!-- https://www.figma.com/path-to-project --> <!-- DEVELOPER -->

### Development access

Ask a devops to give you access to:

* 1password vault - **VAULT-NAME** <!-- DEVELOPER -->
* git repository - **LINK-TO-GIT-REPO** <!-- https://github.com/path-to-project --> <!-- DEVELOPER -->
* development and staging secrets - **LINK-TO-GIT-REPO** <!-- https://github.com/path-to-project --> <!-- DEVELOPER -->
* bugsnag project - **LINK-TO-BUGSNAG** <!-- https://bugsnag.com/path-to-project --> <!-- DEVELOPER -->
* semaphore project - **LINK-TO-SEMAPHORE** <!-- https://semaphoreci.com/path-to-project --> <!-- DEVELOPER -->
* staging and/or UAT server
<!-- any other project specific services that are required for development -->


## Architecture

### Main info

* Framework: Ruby on Rails
* Language: Ruby

<!-- DEVELOPER -->
<!-- if exists
## Diagram

![diagram](https://lucid.app/publicSegments/view/e1a4ca97-cf28-4b3b-8283-6e76a27f0158/image.png)
-->

### Aws Account

* ACCOUNT-NAME (ACCOUNT-ID) <!-- infinum-dev (7021-9251-8610) --> <!-- DEVOPS -->
<!-- * ACCOUNT-NAME (ACCOUNT-ID) [staging] --> <!-- if multiple AWS account add a [tag]-->

### Infrastructure
[terraform config](https://github.com/infinum/terraform-take-care/tree/master/environments/stage) <!-- DEVOPS -->

<!-- DEVOPS -->
<!-- if exists
## Devops wiki
[wiki](https://devops-wiki.infinum.co/books/projects/chapter/APP)
-->

### Application
* ruby version: **RUBY VERSION** <!-- 2.7.1 --> <!-- DEVELOPER -->
* node version: **NODE VERSION** <!-- 14.0.1 --> <!-- DEVELOPER -->
* application dependencies <!-- DEVELOPER -->
  <!-- * vips -->

### Database
* extensions: <!-- DEVELOPER -->
  <!-- * unaccent -->

### 3rd party services

 <!-- DEVELOPER -->
* [Bugsnag](https://app.bugsnag.com/infinum/APP)
  * notifies to **#project-app-alerts**
* [GHA](https://github.com/infinum/rails-infinum-guess_who/actions/)
  * notifies to **#project-app-alerts**
* [Mailgun](https://mailgun.com)
  * staging account: **mailgun.staging@infinum.hr**
  * production account: **mailgun.APP@infinum.com**


## Development Setup

Run:

```bash
./bin/setup
```

Ensure all tests pass with:
Run:

```bash
bin/rspec
```

## Environments

* staging <stg>: [staging-project-name](https://staging-api-url)
 * documentation: [documentation-endpoint](https://staging-api-url/api/v1/docs/)
 * frontend: [staging-frontend-app-name](https://staging-app-url)
* production <prod>: [production-project-name](https://production-api-url)
  * frontend: [prod-frontend-app-name](https://production-app-url)

## Deployment
[Github Actions](https://github.com/APP-REPO-NAME/actions)

### Builds
Our continuous integration tool will automatically build the environment upon each push to whatever branch.
The build installs all dependencies and runs all the specs

### Deploying
The `staging` branch is used for the staging environment and `master` for production.
Whenever a branch or pull request is merged to one of those environments, after the build is finished Semaphore will try to deploy it to the environment.


## Console Access

### Staging

'mina staging console'

### Production

'mina production console

## Workflow

### Commits

Commits should have a descriptive subject as well as a quick explanation of the reason for the change in the commit body.
This makes it easier to check changes in the code editor as you do not have to find the pull request and open it on github.
These commit bodies can also be used to fill the content of the pull request if you wish.

### Branches

Branches should be opened from the master branch. Naming convention is {type}/{task-number}-{descriptive-task-name}

#### Types:

- feature

  A new feature or an improvement to an existing feature

- fix

  A non-critical bugfix, improvement, paying technical debt. Goes through code review process.

- hotfix

  A time sensitive critical bugfix, that should be deployed to production as soon as possible.
  Not necessary that it goes through code review, but it should be revisited at a later stage, and properly fixed or improved.

### Pull Requests

Once the feature or fix is done, a PR for it should be opened. We have a pull request template with placeholders for all relevant data that should be included.
Code-owners are automatically assigned as reviewers

#### Labels

We are using labels on PRs to visually mark the different states of the PRs.

- 'deployed to staging'
- 'blocked' - blocked by a third party
- 'code review' - explicit review needed before deploy to staging
- 'waiting on QA' - waiting for QA confirmation on staging

#### Solving Change Requests

Change requests should be fixed in separate fixup or squash commits. Rebasing the branch during an ongoing review is not
appreciated unless there is a good reason for it, like pulling in some new and necessary changes from master, because it
makes harder for the reviewers to know what the new changes are and what they already reviewed.

These commits should be merged into staging as well when they are done.

### Merging

#### Staging

Once the PR is opened, the feature can be merged into staging (PR label: `deployed to staging`), unless it contains
considerable logic in the migrations, in which case the reviewers should prioritize reviewing the migrations first (PR
label: `code review`), and giving a thumbs up for a merge into staging (PR label: `deployed to staging`).

##### Merge Methodology

We are doing merge-squashes to staging, as well of resets of the staging branch to master after each
sprint, or more frequently as we see fit.

We are usually doing merge squashes by cherry-picking a commit range.
Cherry-picking usually produces less merge conflicts once master and target branch diverge.

Note that BASE-OF-BRANCH is one commit prior of
the first commit of the branch.

```bash
git switch staging
git fetch origin staging && git pull --rebase
git cherry-pick -n {BASE-OF-BRANCH}..{feature-branch}
```

The commit message should be in the following format.

```
Merge-squash {feature-branch}

(pull request {pull-request-link})
[optionally](cherry picked from {commit-sha})
```

Including the pull request link makes github pick up that commit in the pull request, so we can know directly in
the pull request, when was the branch deployed to staging.

Run the specs, check if everything is ok, then push 🎉

#### Master (Production)

Once the PR has at least 1 approval, the branch was successfully deployed to staging and tested, deployed to UAT and
confirmed by the client, and there are no failing specs, it can be merged into master.

##### Merge Methodology

There are generally 2 ways we are merging PRs to Master.
With `git merge --squash` (squash and merge button on GitHub) or non fast forward merge.
Each of these is project specific and should be agreed upon which would be used when starting the project.

Squash and merge way:

While on a feature branch:

```bash
git fetch origin master
git rebase -i origin/master
git push --force
```

Check once again that everything was rebased correctly and continue on the master branch:

```bash
git fetch origin master
git switch master && git pull
git merge --squash {feature-branch}
```

Then commit the new changes with a message of this format
{pr-title} ({pr-number})

{pr-description}


```bash
Methodology/squash and merge with default to pr title and description (#9)
    
TASK:
[#732](https://app.productive.io/1-infinum/projects/2274/tasks/task/3497433?board=291038&filter=MjA2MTY2&task-list=631567)

Problem:
What we discussed

Solution:
Thingy, do the thingy
```bash

*Note*: when doing merge-squash through terminal you will need to manually close the PR, as opposed to using the Squash and merge on GitHub

Non fast forward merge way:

Follow the squash and merge way, but change `git merge --squash {feature-branch}` with `git merge --no-ff --no-edit {feature-branch}`


Make sure the history graph is nice and clean by entering the following command or similanr and make sure that no lines "cross over".

```bash
git log --oneline --graph
```

Bad:

```bash
*   1b82b9f (HEAD -> master) Merge branch 'feature/add-git-process-to-readme'
|\
| * a25b3dc (origin/feature/add-git-process-to-readme, feature/add-git-process-to-readme) Add git process to readme
* |   bfe1152 (origin/master) Merge branch 'feature/xx-some-other-feature'
|\ \
| |/
|/|
| * 3345dbb Some other feature subject
|/
*   7eade95 Merge branch 'feature/xx-another-other-feature'
|\
| * 0a80385 Another feature subject
|/
*
```

Good:

# Merge-squash
```bash
* ba19c66 (HEAD -> cve/fix-rack-and-nokogiri-cves, origin/cve/fix-rack-and-nokogiri-cves) Update rack to 2.2.7 and nokogiri to 1.14.4 to fix CVES
* 52bfab2 (origin/master, origin/HEAD, master) Update rack to 2.2.6.4 (#40)
* ae1621a Upgrade rails to 7.0.4.3 to fix CVE (#39)
* 3e8d526 Update rack to 2.2.6.3 to fix CVE (#38)
* 2c98a9a Upgrade rack and globalid to fix cves (#37)
* d8bb387 Upgrade rails to 7.0.4.1 (#36)
```

# Non fast forward merge 
```bash
*   1a164b4 (HEAD -> master) Merge branch 'feature/add-git-process-to-readme'
|\
| * 222sad5 (feature/add-something-more) Something more is added
| * 497dcd7 (origin/feature/add-git-process-to-readme, feature/add-git-process-to-readme) Add git process to readme
|/
*   bfe1152 (origin/master) Merge branch 'feature/xx-some-other-feature'
|\
| * 3345dbb Some other feature subject
|/
*   7eade95 Merge branch 'feature/xx-another-other-feature'
|\
| * 0a80385 Another feature subject
|/
*
```

Double check everything, run the specs locally and push 🎉

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

  # leaving it here as it's required by the GHA
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
%w(jbuilder tzinfo-data byebug web-console).each do |unwanted_gem|
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
if yes?('Will this application have a frontend? [No]', :green)
  append_to_file 'Gemfile', after: "gem 'pry-rails'\n" do
    "gem 'slim'\n"
  end

  append_to_file 'Gemfile', after: " gem 'rubocop-infinum', require: false\n" do
    "    gem 'slim_lint', require: false\n"
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

# Fix default rubocop errors
run 'bundle exec rubocop -A'
