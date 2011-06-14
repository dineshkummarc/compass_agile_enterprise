(function(){
    //Section 1 : Code to execute when the toolbar button is pressed
    var a= {
        exec:function(editor){
            var uploadWindow = new Compass.ErpApp.Shared.UploadWindow();
            uploadWindow.show();
        }
    },
    //Section 2 : Create the button and add the functionality to it
    b='compassupload';
    CKEDITOR.plugins.add(b,{
        init:function(editor){
            editor.addCommand(b,a);
            editor.ui.addButton('compassupload',{
                label:'Upload',
                icon: '/images/erp_app/desktop/image_add.png',
                command:b
            });
        }
    });
})();
