class Site < ActiveRecord::Base
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

end
