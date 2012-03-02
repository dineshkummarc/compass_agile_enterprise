require 'optparse'

REMOVE_FILES_REGEX = /^\./
GEM_FILE_REGEX = /.gem$/
options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: push_gems.rb [options]"

  options[:verbose] = false
  opts.on('-v', '--verbose', 'Output more information') do
    options[:verbose] = true
  end

  options[:ruby_gems] = false
  opts.on('-r', '--ruby_gems', 'push to ruby gems') do
    options[:ruby_gems] = true
  end

  options[:geminabox] = true
  opts.on('-b', '--geminabox', 'push to geminabox') do
    options[:geminabox] = true
    options[:ruby_gems] = false
  end
end

optparse.parse!

def push_gem(dir, options)
  puts "In #{dir}" if options[:verbose]
  Dir.chdir(dir)
  gem = Dir.entries('./').find{|entry| entry =~ GEM_FILE_REGEX}
  if options[:ruby_gems]
    result = `gem push #{gem}`
  else options[:geminabox]
    result = `gem inabox #{gem}`
  end
  puts result if options[:verbose]
  Dir.chdir('../')
end

def push_nested_gem(dir, options)
  Dir.chdir(dir)
  sub_dirs = Dir.entries('./').delete_if{|dir| dir =~ REMOVE_FILES_REGEX}
  sub_dirs = sub_dirs.delete_if{|dir| %w(README.md Rakefile).include?(dir)}
  sub_dirs.each do |sub_dir|
    push_gem(sub_dir, options)
  end
  Dir.chdir('../')
end

dirs =  Dir.entries('./').delete_if{|dir| dir =~ REMOVE_FILES_REGEX}
dirs.each do |dir|
  case dir
  when 'Erp-Modules'
    push_nested_gem(dir, options)
  when 'Application-Stack---Suite'
    push_nested_gem(dir, options)
  when 'Compass-AE-Kernel'
    push_nested_gem(dir, options)
  when 'Compass-AE-Console'
    push_gem(dir, options)
  when 'Rails-DB-Admin'
    push_gem(dir, options)
  when 'Knitkit-CMS'
    push_gem(dir, options)
  end
end
