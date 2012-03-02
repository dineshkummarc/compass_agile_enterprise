require 'uuid'

class CreditCardToken
  @cc_token
  
  def initialize
    uuid = UUID.new
    @cc_token =  uuid.generate(:compact).upcase
  end
  
  attr_accessor :cc_token
end