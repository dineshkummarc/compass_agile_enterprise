class ContentMgtAsset < ActiveRecord::Base

  belongs_to :digital_asset, :polymorphic => true
  
  has_many :entity_content_assignments
  # this doesn't work, find alternate ...
  #has_many :da_assignments, :through => :entity_content_assignments

  delegate :public_filename, :to => :digital_asset, :allow_nil => true


  def to_label
    "#{description}"
  end

  def to_s
    "#{description}"
  end
  
  def after_destroy
        
    if self.digital_asset && !self.digital_asset.frozen?
      self.digital_asset.destroy
    end
      
  end

  def image
    digital_asset.public_filename(:thumb) if digital_asset.is_a?(ImageAsset)
  end
  
  def url
    if digital_asset.is_a?(ImageAsset)
      image 
    else
      ''
    end
  end
  
end
