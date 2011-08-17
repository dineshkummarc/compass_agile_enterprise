require 'routing_filter'
require "#{File.dirname(__FILE__)}/../lib/knitkit/routing_filter/section_router.rb"

Compass::Application.routes.draw do
  filter :section_router
  
  get 'pages/:section_id' => 'knitkit/website_sections#index', :as => 'page'
  get 'pages/:section_id/:id' => 'knitkit/articles#show', :as => 'page_article'
  get 'blogs/:section_id.:format' => 'knitkit/blogs#index', :as => 'blogs'
  get 'blogs/:section_id/:id' => 'knitkit/blogs#show', :as => 'blog_article'
  get 'blogs/:section_id/tag/:tag_id.:format' => 'knitkit/blogs#tag', :as => 'blog_tag'
  
  match '/comments/add/:section_id/:content_id' => 'knitkit/comments#add', :as => 'comments'
  match '/unauthorized' => 'unauthorized#index', :as => 'knitkit/unauthorized'
  match '/view_current_publication' => 'knitkit/base#view_current_publication'
end

Knitkit::Engine.routes.draw do
  #Desktop Applications
  #knitkit
  match '/erp_app/desktop/:action' => 'erp_app/desktop/app'
  match '/erp_app/desktop/image_assets/:action' => 'erp_app/desktop/image_assets'
  match '/erp_app/desktop/file_assets/:action' => 'erp_app/desktop/file_assets'
  #article
  match '/erp_app/desktop/articles/:action/:section_id' => 'erp_app/desktop/articles'
  #content
  match '/erp_app/desktop/content/:action' => 'erp_app/desktop/content'
  #website
  match '/erp_app/desktop/site(/:action)' => 'erp_app/desktop/website'
  #section
  match '/erp_app/desktop/section/:action' => 'erp_app/desktop/website_section'
  #theme
  match '/erp_app/desktop/theme/:action' => 'erp_app/desktop/theme'
  #versions
  match '/erp_app/desktop/versions/:action' => 'erp_app/desktop/versions'
  #comments
  match '/erp_app/desktop/comments/:action/:content_id' => 'erp_app/desktop/comments'
  #inquiries
  match '/erp_app/desktop/inquiries/:action/:website_id' => 'erp_app/desktop/inquiries'
  #website_nav
  match '/erp_app/desktop/website_nav/:action' => 'erp_app/desktop/website_nav'
  #position
  match '/erp_app/desktop/position/:action' => 'erp_app/desktop/position'
end
