module ActionView
  class PathResolver
    def query(path, details, formats)
      file_support = ErpTechSvcs::FileSupport::Base.new(:storage => ErpTechSvcs::FileSupport.options[:storage])
      query = build_query(path, details)
      templates = []
      sanitizer = Hash.new { |h,k| h[k] = Dir["#{File.dirname(k)}/*"] }

      get_dir_entries(query, path, file_support).each do |p|
        (next if File.directory?(p[:path]) || !sanitizer[p[:path]].include?(p[:path])) if p[:storage] == :filesystem

        handler, format = extract_handler_and_format(p[:path], formats)
        if p[:storage] == :filesystem
          contents = File.open(p[:path], "rb") { |io| io.read }
        else
          contents, message = file_support.get_contents(p[:path])
        end

        identifier = (p[:storage] == :filesystem) ? File.expand_path(p[:path]) : p[:path]

        templates << Template.new(contents, identifier, handler,
          :virtual_path => path.virtual, :format => format, :updated_at => mtime(p[:path], file_support))
      end

      templates
    end

    def get_dir_entries(query, path, file_support)
      if @path and @path.to_s.scan(Rails.root.to_s).empty?
        full_path = File.join(@path, path)
        node = file_support.find_node(File.dirname(full_path))
        if (node.nil? or node.empty?)
          Dir[query].collect{|p| {:path => p, :storage => :filesystem}}
        else
          files = node[:children].select{|child| child[:leaf]}.collect do |child|
            {:path => child[:id], :storage => ErpTechSvcs::FileSupport.options[:storage]}
          end

          files.select do |p|
            !p[:path].scan(full_path).empty?
          end
        end
      else
        Dir[query].collect{|p| {:path => p, :storage => :filesystem}}
      end
    end
  
    def mtime(p, file_support=nil)
      if File.exists? p
        File.stat(p).mtime
      else
        node = file_support.find_node(p)
        (node.nil? or node.empty?) ? File.stat(p).mtime : node[:last_modified]
      end
    end
    
  end
end