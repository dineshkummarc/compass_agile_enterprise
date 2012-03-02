class Money < ActiveRecord::Base
  
  belongs_to :currency
  before_save :parse_currency_code

  attr_accessor :currency_code

  private 
  
  def parse_currency_code
    unless currency_code.blank?
      case currency_code.downcase
        # Check for all iso currency types we support
        when "usd" then self.currency = Currency.usd
        # add additional currency types
      end
    end
  end
end