require 'routing_filter'
require "#{RAILS_ROOT}/vendor/plugins/knitkit/lib/routing_filter/section_router.rb"

ActionController::Routing::Routes.draw do |map|
  map.filter 'section_router'

  map.page 'pages/:section_id',
    :controller   => 'sections',
    :action       => "index",
    :conditions => { :method => :get }

  map.page_article 'pages/:section_id/:id',
    :controller   => 'articles',
    :action       => "show",
    :conditions => { :method => :get }

  map.blogs 'blogs/:section_id',
                    :controller => 'blogs',
                    :action => 'index',
                    :conditions => { :method => :get }

  map.blog_article 'blogs/:section_id/:id',
                    :controller => 'blogs',
                    :action => 'show',
                    :conditions => { :method => :get }

  #Desktop Applications
  #knitkit
  map.connect '/erp_app/desktop/knitkit/:action', :controller => 'erp_app/desktop/knitkit/base'
  map.connect '/erp_app/desktop/knitkit/image_assets/:action', :controller => 'erp_app/desktop/knitkit/image_assets'
  map.connect '/erp_app/desktop/knitkit/file_assets/:action', :controller => 'erp_app/desktop/knitkit/file_assets'
  #article
  map.connect '/erp_app/desktop/knitkit/articles/:action/:section_id', :controller => 'erp_app/desktop/knitkit/articles'
  #content
  map.connect '/erp_app/desktop/knitkit/content/:action', :controller => 'erp_app/desktop/knitkit/content'
  #website
  map.connect '/erp_app/desktop/knitkit/site/:action', :controller => 'erp_app/desktop/knitkit/site'
  #section
  map.connect '/erp_app/desktop/knitkit/section/:action', :controller => 'erp_app/desktop/knitkit/section'
  #theme
  map.connect '/erp_app/desktop/knitkit/theme/:action', :controller => 'erp_app/desktop/knitkit/theme'
end