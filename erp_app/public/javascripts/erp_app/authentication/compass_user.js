Ext.ns("ErpApp.CompassAccessNegotiator");

/**
 * @class ErpApp.CompassAccessNegotiator.CompassUser
 **/

ErpApp.CompassAccessNegotiator.CompassUser = function(user, applicationRoleManager){
  this.id = user.id,
  this.roles = user.roles,
  this.username = user.username,
  this.lastloginAt = user.lastloginAt,
  this.lastActivityAt = user.lastActivityAt,
  this.failedLoginCount = user.failedLoginCount,
  this.email = user.email,
  this.applicationRoleManager = applicationRoleManager,
  this.description = user.description

  /**
   * Checks to see if the passed roles exists in this.roles
   * @param {String or Array} internal_identifier of role or array of internal_identifiers
   */
  this.hasRole = function(role){
    var result = false;

    if(role instanceof Array){
      var self = this;
      for(var i = 0; i < role.length; i ++){
        if(self.hasRole(role[i])){
          result = true;
          break;
        }
      }
    }
    else
    {
      if(this.roles.contains(role)){
        result = true;
      }
      else{
        result = false;
      }
    }

    return result;
  },

  this.hasApplicationCapability = function(application_iid, capability){
    return this.applicationRoleManager.hasApplicationCapability(application_iid, capability, this);
  },

  this.hasWidgetCapability = function(xtype, capability){
    return this.applicationRoleManager.hasWidgetCapability(xtype, capability, this);
  },

  this.hasAccessToWidget = function(xtype){
    return this.applicationRoleManager.hasAccessToWidget(xtype, this);
  },

  this.validWidgets = function(application_iid, filters){
    return this.applicationRoleManager.validWidgets(application_iid, filters, this);
  },

  /**
   * Use when role check fails, displays message add logging if needed.
   * @param {String} message to overwrite default
   * @param {fn} function to call when complete
   */
  this.showInvalidAccess = function(options){
    if(Compass.ErpApp.Utility.isBlank(options))
      options = {};
    Ext.Msg.show({
      title:'Warning',
      msg: options['msg'] || 'You do not have permission to perform this action.',
      buttons: Ext.Msg.OK,
      fn: options['fn'] || null,
      iconCls:'icon-warning'
    });
  }

};



