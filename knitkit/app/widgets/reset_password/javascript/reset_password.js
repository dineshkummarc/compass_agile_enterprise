Compass.ErpApp.Widgets.ResetPassword = {
    addResetPassword:function(){
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror('<%= render_widget :reset_password, :params => {:login_url => "/login"}%>');
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Reset Password',
    iconUrl:'/images/icons/edit/edit_48x48.png',
    onClick:Compass.ErpApp.Widgets.ResetPassword.addResetPassword,
    about:"This widget creates a form to submit for a user's password to be reset."
});


