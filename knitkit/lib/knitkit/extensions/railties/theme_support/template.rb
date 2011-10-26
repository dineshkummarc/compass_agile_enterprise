ActionView::PathResolver.class_eval do
  # def find_templates(name, prefix, partial, details)
  #     path = Path.build(name, prefix, partial)
  #     query(path, details, details[:formats])
  #   end
  #   
  #   def query(path, details, formats)
  #     query = build_query(path, details)
  #     templates = []
  #     sanitizer = Hash.new { |h,k| h[k] = Dir["#{File.dirname(k)}/*"] }
  # 
  #     Dir[query].each do |p|
  #       next if File.directory?(p) || !sanitizer[p].include?(p)
  # 
  #       handler, format = extract_handler_and_format(p, formats)
  #       contents = File.open(p, "rb") { |io| io.read }
  # 
  #       templates << Template.new(contents, File.expand_path(p), handler,
  #         :virtual_path => path.virtual, :format => format, :updated_at => mtime(p))
  #     end
  # 
  #     templates
  #   end
  
  # def mtime(p)
  #     file_name = filename
  #     if file_name.to_s.scan(Rails.root).empty?
  #       file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
  #       node = file_support.build_tree(file_name)
  #       (node.nil? or node.empty?) ? File.stat(p).mtime : node[:last_modified]
  #     else
  #       File.stat(p).mtime
  #     end
  #   end
end