class WebsiteSectionContent < ActiveRecord::Base
  belongs_to :website_section
  belongs_to :content
end
