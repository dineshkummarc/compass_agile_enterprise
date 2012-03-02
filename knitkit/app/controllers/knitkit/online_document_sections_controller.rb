module Knitkit
  class OnlineDocumentSectionsController < BaseController
    layout 'knitkit/online_document_sections'
    
    before_filter :find_root
    before_filter :find_document_sections, :only => :build_tree

    def index
            
    end
    
    def build_tree
      render :inline => build_document_hash.to_json
    end
    
    protected 
    
    def id_or_node
      (params[:node].to_i == 0) ? params[:section_id] : params[:node]
    end
    
    def find_root
      @root = OnlineDocumentSection.find(params[:section_id])
      if @root.documented_item_published_content(@active_publication)
        @root_content = @root.documented_item_published_content(@active_publication).body_html 
      else
        @root_content = ""
      end
    end
    
    def find_document_sections
      @document_sections = OnlineDocumentSection.find(id_or_node).positioned_children
    end
    
    def build_document_hash
      [].tap do |documents|
        @document_sections.each do |section|
          documents <<  {:id => section.id, :title => section.title, 
                        :leaf => section.leaf, :documented_item_published_content_html => section.documented_item_published_content_html(@active_publication)}
        end
      end
    end
    
  end
end