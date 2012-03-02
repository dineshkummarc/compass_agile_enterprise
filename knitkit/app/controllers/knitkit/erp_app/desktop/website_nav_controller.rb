module Knitkit
  module ErpApp
    module Desktop
      class WebsiteNavController < Knitkit::ErpApp::Desktop::AppController
        def new
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'create', 'Menu') do
              result = {}
              website = Website.find(params[:website_id])
              website_nav = WebsiteNav.new(:name => params[:name])
              website.website_navs << website_nav

              if website_nav.save
                result[:success] = true
                result[:node] = {:text => params[:name],
                  :websiteNavId => website_nav.id,
                  :websiteId => website.id,
                  :iconCls => 'icon-index',
                  :canAddMenuItems => true,
                  :isWebsiteNav => true,
                  :leaf => false,
                  :children => []}
              else
                result[:success] = false
              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit', 'Menu') do
              website_nav = WebsiteNav.find(params[:website_nav_id])
              website_nav.name = params[:name]

              render :json => (website_nav.save ? {:success => true} : {:success => false})
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def delete
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'delete', 'Menu') do
              render :json => (WebsiteNav.destroy(params[:id]) ? {:success => true} : {:success => false})
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def add_menu_item
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'create', 'MenuItem') do
              result = {}
              klass = params[:klass].constantize
              parent = klass.find(params[:id])
              website_nav = parent.is_a?(WebsiteNav) ? parent : parent.website_nav
              website_nav_item = WebsiteNavItem.new(:title => params[:title])

              url = params[:url]
              if(params[:link_to] != 'url')
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
                if parent.is_a?(WebsiteNav)
                  parent.website_nav_items << website_nav_item
                else
                  website_nav_item.move_to_child_of(parent)
                end

                result[:success] = true
                result[:node] = {:text => params[:title],
                  :linkToType => params[:link_to].underscore,
                  :linkedToId => linked_to_id,
                  :websiteId => website_nav.website.id,
                  :url => url,
                  :isSecure => false,
                  :canAddMenuItems => true,
                  :websiteNavItemId => website_nav_item.id,
                  :iconCls => 'icon-document',
                  :isWebsiteNavItem => true,
                  :leaf => false,
                  :children => []}
              else
                result[:success] = false
              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update_menu_item
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit', 'MenuItem') do
              result = {}
              website_nav_item = WebsiteNavItem.find(params[:website_nav_item_id])
              website_nav_item.title = params[:title]

              url = params[:url]
              linked_to_id = nil
              if(params[:link_to] != 'url')
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
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def update_security
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          if current_user.has_capability?(model, 'secure', 'MenuItem') or current_user.has_capability?(model, 'unsecure', 'MenuItem')
            website_nav_item = WebsiteNavItem.find(params[:id])
            website = Website.find(params[:site_id])
            if(params[:secure] == "true")
              website_nav_item.add_role(website.role)
            else
              website_nav_item.remove_role(website.role)
            end

            render :json => {:success => true}
          else
            render :json => {:success => false, :message => "User does not have capability."}
          end
        end

        def delete_menu_item
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'delete', 'MenuItem') do
              render :json => (WebsiteNavItem.destroy(params[:id]) ? {:success => true} : {:success => false})
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

      end#WebsiteNavController
    end#Desktop
  end#ErpApp
end#Knitkit
