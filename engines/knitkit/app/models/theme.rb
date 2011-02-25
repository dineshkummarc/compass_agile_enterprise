require_dependency 'theme/file'

class Theme < ActiveRecord::Base
  cattr_accessor :root_dir
  @@root_dir = "#{RAILS_ROOT}/vendor/plugins/knitkit/public"

  cattr_accessor :default_preview
  @@default_preview = "#{::File.dirname(__FILE__)}/../../public/preview.png"
  
  THEME_STRUCTURE = ['stylesheets', 'javascripts', 'images', 'templates']
  
  class << self
    def base_dir(site)
      "#{root_dir}/sites/site-#{site.id}/themes"
    end
  end
  
  belongs_to :site
  has_many :files, :order => "directory ASC, name ASC", :class_name => 'Theme::File', :dependent => :delete_all
  has_many :templates, :order => "directory ASC, name ASC"
  has_many :images, :order => "directory ASC, name ASC"
  has_many :javascripts, :order => "directory ASC, name ASC"
  has_many :stylesheets, :order => "directory ASC, name ASC"
  has_one  :preview

  has_permalink :name, :theme_id, :scope => :site_id,
                       :only_when_blank => false, :sync_url => true

  validates_presence_of :name
  
  after_create  :create_theme_dir
  after_destroy :delete_theme_dir
  
  def path
    "#{self.class.base_dir(site)}/#{theme_id}"
  end

  def url
    "sites/site-#{site.id}/themes/#{theme_id}"
  end
  
  def activate!
    update_attributes! :active => true
  end

  def deactivate!
    update_attributes! :active => false
  end
  
  protected

    def create_theme_dir
      FileUtils.mkdir_p(path)
    end

    def delete_theme_dir
      FileUtils.rm_rf(path)
    end
end
