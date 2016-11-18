BUGSNAG_CONFIG = <<-HEREDOC.strip_heredoc
  Bugsnag.configure do |config|
    config.api_key = Rails.application.secrets.bugsnag['api_key']
    config.notify_release_stages = %w(production staging)
  end
HEREDOC

create_file 'config/initializers/bugsnag.rb', BUGSNAG_CONFIG
