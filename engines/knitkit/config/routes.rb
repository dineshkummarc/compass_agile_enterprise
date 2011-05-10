require 'routing_filter'
require "#{RAILS_ROOT}/vendor/plugins/knitkit/lib/routing_filter/section_router.rb"

ActionController::Routing::Routes.draw do |map|
  map.filter 'section_router'

  map.page 'pages/:section_id',
    :controller   => 'website_sections',
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

  map.blog_tag 'blogs/:section_id/tag/:tag_id',
                    :controller => 'blogs',
                    :action => 'tag',
                    :conditions => { :method => :get }

  map.comments '/comments/add/:section_id/:content_id', :controller => 'comments', :action => 'add'
  map.login '/login', :controller => 'login', :action => 'index'
  map.signup '/signup/:action', :controller => 'signup'
  map.unauthorized '/unauthorized', :controller => 'unauthorized', :action => 'index'
  map.contact '/contact_us', :controller => 'contact', :action => 'show'
  map.connect '/view_current_publication', :controller => 'base', :action => 'view_current_publication'

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
  map.connect '/erp_app/desktop/knitkit/site/:action', :controller => 'erp_app/desktop/knitkit/website'
  #section
  map.connect '/erp_app/desktop/knitkit/section/:action', :controller => 'erp_app/desktop/knitkit/website_section'
  #theme
  map.connect '/erp_app/desktop/knitkit/theme/:action', :controller => 'erp_app/desktop/knitkit/theme'
  #versions
  map.connect '/erp_app/desktop/knitkit/versions/:action', :controller => 'erp_app/desktop/knitkit/versions'
  #comments
  map.connect '/erp_app/desktop/knitkit/comments/:action/:content_id', :controller => 'erp_app/desktop/knitkit/comments'
  #inquiries
  map.connect '/erp_app/desktop/knitkit/inquiries/:action/:website_id', :controller => 'erp_app/desktop/knitkit/inquiries'
  #website_nav
  map.connect '/erp_app/desktop/knitkit/website_nav/:action', :controller => 'erp_app/desktop/knitkit/website_nav'
  #position
  map.connect '/erp_app/desktop/knitkit/position/:action', :controller => 'erp_app/desktop/knitkit/position'
end
