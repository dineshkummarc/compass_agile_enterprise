Module.class_eval do
  alias_method :const_missing, :const_missing_not_from_s3_library
end