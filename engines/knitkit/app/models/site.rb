class Site < ActiveRecord::Base
  has_many :published_sites, :dependent => :destroy

  has_many :sections, :dependent => :destroy, :order => :lft do
    def root
      Section.root(:site_id => proxy_owner.id)
    end

    def roots
      Section.roots(:site_id => proxy_owner.id)
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
  
  has_many :themes, :dependent => :delete_all do
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
    self.published_sites.last.publish_element(comment, element, version)
  end

  def publish(comment)
    self.published_sites.last.publish(comment)
  end

  def set_publication_version(version)
    PublishedSite.activate(self, version)
  end

  def active_publication
    self.published_sites.all.find{|item| item.active}
  end

  def after_create
    PublishedSite.create(:site => self, :version => 0, :active => true, :comment => 'New Site Created')
  end

end
