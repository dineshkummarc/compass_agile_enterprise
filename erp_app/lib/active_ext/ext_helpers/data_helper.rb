module ActiveExt::ExtHelpers::DataHelper
  def self.build_json_data(core, options={})
    result = {:totalCount => 0, :data => []}
    klass = get_klass(core.model)

    klass.include_root_in_json = false
    
    records = klass.all(options)
    result[:totalCount] = klass.count
    result[:data] = records

    result.to_json(:include => core.association_names)
  end

  def self.create_record(core, options={})
    ignored_columns = %w{id created_at updated_at}

    klass = get_klass(core.model)

    options[:data].delete_if{|k,v| k.blank? || ignored_columns.include?(k)}
    obj = klass.create
    options[:data].each do |k,v|
      obj.send("#{k.to_s}=", v)
    end
    obj.save

    result = {:success => true, :data => []}
    result[:data] = obj

    result.to_json
  end

  def self.update_record(core, options={})
    klass = get_klass(core.model)
    
    obj = klass.find(options[:id])
    options[:data].each do |k,v|
      obj.send("#{k.to_s}=", v)
    end
    obj.save

    result = {:success => true, :data => []}
    result[:data] = obj
    result.to_json
  end

  def self.delete_record(core, options={})
    klass = get_klass(core.model)

    klass.destroy(options[:id])

    result = {:success => true, :data => []}
    result.to_json
  end

  private

  def self.get_klass(model)
    model.to_s.constantize
  end

end
