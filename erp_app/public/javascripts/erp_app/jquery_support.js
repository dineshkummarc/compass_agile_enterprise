if($){
  $(document).ready(function () {
    Compass.ErpApp.JQuerySupport.setupHtmlReplace();
  });

  Ext.ns("Compass.ErpApp.JQuerySupport");

  Compass.ErpApp.JQuerySupport.setupHtmlReplace = function(){
    jQuery('body').unbind('ajaxSuccess').bind('ajaxSuccess', Compass.ErpApp.JQuerySupport.handleHtmlUpdateResponse);
  };

  Compass.ErpApp.JQuerySupport.handleHtmlUpdateResponse = function(e, xhr, settings){
    try{
      var responseData = jQuery.parseJSON(xhr.responseText);
      var element = document.getElementById(responseData.htmlId);
      element.innerHTML = responseData.html;
      Compass.ErpApp.Utility.evaluateScriptTags(element);
    }
    catch(err){
    //handle errors silently
    }
		
  };
}