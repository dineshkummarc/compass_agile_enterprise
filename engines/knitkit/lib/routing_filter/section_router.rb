# If the path is, aside from a slash and an optional locale, the leftmost part
# of the path, replace it by "sections/:id" segments.

module RoutingFilter
  class SectionRouter < Filter

    def around_recognize(path, env, &block)
      website = Website.find_by_host(env[:host_with_port])
      unless website.nil?
        paths = paths_for_website(website)
        if paths.include?(path)
          if website_section = website_section_by_path(website, path)
            type = website_section.type.pluralize.downcase
            path.sub!(path.to_s, "/#{type}/#{website_section.id}")
          end
        end
      end
      yield
    end
    
    def around_generate(*args, &block)      
      returning yield do |result|
        result = result.first if result.is_a?(Array)
        if result !~ %r(^/([\w]{2,4}/)?admin) and result =~ generate_pattern
          website_section = WebsiteSection.find $2.to_i
          result.sub! "#{$1}/#{$2}", "#{website_section.permalink}#{$3}"
        end
      end
    end
    
    protected
    def paths_for_website(website)
      website ? website.website_sections.paths : []
    end

    def website_section_by_path(website, path)
      valid_section = website.website_sections.detect{|website_section| website_section.path == path }
      if valid_section.nil?
        website.website_sections.each do |website_section|
          valid_section = website_section.child_by_path(path)
          break unless valid_section.nil?
        end
      end

      valid_section
    end

    def generate_pattern
      types = WebsiteSection.types.map{|type| type.downcase.pluralize }.join('|')
      %r((#{types})/([\w]+(/?))(\.?)) # ?(?=\b)?
    end
  end
end
