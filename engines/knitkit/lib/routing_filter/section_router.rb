# If the path is, aside from a slash and an optional locale, the leftmost part
# of the path, replace it by "sections/:id" segments.

module RoutingFilter
  class SectionRouter < Filter

    def around_recognize(path, env, &block)
      website = Website.find_by_host(env[:host_with_port])
        unless website.nil?
          paths = paths_for_website(website)
          if path !~ %r(^/([\w]{2,4}/)?admin) and !paths.empty? and path =~ recognize_pattern(paths)
            if website_section = website_section_by_path(website, $2)
              type = website_section.type.pluralize.downcase
              path.sub! %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$)), "/#{$1}#{type}/#{website_section.id}#{$3}"
            end
          end
        end
        check_tenants  yield
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
      website ? website.website_sections.permalinks.sort{|a, b| b.size <=> a.size }.join('|') : []
    end

    def website_section_by_path(website, path)
      website.website_sections.detect{|website_section| website_section.permalink == path }
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
