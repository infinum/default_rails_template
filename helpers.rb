def ask_with_default(question, color, default)
  return default unless $stdin.tty?
  question = "#{question} [#{default}]?"
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def install_spring?
  ask_with_default('Install spring', :green, 'no') =~ /^y(es)?/i
end
