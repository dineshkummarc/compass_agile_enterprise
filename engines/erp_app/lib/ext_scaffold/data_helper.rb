module ExtScaffold::DataHelper
  def self.build_json_data(model, options={})
    model.include_root_in_json = false
    
    records = model.all(options)

    json_text = "{\"totalCount\":#{model.count},\"data\":"

    json_text += records.to_json()

    json_text += '}'

    json_text
  end

  def self.create_record(model, options={})
    obj = model.new
    options[:data].each do |k,v|
      obj.send("#{k.to_s}=", v)
    end
    obj.save

    json_text = "{\"success\":true,data:"

    json_text += obj.to_json

    json_text += '}'

    json_text
  end

  def self.update_record(model, options={})
    obj = model.find(options[:id])
    options[:data].each do |k,v|
      obj.send("#{k.to_s}=", v)
    end
    obj.save

    json_text = "{\"success\":true,data:"

    json_text += obj.to_json

    json_text += '}'

    json_text
  end

  def self.delete_record(model, options={})
    model.destroy(options[:id])

    "{\"success\":true,data:[]}"
  end

end
