Ext.define("Compass.ErpApp.Ecommerce.CreditCardWindow",{
    extend:"Ext.window.Window",
    alias:'widget.creditcardwindow',
    visaPattern : '^4[0-9]{12}(?:[0-9]{3})?$',
    mastercardPattern : '^5[1-5][0-9]{14}$',
    amexPattern : '^3[47][0-9]{13}$',
    dinersClubPattern : '^3(?:0[0-5]|[68][0-9])[0-9]{11}$',
    discoverPattern : '^6(?:011|5[0-9]{2})[0-9]{12}$',

    validateCardNumber : function(cardType, cardNumber, pattern){
        var regex = new RegExp(pattern);
        if (regex.test(cardNumber)){
            return true;
        }else{
            Ext.Msg.alert('Error', 'Invalid credit card number for '+cardType+'.');
            return false;          
        }
    },

    validateCreditCardInfo : function(form){
        var total = parseFloat(form.findField('amount').getValue());
        // if nothing to charge return true
        if (total == 0){
            Ext.Msg.alert('Error', 'You must specify a dollar amount');
            return false;
        }
        var date = new Date();
        var currentYear = parseInt(date.getFullYear().toString().substr(2));
        var currentMonth = date.getMonth() + 1;
        var expYear = parseInt(form.findField('credit_card_exp_year_hidden').getValue(),10);
        var expMonth = parseInt(form.findField('credit_card_exp_month_hidden').getValue(),10);


        // make sure currentYear >= this_month if exp_year == this_year
        if (expYear == currentYear)
        {
            if (expMonth < currentMonth)
            {
                Ext.Msg.alert('Error', 'Please enter a valid expiration date.');
                return false;
            }
        }
        else
        if(expYear < currentYear){
            Ext.Msg.alert('Error', 'Please enter a valid expiration date.');
            return false;
        }

        var cardType = form.findField('card_type').getValue();
        var cardNumber = form.findField('credit_card_number_hidden').getValue();

        switch (cardType) {
            case 'visa':
                return this.validateCardNumber('Visa', cardNumber, this.visaPattern);
            case 'mastercard':
                return this.validateCardNumber('Master Card', cardNumber, this.mastercardPattern);
            case 'amex':
                return this.validateCardNumber('American Express', cardNumber, this.amexPattern);
            case 'discover':
                return this.validateCardNumber('Discover', cardNumber, this.discoverPattern);
            case 'dc':
                return this.validateCardNumber('Diners Club', cardNumber, this.dinersClubPattern);
            default:
                return false;
        }
        
    },

    initComponent : function() {
        this.addEvents(
            /**
         * @event charge_response
         * Fired after response is recieved from server
         * @param {CreditCardWindow} this Object
         * @param {Object} Server Response
         */
            "charge_response",
            /**
         * @event charge_failure
         * Fired after response is recieved from server with error
         * @param {CreditCardWindow} this Object
         * @param {Object} Server Response
         */
            "charge_failure"
            );

        this.callParent(arguments);
    },

    constructor : function(config) {
        var formFields = [];

        var encryptField = function(field, hiddenFieldId){
            var value = field.getValue();
            var form = field.findParentByType('form');
            var hidden_field = form.findById(hiddenFieldId);
            hidden_field.setValue(value);
            var encrypt_value = '';
            for(var i=0;i < value.length;i++){
                encrypt_value += '*';
            }
            field.setValue(encrypt_value);
        };

        var unEncryptField = function(field, hiddenFieldId){
            var form = field.findParentByType('form');
            var hidden_field = form.findById(hiddenFieldId);
            field.setValue(hidden_field.getValue());
        };

        if (config["additionalFields"] != null){
            formFields = formFields.concat(config["additionalFields"]);
        }
		
        formFields = formFields.concat(
        {
            xtype: 'textfield',
            fieldLabel: 'Amount',
            id: 'amount',
            name: 'amount',
            renderer: Ext.util.Format.usMoney,
            allowBlank: false,
            disabled:config['chargeAmountDisabled'] || false,
            value: config['chargeAmount'] || ''
        },
        {
            xtype: 'combo',
            store: [
            ['visa','Visa'],
            ['mastercard','MasterCard'],
            ['discover','Discover'],
            ['amex','American Express'],
            ['dc','Diners Club']
            ],
            fieldLabel: 'Card Type',
            hiddenName: 'card_type',
            forceSelection:true,
            name: 'card_type',
            allowBlank: false,
            value: 'visa',
            triggerAction: 'all',
            width: 225
        },
        {
            xtype: 'textfield',
            fieldLabel: 'Card Number',
            id: 'card_number',
            name: 'card_number_encrypt',
            allowBlank: false,
            listeners:{
                blur:function(field){
                    encryptField(field,'credit_card_number_hidden');
                },
                focus:function(field){
                    unEncryptField(field,'credit_card_number_hidden');
                }
            }
        },
        {
            xtype: 'hidden',
            name:'card_number',
            id:'credit_card_number_hidden'
        },
        {
            xtype: 'textfield',
            id:'credit_card_exp_month',
            fieldLabel: 'Exp Month',
            maxLength:2,
            autoCreate: {
                tag: 'input',
                type: 'text',
                size: '2',
                autocomplete: 'off',
                maxlength: '2'
            },
            name: 'exp_month_encrypt',
            allowBlank: false,
            width:100,
            listeners:{
                blur:function(field){
                    encryptField(field,'credit_card_exp_month_hidden');
                },
                focus:function(field){
                    unEncryptField(field,'credit_card_exp_month_hidden');
                }
            }
        },
        {
            xtype: 'hidden',
            name:'exp_month',
            id:'credit_card_exp_month_hidden'
        },
        {
            xtype: 'textfield',
            fieldLabel: 'Exp Year',
            name: 'exp_year_encrypt',
            maxLength:2,
            autoCreate: {
                tag: 'input',
                type: 'text',
                size: '2',
                autocomplete: 'off',
                maxlength: '2'
            },
            allowBlank: false,
            width: 100,
            listeners:{
                blur:function(field){
                    encryptField(field,'credit_card_exp_year_hidden');
                },
                focus:function(field){
                    unEncryptField(field,'credit_card_exp_year_hidden');
                }
            }
        },
        {
            xtype: 'hidden',
            name:'exp_year',
            id:'credit_card_exp_year_hidden'
        },
        {
            xtype: 'textfield',
            fieldLabel: 'CVVS',
            id: 'cvvs',
            name: 'cvvs_encrypt',
            allowBlank: false,
            width:100,
            listeners:{
                blur:function(field){
                    encryptField(field,'credit_card_cvvs_hidden');
                },
                focus:function(field){
                    unEncryptField(field,'credit_card_cvvs_hidden');
                }
            }
        },
        {
            xtype: 'hidden',
            name:'cvvs',
            id:'credit_card_cvvs_hidden'
        },
        {
            xtype: 'textfield',
            fieldLabel: 'Billing Zip Code',
            id: 'billing_zip_code',
            name: 'billing_zip_code',
            width:100,
            allowBlank: false
        });

        config = Ext.apply({
            layout:'fit',
            title:'Credit Card Payment',
            autoHeight:true,
            iconCls:'icon-creditcards',
            width:config["width"] || 400,
            closeAction:'close',
            buttonAlign:'center',
            plain: true,
            items: new Ext.form.FormPanel({
                timeout: 130000,
                baseParams:config['baseParams'],
                autoHeight:true,
                labelWidth: config['labelWidth'] || 110,
                frame:false,
                url:config['url'],
                defaults: {
                    width: 225
                },
                items: [formFields]
            }),
            buttons: [{
                text:'Submit',
                listeners:{
                    'click':function(button){
                        var win = button.findParentByType('creditcardwindow');
                        var formPanel = win.findByType('form')[0];
                        //formPanel.findById('credit_card_amount_hidden').setValue(formPanel.findById('credit_card_amount').getValue().replace("$","").replace(",",""));
                        if(win.validateCreditCardInfo(formPanel.getForm())){
                            formPanel.getForm().submit({
                                method:config['method'] || 'POST',
                                waitMsg:'Processing Credit Card...',
                                success:function(form, action){
                                    var response =  Ext.util.JSON.decode(action.response.responseText);
                                    win.fireEvent('charge_response', win, response);
                                },
                                failure:function(form, action){
                                    if(action.response != null){
                                        var response =  Ext.util.JSON.decode(action.response.responseText);
                                        win.fireEvent('charge_failure', win, response);
                                    }
                                    else
                                    {
                                        Ext.Msg.alert("Error", 'Error Processing Credit Card');
                                    }
                                }
                            });
                        }
                    }
                }
            },
            {
                text: 'Cancel',
                listeners:{
                    'click':function(button){
                        var win = button.findParentByType('creditcardwindow');
                        var form = win.findByType('form')[0];
                        form.getForm().reset();
                        win.close();
                    }
                }
            }]
        }, config);

        this.callParent([config]);
    }
    
});

window.showCreditCardPayment = function(params){
    
    if(params["chargeAmount"] == null){
        throw "charge amount is null";
    }

    var win = new Compass.ErpApp.Ecommerce.CreditCardWindow(params);
 
    win.show();
};