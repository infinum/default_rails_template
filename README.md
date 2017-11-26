# Rails Default Template

The [Infinum](infinum.co) default template for generating new Rails applications.

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
- Initializes deploy script with [Mina](https://github.com/mina-deploy/mina)
- Initializes spring binstubs
- Updates the secrets.yml file to use Figaro and have defaults
- Creates a `config/application.yml` file for Figaro
- Creates a `.rubocop.yml` file with our defaults
- Git inits
- Adds more common gitignored files to `.gitignore`

## Recommendations

After running the template generator, this script will install overcommit which won't let you commit your project if it has some Rubocop offenses or if your Gemfile isn't alphabetically sorted. To sort your Gemfile, use the [Eefgilm](https://github.com/enilsen16/Eefgilm) gem. Install it with `gem install eefgilm` and run the `eefgilm` command to sort your Gemfile.
