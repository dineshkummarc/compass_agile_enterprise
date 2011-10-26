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

            def published
              !PublishedElement.where('published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.content_id, 'Content', self.version).first.nil?
            end

            def publisher
              PublishedElement.find_by_published_element_record_type_and_published_element_record_id('Content', self.content_id).published_by_username if published
            end
          end

          render :inline => "{\"totalCount\":#{content.versions.count},data:#{versions.to_json(
          :only => [:id, :version, :title, :body_html, :excerpt_html, :created_at],
          :methods => [:active, :published, :publisher])}}"
        end
  
        def non_published_content_versions
          content   = Content.find(params[:id])
          sort_hash = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort      = sort_hash[:property] || 'version'
          dir       = sort_hash[:direction] || 'DESC'
          limit     = params[:limit] || 15
          start     = params[:start] || 0

          versions = content.versions.order("#{sort} #{dir}").offset(start).limit(limit)

          render :inline => "{\"totalCount\":#{content.versions.count},data:#{versions.to_json(:only => [:id, :version, :title, :body_html, :excerpt_html, :created_at])}}"
        end

        def publish_content
          content = Content.find(Content::Version.find(params[:id]).content_id)
          content.publish(Website.find(params[:site_id]), params[:comment], params[:version], current_user)

          render :json => {:success => true}
        end

        def revert_content
          content = Content.find(Content::Version.find(params[:id]).content_id)
          version = params[:version]
          content.revert_to(version)
          content.save!

          render :to_json => {:success => true}
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

            def published
              !PublishedElement.where('published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', self.website_section_id, 'WebsiteSection', self.version).first.nil?
            end

            def publisher
              PublishedElement.find_by_published_element_record_type_and_published_element_record_id('WebsiteSection', self.website_section_id).published_by_username if published
            end
          end

          render :inline => "{\"totalCount\":#{website_section.versions.count},data:#{versions.to_json(
                            :only => [:id, :version, :title, :created_at],
                            :methods => [:active, :published, :publisher])}}"
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
