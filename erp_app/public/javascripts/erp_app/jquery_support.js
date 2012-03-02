if($){
  $(document).ready(function () {
    Compass.ErpApp.JQuerySpport.setupHtmlReplace();
  });

  Ext.ns("Compass.ErpApp.JQuerySpport");

  Compass.ErpApp.JQuerySpport.setupHtmlReplace = function(){
    $('body').unbind('ajaxSuccess').bind('ajaxSuccess', Compass.ErpApp.JQuerySpport.handleHtmlUpdateResponse);
  };

  Compass.ErpApp.JQuerySpport.handleHtmlUpdateResponse = function(e, xhr, settings){
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