require 'optparse'

REMOVE_FILES_REGEX = /^\./
options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: build_gems.rb [options]"

  options[:verbose] = false
  opts.on('-v', '--verbose', 'Output more information') do
    options[:verbose] = true
  end
end

optparse.parse!

def build_gem(dir, name, options)
  Dir.chdir(dir)
  if options[:verbose]
    puts '###########################'
    puts "Building gem #{name}"
    result = `gem build #{name}.gemspec`
    puts result if options[:verbose]
    puts '###########################'
  else
    `gem build #{name}.gemspec`
  end
  Dir.chdir('../')
end

def build_nested_gem(dir, options)
  Dir.chdir(dir)
  sub_dirs = Dir.entries('./').delete_if{|dir| dir =~ REMOVE_FILES_REGEX}
  sub_dirs = sub_dirs.delete_if{|dir| %w(README.md Rakefile).include?(dir)}
  sub_dirs.each do |sub_dir|
    build_gem(sub_dir, sub_dir, options)
  end
  Dir.chdir('../')
end

dirs =  Dir.entries('./').delete_if{|dir| dir =~ REMOVE_FILES_REGEX}
dirs.each do |dir|
  case dir
  when 'Erp-Modules'
    build_nested_gem(dir, options)
  when 'Application-Stack---Suite'
    build_nested_gem(dir, options)
  when 'Compass-AE-Kernel'
    build_nested_gem(dir, options)
  when 'Compass-AE-Console'
    build_gem(dir, 'compass_ae_console', options)
  when 'Rails-DB-Admin'
    build_gem(dir, 'rails_db_admin', options)
  when 'Knitkit-CMS'
    build_gem(dir, 'knitkit', options)
  end
end
