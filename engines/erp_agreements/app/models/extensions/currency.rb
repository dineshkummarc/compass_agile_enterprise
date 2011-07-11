ErpBaseErpSvcs::Currency.class_eval do

  has_many_polymorphs :locales,
    :from => [:"iso_country_codes", :"loyalty_program_codes"],
    :through => :"currencies_locale"
  
end
