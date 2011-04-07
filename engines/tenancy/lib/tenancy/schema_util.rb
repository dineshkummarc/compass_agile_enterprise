module Tenancy
  module SchemaUtil
    def self.with_schema(schema_name, &block)
      conn = ActiveRecord::Base.connection
      old_schema_search_path = conn.schema_search_path
      conn.schema_search_path = schema_name
      begin
        yield
      ensure
        conn.schema_search_path = old_schema_search_path
      end
    end
    
    def self.set_search_path(schema_name)
      conn = ActiveRecord::Base.connection
      conn.schema_search_path = schema_name
    end
    
    def self.reset_search_path
      conn = ActiveRecord::Base.connection
      conn.schema_search_path = 'public'
    end

    def self.create_schema(schema_name)
      ActiveRecord::Base.connection.execute("create schema #{schema_name}")
    end

    def self.delete_schema(schema_name)
      conn = ActiveRecord::Base.connection
      conn.execute("drop schema #{schema_name} CASCADE;") if schema_exists(schema_name)
    end

    def self.schema_exists(schema_name)
      conn = ActiveRecord::Base.connection
      ntuples = conn.execute("select * from pg_namespace where nspname = '#{schema_name}'").ntuples
      ntuples.to_i > 0
    end

    def self.rename_schema(old_name, new_name)
      conn = ActiveRecord::Base.connection
      conn.execute("alter schema #{old_name} rename to #{new_name};")
    end
    
  end
end