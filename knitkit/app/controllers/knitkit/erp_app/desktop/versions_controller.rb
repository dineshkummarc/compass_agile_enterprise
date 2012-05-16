module Knitkit
  module ErpApp
    module Desktop
      class VersionsController < Knitkit::ErpApp::Desktop::AppController
        #content

        def content_versions
          content   = Content.find(params[:id])
          website   = Website.find(params[:site_id])
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort      = sort_hash[:property] || 'version'
          dir       = sort_hash[:direction] || 'DESC'
          limit     = params[:limit] || 15
          start     = params[:start] || 0

          versions = content.versions.order("#{sort} #{dir}").offset(start).limit(limit)

          Content::Version.class_exec(website) do
            cattr_accessor :website
            self.website = website
            def active
              published_site_id = self.website.active_publication.id
              !PublishedElement.includes([:published_website]).where('published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', published_site_id, self.content_id, 'Content', self.version).first.nil?
            end

            def published_element
              PublishedElement.where('published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.content_id, 'Content', self.version).first
            end

            def published
              !published_element.nil?
            end

            def publisher
              published_element.published_by_username if published
            end

          end

          render :json => {:totalCount => content.versions.count,
            :data => versions.collect{|version|version.to_hash(
                :only => [:id, :content_id, :version, :title, :body_html, :excerpt_html, :updated_at],
                :methods => [:active, :published, :publisher])}
          }
        end
  
        def non_published_content_versions
          content   = Content.find(params[:id])
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort      = sort_hash[:property] || 'version'
          dir       = sort_hash[:direction] || 'DESC'
          limit     = params[:limit] || 15
          start     = params[:start] || 0

          versions = content.versions.order("#{sort} #{dir}").offset(start).limit(limit)

          render :json => {:totalCount => content.versions.count,
            :data => versions.collect{|version|version.to_hash(
                :only => [:id, :version, :title, :body_html, :excerpt_html, :updated_at])}
          }
        end

        def publish_content
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'publish', 'Article') do
              content = Content.find(Content::Version.find(params[:id]).content_id)
              content.publish(Website.find(params[:site_id]), params[:comment], params[:version], current_user)

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        def revert_content
          model = DesktopApplication.find_by_internal_identifier('knitkit')
          begin
            current_user.with_capability(model, 'revert_version', 'Article') do
              content = Content.find(Content::Version.find(params[:id]).content_id)
              version = params[:version]
              content.revert_to(version)
              content.save!

              render :json => {:success => true}
            end
          rescue ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::UserDoesNotHaveCapability=>ex
            render :json => {:success => false, :message => ex.message}
          end
        end

        #website section layouts

        def website_section_layout_versions
          website_section = WebsiteSection.find(params[:id])
          website = Website.find(params[:site_id])
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort = sort_hash[:property] || 'version'
          dir  = sort_hash[:direction] || 'DESC'
          limit = params[:limit] || 15
          start = params[:start] || 0

          versions = website_section.versions.order("#{sort} #{dir}").offset(start).limit(limit)

          WebsiteSection::Version.class_exec(website) do
            cattr_accessor :website
            self.website = website
            def active
              published_site_id = self.website.active_publication.id
              !PublishedElement.includes([:published_website]).where('published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', published_site_id, self.website_section_id, 'WebsiteSection', self.version).first.nil?
            end

            def published_element
              PublishedElement.where('published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.website_section_id, 'WebsiteSection', self.version).first
            end

            def published
              !published_element.nil?
            end

            def publisher
              published_element.published_by_username if published
            end
          end

          render :json => {:totalCount => website_section.versions.count,
            :data => versions.collect{|version|version.to_hash(
                :only => [:id, :version, :title, :updated_at],
                :methods => [:active, :published, :publisher])}
          }
        end

        def get_website_section_version
          render :text => WebsiteSection::Version.find(params[:id]).layout
        end

        def publish_website_section
          website_section = WebsiteSection.find(WebsiteSection::Version.find(params[:id]).website_section_id)
          website_section.publish(Website.find(params[:site_id]), params[:comment], params[:version], current_user)

          render :json => {:success => true}
        end

        def revert_website_section
          website_section = WebsiteSection.find(WebsiteSection::Version.find(params[:id]).website_section_id)
          version = params[:version]
          website_section.revert_to(version)
          website_section.save!

          render :text => {:success => true, :body_html => website_section.layout}.to_json
        end
        
      end#VersionsController
    end#Desktop
  end#ErpApp
end#Knitkit
