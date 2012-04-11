module ErpApp::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper 
  include ActionView::Helpers::TagHelper 

  def link_to_remote(name, url, options={})
    options.merge!({:class => 'ajax_replace', :remote => true})
    link_to name, url, options
  end
  
  def form_remote_tag(url, options={}, &block)
    options.merge!({:class => 'ajax_replace', :remote => true})
    form_tag url, options do
      yield
    end
  end

end
