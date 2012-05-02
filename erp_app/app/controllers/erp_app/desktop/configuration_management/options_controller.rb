module ErpApp
  module Desktop
    module ConfigurationManagement
      class OptionsController < ::ErpApp::Desktop::BaseController

        def index
          options_tbl = ConfigurationOption.arel_table
          arel_query = ConfigurationOption.where(options_tbl[:value].matches("%#{params[:query]}%")
            .or(options_tbl[:internal_identifier].matches("%#{params[:query]}%")))
            .where(options_tbl[:user_defined].eq(false))
            .limit(params[:limit])
            .offset(params[:start])
          options = arel_query.all

          respond_to do |format|
            format.json {
              render :json => {
                :success => true,
                :total_count => options.count,
                :options => options.collect{|option|option.to_hash(:only => [:id, :description, :comment, :value, :internal_identifier])}}
            }
            format.tree {
              render :json => options.collect{|option| option.to_hash(:only => [:internal_identifier, :value, :comment, :description],
                                              :methods => [{:description => :text}, {:id => :model_id}],
                                              :additional_values => {:iconCls => 'icon-document', :leaf => true, :children => []})}
            }
          end

        end

        def create_or_update
          option = params[:model_id].blank? ? ConfigurationOption.new : ConfigurationOption.find(params[:model_id])
          option.value = params[:value]
          option.internal_identifier = params[:internal_identifier]
          option.comment = params[:comment]
          option.description = params[:description]
          if option.save
            render :json => {:success => true}
          else
            render :json => {:success => false}
          end
        end

        def destroy
          if ConfigurationOption.destroy(params[:id])
            render :json => {:success => true}
          else
            render :json => {:success => false}
          end
        end

      end#BaseController
    end#ConfigurationManagement
  end#Desktop
end#ErpApp