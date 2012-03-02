module Knitkit
  module ErpApp
    module Desktop
      class OnlineDocumentSectionsController < Knitkit::ErpApp::Desktop::AppController
        
        def new
          website = Website.find(params[:website_id])
          online_document_section = OnlineDocumentSection.new(:website_id => website.id, :in_menu => params[:in_menu] == 'yes', :title => params[:title],
                                                              :internal_identifier => params[:internal_identifier])
           
          if online_document_section.save
            if params[:website_section_id]
              parent_website_section = WebsiteSection.find(params[:website_section_id])
              online_document_section.move_to_child_of(parent_website_section)
            end 
            online_document_section.update_path!
            if params[:documenttype] == "Content"
              documented_content = DocumentedContent.create(:title => online_document_section.title, :created_by => current_user, :body_html => online_document_section.title)
              DocumentedItem.create(:documented_content_id => documented_content.id, :online_document_section_id => online_document_section.id)
            end
            
            result = {:success => true, :node => build_section_hash(online_document_section, online_document_section.website),
                      :documented_content => documented_content.content_hash}
          else
            message = "<ul>"
            online_document_section.errors.collect do |e, m|
              message << "<li>#{e} #{m}</li>"
            end
            message << "</ul>"
            result = {:success => false, :message => message}
          end

          render :json => result
        end     
      end
    end
  end
end