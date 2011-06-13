class ErpApp::Desktop::Knitkit::PositionController < ErpApp::Desktop::Knitkit::BaseController
  def update
    params[:position_array].each do |position|
      model = position['klass'].constantize.find(position['id'])
      model.position = position['position'].to_i
      model.save
    end

    render :inline => {:success => true}.to_json
  end
end
