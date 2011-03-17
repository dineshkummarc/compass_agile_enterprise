class Website < ActiveRecord::Base
  validates_uniqueness_of :name, :host

  has_many :published_websites, :dependent => :destroy
  has_many :website_inquiries, :dependent => :destroy

  has_many :website_sections, :dependent => :destroy, :order => :lft do
    def root
      WebsiteSection.root(:website_id => proxy_owner.id)
    end

    def roots
      WebsiteSection.roots(:website_id => proxy_owner.id)
    end

    def paths
      map(&:path)
    end

    def permalinks
      map(&:permalink)
    end
    
    # FIXME can this be on the nested_set?
    def update_paths!
      paths = Hash[*roots.map { |r|
        r.self_and_descendants.map { |n| [n.id, { 'path' => n.send(:build_path) }] } }.flatten]
      update paths.keys, paths.values
    end
  end
  
  has_many :themes, :dependent => :destroy do
    def active
      find(:all,:conditions => 'active = 1')
    end
  end

  def deactivate_themes!
    themes.each do |theme|
      theme.deactivate!
    end
  end

  def publish_element(comment, element, version)
    self.published_websites.last.publish_element(comment, element, version)
  end

  def publish(comment)
    self.published_websites.last.publish(comment)
  end

  def set_publication_version(version)
    PublishedWebsite.activate(self, version)
  end

  def active_publication
    self.published_websites.all.find{|item| item.active}
  end

  def role
    Role.iid(website_role_iid)
  end

  def after_create
    PublishedWebsite.create(:website => self, :version => 0, :active => true, :comment => 'New Site Created')
    Role.create(:description => "Website #{self.title}", :internal_identifier => website_role_iid)
  end

  private
  
  def website_role_iid
    "website_#{self.name.underscore}_access"
  end

end
