require 'rubygems'
require 'rake'
require 'active_record'
require 'vendor/plugins/acts_as_java_value_object/lib/java_support'
require 'fileutils'

include GC

# these rake tasks provide a mechanism for dynamically generating the
# java value objects from the current ActiveRecord models

namespace :jvo do
  # call with rake jvo:create
  # or        rake jvo:create[com.package.xyz]
  task :create ,[ :package_name ] => :environment do | t, args|
    start_time=Time.now.to_i
    package_name =args[:package_name]
    if(package_name==nil)
      #setup default package
      package_name='com.tnsolutionsinc.compass.erp.models'
      puts "NO PACKAGE NAME DECLARED"

      puts "using defaults package :#{package_name}"
    else
      puts "Package Name:#{package_name}"
    end
    models =Array.new
    Dir.entries(RAILS_ROOT + '/app/models').each do |file|
      if(file.ends_with?('.rb'))
        models << file[0,file.length-3]
      end
    end

    # delete the generated source, bin and dist directories
    # if the exist
    root_dir="./jvo"
    if(File.exist?(root_dir))
      puts "removing #{root_dir}"
      FileUtils.rm_r(Dir.glob("#{root_dir}/*"))
  
    end

    #model = 'agreement'

    models.each do |model|
      begin
        build_java_value_object_source_file(package_name,camel_case(model))
      rescue Exception =>e
        puts "Trapped Exception building #{model}"
        puts "Exception=:#{e}\n"
      end
    end

    

    # now compile the java source that was created
    compile_jvo_source(package_name)

    # now package the binaries into the compass model jar
    Rake::Task['jvo:package']


    end_time=Time.now.to_i
    puts "Completed in #{(end_time-start_time)} msecs"
  end


 

  


  def build_java_value_object_source_file(package_name , active_record_model_name)
    class_name=active_record_model_name
    if(package_name==nil)
      fully_qualified_class_name=active_record_model_name
    else
      fully_qualified_class_name="#{package_name}.#{active_record_model_name}"
    end

    
    klass = Kernel.const_get(active_record_model_name)

    puts "obtained Active Record Model class: #{klass}"

    klass_instance = klass.new
    if(klass_instance.is_a?(ActiveRecord::Base))

      puts "building #{fully_qualified_class_name}"
      attributes=attributes_only(klass_instance,[])
      attributes.each_pair do |key,value|
        puts "attribute [#{key}], #{value.class}"
      end



      ## build simple attribute accessor mutators

      ## need to gather all the associations & types

      associations= get_create_associations(klass_instance)
      associations.each do |association|
        puts "association=#{association}"
      end

      # aggregations
      puts "columns_hash"
      columns_hash= klass.send("columns_hash".to_sym)
      columns_hash.each_pair do |key, column|
        puts "#{key}-#{column.type}"
      end

      associations= klass.send("reflections".to_sym)
    
      associations.each do |assoc|
        puts "\nreflections\n "
        puts "assco-#{assoc}"
        puts "class-#{assoc.class}"
        puts "type-#{assoc.type}"
        #      assoc.methods.sort.each do |m|
        #
        #
        #      puts "#{m}\n"
        #      end
      end

      source = create_source_file(package_name,class_name,nil,nil)
      write_source_file(source,package_name,class_name)
    else
      puts ("#{active_record_model_name} - is not an active record model")
    end
 
  end

  def create_source_file(package_name,class_name,attributes, associations)
    source_file=source_prologue(package_name,class_name)
    source_file<< source_imports
    source_file << source_class_declaration(class_name)
    source_file << source_constructor(class_name)
    source_file << source_epilogue(class_name)

    source_file
  end

  # generate the value object prologue
  def source_prologue(package_name,class_name)
    prologue = "// -------------------------------------------------------------\n"
    prologue << "// Source code generated (#{Time.now}by  jvo_creator\n"
    prologue << "// DO NOT EDIT\n"
    prologue << "// Class: #{class_name}\n"
    prologue << "// JAVA VALUE OBJECT\n"
    current_time=Time.now
    prologue << "// Copyright #{current_time.year} TrueNorth Solutions Inc\n"
    prologue << "// ------------------------------------------------------------\n\n"
    if(package_name != nil)
      prologue << "package #{package_name};\n\n"
    else
      prologue << "// no package specified"
    end
    return prologue
  end

  # generate the source file imports
  def source_imports
    imports =  "// these imports are required\n"
    #imports << " import org.apache.commons.lang.builder.ToStringBuilder;\n"
    return imports
  end

  # returns the class  declaration
  def source_class_declaration (class_name)

    class_declaration = "\n// declare the class\n"
    #class_declaration << "public class #{class_name} extends BaseModel {\n\n"
    class_declaration << "public class #{class_name} {\n\n"
    return class_declaration

  end

  def source_attributes(attributes)

  end

  def source_accessor_mutator_pair(type, name)
    accessor= "\n\n//Accessor\n"
    accessor << "public #{type} getName() {\n"
    accessor << " return this.#{make_member_variable_name(name)}\n"
    accessor << "}/n"

    mutator= "\n\n//Mutator\n"
    mutator << "public void setName(#{type} #{make_member_variable_name(name)}) {\n"
    mutator  << " this.#{make_member_variable_name(name)}=#{make_member_variable_name(name)}\n"
    mutator << "}/n"

    accessor << mutator
    return accessor
  end

  def source_constructor (class_name)
    constructor =  "\n// define constructor\n"
    constructor << "public #{class_name}() {}\n"
  end

  def source_epilogue(class_name)
    epilogue = "\n}\n\ // End of [#{class_name}]  jvo source"

    return epilogue
  end

  def make_member_variable_name(string)
    return "var_#{string}"
  end

  ## create a hash containing only attribute and attribute values
  ## without including the association _ids
  def attributes_only(object,exclude_attribute_array=[])
    attribute_hash=Hash.new
    attributes=object.attributes
    attributes.each_pair do |key, value|
      if((key.ends_with?("_id")) )
        # skip over the association attributes
        Rails.logger.debug("Excluding association attribute.:#{key}")
      elsif ((exclude_attribute_array!=nil) &&( exclude_attribute_array.include?(key)))
        # and any explicit attribute exclusions
        Rails.logger.debug("Excluding attribute.............:#{key}")
      else
        attribute_hash[key]=value
      end
    end
    return attribute_hash

  end

  # create a hash containing only the associations
  def associations_only(object)
    associations_hash=Hash.new
    attributes=object.attributes
    attributes.each_pair do |key, value|
      if((key.ends_with?("_id")) )
        Rails.logger.debug("adding association :#{key}")
        association_hash[key]=value
      end
    end
    return associations_hash

  end

  

  # get the names of methods starting with create

  def get_create_associations(active_record_model)
    # define any excluded create methods
    excluded_create_methods=['create_default_active_record_model_from_java_value_object',
      'create_java_accessor_name','create_java_graph','create_java_mutator_name']
    
    associations=Array.new
    klass_methods=active_record_model.methods
    klass_methods.each do |m|
      if(m.starts_with?("create_"))
        if(excluded_create_methods.include?(m))
          # skip
          puts "skipping #{m}"
        else
          # return only the attribute name
          associations<<m[6,m.length]
        end
      end
    end
    return associations
  end

  def reflect_aggregations(active_record_model)
    puts "columns_hash:#{active_record_model.columns_hash}"
    #    aggregations=ActiveRecord::Reflection.reflect_on_all_aggregations
    #    aggregations.each do |ag|
    #      puts.ag
    #    end
  end


  def write_source_file(source,package_name,class_name)
    dir_pwd=Dir.pwd()
    
    if(package_name==nil)
      target_file="./jvo/java_source/#{class_name}.java"
    else
      package_path=package_name.gsub('.','/')
      target_file="./jvo/java_source/#{package_path}/#{class_name}.java"
    end


    # if the file exists delete it
    if(File.exist?(target_file))
      puts "deleting current #{target_file}"
      File.delete(target_file)
      
      
    end
    #ensure the package_path exists before creating the file
    package_path=File.dirname(target_file)
    puts "checking for path:#{package_path}"
    if(File.exist?(package_path))
      # do nothing the path exists
      puts "path exists:#{package_path}"
    else
      FileUtils.mkdir_p("#{package_path}")
      puts "created package path:"
    end
 
    # write the source to the file
    File.open(target_file, 'w') do |f2|
      # use "\n" for two lines of text
      f2.puts source
    end
  end

  # executes the java compiler
  def compile_jvo_source(package_name)
    ENV['JAVA_HOME'] = "C:/Program Files/Java/jdk1.6.0_14"
    puts("JAVA HOME:#{ENV['JAVA_HOME']}")

    puts ("\n\nCompile JVO source\n\n")
    if(File.exists?("jvo/bin"))
    else
      FileUtils.mkdir_p("jvo/bin")
    end
  
    package_path=package_name.gsub('.','/')
    source_path="."
    dest_path="../bin"
    exec_string="#{ENV['JAVA_HOME']}/bin/javac -verbose -d #{dest_path} #{package_path}/*.java"
    puts exec_string
    
    dir_pwd=Dir.pwd
    FileUtils.cd("#{pwd}/jvo/java_source")
    puts "current working directory is #{Dir.pwd}"
    exec(exec_string)

    FileUtils.cd(dir_pwd)
    puts "current working directory is #{Dir.pwd}"

  end


   

  
  # helper method to create a standard java
  # mutator name from a snake_cased string
  def create_java_mutator_name(str)
    return "set"+camel_case(str)
  end

  # helper method to create a standard java
  # accessor name from a snake_cased string
  def create_java_accessor_name(str)
    return "get"+camel_case(str)
  end

  # convert a snake_case string to CamelCase
  def camel_case(str)
    return str if str !~ /_/ && str =~ /[A-Z]+.*/
    retval=""
    str.split('_').map do |i|
      d=i.capitalize

      retval<< d

    end
    return retval
  end

  # Packages the binary classes into a jar file
  # rake jvo:package
  task :package   => :environment do | t, args|
    if(File.exist?("./jvo/dist"))
    else
      FileUtils.mkdir("./jvo/dist")
    end
    package_name =args[:package_name]
    if(package_name==nil)
      #setup default package
      package_name='com.tnsolutionsinc.compass.erp.models'
      puts "NO PACKAGE NAME DECLARED"

      puts "using defaults package :#{package_name}"
    else
      puts "Package Name:#{package_name}"
    end
    puts("Package JAR")
    ENV['JAVA_HOME'] = "C:/Program Files/Java/jdk1.6.0_14"
    puts("JAVA HOME:#{ENV['JAVA_HOME']}")

    package_path=package_name.gsub('.','/')
    source_path="."
    dest_path="../bin"
    t = Time.now
    jar_timestamp=t.strftime("%Y%m%d")
    exec_string="#{ENV['JAVA_HOME']}/bin/jar cvf ../dist/compassERP_models-#{jar_timestamp}.jar *"
   

    dir_pwd=Dir.pwd
    FileUtils.cd("#{pwd}/jvo/bin")
    puts "current working directory is #{Dir.pwd}"
    puts exec_string
    exec(exec_string)
    FileUtils.cd("#{pwd}")
    puts "current working directory is #{Dir.pwd}"
  end

end
