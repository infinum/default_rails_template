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
