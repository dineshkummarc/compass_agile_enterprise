/*
 *
 *   Ext.ux.menu.Clock
 *
 */

Ext.define("Ext.ux.menu.Clock",{
  extend:"Ext.panel.Panel",
  requires:["Ext.menu.Menu","Ext.toolbar.Toolbar"],
  ariaRole:"menu",
  cls:"x-menu ux-start-menu",
  defaultAlign:"bl-tl",
  height:230,
  floating:true,
  layout:'border',
  shadow:true,
  width:375,
  timeFormat:"g:i:s A",
  tpl:"{time}",
  initComponent:function(){
    var a=this;

    if(typeof(a.tpl)=="string"){
      a.tpl=new Ext.XTemplate(a.tpl)
    }

    var html = '<canvas class="CoolClock:chunkySwiss"></canvas><br/><div style="text-align:center;width:100%;font-size:18px;"><span id="desktopClockTime"></span></div>';
    if (Ext.isIE || Ext.isIE6 || Ext.isIE7 || Ext.isIE8)
      html = "Clock Not Supported By Browser";

    var clock = Ext.create("Ext.panel.Panel",{
      layout:'fit',
      frame:false,
      region:'center',
      height:175,
      width:175,
      html:html
    });

    var calandar = Ext.create("Ext.panel.Panel",{
      width: 200,
      frame:false,
      region:'west',
      bodyPadding: 10,
      items: [{
        xtype: 'datepicker',
        handler: function(picker, date) {
        // do something with the selected date
        }
      }]
    });


    a.items = [clock,calandar]
    Ext.menu.Manager.register(a);
    a.callParent();
  },
  showBy:function(c,f,e){
    var b=this;
    if(b.floating&&c){
      b.layout.autoSize=true;
      b.show();
      c=c.el||c;
      var d=b.el.getAlignToXY(c,f||b.defaultAlign,e);
      if(b.floatParent){
        var a=b.floatParent.getTargetEl().getViewRegion();
        d[0]-=a.x;
        d[1]-=a.y
      }
      b.showAt(d);
      b.doConstrain()
    }
    return b
  },
  updateTime:function(){
    var a=this,el=Ext.get('desktopClockTime');
    if(el){
      var time=a.tpl.apply({
        time:Ext.Date.format(new Date(),a.timeFormat)
        });
      el.dom.innerHTML = time;
      a.timer=Ext.Function.defer(a.updateTime,1000,a);
    }
  },
  hide:function(){
    var a=this;
    if(a.timer){
      window.clearTimeout(a.timer);
      a.timer=null
    }
    a.callParent()
  },
  show:function(){
    var a=this;
    CoolClock.findAndCreateClocks();
    if(!a.timer){
      a.updateTime();
    }
    a.callParent();
  }
});

/*
 *
 *   Ext.ux.menu.TrayClock
 *
 */

Ext.define("Ext.ux.menu.TrayClock",{
  extend:"Ext.button.Button",
  alias:"widget.trayclock",
  timeFormat:"g:i A",
  menu:new Ext.ux.menu.Clock(),
  tpl:"{time}",
  initComponent:function(){
    var a=this;
    a.callParent();
    if(typeof(a.tpl)=="string"){
      a.tpl=new Ext.XTemplate(a.tpl)
    }
  },
  afterRender:function(){
    var a=this;
    Ext.Function.defer(a.updateTime,100,a);
    a.callParent()
  },
  onDestroy:function(){
    var a=this;
    if(a.timer){
      window.clearTimeout(a.timer);
      a.timer=null
    }
    a.callParent()
  },
  updateTime:function(){
    var a=this,b=Ext.Date.format(new Date(),a.timeFormat),c=a.tpl.apply({
      time:b
    });
    if(a.lastText!=c){
      a.setText(c);
      a.lastText=c
    }
    a.timer=Ext.Function.defer(a.updateTime,10000,a)
  }
});
