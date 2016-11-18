STAGING_DB_CONFIG = <<-HEREDOC.strip_heredoc
  staging:
    <<: *default
    database: <%= @app_name %>_staging
HEREDOC

append_to_file 'config/database.yml', STAGING_DB_CONFIG, after: "database: #{@app_name}_test\n\n"
