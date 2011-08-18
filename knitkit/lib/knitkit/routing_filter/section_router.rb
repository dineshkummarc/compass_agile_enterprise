# If the path is, aside from a slash and an optional locale, the leftmost part
# of the path, replace it by "sections/:id" segments.

module RoutingFilter
  class SectionRouter < Filter

    def around_recognize(path, env, &block)
      website = Website.find_by_host(env["HTTP_HOST"])
      unless website.nil?
        paths = paths_for_website(website)
        if path !~ %r(^/([\w]{2,4}/)?admin) and !paths.empty? and path =~ recognize_pattern(paths)
          if website_section = website_section_by_path(website, $2)
            type = website_section.type.pluralize.downcase
            path.sub! %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$)), "/#{$1}#{type}/#{website_section.id}#{$3}"
          end
        end
      end
      yield
    end
    
    def around_generate(params, &block)      
      yield.tap do |path|
        path = path.first if path.is_a?(Array)
        if path !~ %r(^/([\w]{2,4}/)?admin) and path =~ generate_pattern
          website_section = WebsiteSection.find $2.to_i
          path.sub! "#{$1}/#{$2}", "#{website_section.permalink}#{$3}"
        end
      end
    end
    
    protected
    def paths_for_website(website)
      website ? website.website_sections.permalinks.sort{|a, b| b.size <=> a.size }.join('|') : []
    end

    def website_section_by_path(website, path)
      valid_section = website.website_sections.detect{|website_section| website_section.permalink == path }
      if valid_section.nil?
        website.website_sections.each do |website_section|
          valid_section = website_section.child_by_permalink(path)
          break unless valid_section.nil?
        end
      end

      valid_section
    end

    def recognize_pattern(paths)
      %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$))
    end

    def generate_pattern
      types = WebsiteSection.types.map{|type| type.downcase.pluralize }.join('|')
      %r((#{types})/([\w]+(/?))(\.?)) # ?(?=\b)?
    end
  end
end
