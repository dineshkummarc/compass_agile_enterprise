module BaseHelper
  def render_menu(contents) 
    render :partial => "shared/menu", :locals => {:contents => contents}
  end
end
