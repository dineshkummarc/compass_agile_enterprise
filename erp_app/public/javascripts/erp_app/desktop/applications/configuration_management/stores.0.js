Ext.create('Ext.data.Store', {
  storeId: 'configurationmanagement-modelsstore',
  fields: ['description', 'id'],
  proxy: {
    type: 'ajax',
    url : '/erp_app/desktop/configuration_management/configurable_models',
    reader: {
      type: 'json',
      root: 'models'
    }
  }
});

Ext.create('Ext.data.Store', {
  storeId: 'configurationmanagement-templatesstore',
  fields: ['description', 'id'],
  proxy: {
    type: 'ajax',
    url : '/erp_app/desktop/configuration_management/configuration_templates_store',
    reader: {
      type: 'json',
      root: 'templates'
    }
  }
});

Ext.create('Ext.data.Store', {
  pageSize:10,
  storeId: 'configurationmanagement-optionsstore',
  fields: ['id', 'description', 'value', 'internal_identifier', 'comment'],
  proxy: {
    type: 'ajax',
    url : '/erp_app/desktop/configuration_management/options/index.json',
    reader: {
      type: 'json',
      root: 'options',
      totalProperty:'totalCount'
    }
  }
});

Ext.create('Ext.data.Store', {
  pageSize:10,
  storeId: 'configurationmanagement-typesstore',
  fields: ['id', 'description', 'internal_identifier'],
  proxy: {
    type: 'ajax',
    url : '/erp_app/desktop/configuration_management/types/types_store',
    reader: {
      type: 'json',
      root: 'types'
    }
  }
});

Ext.create('Ext.data.Store', {
  storeId: 'configurationmanagement-categoriesstore',
  fields: ['description', 'category_id'],
  proxy: {
    type: 'ajax',
    url : '/erp_app/desktop/configuration_management/types/categories',
    reader: {
      type: 'json',
      root: 'categories'
    }
  }
});

