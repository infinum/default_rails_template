require 'net/http'

RUBOCOP_CONFIG_URL = 'https://raw.githubusercontent.com/infinum/default_rails_template/master/.rubocop.yml'.freeze
create_file '.rubocop.yml', Net::HTTP.get(URI(RUBOCOP_CONFIG_URL))
