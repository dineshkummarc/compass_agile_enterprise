Object.instance_eval do
  def all_subclasses
    klasses = self.subclasses
    (klasses | klasses.collect do |klass| klass.all_subclasses end).flatten.uniq
  end
end