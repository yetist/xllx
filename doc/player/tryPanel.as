package ctr.tip {
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.text.*;

    public class ToolTip extends Sprite {

        private static var _instance:ToolTip;

        private var _label:TextField;
        private var _base:Sprite;

        public function ToolTip(_arg1:Sprite){
            this._base = _arg1;
            var _local2:TextFormat = new TextFormat("宋体");
            this._label = new TextField();
            this._label.autoSize = TextFieldAutoSize.LEFT;
            this._label.textColor = 0x333333;
            this._label.text = " ";
            this._label.selectable = false;
            this._label.x = 3;
            this._label.y = 2;
            this._label.setTextFormat(_local2);
            addChild(this._label);
            filters = [this.getBitmapFilter()];
            this._base.addChild(this);
            _instance = this;
            this._hide();
        }
        public static function show(_arg1:String):void{
            if (_instance == null){
                return;
            };
            _instance._show(_arg1);
        }
        public static function hide():void{
            if (_instance == null){
                return;
            };
            _instance._hide();
        }
        public static function move(_arg1:Number, _arg2:Number):void{
            if (_instance == null){
                return;
            };
            _instance._move(_arg1, _arg2);
        }
        public static function get width():Number{
            return (_instance.width);
        }

        public function _show(_arg1:String):void{
            visible = true;
            this._label.text = _arg1;
            this.updateShape();
        }
        public function _hide():void{
            visible = false;
        }
        public function _move(_arg1:Number, _arg2:Number):void{
            this.x = ((((_arg1 + this.width) + this._base.x))>stage.stageWidth) ? ((stage.stageWidth - this.width) - this._base.x) : _arg1;
            this.y = (_arg2 - this.height);
        }
        private function changeHandler(_arg1:Event):void{
            this.updateShape();
        }
        private function updateShape():void{
            var _local1:Number = (this._label.textWidth + 8);
            var _local2:Number = 23;
            graphics.clear();
            graphics.lineStyle(1, 0);
            graphics.beginFill(16777185);
            graphics.drawRect(0, 0, _local1, _local2);
            graphics.endFill();
        }
        private function getBitmapFilter():BitmapFilter{
            var _local1:Number = 0;
            var _local2:Number = 0.3;
            var _local3:Number = 5;
            var _local4:Number = 5;
            var _local5:Number = 2;
            var _local6:Boolean;
            var _local7:Boolean;
            var _local8:Number = BitmapFilterQuality.HIGH;
            return (new GlowFilter(_local1, _local2, _local3, _local4, _local5, _local8, _local6, _local7));
        }

    }
}//package ctr.tip 
﻿package ctr.tryplay {
    import flash.display.*;
    import flash.events.*;
    import com.common.*;
    import eve.*;
    import flash.text.*;

    public class ViewListFace extends MovieClip {

        public var vip_line:MovieClip;
        public var view_btn:SimpleButton;
        public var home_btn:SimpleButton;
        public var vip_btn:SimpleButton;
        public var buy_txt:TextField;
        public var home_line:MovieClip;
        public var close_btn:SimpleButton;
        private var _time:Number = 0;
        private var _isTrial:Boolean;

        public function ViewListFace(){
            if ((((Tools.getUserInfo("userid") == "0")) || ((Tools.getUserInfo("sessionid") == null)))){
                this.buy_txt.visible = true;
            } else {
                this.buy_txt.visible = false;
            };
            var _local1:StyleSheet = new StyleSheet();
            _local1.setStyle("a", {textDecoration:"underline"});
            this.buy_txt.styleSheet = _local1;
            this.buy_txt.htmlText = "<a href='event:login'>会员登录</a>";
            this.buy_txt.addEventListener(TextEvent.LINK, this.clickText);
            this.view_btn.addEventListener(MouseEvent.CLICK, this.onViewClick);
            this.home_line.visible = false;
            this.vip_line.visible = false;
            this.home_btn.addEventListener(MouseEvent.CLICK, this.onHomeClick);
            this.home_btn.addEventListener(MouseEvent.MOUSE_OVER, this.onOverBtn);
            this.home_btn.addEventListener(MouseEvent.MOUSE_OUT, this.onOutBtn);
            this.vip_btn.addEventListener(MouseEvent.CLICK, this.onVipClick);
            this.vip_btn.addEventListener(MouseEvent.MOUSE_OVER, this.onOverBtn);
            this.vip_btn.addEventListener(MouseEvent.MOUSE_OUT, this.onOutBtn);
            this.close_btn.visible = false;
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
        }
        public function set isTrial(_arg1:Boolean):void{
            this._isTrial = _arg1;
        }
        public function setTime(_arg1:Number):void{
            this._time = _arg1;
        }
        public function setPosition():void{
            this.x = int(((stage.stageWidth - 726) / 2));
            this.y = int((((stage.stageHeight - 350) - 33) / 2));
        }
        private function onHomeClick(_arg1:MouseEvent):void{
            Tools.windowOpen("http://vod.xunlei.com/?referfrom=dmb", "_blank", "jump");
        }
        private function onVipClick(_arg1:MouseEvent):void{
            Tools.windowOpen("http://vip.xunlei.com/client/?referfrom=vod_dmb", "_blank", "jump");
        }
        private function onOverBtn(_arg1:MouseEvent):void{
            if (_arg1.currentTarget == this.home_btn){
                this.home_line.visible = true;
            } else {
                if (_arg1.currentTarget == this.vip_btn){
                    this.vip_line.visible = true;
                };
            };
        }
        private function onOutBtn(_arg1:MouseEvent):void{
            this.home_line.visible = false;
            this.vip_line.visible = false;
        }
        private function clickText(_arg1:TextEvent):void{
            switch (_arg1.text){
                case "login":
                    Tools.stat("b=trialEndLogin");
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.Login));
                    break;
                case "home":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.GoHome));
                    break;
            };
        }
        private function onViewClick(_arg1:MouseEvent):void{
            Tools.stat("b=trialEndViewAndPlay");
            dispatchEvent(new TryPlayEvent(TryPlayEvent.ViewList));
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new TryPlayEvent(TryPlayEvent.HidePanel));
        }

    }
}//package ctr.tryplay 
﻿package ctr.tryplay {
    import com.global.*;
    import flash.display.*;
    import flash.events.*;
    import com.common.*;
    import eve.*;
    import flash.text.*;

    public class TryEndFace extends MovieClip {

        public var buy_btn:SimpleButton;
        public var one_btn:SimpleButton;
        public var buy_txt:TextField;
        public var close_btn:SimpleButton;
        private var _time:Number = 0;
        private var _isTrial:Boolean;

        public function TryEndFace(){
            if ((((Tools.getUserInfo("userid") == "0")) || ((Tools.getUserInfo("sessionid") == null)))){
                this.buy_txt.visible = true;
            } else {
                this.buy_txt.visible = false;
            };
            var _local1:StyleSheet = new StyleSheet();
            _local1.setStyle("a", {textDecoration:"underline"});
            this.buy_txt.styleSheet = _local1;
            this.buy_txt.htmlText = "<a href='event:login'>会员登录</a>";
            this.buy_txt.addEventListener(TextEvent.LINK, this.clickText);
            this.one_btn.addEventListener(MouseEvent.CLICK, this.onBuyClick);
            this.buy_btn.addEventListener(MouseEvent.CLICK, this.onBuyClick);
            this.close_btn.visible = false;
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
        }
        public function setTime(_arg1:Number):void{
            this._time = _arg1;
        }
        public function set isTrial(_arg1:Boolean):void{
            this._isTrial = _arg1;
        }
        public function setPosition():void{
            this.x = int(((stage.stageWidth - 726) / 2));
            this.y = int((((stage.stageHeight - 350) - 33) / 2));
        }
        private function clickText(_arg1:TextEvent):void{
            switch (_arg1.text){
                case "login":
                    Tools.stat("b=trialEndLogin");
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.Login));
                    break;
            };
        }
        private function onBuyClick(_arg1:MouseEvent):void{
            var _local2:String = Tools.getReferfrom();
            var _local3:String = ((this._isTrial) ? GlobalVars.instance.paypos_tryfinish : GlobalVars.instance.paypos_trystop);
            if (_arg1.currentTarget == this.one_btn){
                dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyTime, {
                    refer:_local2,
                    paypos:GlobalVars.instance.paypos_time
                }));
            } else {
                dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                    refer:_local2,
                    paypos:_local3
                }));
            };
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new TryPlayEvent(TryPlayEvent.HidePanel));
        }

    }
}//package ctr.tryplay 
﻿package ctr.tryplay {
    import com.global.*;
    import flash.display.*;
    import flash.events.*;
    import com.common.*;
    import eve.*;
    import flash.text.*;

    public class TryPauseFace extends MovieClip {

        public var buy_btn:SimpleButton;
        public var time_txt:TextField;
        public var home_btn:SimpleButton;
        public var update_btn:SimpleButton;
        public var resume_btn:SimpleButton;
        public var time_mc:MovieClip;
        public var close_btn:SimpleButton;

        public function TryPauseFace(){
            var _local1:Number = Number(Tools.getUserInfo("userType"));
            if ((((_local1 == 2)) && (!((Tools.getUserInfo("from") == GlobalVars.instance.fromXLPan))))){
                this.buy_btn.visible = false;
                this.update_btn.visible = true;
            } else {
                this.buy_btn.visible = true;
                this.update_btn.visible = false;
            };
            this.home_btn.addEventListener(MouseEvent.CLICK, this.onHomeClick);
            this.resume_btn.addEventListener(MouseEvent.CLICK, this.onResumeClick);
            this.buy_btn.addEventListener(MouseEvent.CLICK, this.onBuyClick);
            this.update_btn.addEventListener(MouseEvent.CLICK, this.onBuyClick);
            this.close_btn.visible = false;
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
        }
        public function setTime(_arg1:Number):void{
            var _local2:Array = this.calculateTimes(_arg1).split("_");
            var _local3:String = _local2[0];
            var _local4:uint = _local2[1];
            this.time_txt.text = _local3;
            this.time_mc.gotoAndStop(_local4);
        }
        public function setPosition():void{
            this.x = int((stage.stageWidth / 2));
            this.y = int(((stage.stageHeight - 33) / 2));
        }
        private function calculateTimes(_arg1:Number):String{
            _arg1 = Math.floor(_arg1);
            var _local2:Number = 0;
            var _local3:Number = 0;
            if (isNaN(_arg1)){
                _arg1 = 0;
            };
            if ((_arg1 / 3600) >= 1){
                _local2 = (Math.floor(((_arg1 / 3600) * 10)) / 10);
                return ((_local2 + "_1"));
            };
            if ((_arg1 / 60) >= 1){
                _local3 = Math.floor((_arg1 / 60));
                return ((_local3 + "_2"));
            };
            return ((((_arg1 == 0)) ? "0_4" : (_arg1.toString() + "_3")));
        }
        private function onHomeClick(_arg1:MouseEvent):void{
            Tools.stat("b=trialPauseToHomePage");
            dispatchEvent(new TryPlayEvent(TryPlayEvent.GoHome));
        }
        private function onResumeClick(_arg1:MouseEvent):void{
            Tools.stat("b=trialPauseResume");
            dispatchEvent(new TryPlayEvent(TryPlayEvent.Resume));
        }
        private function onBuyClick(_arg1:MouseEvent):void{
            if (_arg1.currentTarget == this.buy_btn){
                Tools.stat("b=trialPauseBuyVIP");
            } else {
                Tools.stat("b=trialPauseUpgradeVIP");
            };
            var _local2:String = Tools.getReferfrom();
            var _local3:String = GlobalVars.instance.paypos_trying;
            dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                refer:_local2,
                paypos:_local3
            }));
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new TryPlayEvent(TryPlayEvent.HidePanel));
        }

    }
}//package ctr.tryplay 
﻿package ctr.tryplay {
    import com.global.*;
    import flash.display.*;
    import flash.events.*;
    import com.common.*;
    import eve.*;
    import flash.text.*;

    public class TimeTryEndFace extends MovieClip {

        public var desc_txt:TextField;
        public var buy_btn:SimpleButton;
        public var time_txt:TextField;
        public var more_mc:MovieClip;
        public var update_btn:SimpleButton;
        public var buy_txt:TextField;
        public var close_btn:SimpleButton;
        private var _time:Number = 0;
        private var _isTrial:Boolean;

        public function TimeTryEndFace(){
            var _local1:Number = Number(Tools.getUserInfo("userType"));
            if ((((_local1 == 2)) && (!((Tools.getUserInfo("from") == GlobalVars.instance.fromXLPan))))){
                this.desc_txt.text = "白金会员 = 不限时云播放 + 1000G高速流量 + 迅雷VIP尊享版 + ...";
                this.update_btn.visible = true;
                this.buy_btn.visible = false;
            } else {
                this.desc_txt.text = "白金会员 = 不限时云播放 + 高速下载 + 迅雷VIP尊享版（清爽轻快） + ...";
                this.update_btn.visible = false;
                this.buy_btn.visible = true;
            };
            if ((((Tools.getUserInfo("userid") == "0")) || ((Tools.getUserInfo("sessionid") == null)))){
                this.buy_txt.visible = true;
            } else {
                this.buy_txt.visible = false;
            };
            var _local2:StyleSheet = new StyleSheet();
            _local2.setStyle("a", {textDecoration:"underline"});
            this.buy_txt.styleSheet = _local2;
            this.buy_txt.htmlText = "<a href='event:login'>会员登录</a>";
            this.buy_txt.addEventListener(TextEvent.LINK, this.clickText);
            this.more_mc.more_txt.htmlText = "更多云播放功能尽在<font color='#3B8FE0'><a href='event:home'>vod.xunlei.com</a></font>";
            this.more_mc.more_txt.addEventListener(TextEvent.LINK, this.clickText);
            this.buy_btn.addEventListener(MouseEvent.CLICK, this.onBuyClick);
            this.update_btn.addEventListener(MouseEvent.CLICK, this.onBuyClick);
            this.close_btn.visible = false;
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
        }
        public function setTime(_arg1:Number):void{
            this._time = _arg1;
            var _local2:Array = this.calculateTimes(_arg1).split("_");
            var _local3:String = _local2[0];
            this.time_txt.htmlText = "您的可播放时长剩余<font color='#FF0000'>0</font>，迅雷白金会员不限时长";
        }
        public function set isTrial(_arg1:Boolean):void{
            this._isTrial = _arg1;
        }
        public function setPosition():void{
            this.x = int(((stage.stageWidth - 466) / 2));
            this.y = int((((stage.stageHeight - 251) - 33) / 2));
        }
        private function calculateTimes(_arg1:Number):String{
            _arg1 = Math.floor(_arg1);
            var _local2:Number = 0;
            var _local3:Number = 0;
            if (isNaN(_arg1)){
                _arg1 = 0;
            };
            if ((_arg1 / 3600) >= 1){
                _local2 = (Math.floor(((_arg1 / 3600) * 10)) / 10);
                return ((_local2 + "_1"));
            };
            if ((_arg1 / 60) >= 1){
                _local3 = Math.floor((_arg1 / 60));
                return ((_local3 + "_2"));
            };
            return ((((_arg1 == 0)) ? "0_4" : (_arg1.toString() + "_3")));
        }
        private function clickText(_arg1:TextEvent):void{
            switch (_arg1.text){
                case "login":
                    Tools.stat("b=trialEndLogin");
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.Login));
                    break;
                case "home":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.GoHome));
                    break;
            };
        }
        private function onBuyClick(_arg1:MouseEvent):void{
            var _local2:String = Tools.getReferfrom();
            var _local3:String = ((this._isTrial) ? GlobalVars.instance.paypos_tryfinish : GlobalVars.instance.paypos_trystop);
            if (this._isTrial){
                dispatchEvent(new TryPlayEvent(TryPlayEvent.ShowViewList, {
                    refer:_local2,
                    paypos:_local3
                }));
            } else {
                dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                    refer:_local2,
                    paypos:_local3
                }));
            };
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new TryPlayEvent(TryPlayEvent.HidePanel));
        }

    }
}//package ctr.tryplay 
﻿package eve {
    import flash.events.*;

    public class TryPlayEvent extends Event {

        public static const BuyVIP:String = "buy_vip";
        public static const UpdateVIP:String = "update_vip";
        public static const GoHome:String = "go_home";
        public static const Resume:String = "resume";
        public static const ViewList:String = "view_list";
        public static const HidePanel:String = "hide_panel";
        public static const ShowViewList:String = "show_view_list";
        public static const Login:String = "login";
        public static const GetBytes:String = "get_bytes";
        public static const DontNoticeBytes:String = "dont_notice_bytes";
        public static const BuyTime:String = "buy_time";

        private var _info:Object;

        public function TryPlayEvent(_arg1:String, _arg2:Object=null){
            super(_arg1, true);
            this._info = _arg2;
        }
        public function get info():Object{
            return (this._info);
        }

    }
}//package eve 
﻿package com.common {
    import com.global.*;
    import flash.display.*;
    import flash.geom.*;
    import flash.net.*;
    import ctr.tip.*;
    import flash.external.*;

    public class Tools {

        private static var _mainMc:Sprite;
        private static var _snptBmd:BitmapData;

        public static function getUserInfo(_arg1:String):String{
            var _local2:GlobalVars = GlobalVars.instance;
            if (((((!(_local2.curFileInfo)) || (!(_local2.curFileInfo.hasOwnProperty(_arg1))))) || ((_local2.curFileInfo[_arg1] === "")))){
                if ((((_arg1 == "userid")) || ((_arg1 == "filesize")))){
                    return ("0");
                };
                return (null);
            };
            return (_local2.curFileInfo[_arg1]);
        }
        public static function setUserInfo(_arg1:String, _arg2:String):void{
            var _local3:GlobalVars = GlobalVars.instance;
            if (_local3.curFileInfo){
                _local3.curFileInfo[_arg1] = _arg2;
            };
        }
        public static function transDate(_arg1:Number):String{
            var _local2:Date = new Date((_arg1 * 1000));
            return (((((_local2.month + 1) + "月") + _local2.date) + "日"));
        }
        public static function cutScreenShot(_arg1:BitmapData, _arg2:Point):BitmapData{
            var _local3:GlobalVars = GlobalVars.instance;
            if (_snptBmd){
                _snptBmd.dispose();
                _snptBmd = null;
            };
            _snptBmd = new BitmapData(_local3.iframeWidth, _local3.iframeHeight);
            _snptBmd.copyPixels(_arg1, new Rectangle(_arg2.x, _arg2.y, _local3.iframeWidth, _local3.iframeHeight), new Point(0, 0));
            return (_snptBmd);
        }
        public static function getReferfrom():String{
            var _local1:GlobalVars = GlobalVars.instance;
            var _local2:Object = _local1.curFileInfo;
            if (!_local2){
                return (null);
            };
            var _local3:Object = _local1.referMaps;
            if (_local2.from.indexOf("lxlua") >= 0){
                return (_local3["lxlua"]);
            };
            if (_local2.from.indexOf("xl_lixian") >= 0){
                return (_local3["xl_lixian"]);
            };
            if (_local2.from.indexOf("xl_scene") >= 0){
                return (_local3["xl_scene"]);
            };
            if (_local3[_local2.from]){
                return (_local3[_local2.from]);
            };
            return (_local3["defaultReferer"]);
        }
        public static function getFormat():void{
            if (ExternalInterface.available){
                ExternalInterface.call("G_PLAYER_INSTANCE.getFormats");
            };
        }
        public static function setFormatCallBack(_arg1:String, _arg2:Boolean):void{
            if (ExternalInterface.available){
                ExternalInterface.call("G_PLAYER_INSTANCE.setFormatsCallback", _arg1, _arg2);
            };
        }
        public static function windowOpen(_arg1:String, _arg2:String="_blank", _arg3:String=""):void{
            ExternalInterface.call("G_PLAYER_INSTANCE.windowOpen", _arg1, _arg2, _arg3);
        }
        public static function stat(_arg1:String):void{
            var _local2:Object = GlobalVars.instance.curFileInfo;
            if (!_local2){
                return;
            };
            var _local3 = "XCVP";
            var _local4:Number = ((_local2.userid) || (0));
            var _local5:Number = ((_local2.isvip) || (0));
            var _local6:String = ((_local2.userType) || (null));
            var _local7:String = encodeURIComponent(((_local2.from) || ("XCVP")));
            var _local8:Number = new Date().time;
            var _local9:String = ((((((((((((((GlobalVars.instance.staticsUrl + "p=") + _local3) + "&u=") + _local4) + "&v=") + _local5) + "&usertype=") + _local6) + "&from=") + _local7) + "&d=") + _local8) + "&") + _arg1);
            var _local10:URLRequest = new URLRequest(_local9);
            sendToURL(_local10);
        }
        public static function statToJS(_arg1:Object):void{
            ExternalInterface.call("XL_CLOUD_FX_INSTANCE.stat", _arg1);
        }
        public static function formatBytes(_arg1:Number):String{
            var _local2 = "MB";
            _arg1 = (_arg1 / (0x0400 * 0x0400));
            if (_arg1 > 0x0400){
                _local2 = "GB";
                _arg1 = (_arg1 / 0x0400);
            };
            _arg1 = (Math.round((_arg1 * 100)) / 100);
            return ((_arg1 + _local2));
        }
        public static function calculateTimes(_arg1:Number):String{
            _arg1 = Math.floor(_arg1);
            var _local2:Number = 0;
            var _local3:Number = 0;
            if (isNaN(_arg1)){
                _arg1 = 0;
            };
            if ((_arg1 / 3600) >= 1){
                _local2 = (Math.floor(((_arg1 / 3600) * 10)) / 10);
                return ((_local2 + "小时"));
            };
            if ((_arg1 / 60) >= 1){
                _local3 = Math.floor((_arg1 / 60));
                return ((_local3 + "分钟"));
            };
            return ((((_arg1 == 0)) ? "0" : (_arg1.toString() + "秒")));
        }
        public static function getTimeUnit(_arg1:Number):uint{
            _arg1 = Math.floor(_arg1);
            var _local2:Number = 0;
            var _local3:Number = 0;
            if (isNaN(_arg1)){
                _arg1 = 0;
            };
            if ((_arg1 / 3600) >= 1){
                return (1);
            };
            if ((_arg1 / 60) >= 1){
                return (2);
            };
            return ((((_arg1 == 0)) ? 4 : 3));
        }
        public static function formatTimes(_arg1:Number):String{
            _arg1 = Math.floor(_arg1);
            var _local2:Number = 0;
            var _local3:Number = 0;
            if (isNaN(_arg1)){
                _arg1 = 0;
            };
            if ((_arg1 / 3600) >= 1){
                _local2 = Math.floor((_arg1 / 3600));
                _arg1 = (_arg1 - (_local2 * 3600));
            };
            if ((_arg1 / 60) >= 1){
                _local3 = Math.floor((_arg1 / 60));
                _arg1 = (_arg1 - (_local3 * 60));
            };
            return ((((((((_local2 < 10)) ? ("0" + _local2) : _local2) + ":") + (((_local3 < 10)) ? ("0" + _local3) : _local3)) + ":") + (((_arg1 < 10)) ? ("0" + _arg1) : _arg1)));
        }
        public static function registerToolTip(_arg1:Sprite):void{
            _mainMc = _arg1;
            new ToolTip(_mainMc);
        }
        public static function showToolTip(_arg1:String):void{
            ToolTip.show(_arg1);
        }
        public static function hideToolTip():void{
            ToolTip.hide();
        }
        public static function moveToolTip():void{
            ToolTip.move((_mainMc.stage.mouseX + 10), (_mainMc.stage.mouseY + 45));
        }
        public static function moveToolTipToPoint(_arg1:Number, _arg2:Number):void{
            ToolTip.move(_arg1, _arg2);
        }
        public static function get toolTipWidth():Number{
            return (ToolTip.width);
        }

    }
}//package com.common 
﻿package com.common {
    import flash.net.*;
    import flash.events.*;
    import flash.external.*;

    public class JTracer {

        private static var conn:LocalConnection;

        public static function sendMessage(_arg1):void{
            var text:* = _arg1;
            try {
                sendLoaclMsg(text);
                ExternalInterface.call("G_PLAYER_INSTANCE.trace", ("mp4_player_debug----" + text));
            } catch(e:Error) {
                trace(e.message);
            };
        }
        public static function sendLoaclMsg(_arg1):void{
            var _local2:LocalConnection = init();
            _local2.send("_myConnection", "lcHandler", _arg1);
        }
        private static function init():LocalConnection{
            if (conn){
                return (conn);
            };
            conn = new LocalConnection();
            conn.addEventListener(StatusEvent.STATUS, onStatus);
            return (conn);
        }
        private static function onStatus(_arg1:StatusEvent):void{
            switch (_arg1.level){
                case "status":
                    break;
                case "error":
                    break;
            };
        }

    }
}//package com.common 
﻿package com.global {
    import com.common.*;

    public class GlobalVars {

        private static var _instance:GlobalVars;

        private var _streamLinkType:String = "p2p";
        private var _streamType:String = "flv";
        private var _streamVcut:Boolean = false;
        public var loadTime:Object;
        public var getVodTime:int;
        private var _codeRate:String = "未知";
        private var _videoRealSize:Object;
        private var _videoPlaySize:Object;
        private var _flashPlayerVer:String;
        private var _stageVideo:Boolean = false;
        private var _decode:String = "软件解码";
        private var _svAvailable:Boolean = false;
        public var movieType:String = "teleplay";
        public var windowMode:String = "browser";
        public var enableShare:Boolean;
        public var isToolsToPause:Boolean;
        public var preFeeTime:Number;
        public var nowFeeTime:Number;
        public var feeInterval:Number = 300000;
        public var curFileInfo:Object;
        public var isExchangeError:Boolean;
        public var movieFormat:String;
        public var customLevel:uint = 0;
        public var defaultFormatChanged:Boolean;
        public var ratioChanged:Boolean;
        public var colorChanged:Boolean;
        public var captionStyleChanged:Boolean;
        public var captionTimeChanged:Boolean;
        public var isCaptionListLoaded:Boolean;
        public var isCaptionStyleLoaded:Boolean;
        public var isCaptionTimeLoaded:Boolean;
        public var isHasAutoloadCaption:Boolean;
        public var iframeRow:uint = 10;
        public var iframeCol:uint = 10;
        public var iframeWidth:Number = 160;
        public var iframeHeight:Number = 90;
        public var bufferType:int = 0;
        public var bufferTypeCustom:int = -2;
        public var bufferTypeFirstBuffer:int = -3;
        public var bufferTypeChangeFormat:int = -4;
        public var bufferTypeDrag:int = -5;
        public var bufferTypeKeyPress:int = -6;
        public var bufferTypePreview:int = -7;
        public var bufferTypeError:int = -8;
        public var showLowSpeedTipsInterval:int = 300;
        public var showBufferMax:int = 3;
        public var showLowSpeedTimeArray:Array;
        public var isHideLowSpeedTips:Boolean;
        public var isHasShowLowSpeedTips:Boolean;
        public var startLowSpeedTipsTime:int = 0;
        public var curLowSpeedTipsTime:int = 0;
        public var showHighSpeedTipsInterval:int = 300;
        public var curHighSpeedTipsTime:int = 0;
        public var showHighSpeedTipsAverageSpeedInterval:int = 300;
        public var showGaoQingTipsSpeed:int = 300;
        public var showChaoQingTipsSpeed:int = 450;
        public var isShowHighSpeedTips:Boolean = true;
        public var isHasShowHighSpeedTips:Boolean;
        public var platform:String;
        public var isStat:Boolean = true;
        public var hasSubtitle:Boolean;
        public var isUseHttpSocket:Boolean = false;
        public var isUseSocket:Boolean = false;
        public var isVodGetted:Boolean;
        public var vodURL:String;
        public var vodURLList:Array;
        public var allURLList:Array;
        public var isReplaceURL:Boolean;
        public var isChangeURL:Boolean;
        public var isFirstBuffer302:Boolean = true;
        public var linkNum:int;
        public var paypos_tips:String = "1";
        public var paypos_trying:String = "2";
        public var paypos_tryfinish:String = "3";
        public var paypos_trystop:String = "4";
        public var paypos_tips_time:String = "5";
        public var paypos_time:String = "6";
        public var referMaps:Object;
        public var fromXLPan:String = "xlpan";
        public var tryTotalTime:Number = 60000;
        public var tryStopTime:Number = 300000;
        public var tryNowTime:Number = -499;
        public var tryDownloadTime:Number = 600000;
        public var tryNowDownloadTime:Number = -499;
        public var tryPauseTime:Number = 20000;
        public var buyFlow:String = "http://pay.vip.xunlei.com/vod.html?refresh=2";
        public var buyTime:String = "http://pay.vip.xunlei.com/vodcard";
        public var freeFlow:String = "http://act.vip.xunlei.com/vodfree/";
        public var checkUser:String = "http://i.vod.xunlei.com/check_user_info";
        public var deductFlow:String = "http://i.vod.xunlei.com/flux_deduct/";
        public var checkFlowUrl:String = "http://i.vod.xunlei.com/flux_query/";
        public var urlScreenShot:String = "http://i.vod.xunlei.com/req_screenshot?jsonp=xxx";
        public var btScreenShot:String = "http://i.vod.xunlei.com/req_screenshot?jsonp=xxx";
        public var searchCaption:String = "http://www.shooter.cn/";
        public var captionItem:String = "http://i.vod.xunlei.com/subtitle/data/scid/";
        public var login:String = "http://vod.xunlei.com/home.html#login=logout";
        public var newWindow:String = "http://10.10.2.201:8801/player.html";
        public var btFileUrl:String = "http://bt.box.n0808.com/";
        public var staticsUrl:String = "http://stat.vod.xunlei.com/stat/s.gif?";
        public var feedbackUrl:String = "http://i.vod.xunlei.com/feedback";
        public var iframeUrl:String = "http://i.vod.xunlei.com/req_screensnpt_url";
        public var chome:String = "http://vod.xunlei.com/client/chome.html";
        public var home:String = "http://vod.xunlei.com/home.html";
        public var saveCaptionStyle:String = "http://i.vod.xunlei.com/subtitle/preference/font";
        public var getCaptionStyle:String = "http://i.vod.xunlei.com/subtitle/preference/font";
        public var getCaptionContent:String = "http://i.vod.xunlei.com/subtitle/content";
        public var getCaptionList:String = "http://i.vod.xunlei.com/subtitle/list";
        public var saveAutoloadCaption:String = "http://i.vod.xunlei.com/subtitle/autoload";
        public var getAutoloadCaption:String = "http://i.vod.xunlei.com/subtitle/autoload";
        public var saveCaptionTimeDelta:String = "http://i.vod.xunlei.com/subtitle/preference/time";
        public var getCaptionTimeDelta:String = "http://i.vod.xunlei.com/subtitle/preference/time";
        public var gradeCaption:String = "http://i.vod.xunlei.com/subtitle/grade";
        public var lastLoadCaption:String = "http://i.vod.xunlei.com/subtitle/last_load";

        public function GlobalVars(){
            this._videoRealSize = {
                width:0,
                height:0
            };
            this._videoPlaySize = {
                width:0,
                height:0
            };
            this.showLowSpeedTimeArray = [];
            this.vodURLList = [];
            this.allURLList = [];
            this.referMaps = {
                disanlan_btn:"XV_19",
                disanlan_trylink:"XV_20",
                disanlan_tip:"XV_21",
                vodHome:"XV_22",
                vlist:"XV_23",
                vodClientHome:"XV_24",
                vodClientList:"XV_25",
                vodClientPlayer:"XV_27",
                xl_scene:"XV_15",
                xl_lixian:"XV_26",
                lxlua:"XV_26",
                bho_play:"XV_30",
                kuaichuan_web:"XV_31",
                defaultReferer:"XV_26"
            };
            super();
        }
        public static function get instance():GlobalVars{
            if (!_instance){
                _instance = new (GlobalVars)();
            };
            return (_instance);
        }

        public function get streamLinkType():String{
            return (this._streamLinkType);
        }
        public function set streamLinkType(_arg1:String):void{
            this._streamLinkType = _arg1;
        }
        public function get streamType():String{
            return (this._streamType);
        }
        public function set streamType(_arg1:String):void{
            this._streamType = _arg1;
        }
        public function get streamVcut():Boolean{
            return (this._streamVcut);
        }
        public function set streamVcut(_arg1:Boolean):void{
            this._streamVcut = _arg1;
        }
        public function get codeRate():String{
            return ((this._codeRate + "Kbps"));
        }
        public function set codeRate(_arg1:String):void{
            this._codeRate = _arg1;
        }
        public function get videoRealSize():Object{
            return (this._videoRealSize);
        }
        public function set videoRealSize(_arg1:Object):void{
            this._videoRealSize.width = _arg1.width;
            this._videoRealSize.height = _arg1.height;
        }
        public function get videoPlaySize():Object{
            return (this._videoPlaySize);
        }
        public function set videoPlaySize(_arg1:Object):void{
            this._videoPlaySize.width = _arg1.width;
            this._videoPlaySize.height = _arg1.height;
        }
        public function get flashPlayerVer():String{
            return (this._flashPlayerVer);
        }
        public function set flashPlayerVer(_arg1:String):void{
            this._flashPlayerVer = _arg1;
        }
        public function get stageVideo():Boolean{
            return (this._stageVideo);
        }
        public function set stageVideo(_arg1:Boolean):void{
            this._stageVideo = _arg1;
        }
        public function get decode():String{
            return (this._decode);
        }
        public function set decode(_arg1:String):void{
            if (_arg1 == "software"){
                this._decode = "软件解码";
            } else {
                if (_arg1 == "accelerated"){
                    this._decode = "硬件解码";
                };
            };
        }
        public function set svAvailable(_arg1:Boolean):void{
            JTracer.sendLoaclMsg(("set svAvailable:" + _arg1));
            this._svAvailable = _arg1;
        }
        public function get svAvailable():Boolean{
            return (this._svAvailable);
        }

    }
}//package com.global