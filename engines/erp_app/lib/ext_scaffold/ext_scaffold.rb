module ExtScaffold
  def self.included(base)
    base.extend(ClassMethods)
  end

  ###############################################################################
  #Options
  #
  #show_id
  #show id column for this model
  #default = false
  #options[:show_id] = true
  #
  #show_timestamps
  #show timestamp columns for this model
  #default = false
  #options[:show_timestamps] = true
  #
  #only
  #show only the attributes specified
  #default = all attributes
  #options[:only] => [:description, :internal_identifier]
  #
  #attribute options
  #required
  #default = false
  #make this attribute required
  #options[:only] => [{:description => {:required => true}}]
  #
  #readonly
  #make this attribute readonly
  #default = false
  #options[:only] => [{:description => {:readonly => true}}]
  #
  #
  ###############################################################################

  module ClassMethods
    def ext_scaffold(model_id = nil, &block)
      @@model_id = model_id
      @@model_id = self.to_s.split('::').last.sub(/Controller$/, '').pluralize.singularize.constantize unless @@model_id
      @@options = block_given? ? block.call({}) : {}

      module_eval do
        def setup
          columns, fields = ExtScaffold::TableBuilder.generate_columns_and_fields(@@model_id,@@options)
          render :inline => "{success:true,columns:#{columns},fields:#{fields}}"
        end

        def data
          json_text = nil

          if request.get?
            json_text = ExtScaffold::DataHelper.build_json_data(@@model_id, :limit => params[:limit], :offset => params[:start])
          elsif request.post?
            json_text = ExtScaffold::DataHelper.create_record(@@model_id, :data => params[:data])
          elsif request.put?
            json_text = ExtScaffold::DataHelper.update_record(@@model_id, :data => params[:data], :id => params[:id])
          elsif request.delete?
            json_text = ExtScaffold::DataHelper.delete_record(@@model_id, :data => params[:data], :id => params[:id])
          end

          render :inline => json_text
        end
      end
    end
  end
end

ActionController::Base.send(:include, ExtScaffold)
