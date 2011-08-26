Compass.ErpApp.Widgets.ManageProfile = {
    addManageProfile:function(){
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror('<%= render_widget :manage_profile %>'); 
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Manage Profile',
    iconUrl:'/images/icons/document_edit/document_edit_48x48.png',
    onClick:Compass.ErpApp.Widgets.ManageProfile.addManageProfile
});