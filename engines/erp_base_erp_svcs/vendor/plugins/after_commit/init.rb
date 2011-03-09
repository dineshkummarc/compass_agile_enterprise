Object.subclasses_of(ActiveRecord::ConnectionAdapters::AbstractAdapter).each do |klass|
  klass.send(:include, AfterCommit::ConnectionAdapters)
end

config.to_prepare do
  ActiveRecord::Base.send(:include, AfterCommit::ActiveRecord)
end
