Ext.define("Compass.ErpApp.Organizer.Applications.BillPay.PartyAccountsTab",{
  extend:"Compass.ErpApp.Shared.BillingAccountsGridPanel",
  alias:'widget.billpay',
    title:'Accounts',
    listeners:{
      activate:function(grid){
        var contactsLayout = grid.findParentByType('contactslayout');
        if(!Compass.ErpApp.Utility.isBlank(contactsLayout.partyId)){
          var store = grid.getStore();
          store.proxy.extraParams.party_id = contactsLayout.partyId;
          store.load({
            params:{
              start:0,
              limit:10
            }
          })
        }
      }
    }

});