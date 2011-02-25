module ActiveExt
  def self.included(base)
    base.extend(ClassMethods)
  end

  def active_ext_core
    self.class.active_ext_core
  end

  ###############################################################################
  #Options
  #
  #ignore_associations
  #ignore associations
  #default = false
  #options[:ignore_associations] = true
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
    def active_ext(model_id = nil, &block)
      model_id = model_id
      model_id = self.to_s.split('::').last.sub(/Controller$/, '') unless model_id
      options = block_given? ? block.call({}) : {}
      @core = ActiveExt::Core.new(model_id,options)

      module_eval do
        def setup
          columns, fields = ActiveExt::ExtHelpers::TableBuilder.generate_columns_and_fields(active_ext_core)
          render :inline => "{\"success\":true,inline_edit:#{active_ext_core.options[:inline_edit]},\"columns\":#{columns},\"fields\":#{fields}}"
        end

        def data
          json_text = nil

          if request.get?
            json_text = ActiveExt::ExtHelpers::DataHelper.build_json_data(active_ext_core, :limit => params[:limit], :offset => params[:start])
          elsif request.post?
            json_text = ActiveExt::ExtHelpers::DataHelper.create_record(active_ext_core, :data => params[:data])
          elsif request.put?
            json_text = ActiveExt::ExtHelpers::DataHelper.update_record(active_ext_core, :data => params[:data], :id => params[:id])
          elsif request.delete?
            json_text = ActiveExt::ExtHelpers::DataHelper.delete_record(active_ext_core, :data => params[:data], :id => params[:id])
          end

          render :inline => json_text
        end

        def edit
          id = params[:id]
          @model = active_ext_core.model.find(id)
          @attributes = @model.attributes
          @singular_name = active_ext_core.model_id
        end

      end
    end

    def active_ext_core
       @core || self.superclass.instance_variable_get('@core')
    end
  end
end

ActionController::Base.send(:include, ActiveExt)
