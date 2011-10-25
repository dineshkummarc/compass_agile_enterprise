#This is used to run rspec tests automatically whenever
#a file is saved
def run_spec(file)
  unless File.exist?(file)
    puts "#{file} does not exist"
    return
  end

  puts "Running #{file}"
  system "bundle exec rspec #{file}"
  puts
end

#if a spec test in lib is changed, run it.
#may not be needed anymore...
watch("^spec/lib/.*/*_spec.rb") do |match|
  puts match[0]
  run_spec match[0]
end

#if a test is changed, then run the test
watch("^spec/.*/*_spec.rb") do |match|
  run_spec match[0]
end

#Anything that's changed in [compass_engine]/app
#should try and run a matching rspec test
watch("app/(.*/.*).rb") do |match|
  run_spec %{spec/#{match[1]}_spec.rb}
end

#changing an app file in libs should kick
#off rspec as well...
watch("^lib/(.*/.*).rb") do |match|
  run_spec %{spec/lib/#{match[1]}_spec.rb}
end
