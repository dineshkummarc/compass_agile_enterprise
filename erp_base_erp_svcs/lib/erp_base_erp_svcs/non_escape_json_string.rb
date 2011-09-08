class NonEscapeJsonString
  def initialize(value) @value = value end
  def as_json(options = nil) self end 
  def encode_json(encoder) @value end
end