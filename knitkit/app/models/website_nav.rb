class WebsiteNav < ActiveRecord::Base
  belongs_to :website
  
  has_many :website_nav_items, :dependent => :destroy do
    def positioned
      order('position desc')
    end
  end

  alias :items :website_nav_items
end
