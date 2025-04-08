# Rails Default Template

The [Infinum](infinum.com) default template for generating new Rails applications.

## Requirements

Install the latest ruby version and set it as global

If you installed rbenv through homebrew:
```shell
brew upgrade ruby-build
```

If you installed rbenv with git:
```shell
  cd "$(rbenv root)"/plugins/ruby-build && git pull
```

then run if needed:

```shell
  rbenv install #{latest_ruby}
  rbenv global #{latest_ruby}
```

### GitHub Actions

This template uses GitHub Actions for CI/CD. In order for workflows to work properly some [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) have to be set up.

For build workflow to work, the following secrets must exist (usually set up by DevOps):
- `VAULT_ADDR`
- `VAULT_AUTH_METHOD`
- `VAULT_AUTH_ROLE_ID`
- `VAULT_AUTH_SECRET_ID`

For deploy workflows, you need to generate private/public SSH key pairs for each environment. Public key should be added to the server to which you're deploying. Private key should be added as a secret to GitHub and named `SSH_PRIVATE_KEY_#{ENVIRONMENT}`, where `ENVIRONMENT` is replaced with an appropriate environment name (`STAGING`, `PRODUCTION`, etc.).

### Flipper

This template uses Flipper for feature flag management. There are two ways for Flipper to function: **Cloud** and **Cloudless(Self-hosted)**. Cloudless will work out of the box, but if we want Flipper to be communicating with Flipper cloud there are a couple of secrets that need to be set:

- `FLIPPER_CLOUD_TOKEN` - needed for our App to be able to communicate with Flipper Cloud
- `FLIPPER_CLOUD_SYNC_SECRET` - used if we want Flipper Cloud to send a webhook request to our app telling it to sync with Cloud

Both of these secrets are available inside the Flipper Cloud dashboard, and need to be configured per environment


#### Slack notifications

Build and deploy workflows can send Slack notifications upon completion of workflow runs. To enable this, add the following to the workflow:
- `SLACK_BOT_TOKEN` secret (you should already have this GitHub secret set up in the repo)
- `slack_notification_channel` input with the name of the Slack channel as the value (without the # symbol)

By default, a notification will be sent if the run either succeeded or failed. If you want notifications only on successful runs, add the `notify_on` input to the workflow with the value `success`. Similarily, if you want notifications only for failed runs, the value of the `notify_on` input should be `failure`.

### Frontend

If your application will have a frontend (the template will ask you that), you must have Node installed on your machine. The template creates a `.node-version` file with the Node version set to the version you're currently running (check by executing `node -v`). Therefore, ensure that you have the latest [Active LTS](https://nodejs.org/en/about/releases/) version of Node running on your machine before using the template.

## Usage

```shell
rails new myapp --database=postgresql -T -B -m https://raw.githubusercontent.com/infinum/default_rails_template/master/template.rb
```
The `-T` flag skips minitest files.

The `-B` flag skips the second bundle install.

The `-m` flag tells the generator to run our app [template](https://github.com/infinum/default_rails_template/blob/master/template.rb).

## What does this template do?

- Updates the README.md file
- Creates bin/setup and bin/update scripts
- Creates a `config/environments/staging.rb` file
- Updates the `config/environments/development.rb` file
- Creates a [Bugsnag](https://bugsnag.com) initializer
- Removes gems we never use: `coffee-rails`, `jbuilder`, `tzinfo-data` & `byebug`
- Adds [Bugsnag](https://github.com/bugsnag/bugsnag-ruby) & [Figaro](https://github.com/laserlemon/figaro) to the Gemfile
- Adds [Pry-Rails](https://github.com/rweng/pry-rails) to the Gemfile, inside of the development and test group
- Adds [Rubocop](https://github.com/bbatsov/rubocop), [RSpec-Rubocop](https://github.com/backus/rubocop-rspec) & [Overcommit](https://github.com/brigade/overcommit) to the Gemfile, inside of the development group
- Adds [Rspec-Rails](https://github.com/rspec/rspec-rails) to the Gemfile and initializes it
- Adds [License-Finder](https://github.com/pivotal/LicenseFinder) to the Gemfile and initializes it
- Initializes deploy script with [Mina](https://github.com/mina-deploy/mina)
- Initializes spring binstubs
- Updates the secrets.yml file to use Figaro and have defaults
- Creates a `config/application.yml` file for Figaro
- Creates a `.rubocop.yml` file with our defaults
- Git inits
- Adds more common gitignored files to `.gitignore`
- Adds documentation in `docs` folders

## Filling up the documentation

Here is an example of line inside documentation:
```
* ACCOUNT-NAME (ACCOUNT-ID) <!-- infinum-dev (7021-9251-8610) --> <!-- DEVOPS -->
```
The first comment is an example of how to fill the data on the left

The second comment is who can fill this information. It can be either DEVOPS or DEVELOPER. If you as a DEVELOPER have access to a specific information, you can also fill up DEVOPS lines (for example, if you have access to AWS console, most of the information in server documenation can be filed by a developer).

## Development

There are a couple of helpers you can use when developing:

``` ruby
ask_with_default # Presents a user with a question he can answer. Returns default if user does not enter anything
yes?             # Ask a user yes/no question. Returns true/false
```
