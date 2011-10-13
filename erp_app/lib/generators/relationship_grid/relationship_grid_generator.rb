class RelationshipGridGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :relationship_type, :type => :string, :required => true
  argument :title, :type => :string, :required => true
  argument :description, :type => :string, :required => true

  def generate_relationship_grid
    path = "public/javascripts/erp_app/organizer/applications/crm/relationship_grid_widgets.js"

    if File.exist?(path)
      insert_into_file path, :after => "});" do
        <<-eos
\nExt.define('Compass.ErpApp.Organizer.Applications.Crm.RelationshipGrid.#{class_name}',{
    extend:'Compass.ErpApp.Organizer.Applications.Crm.RelationshipGrid',
    alias:'widget.#{file_name}',
    initComponent: function () {
        this.callParent(arguments);
    },
    constructor: function(config) {
        config.relationshiptype = '#{relationship_type}';
        config.title = '#{title}';
        this.callParent([config]);
    }
});
        eos
      end
    else 
      create_file path do
        <<-eos
\nExt.define('Compass.ErpApp.Organizer.Applications.Crm.RelationshipGrid.#{class_name}',{
    extend:'Compass.ErpApp.Organizer.Applications.Crm.RelationshipGrid',
    alias:'widget.#{file_name}',
    initComponent: function () {
        this.callParent(arguments);
    },
    constructor: function(config) {
        config.relationshiptype = '#{relationship_type}';
        config.title = '#{title}';
        this.callParent([config]);
    }
});
        eos
      end
    end

    #migration
    template "migrate/migration_template.rb", "db/data_migrations/#{RussellEdge::DataMigrator.next_migration_number}_create_#{file_name}_relationship_grid.rb"
  end

end

