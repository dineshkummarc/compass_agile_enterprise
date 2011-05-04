class WebsiteNav < ActiveRecord::Base
  belongs_to :website
  
  has_many :website_nav_items, :dependent => :destroy do
    def positioned
      find(:all, :order => 'position')
    end
  end

  alias :items :website_nav_items
end
