class ErpApp::Desktop::Tenancy::BaseController < ErpApp::Desktop::BaseController
  IGNORED_PARAMS = %w{action controller id}
  ROOT_NODE = 'root_node'

  def tenants
    tree = []
    
    node_id = params[:node]

    if node_id == ROOT_NODE
      tenants = Tenant.all
      tenants.each do |tenant|
        tree << {:text => tenant.schema, :leaf => false, :schema => tenant.schema, :isTenant => true, :id => tenant.id}
      end
    else
      tenant = Tenant.find(node_id)
      tenant.domains.each do |domain|
        tree << {:text => "#{domain.host}[#{domain.route}]", :host => domain.host, :route => domain.route, :isDomain => true, :leaf => true, :id => domain.id}
      end
    end
    
    render :inline => tree.to_json
  end

  def new_tenant
    Tenant.create(:schema => params[:schema])
    render :inline => {:success => true}.to_json
  end
  
  def new_domain
    tenant = Tenant.find(params[:id])
    tenant.add_domain(params[:host], params[:route])
    render :inline => {:success => true}.to_json
  end

  def update_tenant
    tenant = Tenant.find(params[:id])
    Tenancy::SchemaUtil.rename_schema(tenant.schema, params[:schema])
    tenant.schema = params[:schema]
    tenant.save
    render :inline => {:success => true}.to_json
  end

  def update_domain
    domain = Domain.find(params[:id])
    domain.host = params[:host]
    domain.route = params[:route]
    domain.save
    render :inline => {:success => true}.to_json
  end

  def delete_domain
    Domain.destroy(params[:id])
    render :inline => {:success => true}.to_json
  end

  def delete_tenant
    tenate = Tenant.find(params[:id])
    Tenancy::SchemaUtil.delete_schema(tenate.schema)
    tenate.destroy

    render :inline => {:success => true}.to_json
  end
end