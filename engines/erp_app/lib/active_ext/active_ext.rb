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
          columns, fields, validations = ActiveExt::ExtHelpers::TableBuilder.generate_columns_and_fields(active_ext_core)
          result = {
            :success => true,
            :use_ext_forms => active_ext_core.options[:use_ext_forms].nil? ? false : active_ext_core.options[:use_ext_forms],
            :inline_edit => active_ext_core.options[:inline_edit].nil? ? false : active_ext_core.options[:inline_edit],
            :columns => columns,
            :fields => fields,
            :validations => validations
          }
          render :inline => result.to_json
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

        #default show

        def show
          if active_ext_core.options[:use_ext_forms]
            form_items_json = ActiveExt::ExtHelpers::FormBuilder.build_form_fields(active_ext_core, params[:id], params[:action])
            render :inline => form_items_json
          else
            Rails.logger.debug(">>ActiveExt.show")
            # get the requested id
            id = params[:id]
            # get the model represented by id
            @model = active_ext_core.model.find(id)
            @options = active_ext_core.options
            # get the fields that should be displayed
            # these fields are rendered in the order
            # they appear in the array
            @fields=active_ext_core.columns.collect(&:name)
            if(@fields==nil)
              # if no fields are specified use all from the model
              @fields=field_names_from_model(@model)
            end
            @attributes = @model.attributes
            @associations =@model.class.reflect_on_all_associations

            @associations.each_with_index { |name, i| Rails.logger.debug "#{i} #{name}" }

            # get alternate labels
            @labels =active_ext_core.options[:labels]
            # get the models name
            @singular_name = active_ext_core.model_id
          end
        end
        
        def new
          if active_ext_core.options[:use_ext_forms]
            form_items_json = ActiveExt::ExtHelpers::FormBuilder.build_form_fields(active_ext_core, nil, params[:action])
            render :inline => form_items_json
          else
            Rails.logger.debug(">>ActiveExt.new")
            @model = active_ext_core.model.new
            @model.created_at=Time.now
            @model.updated_at=Time.now
            @options = active_ext_core.options
            Rails.logger.debug(">> new:#{@model}")
            @attributes = @model.attributes
            @fields= active_ext_core.columns.collect(&:name)
            @disabled_fields=active_ext_core.options[:disabled]
            if(@fields==nil)
              # if no fields are specified use all from the model
              @fields=field_names_from_model(@model)
            end
            @labels =active_ext_core.options[:labels]
            @singular_name = active_ext_core.model_id
          end
        end

        # default create

        def create
          if active_ext_core.options[:use_ext_forms]
            json_text = ActiveExt::ExtHelpers::DataHelper.create_record(active_ext_core, :data => get_data)
            render :inline => json_text
          else
            Rails.logger.debug(">>ActiveExt.create")
            @model = active_ext_core.model.new
            begin
              # get the name of the model
              @singular_name = active_ext_core.model_id
              @options = active_ext_core.options
              # get the form parameters by model name
              model_params=params[@singular_name];
              # get the model id
              id = model_params[:id]
              Rails.logger.debug("[#{@singular_name}]update id:#{id}")
              # create new model to receive attributes

              @fields=active_ext_core.columns.collect(&:name)
              if(@fields==nil)
                # if no fields are specified use all from the model
                @fields=field_names_from_model(@model)
              end
              Rails.logger.debug("Model_params:#{model_params.class}")
              # update the models
              #@model.update(id,model_params)
              #@model.attributes= (model_params, guard_protected_attributes = true)
              #model_class=Kernel.const_get(@singular_name.capitalize)
              #logger.debug("model_class:#{model_class}")

              @model.attributes= (model_params)
              @labels =active_ext_core.options[:labels]
              @model.save(false)
            rescue Exception =>ex
              flash[:error]=ex
            end
            flash[:notice]="#{@model.class} created"
            render :partial => 'edit', :object => @model
          end
        end

        # default edit

        def edit
          if active_ext_core.options[:use_ext_forms]
            form_items_json = ActiveExt::ExtHelpers::FormBuilder.build_form_fields(active_ext_core, params[:id], params[:action])
            render :inline => form_items_json
          else
          
            Rails.logger.debug(">>ActiveExt.edit")

            id = params[:id]
            @model = active_ext_core.model.find(id)
            @options = active_ext_core.options
            @attributes = @model.attributes
            @fields=active_ext_core.columns.collect(&:name)
            if(@fields==nil)
              # if no fields are specified use all from the model
              @fields=@model.attributes
            end
            @disabled_fields=active_ext_core.options[:disabled]
            @labels =active_ext_core.options[:labels]
            @singular_name = active_ext_core.model_id
          end
        end
        
        # default update

        def update
          if active_ext_core.options[:use_ext_forms]
            json_text = ActiveExt::ExtHelpers::DataHelper.update_record(active_ext_core, :data => get_data, :id => params[:id])
            render :inline => json_text
          else
            Rails.logger.debug(">>ActiveExt.update")
            begin
              @labels =active_ext_core.options[:labels]
              @options = active_ext_core.options
              # get the name of the model
              @singular_name = active_ext_core.model_id
              # get the form parameters by model name
              model_params=params[@singular_name.underscore];
              Rails.logger.debug("Model_params:#{model_params }")
              # get the model id
              id = model_params[:id]
              Rails.logger.debug("[#{@singular_name}]update id:#{id}")
              # find the model by id
              @model = active_ext_core.model.find(id)
              Rails.logger.debug("Model:#{@model.class}")
              model_params.delete("id")

              Rails.logger.debug("Model_params:#{model_params }")
              # update the models

              #Rails.logger.debug("model_class:#{model_class}")

              @model.attributes= (model_params)
              @model.updated_at=Time.now
              @model.save(false)
            rescue Exception =>ex
              flash[:error]=ex
            end
            flash[:notice]="#{@model.class} updated"
            #setup for edit this needs to be pulled out to another method for re-use
            @options = active_ext_core.options
            @attributes = @model.attributes
            @fields=active_ext_core.columns.collect(&:name)
            if(@fields==nil)
              # if no fields are specified use all from the model
              @fields=@model.attributes
            end
            @disabled_fields=active_ext_core.options[:disabled]
            @labels =active_ext_core.options[:labels]
            render :action => :edit
          end
        end

        # get the attribute names for the specified model

        def field_names_from_model( model)
          field_names = Array.new
          model_attributes=model.attributes.keys
          model_attributes.length.times do |attribute_key_id|
            field_names<< model_attributes[attribute_key_id].to_s
            Rails.logger.debug("FieldNames:#{field_names}")
          end
          field_names
        end




        # Finds the controller for the given ActiveRecord model.
        # Searches in the namespace of the current controller for singular
        # and plural versions of the conventional "#{model}Controller" syntax.

        def active_ext_controller_for(klass)
          if(klass.class!="Class")
            klass=klass.class
          end
          namespace = self.to_s.split('::')[0...-1].join('::') + '::'
          error_message = []
          ["#{klass.to_s.underscore.pluralize.singularize}",
            "#{klass.to_s.underscore.pluralize.singularize}"].each do |controller_name|
            puts(">>active_ext_controller(#{klass},#{controller_name}")
            begin
              controller = "#{namespace}#{controller_name.camelize}Controller".constantize
              #controller = Kernel.const_get("#{namespace}#{controller_name.camelize}Controller")
            rescue NameError => error
              # Only rescue NameError associated with the controller constant not existing - not other compile errors
              if error.message["uninitialized constant #{controller}"]
                error_message << "#{namespace}#{controller_name.camelize}Controller"
                next
              else
                raise
              end
            end
            return controller
          end
          raise ActiveExt::ControllerNotFound, "Could not find " + error_message.join(" or "), caller
        end

        # get the model's :has_many relationships
        def get_relationships(model )
          Rails.logger.debug(">>get_relationships:#{model}")
          # create a hash that will contain the
          # relationships returned to the caller
          relationships = Hash.new
          has_one_hash= Hash.new
          has_many_hash=Hash.new
          has_many_through_hash=Hash.new
          # create the array of ActiveRecord::Reflection::AssociationReflection
          associations=model.class.reflect_on_all_associations
          # iterate over the associations and get the corresponding model
          associations.each do |association|

            if (association.macro == :has_one)
              # get the :has_one model from the association
              association_model=model.send(association.name)
              has_one_hash[association.name]=association_model
              Rails.logger.debug(">>:has_one-(#{association.name.to_s.humanize})- #{association_model}")

            elsif (association.macro == :has_many)

              # get the array of :has_many models from the associations
              association_models=model.send(association.name)

              # check if this is a :has_many or :has_many :through
              if(association.class == ActiveRecord::Reflection::AssociationReflection)
                has_many_hash[association.name]= association_models
              elsif (association.class == ActiveRecord::Reflection::ThroughReflection)
                has_many_through_hash[association.name]= association_models
              else

              end

              Rails.logger.debug(">>:has_many-(#{association.name.to_s.humanize})- #{association_models}")
            end
          end
          relationships[:has_one]=has_one_hash
          relationships[:has_many]=has_many_hash
          relationships[:has_many_through]=has_many_through_hash
          Rails.logger.debug(">>relationships[:has_one]=#{relationships[:has_one]}")
          Rails.logger.debug(">>relationships[:has_many]=#{relationships[:has_many]}")
          return relationships
        end

        # return a hash containing:
        # :model - the original model
        # :controller - the model's controller
        # :controller_path - the path to the model's controller
        # :options - the model's active_ext controller options
        # :fields - returns the model's renderable fields
        def active_ext_context_for(model)
          context = Hash.new
          context[:model]=model
          context[:controller]=active_ext_controller_for(model)
          context[:controller_path]=active_ext_controller_path(context[:controller])
          context[:options]=context[:controller].active_ext_core.options
          context[:renderable_fields]=context[:controller].active_ext_renderable_fields(model)
          return context
        end

        # get the path for a specific controller
        def active_ext_controller_path(controller)
          Rails.logger.debug("get_controller_path:#{controller}")
          #make sure the object is an instance of BaseController

          #if(controller.is_a?(ErpApp::ApplicationController ))

          if (controller.respond_to? ("active_ext_core"))
            Rails.logger.debug(">>active_ext controller :#{controller}")
            #convert controller name to string
            target_controller_path=controller.to_s
            #convert camelcase to underscore/snakecase
            target_controller_path=target_controller_path.underscore
            #remove the controller name
            target_controller_path=target_controller_path.gsub("_controller","")

            Rails.logger.debug(">>path :#{target_controller_path}")
            return target_controller_path
          else
            raise "Not an active_ext controller :#{controller}"
          end
          # else
          #  raise "Cannot get controller path for #{controller}. Not a  ErpApp::ApplicationController"
          # end
        end

        # gets the label to use for a given attribute
        def active_ext_label(attribute_name)
          labels = active_ext_core.options[:labels]
          if(labels[attribute_name]!=nil)
            return labels[attribute_name]
          else
            return "-#{attribute_name.to_s.humanize}-"
          end
        end

        # when options[:only] isnt supplied supply these default
        # field values
        def active_ext_default_fields(model)
          default_fields = Array.new
          #default_fields<< :id
          default_fields=model.attributes.keys
          Rails.logger.debug(">> USING DEFAULT FIELDS FOR [#{model.class}]")
          Rails.logger.debug(">>  DEFAULT FIELDS :[#{default_fields.join(',')}]")
          return default_fields
        end

        # returns the list of fields that should be rendered
        # why dynamically rendering :show or :edit
        def active_ext_rendered_fields(model)
          Rails.logger.debug(">>active_ext_rendered_fields #{model.class}")
          #check if options[:only] is set. If it is not
          # we will use all fields- otherwise we use only
          # those fields explicitly declared
          target_controller = active_ext_controller_for(model)
          options_only =target_controller.active_ext_core.options[:only]
          if(options_only==nil)
            options_only= active_ext_default_fields(model)
          end
          fields = Array.new
          if(options_only.length==0)
            fields= field_names_from_model(model)
          else
            fields =options_only
          end
          Rails.logger.debug(">> rendered fields[#{fields.join(',')}]")
          return fields
        end

        # for a given model returns a hash containing
        # :fields - these are directly editiable fields (e.g. Fixnum, String, etc)
        # :subfields - these are handled separate from the

        # this should probably  model.class.columns_hash[key].type
        # to determine which fields are renderable
        def active_ext_renderable_fields(model)



          Rails.logger.debug(">>active_ext_renderable_fields")
          fields = active_ext_rendered_fields(model);


          rendered_fields = Hash.new # top level result container
          editible_fields = Hash.new # contains :fields
          editible_fields_ordered= Array.new # contains the order the editible fields should be rendered in
          subform_fields = Hash.new  # contains :subfields
          subform_fields_ordered= Array.new # contains the order the subform  should be rendered in

          # add id to beginning of field list if the options[:show_id] is true
          if(active_ext_core.options[:show_id]== true)
            if (fields.include?("id"))
              fields.delete("id") # if the id exists remove it from the array
            end
            fields.insert(0,"id")
          end

          # add create_at & updated_at to field list if the options[:show_timestamps] is true
          if(active_ext_core.options[:show_timestamps]== true)
            if (fields.include?("created_at"))
              fields.delete("created_at") # if the created_at exists remove it from the array
            end
            fields << "created_at"
            if (fields.include?("updated_at"))
              fields.delete("updated_at") # if the updated_at exists remove it from the array
            end
            fields << "updated_at"
          end

          attribute_types=get_attribute_types(model)
          attribute_types.each_pair do |attribute, type|
            Rails.logger.debug("#{model.class}.#{attribute}: #{type}")

            if( (attribute.length>2) && !(attribute.ends_with?('id')))
              editible_fields[attribute]=model.send(attribute)
              editible_fields_ordered<<attribute
            else
              if(attribute[0,attribute.length-3]!=nil)
                subform_fields[attribute[0,attribute.length-3]]=model.send(attribute[0,attribute.length-3])
                subform_fields_ordered<<attribute[0,attribute.length-3]
              end
            end
          end

          # loop over fields and add to the appropriate collection
=begin
      fields.each do |field|
        current_model = model.send(field)
        Rails.logger.debug("inspect field[#{field}]:#{current_model.class}")
        if(is_active_ext_subform_record?(current_model))
          subform_fields[field]=current_model # add the current model to the the subform hash
          subform_fields_ordered<<field #  add the field name to maintain the order
       else
         editible_fields[field]=current_model # add the current model to the the editible fields hash
         editible_fields_ordered<<field #  add the field name to maintain the order
        end
      end
=end
          rendered_fields[:fields]=editible_fields
          rendered_fields[:subfields]=subform_fields
          rendered_fields[:fields_order]=editible_fields_ordered
          rendered_fields[:subfields_order]=subform_fields_ordered
          return rendered_fields
        end

        #return a hash of attribute & types for a give model
        def get_attribute_types(model)
          Rails.logger.debug("#{model}.get_attribute_types")
          attributes=model.attributes
          results=Hash.new
          attributes.each_pair do |key,value|


            attribute_type=model.class.columns_hash[key].type

            results[key]=attribute_type
          end
          return results

        end

        # returns true if the field name is in the options[:disabled_fields] list
        def active_ext_field_disabled?(field_name)
          disabled_fields = active_ext_core.options[:disabled_fields]
          # in the event there are no disabled_fields create an instance of
          # an array
          if (disabled_fields ==nil)
            disabled_fields=Array.new
          end
          # automatically add id & timestamps
          disabled_fields<<:id
          disabled_fields<<:created_at
          disabled_fields<<:updated_at
          Rails.logger.debug(">> Controller:(#{self.to_s})")
          Rails.logger.debug(">> Disabled fields:#{disabled_fields.join(',')}")
          Rails.logger.debug(">> include?(#{field_name})=#{disabled_fields.include?(field_name.to_sym)}")
          if (disabled_fields.include?(field_name.to_sym))

            return true
          else
            return false
          end
        end

        # test if the model should be rendered as a primitive type or
        # as a subform type
        def is_active_ext_subform_record?(model)
          primitive_types =["Class","Fixnum","String","ActiveSupport::TimeWithZone"]


          Rails.logger.debug(">>subform test:#{model.class.to_s}")
          if(primitive_types.include?(model.class.to_s))

            return false;
          else
            return true;
          end
        end

        private

        def get_data
          ignored_params = %w{action controller id}

          data = {}
          params.each do |k,v|
            data[k] = v unless ignored_params.include?(k.to_s)
          end

          data
        end

      end
    end

    def active_ext_core
      @core || self.superclass.instance_variable_get('@core')
    end
  end
end

ActionController::Base.send(:include, ActiveExt)
