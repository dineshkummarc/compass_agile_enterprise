ActionView::Base.class_eval do

  # name is ClassName of form you want
  # options are optional
  # options = {
  #   :internal_identifier => 'iid of exact form you want' (a model can have multiple forms)
  #   :width => 'width of form in pixels'
  # }
  def render_dynamic_form(name, options={})
    
    form = DynamicForm.get_form(name.to_s, options[:internal_identifier]).to_extjs_widget(
                { :url => build_widget_url(:new),
                  :widget_result_id => widget_result_id,
                  :width => options[:width] 
                })

    form
  end
  
end