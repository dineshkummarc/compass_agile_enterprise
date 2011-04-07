class Tenant < ActiveRecord::Base
  has_many :domains, :dependent => :destroy

  after_create :create_schema

  def self.find_schema_by_host(host)
    schema = nil
    tenant = self.find(:first, :joins => "join domains on domains.tenant_id = #{self.object_id}", :conditions => ['domains.host = ?', host])
    schema = tenant.schema unless tenant.nil?
    schema
  end

  def self.find_route_by_host(host)
    route = nil
    domain = Domain.find_by_host(host)
    route = domain.route unless domain.nil?
    route
  end

  def create_schema()
    unless Tenancy::SchemaUtil.schema_exists(self.schema)
      Tenancy::SchemaUtil.create_schema(self.schema)
      Tenancy::SchemaUtil.with_schema(self.schema) do
        #load schema file
        schema_file = "#{RAILS_ROOT}/db/schema.rb"
        load(schema_file)
        #load setup data
        ErpApp::Setup::Data.run_setup
      end
    end
  end

  def add_domain(host, route)
    self.domains << Domain.create(:host => host, :route => route)
    self.save
  end
  
end
