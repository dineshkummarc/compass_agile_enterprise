module Knitkit
  module ErpApp
    module Desktop
      class AppController < ::ErpApp::Desktop::BaseController
        KNIT_KIT_ROOT = Knitkit::Engine.root.to_s

        def websites
          websites = Website.all

          tree = []

          websites.each do |website|
            website_hash = {
              :text => website.title,
              :iconCls => 'icon-globe_disconnected',
              :id => "website_#{website.id}",
              :leaf => false,
              :url => "http://#{website.hosts.first.host}",
              :name => website.name,
              :title => website.title,
              :subtitle => website.subtitle,
              :isWebsite => true,
              :email => website.email,
              :siteName => website.title,
              :emailInquiries =>  website.email_inquiries?,
              :autoActivatePublication => website.auto_activate_publication?,
              :children => []
            }

            #handle hosts
            hosts_hash = {:text => 'Hosts', :iconCls => 'icon-gear', :isHostRoot => true, :websiteId => website.id, :leaf => false, :children => []}
            website.hosts.each do |website_host|
              hosts_hash[:children] << {:text => website_host.host, :websiteHostId => website_host.id, :host => website_host.host, :iconCls => 'icon-globe', :url => "http://#{website_host.host}", :isHost => true, :leaf => true, :children => []}
            end

            website_hash[:children] << hosts_hash

            #handle sections
            sections_hash = {:text => 'Sections', :isSectionRoot => true, :websiteId => website.id, :iconCls => 'icon-content', :leaf => false, :children => []}
            website.website_sections.positioned.each do |website_section|
              sections_hash[:children] << build_section_hash(website_section, website)
            end

            website_hash[:children] << sections_hash
      
            #handle menus
            menus_hash = {:text => 'Menus', :iconCls => 'icon-content', :isMenuRoot => true, :websiteId => website.id, :leaf => false, :children => []}
            website.website_navs.each do |website_nav|
              menu_hash = {:text => website_nav.name, :websiteNavId => website_nav.id, :websiteId => website.id, :iconCls => 'icon-index', :canAddMenuItems => true, :isWebsiteNav => true, :leaf => false, :children => []}
              menu_hash[:children] = website_nav.website_nav_items.positioned.map{|item|build_menu_item_hash(website, item)}
              menus_hash[:children] << menu_hash
            end

            website_hash[:children] << menus_hash
      
            #added website to main tree
            tree << website_hash
          end

          render :json => tree
        end

        protected

        def page
          offset = params[:start].to_f
          (offset > 0) ? (offset / params[:limit].to_f).to_i + 1 : 1
        end
  
        def per_page
          params[:limit].nil? ? 20 : params[:limit].to_i
        end
        
        def build_menu_item_hash(website, item)
          url = item.url
          linked_to_item_id = nil
          link_to_type = 'url'
          unless item.linked_to_item.nil?
            linked_to_item_id = item.linked_to_item_id
            link_to_type = item.linked_to_item.class.to_s.underscore
            url = "http://#{website.hosts.first.host}/" + item.linked_to_item.permalink
          end

          menu_item_hash = {
            :text => item.title,
            :linkToType => link_to_type,
            :canAddMenuItems => true,
            :websiteId => website.id,
            :linkedToId => linked_to_item_id, 
            :websiteNavItemId => item.id,
            :url => url,
            :iconCls => 'icon-document',
            :isWebsiteNavItem => true,
            :leaf => false
          }

          menu_item_hash[:children] = item.positioned_children.map{ |child| build_menu_item_hash(website, child)}

          menu_item_hash
        end
  
        def build_section_hash(website_section, website)
          website_section_hash = {
            :text => website_section.title,
            :siteName => website.title,
            :siteId => website.id,
            :type => website_section.type,
            :isSecured => !website_section.roles.empty?,
            :isSection => true,
            :inMenu => website_section.in_menu,
            :hasLayout => !website_section.layout.blank?,
            :id => "section_#{website_section.id}",
            :url => "http://#{website.hosts.first.host}/#{website_section.permalink}"
          }

          if website_section.is_a?(Blog) || website_section.type == 'Blog'
            website_section_hash[:isBlog] = true
            website_section_hash[:iconCls] = 'icon-blog'
            website_section_hash[:leaf] = true
          else
            website_section_hash[:is_leaf] = false
            website_section_hash[:children] = []
            website_section.positioned_children.each do |child|
              website_section_hash[:children] << build_section_hash(child, website)
            end unless website_section.children.empty?
            website_section_hash[:isSecured] ? website_section_hash[:iconCls] = 'icon-document_lock' : website_section_hash[:iconCls] = 'icon-document'
          end

          website_section_hash
        end
      end
    end
  end
end