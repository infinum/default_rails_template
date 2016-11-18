#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path('../lib', File.dirname(__FILE__)))

puts $LOAD_PATH

require 'optparse'
require 'builder'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: build.rb [options]'

  opts.on('-a', '--[no-]annotate', 'Set source file comments') do |a|
    options[:annotate] = a
  end

  opts.on('-s', 'Print template to stdout') do |s|
    options[:stdout] = s
  end
end.parse!

Builder.new(options,
            order: %w(readme staging db_config bugsnag gemfile secrets figaro rubocop git)).run
