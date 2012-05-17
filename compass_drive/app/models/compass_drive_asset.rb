#Attributes
#comment           text
#checked_out       boolean
#last_checkout_at  datetime
#name              string
class CompassDriveAsset < ActiveRecord::Base
  acts_as_versioned :table_name => :compass_drive_versions

  belongs_to :file_asset
  belongs_to :checked_out_by, :class_name => 'User', :foreign_key => 'checked_out_by_id'
  has_one :category_classification, :as => :classification, :dependent => :destroy

  def add_file(data)
    file_asset = FileAsset.create!(:base_path => self.file_path, :data => data)
    self.file_asset = file_asset
    self.save
    file_asset
  end

  def get_version(version)
    self.versions.where('version = ?', version).file_asset
  end

  private

  def file_path
    File.join(self.root_path, self.basename, "#{(self.version)}.#{self.extname}")
  end

  def basename
    self.name.gsub(/\.#{extname}$/, "")
  end

  def extname
    File.extname(self.name).gsub(/^\.+/, '')
  end

  def root_path
    file_support = ErpTechSvcs::FileSupport::Base.new(:storage => Rails.application.config.erp_tech_svcs.file_storage)
    File.join(file_support.root, Rails.application.config.compass_drive.compass_drive_directory)
  end
end

