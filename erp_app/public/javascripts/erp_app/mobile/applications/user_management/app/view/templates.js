Compass.ErpApp.Mobile.UserManagement.Templates = {};
Compass.ErpApp.Mobile.UserManagement.Templates.userDetails = new Ext.XTemplate(
  '<div class="display">',
  '<span>Username</span>',
  '{username}',
  '<br/>',
  '<span>Last Activity At</span>',
  '{last_activity_at:date("m/d/Y g:i:s")}',
  '<br/>',
  '<span>Last Login At</span>',
  '{last_login_at:date("m/d/Y g:i:s")}',
  '<br/>',
  '<span>Email</span>',
  '{email}',
  '<br/>',
  '<span># Failed Login</span>',
  '{failed_logins_count}',
  '<br/>',
  '<span>Status</span>',
  '{activation_state}',
  '</div>',
  '<br/>',
  '<div id="resetPasswdBtnHolder"></div>'
  );