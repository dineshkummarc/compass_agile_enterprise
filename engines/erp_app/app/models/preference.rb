class Preference < ActiveRecord::Base
  belongs_to :preference_type
  belongs_to :preference_option

end
