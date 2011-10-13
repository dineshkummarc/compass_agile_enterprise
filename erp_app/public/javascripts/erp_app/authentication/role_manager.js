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
 * @param {String or Array} internal_identifier of role or array of internal_identifiers
 */
    hasRole : function(role){
        var result = false;

        if(role instanceof Array){
            var self = this;
            Ext.each(role,function(role){
                if(self.hasRole(role)){
                    result = true;
                    return false;
                }
            });
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

    /**
     * Checks to see if user has access to passed widget
     * @param {Array} array of widget role objects
     */
    hasAccessToWidget : function(widget_roles, xtype){
        var roles = widget_roles.find('xtype == "'+xtype+'"').roles;
        return this.hasRole(roles);
    },

    /**
     * Checks to find valid widegts and returns their
     * xtypes.  Optionally pass an object like so: {x_type : true},
     * to filter those xtypes out of the return.
     * @param {Array} array of widget role objects
     */
    findValidWidgets : function(widget_roles, filter){
        var valid_xtypes, xtype, roles;

        valid_xtypes = [];
        for (var i = 0; i < widget_roles.length; i++) {
            xtype = filter[widget_roles[i].xtype] ? false : widget_roles[i].xtype;
            if (xtype === false) {
                continue;
            }

            roles = widget_roles[i].roles;
            if (this.hasRole(roles)) {
                valid_xtypes.push(xtype);
            }
        }
        return valid_xtypes;
    },

    /**
     * Use when role check fails, displays message add logging if needed.
     * @param {String} message to overwrite default
     * @param {fn} function to call when complete
     */
    invalidRole : function(options){
        Ext.Msg.show({
            title:'Warning',
            msg: options['msg'] || 'You do not have permission to perform this action.',
            buttons: Ext.Msg.OK,
            fn: options['fn'] || null,
            iconCls:'icon-warning'
        });
    }

};

