Compass.ErpApp.Widgets.Signup = {
    addSignup:function(){
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror('<%= render_widget :signup %>');
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Signup',
    iconUrl:'/images/icons/user/user_48x48.png',
    onClick:"Compass.ErpApp.Widgets.Signup.addSignup();"
});


