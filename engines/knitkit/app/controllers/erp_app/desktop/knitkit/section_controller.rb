class ErpApp::Desktop::Knitkit::SectionController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller node_id}

  before_filter :set_section, :only => [:add_layout, :get_layout, :save_layout]

  def new
    section = Section.new
    params.each do |k,v|
      next if k == 'type' && v == 'Page'
      section.send(k + '=', v) unless IGNORED_PARAMS.include?(k.to_s)
    end
    section.save

    node_id = params[:node_id]
    type = node_id.split('_')[0]
    id   = node_id.split('_')[1]

    if type == 'section'
      parent = Section.find(id)
      section.move_to_child_of(parent)
    else
      website = Site.find(id)
      website.sections << section
      website.save
    end

    render :inline => {:success => true}.to_json
  end

  def add_layout
    @section.create_layout
    render :inline => {:success => true}.to_json
  end

  def get_layout
    render :text => @section.layout
  end
  
  def save_layout
    @section.layout = params[:content]
    
    if @section.save
      render :inline => {:success => true}.to_json
    else
      render :inline => {:success => false}.to_json
    end
  end
  
  protected
  
  def set_section
    @section = Section.find(params[:section_id])
  end
  
end
