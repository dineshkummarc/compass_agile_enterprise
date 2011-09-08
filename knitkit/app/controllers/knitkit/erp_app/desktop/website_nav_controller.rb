module Knitkit
  module ErpApp
    module Desktop
class WebsiteNavController < Knitkit::ErpApp::Desktop::AppController
  def new
    result = {}
    website = Website.find(params[:website_id])
    website_nav = WebsiteNav.new(:name => params[:name])

    if website_nav.save
      website.website_navs << website_nav
      result[:success] = true
      result[:node] = {:text => params[:name], :websiteNavId => website_nav.id, :websiteId => website.id, :iconCls => 'icon-index', :isWebsiteNav => true, :leaf => false, :children => []}
    else
      result[:success] = false
    end

    render :json=> result
  end

  def update
    result = {}
    website_nav = WebsiteNav.find(params[:website_nav_id])
    website_nav.name = params[:name]
	
    render :json => website_nav.save ? {:success => true} : {:success => false}
  end

  def delete
    render :json => WebsiteNav.find(params[:id]).destroy ? {:success => true} : {:success => false}
  end

  def add_menu_item
    result = {}
    website_nav = WebsiteNav.find(params[:website_nav_id])
    website_nav_item = WebsiteNavItem.new(:title => params[:title])

    url = params[:url]
    if(params[:link_to] != 'Url')
      #user wants to see Section so this is needed
      params[:link_to] = 'WebsiteSection' if params[:link_to] == 'website_section'

      #get link to item can be Article or Section
      linked_to_id = params["#{params[:link_to].underscore}_id".to_sym]
      link_to_item = params[:link_to].constantize.find(linked_to_id)
      #setup link
      website_nav_item.url = '/' + link_to_item.permalink
      website_nav_item.linked_to_item = link_to_item
      url = "http://#{website_nav.website.hosts.first.host}/" + link_to_item.permalink
    else
      website_nav_item.url = url
    end
  
    if website_nav_item.save
      website_nav.website_nav_items << website_nav_item
      result[:success] = true
      result[:node] = {:text => params[:title], :linkToType => params[:link_to].underscore, :linkedToId => linked_to_id, :websiteId => website_nav.website.id, :url => url, :websiteNavItemId => website_nav_item.id, :iconCls => 'icon-document', :isWebsiteNavItem => true, :leaf => true, :children => []}
    else
      result[:success] = false
    end

    render :json => result
  end

  def update_menu_item
    result = {}
    website_nav_item = WebsiteNavItem.find(params[:website_nav_item_id])
    website_nav_item.title = params[:title]

    url = params[:url]
    linked_to_id = nil
    if(params[:link_to] != 'Url')
      #user wants to see Section so this is needed
      params[:link_to] = 'WebsiteSection' if params[:link_to] == 'website_section'

      #get link to item can be Article or Section
      linked_to_id = params["#{params[:link_to].underscore}_id".to_sym]
      link_to_item = params[:link_to].constantize.find(linked_to_id)
      #setup link
      website_nav_item.url = '/' + link_to_item.permalink
      website_nav_item.linked_to_item = link_to_item
      url = "http://#{website_nav_item.website_nav.website.hosts.first.host}/" + link_to_item.permalink
    else
      website_nav_item.url = url
    end

    if website_nav_item.save
      result[:success] = true
      result[:title] = params[:title]
      result[:linkedToId] = linked_to_id
      result[:linkToType] = params[:link_to].underscore
      result[:url] = url
    else
      result[:success] = false
    end

    render :json => result
  end

  def delete_menu_item
    render :json => WebsiteNavItem.find(params[:id]).destroy ? {:success => true} : {:success => false}
  end

end
end
end
end
