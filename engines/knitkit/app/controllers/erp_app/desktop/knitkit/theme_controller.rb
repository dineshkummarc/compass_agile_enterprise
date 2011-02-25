class ErpApp::Desktop::Knitkit::ThemeController < ErpApp::Desktop::FileManager::BaseController
  IGNORED_PARAMS = %w{action controller node_id}

  def index
    if params[:node] == ROOT_NODE
      setup_tree
    else
      expand_file_directory(params[:node], :folders_only => false)
    end
  end

  def new
    site = Site.find(params[:site_id])
    
    theme = Theme.create(:site => site, :name => params[:name])
    params.each do |k,v|
      next if k.to_s == 'name' || k.to_s == 'site_id'
      theme.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end
    theme.save
   
    render :inline => {:success => true}.to_json
  end

  def change_status
    site = Site.find(params[:site_id])

    #clear active themes
    if (params[:active] == 'true')
      site.deactivate_themes!
    end

    theme = Theme.find(params[:id])
    if (params[:active] == 'true')
      theme.activate!
    else
      theme.deactivate!
    end

    render :inline => {:success => true}.to_json
  end
  
  private

  def setup_tree
    tree = []
    sites = Site.all
    sites.each do |site|
      site_hash = {
        :text => site.title,
        :browseable => true,
        :contextMenuDisabled => true,
        :iconCls => 'icon-globe',
        :id => "site_#{site.id}",
        :leaf => false,
        :url => "http://#{site.host}",
        :children => []
      }

      #handle themes
      themes_hash = {:text => 'Themes', :contextMenuDisabled => true, :isThemeRoot => true, :siteId => site.id, :children => []}
      site.themes.each do |theme|
        theme_hash = {:text => theme.name, :handleContextMenu => true, :siteId => site.id, :isActive => (theme.active == 1), :isTheme => true, :id => theme.id, :children => []}
        if theme.active == 1
          theme_hash[:iconCls] = 'icon-add'
        else
          theme_hash[:iconCls] = 'icon-delete'
        end
        ['stylesheets', 'javascripts', 'images', 'templates'].each do |resource_folder|
          theme_hash[:children] << {:text => resource_folder, :leaf => false, :id => "#{theme.path}/#{resource_folder}"}
        end
        themes_hash[:children] << theme_hash
      end
      site_hash[:children] << themes_hash
      tree << site_hash
    end

    render :json => tree.to_json
  end
  
end
