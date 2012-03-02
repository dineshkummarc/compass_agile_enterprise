require 'optparse'

REMOVE_FILES_REGEX = /^\./
options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: update_repos.rb [options]"

  options[:verbose] = false
  opts.on('-v', '--verbose', 'Output more information') do
    options[:verbose] = true
  end
end

optparse.parse!

def update_repository(dir, options)
  Dir.chdir(dir)
  puts `git pull`
  Dir.chdir('../')
end

dirs =  Dir.entries('./').delete_if{|dir| dir =~ REMOVE_FILES_REGEX}
dirs.each do |dir|
  case dir
  when 'Erp-Modules'
    update_repository(dir, options)
  when 'Application-Stack---Suite'
    update_repository(dir, options)
  when 'Compass-AE-Kernel'
    update_repository(dir, options)
  when 'Compass-AE-Console'
    update_repository(dir, options)
  when 'Rails-DB-Admin'
    update_repository(dir, options)
  when 'Knitkit-CMS'
    update_repository(dir, options)
  end
end
