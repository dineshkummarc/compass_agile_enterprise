ActionView::Template.class_eval do
  
  def source
    file_name = filename
    if file_name.to_s.scan(Rails.root).empty?
      file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
      node = file_support.build_tree(file_name)
      (node.nil? or node.empty?) ? File.read(file_name) : file_support.get_contents(file_name).to_s
    else
      File.read(file_name)
    end
  end

  def filename
    # no load_path means this is an "absolute pathed" template
    load_path ? File.join(load_path, template_path) : template_path
  end

end

ActionView::ReloadableTemplate.class_eval do
  def mtime
    file_name = filename
    if file_name.to_s.scan(Rails.root).empty?
      file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
      node = file_support.build_tree(file_name)
      (node.nil? or node.empty?) ? File.mtime(file_name) : node[:last_modified]
    else
      File.mtime(file_name)
    end
  end
end

ActionView::ReloadableTemplate::ReloadablePath.class_eval do
  private

  def register_template_from_file(template_full_file_path)
    if template_full_file_path.to_s.scan(Rails.root).empty?
      if !@paths[relative_path = relative_path_for_template_file(template_full_file_path)]
        register_template(ActionView::ReloadableTemplate.new(relative_path, self))
      end
    else
      if !@paths[relative_path = relative_path_for_template_file(template_full_file_path)] && File.file?(template_full_file_path)
        register_template(ActionView::ReloadableTemplate.new(relative_path, self))
      end
    end
  end

  # get all the template filenames from the dir
  def template_files_from_dir(dir)
    if dir.to_s.scan(Rails.root).empty?
      file_support = TechServices::FileSupport::Base.new(:storage => TechServices::FileSupport.options[:storage])
      node = file_support.build_tree(dir)
      (node.nil? or node.empty?) ? Dir.glob(File.join(dir, '*')) : node[:children].select{|child| child[:leaf]}.collect{|child| child[:id]}
    else
      Dir.glob(File.join(dir, '*'))
    end
  end

end
