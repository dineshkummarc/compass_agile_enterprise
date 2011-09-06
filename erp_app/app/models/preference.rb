class Preference < ActiveRecord::Base
  belongs_to :preference_type, :dependent => :destroy
  belongs_to :preference_option, :dependent => :destroy

end
