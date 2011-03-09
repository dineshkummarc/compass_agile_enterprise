Role.class_eval do
  
  acts_as_solr :fields => [
    :internal_identifier,
    :description
  ]

  def Role.find_by_solr_ext_data(fields, query, limit = 25, start = 0, sort = 'id', direction = 'ASC')
    results = Role.find_by_solr(query, :limit => limit, :offset => start)
    total_count = results.total
    result_count = results.docs.size
    role_results = []
    results.docs.each do |role|
      temp_hash = {}
      fields.each do |field|
        temp_hash.merge!(field.to_sym => role.send(field))
      end
      role_results << temp_hash

    end
    return "{
        'success': true,
        'count': #{total_count},
        'results': #{result_count},
        'roles': #{role_results.to_json}
        }"
  end

end