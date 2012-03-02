# If the path is, aside from a slash and an optional locale, the leftmost part
# of the path, replace it by "sections/:id" segments.

module RoutingFilter
  require 'logger'
  class SectionRouter < Filter
    def around_recognize(path, env, &block)
      website = Website.find_by_host(env["HTTP_HOST"])
      if website
        paths = paths_for_website(website)
        if path.to_sym == :/
          home_page_url = website.configurations.first.get_configuration_item(ConfigurationItemType.find_by_internal_identifier('homepage_url')).options.first.value
          valid_section = website.website_sections.detect{|website_section| website_section.path == home_page_url }
          type = valid_section.type.pluralize.downcase
          path.sub!('/', "/#{$1}#{type}/#{valid_section.id}#{$3}")
        else
          if !Rails.application.config.knitkit.ignored_prefix_paths.include?(path) and path !~ %r(^/([\w]{2,4}/)?admin) and !paths.empty? and path =~ recognize_pattern(paths)
            if section = website_section_by_path(website, $2)
              type = section.type.pluralize.downcase
              path.sub! %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$)), "/#{$1}#{type}/#{section.id}#{$3}"
            end
          end
        end
      end
      yield
    end
    
    def around_generate(params, &block)   
      yield.tap do |path|
        result = result.first if result.is_a?(Array)
        if result !~ %r(^/([\w]{2,4}/)?admin) and result =~ generate_pattern
          section = WebsiteSection.find $2.to_i
          result.sub! "#{$1}/#{$2}", "#{section.path[1..section.path.length]}#{$3}"
        end
      end
    end
    
    protected
    def paths_for_website(website)
      website ? website.all_section_paths.map{|path| path[1..path.length]}.sort{|a, b| b.size <=> a.size }.join('|') : []
    end

    def website_section_by_path(website, path)
      path = "/#{path}"
      valid_section = website.website_sections.detect{|website_section| website_section.path == path }
      if valid_section.nil?
        website.website_sections.each do |website_section|
          valid_section = website_section.child_by_path(path)
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
