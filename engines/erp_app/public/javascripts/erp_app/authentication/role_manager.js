Ext.ns("ErpApp.Authentication");

/**
* @class ErpApp.Authentication.RoleManager
**/

ErpApp.Authentication.RoleManager = {
    /**
 *array holding roles current user has
 */
    roles : [],

    /**
 * Checks to see if the passed roles exists in this.roles
 * @param {String} internal_identifier of role
 */
    hasRole : function(role){
        if(this.roles.contains(role)){
            return true;
        }
        else{
            return false;
        }
    },

    /**
 * Checks to see if any of the passed roles exists in this.roles
 * @param {Array} array of roles
 */
    hasRoles : function(roles){
        var result = false;

        //if no roles were passed in then they have access
        if(Compass.ErpApp.Utility.isBlank(roles) || roles.length == 0){
            result = true;
        }
        else
        {
            var self = this;
            Ext.each(roles,function(role){
                if(self.hasRole(role)){
                    result = true;
                    return false;
                }
            });
        }

        return result;
    },

    /**
     * Checks to see if user has access to passed widget
     * @param {Array} array of widget role objects
     */
    hasAccessToWidget : function(widget_roles, xtype){
        var roles = widget_roles.find('xtype == "'+xtype+'"').roles;
        return this.hasRoles(roles);
    }

}

