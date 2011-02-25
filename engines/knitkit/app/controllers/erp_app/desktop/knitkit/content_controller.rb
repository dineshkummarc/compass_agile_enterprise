class ErpApp::Desktop::Knitkit::ContentController < ErpApp::Desktop::Knitkit::BaseController
  def update
    id      = params[:id]
    html    = params[:html]
    result = {}
    content = Content.find(id)
    content.body_html = html
    if content.save
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end

  def save_excerpt
    id      = params[:id]
    html    = params[:html]
    result = {}
    content = Content.find(id)
    content.excerpt_html = html
    if content.save
      result[:success] = true
    else
      result[:success] = false
    end

    render :inline => result.to_json
  end
end
