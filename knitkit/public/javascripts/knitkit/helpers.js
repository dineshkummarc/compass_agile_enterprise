Ext.ns("Knitkit.Helpers");

Knitkit.Helpers.toggleArchivableContent = function(archiveToggle, name){
  var current_items = document.getElementsByClassName(name+'_current');
  var archived_items = document.getElementsByClassName(name+'_archived');
  var i = null;

  if (archiveToggle.innerHTML == 'Show Archived'){
    for (i = 0; i < current_items.length; i++) {
      current_items[i].style.display='none';
    }
    for (i = 0; i < archived_items.length; i++){
      archived_items[i].style.display='';
    }
    archiveToggle.innerHTML = 'Show Current';
  }else{
    for (i = 0; i < archived_items.length; i++){
      archived_items[i].style.display='none';
    }
    for (i = 0; i < current_items.length; i++){
      current_items[i].style.display='';
    }
    archiveToggle.innerHTML = 'Show Archived';
  }
}

