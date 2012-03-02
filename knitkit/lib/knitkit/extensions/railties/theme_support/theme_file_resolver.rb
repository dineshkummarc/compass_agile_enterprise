module ActionView
  class ThemeFileResolver < OptimizedFileSystemResolver
    def cached(key, path_info, details, locals) #:nodoc:
      name, prefix, partial = path_info
      locals = sort_locals(locals)

      if key && caching?
        if @cached[key][name][prefix][partial][locals].nil? or @cached[key][name][prefix][partial][locals].empty?
          @cached[key][name][prefix][partial][locals] = decorate(yield, path_info, details, locals)
        else
          @cached[key][name][prefix][partial][locals].each do |template|
            #check if the file still exists
            if File.exists? template.identifier
              last_update = mtime(template.identifier)
              if last_update > template.updated_at
                @cached[key][name][prefix][partial][locals].delete_if{|item| item.identifier == template.identifier}
                @cached[key][name][prefix][partial][locals] << build_template(template.identifier, template.virtual_path, (details[:formats] || [:html] if template.formats.empty?), template.locals)
              end
            else
              @cached[key][name][prefix][partial][locals].delete_if{|item| item.identifier == template.identifier}
            end
          end
          @cached[key][name][prefix][partial][locals]
        end
      else
        fresh = decorate(yield, path_info, details, locals)
        return fresh unless key

        scope = @cached[key][name][prefix][partial]
        cache = scope[locals]
        mtime = cache && cache.map(&:updated_at).max

        if !mtime || fresh.empty?  || fresh.any? { |t| t.updated_at > mtime }
          scope[locals] = fresh
        else
          cache
        end
      end
    end

    protected

    def build_template(p, virtual_path, formats, locals=nil)
      handler, format = extract_handler_and_format(p, formats)
      contents = File.open(p, "rb") { |io| io.read }
      Template.new(contents, p, handler, :virtual_path => virtual_path, :format => format, :updated_at => mtime(p), :locals => locals)
    end
  end
end