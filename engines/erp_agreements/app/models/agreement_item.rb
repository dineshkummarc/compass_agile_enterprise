class AgreementItem < ActiveRecord::Base

	belongs_to 	:agreement
	belongs_to	:agreement_item_type

end
