#!/usr/bin/env ruby
require 'json'
require 'optparse'

options = {interactive: false}
op = OptionParser.new do |opts|
  opts.banner = "Usage: parse_json.rb [options] 'data'"
  opts.on("-c 'ruby code'", "--code 'ruby'", "code to be executed ; json is in @data variable") do |c|
    options[:code] = c
  end
  opts.on("-i", "--[no-]interactive", "Run with interactive console") do |v|
    if v
      begin
        require 'pry'
        options[:interactive] = true
      rescue LoadError
        STDERR.puts "Couldn't load the pry gem ; can not run in interactive mode"
      end
    end
  end
end

begin op.parse! ARGV
rescue OptionParser::ParseError => e
  puts e
  puts op
  exit 1
end

@raw = ARGV.empty? ? ARGF.read : File.read(ARGV.shift)
@data = JSON.parse(@raw)
ta = JSON.parse(@raw)

if options[:code]
  eval(options[:code])
elsif options[:interactive]
  #ARGF pry issue : http://stackoverflow.com/questions/32333962/pry-not-stopping-when-called-from-a-ruby-script-that-reads-from-stdin
  pry_fd_stdin = IO.sysopen("/dev/tty")
  pry_stdin = IO.new(pry_fd_stdin, "r")
  Pry.config.input = pry_stdin
  Pry.output.puts "
  The JSON hash is available in @data
  The input string in @raw"
#  binding.pry
  Pry.start
else
  puts @raw
end
