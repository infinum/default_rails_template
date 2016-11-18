git :init

GITIGNORED_FILES = <<-HEREDOC.strip_heredoc
  .sass-cache
  powder
  public/system
  dump.rdb
  logfile
  .DS_Store
  # Ignore application configuration
  config/application*.yml
HEREDOC

append_file '.gitignore', GITIGNORED_FILES
