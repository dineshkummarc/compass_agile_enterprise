class WebsitePartyRole < ActiveRecord::Base
  belongs_to :party
  belongs_to :website
  belongs_to :role_type
end
