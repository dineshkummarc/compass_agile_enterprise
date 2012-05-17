/* ajax pagination */

/* Prototype implementation let here for reference
document.observe("dom:loaded", function() {
  // the element in which we will observe all clicks and capture
  // ones originating from pagination links
  var container = $(document.body);

  if (container) {
    var img = new Image;
    img.src = '/images/erp_app/ajax-loader.gif';

    function createSpinner() {
      return new Element('img', { src: img.src, 'class': 'spinner' });
    }

    container.observe('click', function(e) {
      var el = e.element();
      if (el.match('.pagination a')) {
        el.up('.pagination').insert(createSpinner());
        new Ajax.Request(el.href, { method: 'get' });
        e.stop();
      }
    });
  }
});
*/

/* jQuery implementation 
NOTE: Does not work standalone like the prototype implementation did, you have to do it inline in the ajax response */
jQuery(function(){
  jQuery('.pagination a').attr('data-remote', 'true'); 
});
