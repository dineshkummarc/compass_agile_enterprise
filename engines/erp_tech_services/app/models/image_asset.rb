class ImageAsset < ActiveRecord::Base

  acts_as_content_mgt_asset

  has_one :content_mgt_asset, :as => :digital_asset

	has_attachment :content_type => :image, 
	               :storage => :file_system, 
	               :max_size => 500.kilobytes,
	               :resize_to => '320x200>',
	               :thumbnails => { :thumb => '50x50>' }
	
	validates_as_attachment

	def size
		self.file_size
	end
	
	def size=(bytes)
		self.file_size = bytes
	end

  def to_label
    "#{description}"
  end
  
  def url
    public_filename(:thumb)
  end
  
end
