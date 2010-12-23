class Money < ActiveRecord::Base
  
  # need to specify class name in this namespaced model to avoid rspec error:
  # ErpServices::Money is not missing constant Currency!
  # see http://pivotallabs.com/users/will/blog/articles/986-standup-8-21-2009-not-missing-constant-and-rake-set-theory-
  belongs_to :currency,  :class_name => "Currency"

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