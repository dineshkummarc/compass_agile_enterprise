
DynamicAttributes.module_eval do
  # Overrides the initializer to take dynamic attributes into account
  def initialize(attributes = nil, options = {})
    dynamic_attributes = {}
    (attributes ||= {}).each{|att,value| dynamic_attributes[att] = value if att.to_s.starts_with?(self.dynamic_attribute_prefix) }
    super(attributes.except(*dynamic_attributes.keys), options)
    set_dynamic_attributes(dynamic_attributes)
  end
end