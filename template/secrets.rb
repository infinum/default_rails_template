SECRETS_YML_FILE = <<-HEREDOC.strip_heredoc
  default: &default
    secret_key_base: <%= Figaro.env.secret_key_base! %>
    bugsnag:
      api_key: <%= Figaro.env.bugsnag_api_key! %>

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
