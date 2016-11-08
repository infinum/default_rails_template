# Rails Default Template

The [Infinum](infinum.co) default template for generating new Rails applications.

```shell
rails new myapp --database=postgresql -T -m https://raw.githubusercontent.com/infinum/default_rails_template/master/template.rb
```
The `-T` flag skips minitest files.

The `-m` flag tells the generator to run our app [template](https://github.com/infinum/default_rails_template/blob/master/template.rb).

## What does this template do?

- Updates the README.md file
- Creates a `config/environments/staging.rb` file
- Creates a [Bugsnag](https://bugsnag.com) initializer
- Removes gems we never use: `coffee-rails`, `jbuilder` & `tzinfo-data`
- Adds [Bugsnag](https://github.com/bugsnag/bugsnag-ruby) & [Figaro](https://github.com/laserlemon/figaro) to the Gemfile
- Adds [Pry-Rails](https://github.com/rweng/pry-rails) to the Gemfile, inside of the development and test group
- Adds [Rubocop](https://github.com/bbatsov/rubocop) & [Overcommit](https://github.com/brigade/overcommit) to the Gemfile, inside of the development group
- Updates the secrets.yml file to use Figaro and have defaults
- Creates a `config/application.yml` file for Figaro
- Creates a `.rubocop.yml` file with our defaults
- Git inits
- Adds more common gitignored files to `.gitignore`
