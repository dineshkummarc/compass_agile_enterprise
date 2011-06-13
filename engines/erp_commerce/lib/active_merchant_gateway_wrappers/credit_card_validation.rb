# To change this template, choose Tools | Templates
# and open the template in the editor.

module ActiveMerchantGatewayWrappers::CreditCardValidation
  VISA_PATTERN = /^4[0-9]{12}(?:[0-9]{3})?$/
  MASTER_CARD_PATTERN = /^5[1-5][0-9]{14}$/
  AMEX_PATTERN = /^3[47][0-9]{13}$'/
  DINERS_CLUB_PATTERN = /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/
  DISCOVER_PATTERN = /^6(?:011|5[0-9]{2})[0-9]{12}$/


  def self.get_card_type(number)
    card_type = nil

    if number =~ VISA_PATTERN
      card_type = 'visa'
    elsif number =~ MASTER_CARD_PATTERN
      card_type = 'master'
    elsif number =~ AMEX_PATTERN
      card_type = 'american_express'
    elsif number =~ DINERS_CLUB_PATTERN
      card_type = 'diners_club'
    elsif number =~ DISCOVER_PATTERN
      card_type = 'discover'
    end

    card_type
  end
end
