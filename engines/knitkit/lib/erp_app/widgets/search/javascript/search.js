widgetTpl = new Ext.Template(
    "<% #Optional Parameters:\n",
    "   # content_type: Leave blank to search all section types, set to Blog to only search Blog articles\n",
    "   # section_permalink: This is the permalink value for the section \n",
    "   #                    Useful if you only want to search articles within a single Blog section\n",
    "   # results_permalink: How do you want your results to display? via ajax? or on a new page?\n",
    "   #                    Leave blank if you want results to display via ajax on the same page as the search form\n",
    "   #                    Enter the permalink of results page if you want the search results to display on a new page\n",
    "   # per_page: Number of results per page %>\n",
    "<%= render_widget :search, \n",
    "                  :action => get_widget_action,\n",
    "                  :params => set_widget_params({\n",
    "                               :content_type => '',\n", 
    "                               :section_permalink => '',\n", 
    "                               :results_permalink => '',\n",
    "                               :per_page => 20 }) %>\n"
    );
    
Compass.ErpApp.Widgets.Search = {
    addSearch:function(){
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(widgetTpl.apply({})); 
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Search',
    iconUrl:'/images/icons/search/search_48x48.png',
    onClick:"Compass.ErpApp.Widgets.Search.addSearch();"
});
