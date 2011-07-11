class ConvertThemeFiles < ActiveRecord::Migration
  
  def self.up
    if table_exists? :theme_files
      results = ActiveRecord::Base.connection.select_all("select * from theme_files;")
      results.each do |result|
        type = result['type'].gsub('Theme::','')

        insert_sql = "insert into file_assets
                    (type, name, directory, data_file_name, data_content_type, data_file_size, file_asset_holder_id, file_asset_holder_type)
                    values
                    (
                      '#{type}',
                      '#{result['name']}',
                      '#{result['directory']}',
                      '#{result['data_file_name']}',
                      '#{result['data_content_type']}',
                      #{result['data_file_size']},
                      #{result['theme_id']},
                      'Theme'
                    );"

        puts insert_sql

        ActiveRecord::Base.connection.execute(insert_sql)
      end

      ActiveRecord::Base.connection.execute('drop table theme_files;')
    end
  end
  
  def self.down
    #no way back from here.
  end

end
