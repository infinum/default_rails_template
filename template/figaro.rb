FIGARO_FILE = <<-HEREDOC.strip_heredoc
  bugsnag_api_key: ''

  development:
    secret_key_base: #{SecureRandom.hex(64)}
  test:
    secret_key_base: #{SecureRandom.hex(64)}
HEREDOC

create_file 'config/application.yml', FIGARO_FILE
