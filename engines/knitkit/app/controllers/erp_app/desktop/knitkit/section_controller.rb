class ErpApp::Desktop::Knitkit::SectionController < ErpApp::Desktop::Knitkit::BaseController
  IGNORED_PARAMS = %w{action controller node_id}

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

  def add_template
    section_id    = params[:section_id]
    template_name = params[:name]
    
    section = Section.find(section_id)
    section.template = template_name
    section.save

    result = section.create_template(template_name)

    unless result.is_a?(TrueClass)
      render :inline => {:success => false, :message => result}.to_json
    else
      render :inline => {:success => true, :path => File.join(KNIT_KIT_ROOT,"app/views/sections/#{template_name}.html.erb").to_s}.to_json
    end
  end

  def get_template
    section_id = params[:section_id]
    section = Section.find(section_id)

    contents = ''
    contents = IO.read(section.template_path)
    render :text => contents
  end
  
end
