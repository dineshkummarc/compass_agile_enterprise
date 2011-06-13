class LoyaltyProgramCode < ActiveRecord::Base
    # Extend this class to define specific loyalty program code functionality
    has_many :currencies, :through => :locales
  
end
