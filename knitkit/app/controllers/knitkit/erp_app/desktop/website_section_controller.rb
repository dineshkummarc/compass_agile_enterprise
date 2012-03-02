module Knitkit
  module ErpApp
    module Desktop
      class WebsiteSectionController < Knitkit::ErpApp::Desktop::AppController
        before_filter :set_website_section, :only => [:detach_article, :update, :update_security, :add_layout, :get_layout, :save_layout]

        def new
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'create', 'Section') do
              website = Website.find(params[:website_id])
              website_section = nil

              if params[:title].to_s.downcase == 'blog' && params[:type] == 'Blog'
                result = {:success => false, :message => 'Blog can not be the title of a Blog'}
              else
                website_section = WebsiteSection.new
                website_section.website_id = website.id
                website_section.in_menu = params[:in_menu] == 'yes'
                website_section.title = params[:title]
                website_section.render_base_layout = params[:render_with_base_layout] == 'yes'
                website_section.type = params[:type] unless params[:type] == 'Page'
                website_section.internal_identifier = params[:internal_identifier]

                if website_section.save
                  if params[:website_section_id]
                    parent_website_section = WebsiteSection.find(params[:website_section_id])
                    website_section.move_to_child_of(parent_website_section)
                  end
                  
                  if params[:type] == "OnlineDocumentSection"
                    documented_content = DocumentedContent.create(:title => website_section.title, :created_by => current_user, :body_html => website_section.title)
                    DocumentedItem.create(:documented_content_id => documented_content.id, :online_document_section_id => website_section.id)
                  end
                  
                  website_section.update_path!
                  result = {:success => true, :node => build_section_hash(website_section, website_section.website)}
                else
                  message = "<ul>"
                  website_section.errors.collect do |e, m|
                    message << "<li>#{e} #{m}</li>"
                  end
                  message << "</ul>"
                  result = {:success => false, :message => message}
                end

              end

              render :json => result
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def delete
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'delete', 'Section') do
              render :json => WebsiteSection.destroy(params[:id]) ? {:success => true} : {:success => false}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def detach_article
          success = WebsiteSectionContent.where(:website_section_id => @website_section.id, :content_id => params[:article_id]).first.destroy
          render :json => success ? {:success => true} : {:success => false}
        end

        def update_security
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          if current_user.has_capability?(model, 'secure', 'Section') or current_user.has_capability?(model, 'unsecure', 'Section')
            website = Website.find(params[:site_id])
            if(params[:secure] == "true")
              @website_section.add_role(website.role)
            else
              @website_section.remove_role(website.role)
            end

            render :json => {:success => true}
          else
            render :json => {:success => false, :message => "User does not have capability."}
          end
        end

        def update
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit', 'Section') do
              @website_section.in_menu = params[:in_menu] == 'yes'
              @website_section.title = params[:title]
              @website_section.render_base_layout = params[:render_with_base_layout] == 'yes'
              @website_section.internal_identifier = params[:internal_identifier]

              if @website_section.save
                render :json => {:success => true}
              else
                render :json => {:success => false}
              end
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def add_layout
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'create', 'Layout') do
              @website_section.create_layout
              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def get_layout
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit', 'Layout') do
              render :text => @website_section.layout
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end
  
        def save_layout
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'edit', 'Layout') do
		      result = Knitkit::SyntaxValidator.validate_content(:erb, params[:content])

              unless result
                @website_section.layout = params[:content]
                render :json => @website_section.save ? {:success => true} : {:success => false}
              else
                render :json => {:success => false, :message => result}
              end
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def available_articles
          current_articles = Article.joins("INNER JOIN website_section_contents ON website_section_contents.content_id = contents.id").where("website_section_id = #{params[:section_id]}").all
          available_articles = Article.order('LOWER(internal_identifier) ASC').all - current_articles

          render :inline => "{\"articles\":#{available_articles.to_json(:only => [:internal_identifier, :id])}}"
        end
  
        def existing_sections
          website = Website.find(params[:website_id])
          WebsiteSection.class_eval do
            def title_permalink
              "#{self.title} - #{self.path}"
            end
          end
          render :inline => website.sections.to_json(:only => [:id], :methods => [:title_permalink])
        end
  
        protected
  
        def set_website_section
          @website_section = WebsiteSection.find(params[:id])
        end
  
      end#WebsiteSectionController
    end#Desktop
  end#ErpApp
end#Knitkit
