Ext.override(Ext.data.Store, {
  setExtraParam: function (name, value){
    this.proxy.extraParams = this.proxy.extraParams || {};
    this.proxy.extraParams[name] = value;
    this.proxy.applyEncoding(this.proxy.extraParams);
  }
});

// fix for tempHidden in ExtJS 4.0.7 - Invoice Mgmt window was not opening correctly
// taken from http://www.sencha.com/forum/showthread.php?160222-quot-this.tempHidden-is-undefined-quot-Error-Workaround
Ext.override(Ext.ZIndexManager, {
  tempHidden: [],

  show: function() {
    var comp, x, y;

    while (comp = this.tempHidden.shift()) {
      x = comp.x;
      y = comp.y;

      comp.show();
      comp.setPosition(x, y);
    }
  }
});

Ext.override(Ext.data.TreeStore, {
  load: function(options) {
    options = options || {};
    options.params = options.params || {};

    var me = this,
    node = options.node || me.tree.getRootNode(),
    root;

    // If there is not a node it means the user hasnt defined a rootnode yet. In this case lets just
    // create one for them.
    if (!node) {
      node = me.setRootNode({
        expanded: true
      });
    }

    if (me.clearOnLoad) {
      node.removeAll(false);
    }

    Ext.applyIf(options, {
      node: node
    });
    options.params[me.nodeParam] = node ? node.getId() : 'root';

    if (node) {
      node.set('loading', true);
    }

    return me.callParent([options]);
  }
});


