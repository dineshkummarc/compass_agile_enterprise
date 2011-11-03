class Currency < ActiveRecord::Base

#  refactor for has_many_polymorphic. Not used at the moment
#
#  has_many_polymorphs :locales,
#    :from => [:"iso_country_codes", :"loyalty_program_codes"],
#    :through => :"currencies_locale"
  
end
