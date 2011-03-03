class SectionContent < ActiveRecord::Base
  belongs_to :section
  belongs_to :content
end
