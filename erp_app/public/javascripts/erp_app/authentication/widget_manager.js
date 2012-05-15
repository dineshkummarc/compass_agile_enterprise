Ext.ns("ErpApp.CompassAccessNegotiator");

/**
* @class ErpApp.CompassAccessNegotiator.ApplicationRoleManager
**/

ErpApp.CompassAccessNegotiator.ApplicationRoleManager = function(applications){
  /**
     * array to hold all application data
     *
     */
  this.applications = applications,

  this.findWidget = function(xtype){
    var widget = null;
    for(var a=0; a < this.applications.length; a++){
      var application = this.applications[a];
      widget = application.widgets.find("xtype == '"+xtype+"'");
      if(!Ext.isEmpty(widget))
          break;
    }
    return widget;
  },

  /**
     * Checks if user has application capability
     * xtypes.
     * @param {String} application iid
     * @param {Object} containing capability_type_iid and resource
     * @param {ErpApp.CompassAccessNegotiator.User} user
     */
  this.hasApplicationCapability = function(application_iid, capability, user){
    var application = this.applications.find("iid == '"+application_iid+"'");
    for(var i = 0; i < application.capabilities.length; i++){
      var app_capability = application.capabilities[i];
      if(app_capability.resource == capability.resource && app_capability.capability_type_iid == capability.capability_type_iid){
        return user.hasRole(app_capability.roles);
      }
    }
    throw "Capability "+capability.capability_type_iid+", "+capability.resource+" does not exist for application " + application_iid
  },

  /**
     * Checks if user has widget capability
     * xtypes.
     * @param {String} widget xtype
     * @param {Object} containing capability_type_iid and resource
     * @param {ErpApp.CompassAccessNegotiator.User} user
     */
  this.hasWidgetCapability = function(xtype, capability, user){
    var widget = this.findWidget(xtype);
    if(Compass.ErpApp.Utility.isBlank(widget)){
      throw "Widget xtype does not exist"
    }
    
    for(var i = 0; i < widget.capabilities.length; i++){
      var widget_capability = widget.capabilities[i];
      if(widget_capability.resource == capability.resource && widget_capability.capability_type_iid == capability.capability_type_iid){
        return user.hasRole(widget_capability.roles);
      }
    }
    throw "Capability "+capability.capability_type_iid+", "+capability.resource+" does not exist for widget " + xtype
  },

  /**
     * Checks to user has access to widget
     * xtypes.
     * @param {String} widget xtype
     * @param {ErpApp.CompassAccessNegotiator.User} user
     */
  this.hasAccessToWidget = function(xtype, user){
    var widget = this.findWidget(xtype);
    if(Compass.ErpApp.Utility.isBlank(widget)){
      throw "Widget xtype does not exist"
    }
    else{
      return user.hasRole(widget.roles);
    }
  },

  /**
     * Checks to find valid widegts and returns their
     * xtypes.
     * @param {String} application iid
     * @param {ErpApp.CompassAccessNegotiator.User} user
     */
  this.validWidgets = function(application_iid, filter, user){
    var validXtypes = [];
    var application = this.applications.find("iid == '"+application_iid+"'");
    var xtypes = application.widgets.collect('xtype');
    for(var i = 0; i < xtypes.length; i++){
      if(this.hasAccessToWidget(xtypes[i], user)){
        if(filter[xtypes[i]] != true){
          validXtypes.push(xtypes[i]);
        }
      }
    }
    
    return validXtypes;
  }
};

