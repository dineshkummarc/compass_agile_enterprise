# add the necessary hook to expose the plugin to
# active records that DONT have a backing table
ActiveRecord::BaseWithoutTable.send(:include,
Eai::Spring::ActsAsSpringEntity)
