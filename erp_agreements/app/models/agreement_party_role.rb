class AgreementPartyRole < ActiveRecord::Base
  belongs_to  :agreement
  belongs_to  :party
  belongs_to  :role_type

end
