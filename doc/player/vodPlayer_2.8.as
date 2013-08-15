package {
    import flash.display.*;

    public dynamic class RightMenuBg extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BtnWindow extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class PlayButtonTop extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BtnFileList extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class FormatBg extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetCommitButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BufferLoading extends MovieClip {

        public var buffer_mc:MovieClip;
        public var loadingtext:TextField;

    }
}//package 
﻿package {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.*;
    import com.common.*;
    import flash.ui.*;
    import ctr.subtitle.*;
    import com.slice.*;
    import eve.*;
    import ctr.setting.*;
    import com.notice.*;
    import flash.filters.*;
    import ctr.contextMenu.*;
    import com.serialization.json.*;
    import ctr.statuMenu.*;
    import ctr.fileList.*;
    import ctr.download.*;
    import ctr.question.*;
    import ctr.share.*;
    import ctr.toolBarTop.*;
    import ctr.toolBarRight.*;
    import ctr.addBytes.*;
    import flash.text.*;
    import flash.external.*;
    import flash.system.*;

    public class PlayerCtrl extends Sprite {

        private const NORMAL_PROGRESSBAR_HEIGTH:uint = 7;
        private const SMALL_PROGRESSBAR_HEIGTH:uint = 3;

        public var _ctrBar:CtrBar;
        public var _player:Player;
        public var _isError:Boolean = false;
        public var _videoMask:VideoMask;
        private var _screenEvent:Sprite;
        private var _playFullWidth:Number;
        private var _playFullHeight:Number;
        public var _bufferTip:bufferTip;
        private var _noticeBar:NoticeBar;
        private var _settingSpace:SettingSpace;
        private var _captionFace:CaptionFace;
        private var _fileListFace:FileListFace;
        private var _downloadFace:DownloadFace;
        private var _feedbackFace:FeedbackFace;
        private var _shareFace:ShareFace;
        private var _toolTopFace:ToolBarTop;
        private var _toolRightFace:ToolBarRight;
        private var _toolRightArrow:ToolBarRightArrow;
        private var _showRightTimer:Timer;
        private var _hideRightTimer:Timer;
        private var _isInitialize:Boolean = false;
        private var _mouseControl:MouseControl;
        private var _playerSize:int = 0;
        private var _playerRealWidth:Number;
        private var _playerRealHeight:Number;
        private var _isDoubleClick:Boolean = false;
        private var _isFullScreen:Boolean = false;
        private var _movieType:String;
        private var _isBuffering:Boolean;
        private var _seekDelayTimer:Timer;
        private var _seekDelayTimer2:Timer;
        private var _noticeMsgArr:Array;
        private var _isFirstLoad:Boolean = true;
        private var _isChangeQuality:Boolean = false;
        private var _ratioVideo:Number = 0;
        private var _setSizeInfo:Object;
        private var _seekEnable:Boolean = true;
        private var _subTitle:Subtitle;
        private var _isPressKeySeek:Boolean;
        private var _checkUserLoader:URLLoader;
        private var _checkFlowLoader:URLLoader;
        private var _iframeLoader:URLLoader;
        private var _snptLoader:Loader;
        private var _isValid:Boolean = true;
        private var _isNoEnoughBytes:Boolean;
        private var _addBytesFace:AddBytesFace;
        private var _noEnoughFace:NoEnoughBytesFace;
        private var _tryEndFace:MovieClip;
        private var _videoUrlArray:Array;
        private var _isFirstTips:Boolean = true;
        private var _isFirstListTips:Boolean = true;
        private var _isFirstRemainTips:Boolean = true;
        private var _isStopNormal:Boolean;
        private var _isFirstOnplaying:Boolean = true;
        private var _isReported:Boolean = false;
        private var _playerTxtTips:TextField;
        private var _playerTxtTipsID:uint;
        private var _remainTimes:Number;
        private var _expiresTime:Number;
        private var _isFlowChecked:Boolean;
        private var _isPlayStart:Boolean;
        private var _isPauseForever:Boolean;
        private var _isShowStopFace:Boolean;
        private var _snptIndex:uint;
        private var _snptArray:Array;
        private var _snptAllArray:Array;
        private var _snptBmdArray:Array;
        private var _isReportedScreenShotError:Boolean;
        private var _formatsObj:Object;
        private var _lastMouseDelta:Number = 0;
        private var _curMouseDelta:Number = 0;
        private var _timeIntervalID:int;
        private var _filterIntervalID:int;
        private var _lastKeyDelta:Number = 0;
        private var _curKeyDelta:Number = 0;
        private var _keyDeltaID:int;
        private var _isPanelLoaded:Boolean;
        private var _panelLoader:Loader;
        private var _completeFunc:Function;
        private var _isShowAutoloadTips:Boolean;
        private var _isSnptLoaded:Boolean;

        public function PlayerCtrl(){
            this._noticeMsgArr = ["广告时间，请稍候，马上为您播放精彩节目!", "当前网速较慢，建议<a href=\"event:pause\">暂停</a>缓冲几分钟", "当前网速较慢，建议<a href=\"event:pause\">暂停</a>缓冲几分钟或切换成<a href=\"event:changeLowerQulity\">标清模式</a>", "正在为您预下载数据，建议暂停 <font color=\"#ff0000\">5分钟</font> 后再观看，播放会更流畅", "系统默认已经为您跳过片头", "您已设置启用硬件加速，刷新页面或下次打开页面时生效", "正在切换至传统播放模式，请稍候..."];
            this._setSizeInfo = {
                ratio:"common",
                size:"100",
                ratioValue:0,
                sizeValue:1
            };
            this._snptArray = [];
            this._snptAllArray = [];
            this._snptBmdArray = [];
            super();
            Security.allowDomain("*");
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.tabChildren = false;
            this._isInitialize = false;
            CreateContextMenu.createMenu(this);
            CreateContextMenu.addItem("播放特权播放器：2.8.94.20130513", false, false, null);
            stage.addEventListener(Event.RESIZE, this.on_stage_RESIZE);
            stage.dispatchEvent(new Event(Event.RESIZE));
            this._checkUserLoader = new URLLoader();
            this._checkUserLoader.addEventListener(Event.COMPLETE, this.onCheckUserComplete);
            this._checkUserLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onCheckUserIOError);
            this._checkUserLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onCheckUserSecurityError);
            this._checkFlowLoader = new URLLoader();
            this._checkFlowLoader.addEventListener(Event.COMPLETE, this.onCheckFlowComplete);
            this._checkFlowLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onCheckFlowIOError);
            this._checkFlowLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onCheckFlowSecurityError);
        }
        private function get isValidPlayer():Boolean{
            var _local6:String;
            var _local7:String;
            var _local8:int;
            var _local1 = "";
            var _local2 = "xunlei.com";
            var _local3:String = ExternalInterface.call("function(){return document.location.host;}");
            var _local4:Boolean;
            var _local5:RegExp;
            if (ExternalInterface.available){
                _local1 = loaderInfo.url;
                _local1 = _local1.replace(/(http:\/\/)/, "");
                _local1 = _local1.slice(0, _local1.indexOf("/"));
                _local2 = _local2.replace(/\./g, "\\.").replace(/\*/g, "\\.*");
                _local5 = new RegExp((("(" + _local2) + ")"), "i");
                if (((_local5.test(_local1)) && (_local5.test(_local3)))){
                    _local4 = true;
                } else {
                    return (false);
                };
                ExternalInterface.call("window.console.log", ("get isXLDomain:" + _local4));
                _local6 = Tools.getDocumentCookieWithKey("sessionid");
                _local7 = Tools.getDocumentCookieWithKey("userid");
                _local8 = int(Tools.getDocumentCookieWithKey("usertype"));
                if ((((_local7 == "")) || ((_local6 == "")))){
                    _local4 = false;
                };
                if ((((_local8 >= 0)) && ((_local8 <= 3)))){
                    _local4 = true;
                } else {
                    _local4 = false;
                };
                ExternalInterface.call("window.console.log", ((((("userid:" + _local7) + " sessionid:") + _local6) + " usertype:") + _local8));
            };
            return (_local4);
        }
        public function setSystemTime():void{
            var _local1:Date = new Date();
            var _local2:Number = _local1.getHours();
            var _local3:Number = _local1.getMinutes();
            var _local4:String = (((_local2 >= 10)) ? _local2.toString() : ("0" + _local2.toString()));
            var _local5:String = (((_local3 >= 10)) ? _local3.toString() : ("0" + _local3.toString()));
            this._toolTopFace.setSystemTime(((_local4 + ":") + _local5));
        }
        public function exchangeVideo():void{
            this._subTitle.hideCaption({
                surl:null,
                scid:null
            });
            this._captionFace.clearCaption();
            this._downloadFace.setAllDisabled();
        }
        public function playNext():void{
            this._fileListFace.playNext();
        }
        public function showInvalidLoginLogo():void{
            this._isValid = false;
            this._isStopNormal = false;
            this._isShowStopFace = false;
            this._player.startPosition = this._player.time;
            this._ctrBar.dispatchStop();
            this._videoMask.showErrorNotice(VideoMask.invalidLogin);
        }
        public function showPlayError(_arg1:String):void{
            this._isStopNormal = false;
            this._isShowStopFace = false;
            this._ctrBar.dispatchStop();
            this._videoMask.showErrorNotice(VideoMask.playError, _arg1);
        }
        public function showAddBytesFace(_arg1:Number, _arg2:Number, _arg3:Number):void{
            var _local4:int;
            if (_arg2 <= 0){
                this._isNoEnoughBytes = true;
                if (!this._player.isStop){
                    this._ctrBar.dispatchPause();
                };
                if (!this._noEnoughFace){
                    _local4 = this.getChildIndex(this._captionFace);
                    this._noEnoughFace = new NoEnoughBytesFace();
                    this._noEnoughFace.addEventListener("CloseNoEnoughFace", this.onCloseNoEnoughFace);
                    addChildAt(this._noEnoughFace, _local4);
                    this._noEnoughFace.setPosition();
                };
                return;
            };
        }
        private function onCloseNoEnoughFace(_arg1:Event):void{
            if (this._noEnoughFace){
                removeChild(this._noEnoughFace);
                this._noEnoughFace = null;
            };
            this._isStopNormal = false;
            this._isShowStopFace = false;
            this._ctrBar.dispatchStop();
            this._videoMask.showErrorNotice(VideoMask.noEnoughBytes);
        }
        private function onCloseAddBytesFace(_arg1:Event):void{
            if (!this._player.isStop){
                this._ctrBar.dispatchPlay();
            };
            if (this._addBytesFace){
                removeChild(this._addBytesFace);
                this._addBytesFace = null;
            };
        }
        public function checkIsValid():void{
            ExternalInterface.call("XL_CLOUD_FX_INSTANCE.uUpdate");
            Tools.setUserInfo("sessionid", ExternalInterface.call("G_PLAYER_INSTANCE.getParamInfo", "sessionid"));
            var _local1:String = Tools.getUserInfo("userid");
            var _local2:String = Tools.getUserInfo("sessionid");
            var _local3 = "1.2.3.4";
            var _local4:String = Tools.getUserInfo("from");
            var _local5:String = ((((((((((GlobalVars.instance.url_check_account + "?userid=") + _local1) + "&sessionid=") + _local2) + "&ip=") + _local3) + "&from=") + _local4) + "&r=") + Math.random());
            JTracer.sendMessage(("PlayerCtrl -> check is valid start, url:" + _local5));
            var _local6:URLRequest = new URLRequest(_local5);
            this._checkUserLoader.load(_local6);
        }
        private function onCheckUserComplete(_arg1:Event):void{
            var _local2:String = _arg1.target.data;
            var _local3:Object = JSON.deserialize(_local2);
            var _local4:Number = _local3.result;
            JTracer.sendMessage(("PlayerCtrl -> onCheckUserComplete, check is valid complete, result:" + _local4));
            if ((((_local4 == 4)) || ((_local4 == 5)))){
                this.showInvalidLoginLogo();
            } else {
                this._isValid = true;
                this._ctrBar.dispatchPlay();
            };
        }
        private function onCheckUserIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> onCheckUserIOError, check is valid IOError");
            this._isValid = true;
            this._ctrBar.dispatchPlay();
        }
        private function onCheckUserSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> onCheckUserSecurityError, check is valid SecurityError");
            this._isValid = true;
            this._ctrBar.dispatchPlay();
        }
        private function onIframeComplete(_arg1:Event):void{
            var _local2:String = _arg1.target.data;
            JTracer.sendMessage(("PlayerCtrl -> iframe url load Complete, jsonStr:" + _local2));
            var _local3:Object = JSON.deserialize(_local2);
            if (_local3){
                if (Number(_local3.ret) == 0){
                    this._snptAllArray = _local3.res_list;
                    this._snptArray = this.getCurSnptArray();
                    this.loadSnpt();
                } else {
                    Tools.stat(((("f=iframeerror&gcid=" + Tools.getUserInfo("gcid")) + "&code=") + _local3.ret));
                };
            };
        }
        private function getCurSnptArray():Array{
            var _local2:*;
            var _local1:Array = [];
            for (_local2 in this._snptAllArray) {
                if (this._snptAllArray[_local2].gcid == Tools.getUserInfo("gcid")){
                    _local1 = this._snptAllArray[_local2].snpt_list;
                };
            };
            return (_local1);
        }
        private function onIframeIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> iframe url load IOError");
        }
        private function onIframeSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> iframe url load SecurityError");
        }
        private function loadSnpt():void{
            if (((!(this._snptArray)) || ((this._snptArray.length == 0)))){
                return;
            };
            var _local1:String = this._snptArray[this._snptIndex].snpt_url;
            var _local2:URLRequest = new URLRequest(_local1);
            JTracer.sendMessage(((("PlayerCtrl -> iframe loadSnpt index:" + this._snptIndex) + ", url:") + _local1));
            this.unloadSnpt();
            this._snptLoader = new Loader();
            this._snptLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onSnptLoaded);
            this._snptLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onSnptIOError);
            this._snptLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSnptSecurityError);
            this._snptLoader.load(_local2, new LoaderContext(true));
        }
        private function unloadSnpt():void{
            if (this._snptLoader){
                this._snptLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onSnptLoaded);
                this._snptLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onSnptIOError);
                this._snptLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSnptSecurityError);
                try {
                    this._snptLoader.unloadAndStop();
                } catch(e:Error) {
                };
                this._snptLoader = null;
            };
        }
        private function onSnptLoaded(_arg1:Event):void{
            JTracer.sendMessage((("PlayerCtrl -> iframe loadSnpt index:" + this._snptIndex) + " complete"));
            var _local2:Bitmap = (this._snptLoader.content as Bitmap);
            var _local3:BitmapData = _local2.bitmapData;
            this._snptBmdArray.push({
                bmd:_local3,
                url:this._snptArray[this._snptIndex].snpt_url
            });
            this._snptIndex++;
            if (this._snptIndex >= this._snptArray.length){
                JTracer.sendMessage("PlayerCtrl -> iframe loadSnpt all complete");
                return;
            };
            this.loadSnpt();
        }
        private function onSnptIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage(("PlayerCtrl -> iframe loadSnpt IOError, index:" + this._snptIndex));
            this.unloadSnpt();
        }
        private function onSnptSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage(("PlayerCtrl -> iframe loadSnpt SecurityError, index:" + this._snptIndex));
            this.unloadSnpt();
            if (!this._isReportedScreenShotError){
                this._isReportedScreenShotError = true;
                Tools.stat((("f=iframeerror&gcid=" + Tools.getUserInfo("gcid")) + "&code=3"));
            };
        }
        private function onCheckFlowComplete(_arg1:Event):void{
            var _local2:String = _arg1.target.data;
            JTracer.sendMessage(("PlayerCtrl -> onCheckFlowComplete, jsonStr:" + _local2));
            var _local3:Object = JSON.deserialize(_local2);
            switch (_local3.result){
                case "0":
                    this._remainTimes = _local3.remain;
                    this._expiresTime = _local3.vtime;
                    this._isFlowChecked = true;
                    this.checkIsShouldPause();
                    break;
                case "1":
                    break;
                case "2":
                    this.showInvalidLoginLogo();
                    break;
            };
        }
        private function onCheckFlowIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> onCheckFlowIOError");
        }
        private function onCheckFlowSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> onCheckFlowSecurityError");
        }
        private function checkIsShouldPause():void{
            var _local2:Number;
            var _local3:String;
            var _local4:String;
            var _local1:Number = Number(Tools.getUserInfo("vodPermit"));
            JTracer.sendMessage(("PlayerCtrl -> checkIsShouldPause vodPermit:" + _local1));
            if ((((((((((((((_local1 == 6)) || ((_local1 == 7)))) || ((_local1 == 8)))) || ((_local1 == 9)))) || ((_local1 == 10)))) || ((_local1 == 11)))) && (!((Tools.getUserInfo("from") == GlobalVars.instance.fromXLPan))))){
                if (((((this._isPlayStart) && (this._isFlowChecked))) && (this._isFirstRemainTips))){
                    this._isFirstRemainTips = false;
                    this._isFirstTips = false;
                    JTracer.sendMessage(("PlayerCtrl -> checkIsShouldPause _remainTimes:" + this._remainTimes));
                    if (this._remainTimes <= 0){
                        setTimeout(this.tryPlayEnded, 1000, 0);
                    } else {
                        _local2 = (this._player.totalTime - this._player.getFirstStartTime());
                        _local3 = Tools.calculateTimes(this._remainTimes);
                        _local4 = (((this._remainTimes == 0)) ? "" : (("（" + Tools.transDate(this._expiresTime)) + "前有效）"));
                        if (this._remainTimes < _local2){
                            this._noticeBar.setContent(((("您的可播放时长剩余" + _local3) + _local4) + "，迅雷白金会员不限时长，<a href='event:buyVIP13'>立即开通</a>"), false, 12);
                            JTracer.sendMessage(((((((("PlayerCtrl -> checkIsShouldPause, 时长不足的提醒, ygcid:" + Tools.getUserInfo("ygcid")) + ", userid:") + Tools.getUserInfo("userid")) + ", remain:") + this._remainTimes) + ", need:") + _local2));
                            Tools.stat(((((("f=fluxlacktips&gcid=" + Tools.getUserInfo("ygcid")) + "&left=") + this._remainTimes) + "&need=") + _local2));
                        } else {
                            this._noticeBar.setContent(((("您的可播放时长剩余" + _local3) + _local4) + "，迅雷白金会员不限时长，<a href='event:buyVIP13'>立即开通</a>"), false, 12);
                            JTracer.sendMessage(((((((("PlayerCtrl -> checkIsShouldPause, 时长充足的提醒, ygcid:" + Tools.getUserInfo("ygcid")) + ", userid:") + Tools.getUserInfo("userid")) + ", remain:") + this._remainTimes) + ", need:") + _local2));
                        };
                    };
                };
            };
        }
        private function pauseForever(_arg1:String):void{
            this._isNoEnoughBytes = true;
            if (!this._player.isStop){
                this._ctrBar.dispatchPause();
            };
            this._noticeBar.setContent(_arg1, true);
            this._noticeBar.showCloseBtn(false);
        }
        public function tryPlayEnded(_arg1:Number):void{
            var _local2:Number;
            var _local3:String;
            if (!this._isPauseForever){
                this._isPauseForever = true;
                JTracer.sendMessage("PlayerCtrl -> tryPlayEnded, pauseForever");
                _local2 = Number(Tools.getUserInfo("userType"));
                if ((((_local2 == 0)) || ((_local2 == 1)))){
                    _local3 = "0";
                } else {
                    _local3 = "2";
                };
                Tools.stat(("f=show_play_end&playtype=" + _local3));
                this.pauseForever("");
                this._noticeBar.hideNoticeBar();
                this.showTryEndFace(_arg1);
            };
        }
        private function tryPlayEventHandler(_arg1:TryPlayEvent):void{
            switch (_arg1.type){
                case TryPlayEvent.BuyVIP:
                    this.buyVIP(_arg1.info);
                    break;
                case TryPlayEvent.BuyTime:
                    this.buyTime(_arg1.info);
                    break;
                case TryPlayEvent.GoHome:
                    this.gotoHome();
                    break;
                case TryPlayEvent.HidePanel:
                    this.hideTryPanel();
                    break;
                case TryPlayEvent.DontNoticeBytes:
                    this.dontNoticeBytes();
                    break;
                case TryPlayEvent.GetBytes:
                    this.getBytes();
                    break;
            };
        }
        private function hideTryPanel():void{
            this.hideTryEndFace();
        }
        private function loadPanel(_arg1:Function):void{
            var _local2:String;
            var _local3:String;
            var _local4:URLRequest;
            var _local5:LoaderContext;
            JTracer.sendMessage("PlayerCtrl -> loadPanel, panel loading");
            this._completeFunc = _arg1;
            if (!this._isPanelLoaded){
                if (this._panelLoader){
                    try {
                        this._panelLoader.unloadAndStop();
                    } catch(e:Error) {
                    };
                    this._panelLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onPanelLoaded);
                    this._panelLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onPanelIOError);
                    this._panelLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onPanelSecurityError);
                    this._panelLoader = null;
                };
                _local2 = this.loaderInfo.url;
                _local3 = _local2.substr(0, (_local2.lastIndexOf("/") + 1));
                _local4 = new URLRequest(((_local3 + "tryPanel.swf?t=") + new Date().time));
                _local5 = new LoaderContext();
                _local5.applicationDomain = ApplicationDomain.currentDomain;
                this._panelLoader = new Loader();
                this._panelLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onPanelLoaded);
                this._panelLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onPanelIOError);
                this._panelLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onPanelSecurityError);
                this._panelLoader.load(_local4, _local5);
            } else {
                if (this._completeFunc != null){
                    this._completeFunc();
                };
            };
        }
        private function onPanelLoaded(_arg1:Event):void{
            JTracer.sendMessage("PlayerCtrl -> onPanelLoaded, panel loaded");
            this._isPanelLoaded = true;
            if (this._completeFunc != null){
                this._completeFunc();
            };
        }
        private function onPanelIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> onPanelIOError, panel io error");
            this._isPanelLoaded = false;
        }
        private function onPanelSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("PlayerCtrl -> onPanelSecurityError, panel security error");
            this._isPanelLoaded = false;
        }
        private function getPanelClass(_arg1:String):Class{
            var _local2:Class = (this._panelLoader.contentLoaderInfo.applicationDomain.getDefinition(_arg1) as Class);
            return (_local2);
        }
        private function showTryEndFace(_arg1:Number):void{
            var time:* = _arg1;
            var comFunc:* = function ():void{
                var _local1:Class = getPanelClass("ctr.tryplay.TryEndFace");
                if (!_tryEndFace){
                    _tryEndFace = new (_local1)();
                    _tryEndFace.setTime(time);
                    _tryEndFace.isTrial = false;
                    addChild(_tryEndFace);
                    _tryEndFace.setPosition();
                };
            };
            this.loadPanel(comFunc);
        }
        private function hideTryEndFace():void{
            if (this._tryEndFace){
                removeChild(this._tryEndFace);
                this._tryEndFace = null;
            };
        }
        private function buyVIP(_arg1:Object):void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            var _local2:String = Tools.getUserInfo("from");
            if (((_local2) && ((_local2.substr(0, 3).toLowerCase() == "un_")))){
                Tools.windowOpen(((((GlobalVars.instance.url_buy_flow + "&referfrom=UN_014&ucid=") + _local2.substr(3)) + "&paypos=") + _arg1.paypos), "_blank", "jump");
                return;
            };
            var _local3 = "";
            if (_arg1.hasBytes){
                _local3 = "HasFluxBuyVIP";
            } else {
                _local3 = "NoFluxBuyVIP";
            };
            var _local4:String = ((_arg1.paypos) ? ("_" + _arg1.paypos) : "");
            if (GlobalVars.instance.platform == "client"){
                Tools.windowOpen((((GlobalVars.instance.url_buy_flow + "&referfrom=") + _arg1.refer) + _local4), "_blank", "jump");
                Tools.stat(("b=client" + _local3));
            } else {
                Tools.windowOpen((((GlobalVars.instance.url_buy_flow + "&referfrom=") + _arg1.refer) + _local4));
                Tools.stat(("b=web" + _local3));
            };
        }
        private function buyTime(_arg1:Object):void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            var _local2:String = Tools.getUserInfo("from");
            if (((_local2) && ((_local2.substr(0, 3).toLowerCase() == "un_")))){
                Tools.windowOpen(((((GlobalVars.instance.url_buy_time + "?referfrom=UN_014&ucid=") + _local2.substr(3)) + "&paypos=") + _arg1.paypos), "_blank", "jump");
                return;
            };
            var _local3 = "NoTimeBuyVIP";
            if (GlobalVars.instance.platform == "client"){
                Tools.windowOpen(((((GlobalVars.instance.url_buy_time + "?referfrom=") + _arg1.refer) + "_") + _arg1.paypos), "_blank", "jump");
                Tools.stat(("b=client" + _local3));
            } else {
                Tools.windowOpen(((((GlobalVars.instance.url_buy_time + "?referfrom=") + _arg1.refer) + "_") + _arg1.paypos));
                Tools.stat(("b=web" + _local3));
            };
        }
        private function gotoHome():void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            Tools.windowOpen(GlobalVars.instance.url_home, "_blank");
        }
        private function initializePlayCtrl():void{
            var _local1:Object = stage.loaderInfo.parameters;
            var _local2:int = ((int(_local1["width"])) ? int(_local1["width"]) : stage.stageWidth);
            var _local3:int = ((int(_local1["height"])) ? int(_local1["height"]) : stage.stageHeight);
            var _local4:int = ((int(_local1["fullscreenbtn"])) || (1));
            this._movieType = ((_local1["movieType"]) ? _local1["movieType"] : "movie");
            GlobalVars.instance.movieType = this._movieType;
            GlobalVars.instance.windowMode = ((_local1["windowMode"]) || ("browser"));
            GlobalVars.instance.platform = ((_local1["platform"]) || ("webpage"));
            GlobalVars.instance.isStat = (((_local1["defStatLevel"] == 2)) ? true : false);
            if (_local2 == 0){
                return;
            };
            if (this._isInitialize){
                if (this._toolRightArrow){
                    this._toolRightArrow.setPosition();
                };
                if (this._toolRightFace){
                    this._toolRightFace.setPosition();
                    this._toolRightFace.hide(true);
                };
                this._ctrBar.y = (stage.stageHeight - 33);
                this._ctrBar.faceLifting(stage.stageWidth);
                this._player.resizePlayerSize(stage.stageWidth, stage.stageHeight);
                this._screenEvent.width = stage.stageWidth;
                this._screenEvent.height = stage.stageHeight;
                this.changePlayerSize();
                this._subTitle.handleStageResize(stage.stageWidth, stage.stageHeight, this._isFullScreen);
                this._captionFace.setPosition();
                this._fileListFace.setPosition();
                if (this._addBytesFace){
                    this._addBytesFace.setPosition();
                };
                if (this._noEnoughFace){
                    this._noEnoughFace.setPosition();
                };
                if (this._tryEndFace){
                    this._tryEndFace.setPosition();
                };
                this._shareFace.setPosition();
                this._feedbackFace.setPosition();
                this._videoMask.setPosition();
                this._downloadFace.setPosition();
            } else {
                this._isInitialize = true;
                this._player = new Player(_local2, (_local3 - 35), _local4, this);
                this._player.name = "_player";
                this._player.addEventListener(Player.SET_QUALITY, this.handleSetQuality);
                this._player.addEventListener(Player.AUTO_PLAY, this.handleAutoPlay);
                this._player.addEventListener(Player.INIT_PAUSE, this.handleInitPause);
                this.addChild(this._player);
                this._subTitle = new Subtitle(this, this._player, _local2, _local3);
                this._subTitle.handleStageResize(stage.stageWidth, stage.stageHeight);
                this._screenEvent = new Sprite();
                this._screenEvent.graphics.clear();
                this._screenEvent.graphics.beginFill(0xFFFFFF, 0);
                this._screenEvent.graphics.drawRect(0, 0, _local2, _local3);
                this._screenEvent.graphics.endFill();
                this._screenEvent.doubleClickEnabled = true;
                this._screenEvent.mouseEnabled = true;
                this.addChild(this._screenEvent);
                this._screenEvent.addEventListener(MouseEvent.DOUBLE_CLICK, this.onDoubleClickHandle);
                this._screenEvent.addEventListener(MouseEvent.CLICK, this.onClickHandle);
                this._videoMask = new VideoMask(this, this._movieType);
                this._videoMask.addEventListener("StartPlayClick", this.onStartPlayClick);
                this._videoMask.addEventListener("Refresh", this.onRefresh);
                this.addChild(this._videoMask);
                this._videoMask.setPosition();
                this._ctrBar = new CtrBar(_local2, _local3, _local4, this);
                this.addChild(this._ctrBar);
                this._ctrBar.showPlayOrPauseButton = "PLAY";
                this._ctrBar.flvPlayer = this._player;
                this._ctrBar.available = true;
                this._ctrBar.faceLifting(stage.stageWidth);
                this._mouseControl = new MouseControl(this);
                this._mouseControl.addEventListener("MOUSE_SHOWED", this.handleMouseShow);
                this._mouseControl.addEventListener("MOUSE_HIDED", this.handleMouseHide);
                this._mouseControl.addEventListener("MOUSE_MOVEED", this.handleMouseMove);
                this._mouseControl.addEventListener("MOUSE_MOVEOUT", this.handleMouseMoveOut);
                this._mouseControl.addEventListener("SMALL_PLAY_PROGRESS_BAR", this.handleMouseHide2);
                this._bufferTip = new bufferTip(this._player);
                this._bufferTip.name = "_bufferTip";
                this.addChild(this._bufferTip);
                this.swapChildren(this._ctrBar, this._bufferTip);
                this._toolRightArrow = new ToolBarRightArrow(this);
                this._toolRightArrow.setPosition();
                this._toolRightFace = new ToolBarRight(this);
                this._toolRightFace.setPosition();
                this._fileListFace = new FileListFace(this);
                addChild(this._fileListFace);
                this._fileListFace.setPosition();
                this._ctrBar.y = (stage.stageHeight - 33);
                this._ctrBar.faceLifting(stage.stageWidth);
                this._noticeBar = new NoticeBar(this);
                addChild(this._noticeBar);
                swapChildren(this._ctrBar, this._noticeBar);
                this._settingSpace = new SettingSpace(this._player);
                this._settingSpace.addEventListener(EventSet.SET_AUTOCHANGE, this.settingSpaceEventHandler);
                this._settingSpace.addEventListener(EventSet.SET_SIZE, this.settingSpaceEventHandler);
                this._settingSpace.addEventListener(EventSet.SET_CHANGED, this.settingSpaceEventHandler);
                addChild(this._settingSpace);
                this._settingSpace.setPosition();
                this._captionFace = new CaptionFace();
                addChild(this._captionFace);
                this._captionFace.setPosition();
                this._toolTopFace = new ToolBarTop(this);
                this._toolTopFace.addEventListener("ShowPlayingTips", this.showPlayingTips);
                this._toolTopFace.setPosition();
                this._downloadFace = new DownloadFace();
                addChild(this._downloadFace);
                this._downloadFace.setPosition();
                this._feedbackFace = new FeedbackFace(this);
                addChild(this._feedbackFace);
                this._feedbackFace.setPosition();
                this._shareFace = new ShareFace();
                addChild(this._shareFace);
                this._shareFace.setPosition();
                Tools.registerToolTip(this);
                this.setObjectLayer();
                this.initJsInterface();
                this.initStageEvent();
                this.loadPanel(null);
            };
        }
        private function initStageEvent():void{
            this.addEventListener(PlayEvent.INVALID, this.playEventHandler);
            this.addEventListener(PlayEvent.PLAY, this.playEventHandler);
            this.addEventListener(PlayEvent.REPLAY, this.playEventHandler);
            this.addEventListener(PlayEvent.PAUSE, this.playEventHandler);
            this.addEventListener(PlayEvent.STOP, this.playEventHandler);
            this.addEventListener(PlayEvent.PAUSE_4_STAGE, this.playEventHandler);
            this.addEventListener(PlayEvent.PLAY_4_STAGE, this.playEventHandler);
            this.addEventListener(PlayEvent.BUFFER_START, this.playEventHandler);
            this.addEventListener(PlayEvent.PLAY_START, this.playEventHandler);
            this.addEventListener(PlayEvent.BUFFER_END, this.playEventHandler);
            this.addEventListener(PlayEvent.SEEK, this.playEventHandler);
            this.addEventListener(PlayEvent.PROGRESS, this.playEventHandler);
            this.addEventListener(PlayEvent.PLAY_NEW_URL, this.playEventHandler);
            this.addEventListener(PlayEvent.INIT_STAGE_VIDEO, this.playEventHandler);
            this.addEventListener(PlayEvent.INSTALL, this.playEventHandler);
            this.addEventListener(PlayEvent.OPEN_WINDOW, this.playEventHandler);
            this.addEventListener(SetQulityEvent.CHANGE_QUILTY, this.changeQualityHandler);
            this.addEventListener(SetQulityEvent.INIT_QULITY, this.changeQualityHandler);
            this.addEventListener(SetQulityEvent.LOWER_QULITY, this.changeQualityHandler);
            this.addEventListener(SetQulityEvent.HAS_QULITY, this.changeQualityHandler);
            this.addEventListener(SetQulityEvent.NO_QULITY, this.changeQualityHandler);
            this.addEventListener(SetQulityEvent.PAUSE_FOR_QUALITY_TIP, this.changeQualityHandler);
            this.addEventListener(EventSet.SKIP_MOVIE_HEAD, this.settingSpaceEventHandler);
            this.addEventListener(EventSet.SHOW_AUTOQUALITY_FACE, this.settingSpaceEventHandler);
            this.addEventListener(EventSet.SHOW_SKIPMOVIE_FACE, this.settingSpaceEventHandler);
            this.addEventListener(EventSet.SHOW_STAGE_VIDEO, this.settingSpaceEventHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownFunc);
            stage.addEventListener(KeyboardEvent.KEY_UP, this.keyUpFunc);
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, this.on_stage_FULLSCREEN);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, this.onMouseWheel);
            this.addEventListener(EventSet.SHOW_FACE, this.showFaceHandler);
            this.addEventListener(ControlEvent.SHOW_CTRBAR, this.controlEventHandler);
            this.addEventListener(CaptionEvent.SET_STYLE, this.setCaptionStyle);
            this.addEventListener(CaptionEvent.LOAD_CONTENT, this.loadCaptionContent);
            this.addEventListener(CaptionEvent.HIDE_CAPTION, this.hideCaption);
            this.addEventListener(CaptionEvent.SET_CONTENT, this.setCaptionContent);
            this.addEventListener(CaptionEvent.APPLY_SUCCESS, this.applyCaptionSuccess);
            this.addEventListener(CaptionEvent.APPLY_ERROR, this.applyCaptionError);
            this.addEventListener(CaptionEvent.LOAD_STYLE, this.loadCaptionStyle);
            this.addEventListener(CaptionEvent.LOAD_TIME, this.loadCaptionTime);
            this.addEventListener(CaptionEvent.SET_TIME, this.setCaptionTime);
            this.addEventListener(TryPlayEvent.BuyVIP, this.tryPlayEventHandler);
            this.addEventListener(TryPlayEvent.BuyTime, this.tryPlayEventHandler);
            this.addEventListener(TryPlayEvent.GoHome, this.tryPlayEventHandler);
            this.addEventListener(TryPlayEvent.HidePanel, this.tryPlayEventHandler);
            this.addEventListener(TryPlayEvent.DontNoticeBytes, this.tryPlayEventHandler);
            this.addEventListener(TryPlayEvent.GetBytes, this.tryPlayEventHandler);
        }
        private function setCaptionStyle(_arg1:CaptionEvent):void{
            this._subTitle.setStyle(_arg1.info);
        }
        private function showPlayingTips(_arg1:Event):void{
            this.showPlayerTxtTips("该视频正在播放", 2000);
        }
        private function showPlayerTxtTips(_arg1:String, _arg2:Number):void{
            var _local4:GlowFilter;
            if (!this._playerTxtTips){
                _local4 = new GlowFilter(0, 1, 2, 2, 5, BitmapFilterQuality.HIGH);
                this._playerTxtTips = new TextField();
                this._playerTxtTips.selectable = false;
                this._playerTxtTips.textColor = 16711169;
                this._playerTxtTips.filters = [_local4];
                this._playerTxtTips.x = 15;
                this._playerTxtTips.y = 25;
                addChild(this._playerTxtTips);
            };
            var _local3:TextFormat = new TextFormat("宋体");
            this._playerTxtTips.text = _arg1;
            this._playerTxtTips.width = (this._playerTxtTips.textWidth + 10);
            this._playerTxtTips.setTextFormat(_local3);
            clearTimeout(this._playerTxtTipsID);
            this._playerTxtTipsID = setTimeout(this.hidePlayerTxtTips, _arg2);
        }
        private function hidePlayerTxtTips():void{
            if (this._playerTxtTips){
                removeChild(this._playerTxtTips);
                this._playerTxtTips = null;
            };
        }
        public function showSetFace():void{
            if (this._settingSpace.visible){
                this.hideAllLayer();
                if (!this._player.isStop){
                    this._ctrBar.dispatchPlay();
                };
                this.reportSetStat();
            } else {
                if (GlobalVars.instance.isStat){
                    Tools.stat("b=setPanel");
                };
                this.hideAllLayer();
                this._settingSpace.showSetFace();
                if (!this._player.isStop){
                    this._ctrBar.dispatchPause();
                };
            };
        }
        private function reportSetStat():void{
            if (!GlobalVars.instance.isStat){
                return;
            };
            if (GlobalVars.instance.defaultFormatChanged){
                GlobalVars.instance.defaultFormatChanged = false;
                Tools.stat("b=changeDefaultFormat");
            };
            if (GlobalVars.instance.ratioChanged){
                GlobalVars.instance.ratioChanged = false;
                Tools.stat("b=changeRatio");
            };
            if (GlobalVars.instance.colorChanged){
                GlobalVars.instance.colorChanged = false;
                Tools.stat("b=changeColor");
            };
        }
        private function showShareFace():void{
            if (this._shareFace.visible){
                this.hideAllLayer();
                if (!this._player.isStop){
                    this._ctrBar.dispatchPlay();
                };
            } else {
                if (GlobalVars.instance.isStat){
                    Tools.stat("b=sharePanel");
                };
                this.hideAllLayer();
                this._shareFace.showFace(true);
                if (!this._player.isStop){
                    this._ctrBar.dispatchPause();
                };
            };
        }
        private function showCaptionFace(_arg1:String="tool"):void{
            if (this._captionFace.visible){
                this.hideAllLayer();
                if (!this._player.isStop){
                    this._ctrBar.dispatchPlay();
                };
                this.reportCaptionStat();
            } else {
                Tools.stat(("b=captionPanel&click=" + _arg1));
                this.hideAllLayer();
                this._captionFace.showFace(true);
                if (!this._player.isStop){
                    this._ctrBar.dispatchPause();
                };
            };
        }
        private function reportCaptionStat():void{
            if (GlobalVars.instance.captionStyleChanged){
                GlobalVars.instance.captionStyleChanged = false;
                if (GlobalVars.instance.isStat){
                    Tools.stat("b=changeSubtitle");
                };
                this._subTitle.saveStyle();
            };
            if (GlobalVars.instance.captionTimeChanged){
                GlobalVars.instance.captionTimeChanged = false;
                if (GlobalVars.instance.isStat){
                    Tools.stat("b=changeSubtitleTime");
                };
                this._subTitle.saveTimeDelta();
            };
        }
        private function showFileListFace():void{
            if (this._fileListFace.visible){
                this.hideAllLayer();
            } else {
                if (GlobalVars.instance.isStat){
                    Tools.stat("b=filelistPanel");
                };
                this.hideAllLayer();
                this._fileListFace.showFace(true);
            };
        }
        private function showFeedbackFace(_arg1:String="tool"):void{
            if (this._feedbackFace.visible){
                this.hideAllLayer();
                if (!this._player.isStop){
                    this._ctrBar.dispatchPlay();
                };
            } else {
                if (GlobalVars.instance.isStat){
                    Tools.stat(("b=feedbackPanel&click=" + _arg1));
                };
                this.hideAllLayer();
                this._feedbackFace.showFace(true);
                if (!this._player.isStop){
                    this._ctrBar.dispatchPause();
                };
            };
        }
        private function showDownloadFace():void{
            if (this._downloadFace.visible){
                this.hideAllLayer();
                if (!this._player.isStop){
                    this._ctrBar.dispatchPlay();
                };
            } else {
                if (GlobalVars.instance.isStat){
                    Tools.stat("b=downloadPanel");
                };
                this.hideAllLayer();
                this._downloadFace.showFace(true);
                if (!this._player.isStop){
                    this._ctrBar.dispatchPause();
                };
            };
        }
        private function closeDownloadFace(_arg1:Event):void{
            this._downloadFace.showFace(false);
            this._ctrBar.dispatchPlay();
        }
        private function setCaptionContent(_arg1:CaptionEvent):void{
            this._subTitle.setContent(_arg1.info.toString());
        }
        private function loadCaptionContent(_arg1:CaptionEvent):void{
            this._subTitle.loadContent(_arg1.info);
            this.showAutoloadTips();
        }
        private function showAutoloadTips():void{
            if (((((((((!(this._isShowAutoloadTips)) && (this._isPlayStart))) && (!(this.isChangeQuality)))) && (!(this._player.isResetStart)))) && (GlobalVars.instance.isHasAutoloadCaption))){
                this._isShowAutoloadTips = true;
                this.showPlayerTxtTips("已自动加载在线字幕", 5000);
            };
        }
        private function hideCaption(_arg1:CaptionEvent):void{
            this._subTitle.hideCaption(_arg1.info);
        }
        private function applyCaptionSuccess(_arg1:CaptionEvent):void{
            this._captionFace.showCompStatus();
        }
        private function applyCaptionError(_arg1:CaptionEvent):void{
            this._captionFace.showErrorStatus();
        }
        private function loadCaptionStyle(_arg1:CaptionEvent):void{
            this._captionFace.loadCaptionStyle();
        }
        private function loadCaptionTime(_arg1:CaptionEvent):void{
            this._captionFace.loadCaptionTime(_arg1.info);
        }
        private function setCaptionTime(_arg1:CaptionEvent):void{
            if (_arg1.info.type == "key"){
                if (this._subTitle.hasSubtitle){
                    if (Number(_arg1.info.time) <= 0){
                        this.showPlayerTxtTips((("字幕提前" + (Math.abs(_arg1.info.time) / 1000)) + "秒"), 3000);
                    } else {
                        this.showPlayerTxtTips((("字幕推迟" + (Math.abs(_arg1.info.time) / 1000)) + "秒"), 3000);
                    };
                };
            };
            this._subTitle.setTimeDelta(Number(_arg1.info.time));
        }
        private function set seekEnable(_arg1:Boolean):void{
            this._seekEnable = _arg1;
            this._ctrBar.seekEnable = _arg1;
        }
        private function controlEventHandler(_arg1:ControlEvent):void{
            if (_arg1.info == "hidden"){
                this._ctrBar._barSlider.visible = false;
                this.seekEnable = false;
            } else {
                this.seekEnable = true;
            };
        }
        private function dontNoticeBytes():void{
            this.hideNoticeBar();
            Cookies.setCookie("isNoticeBytes", false);
        }
        private function getBytes():void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            if (GlobalVars.instance.platform == "client"){
                Tools.windowOpen(GlobalVars.instance.url_free_flow, "_blank", "jump");
            } else {
                Tools.windowOpen(GlobalVars.instance.url_free_flow);
            };
        }
        private function showFaceHandler(_arg1:EventSet):void{
            switch (_arg1.info){
                case "set":
                    this.showSetFace();
                    break;
                case "share":
                    this.showShareFace();
                    break;
                case "caption":
                    this.showCaptionFace("tool");
                    break;
                case "captionFromTips":
                    this.showCaptionFace("tips");
                    break;
                case "filelist":
                    this.showFileListFace();
                    break;
                case "feedback":
                    this.showFeedbackFace("tool");
                    break;
                case "feedbackFromTips":
                    this.showFeedbackFace("tips");
                    break;
                case "download":
                    this.showDownloadFace();
                    break;
            };
        }
        private function settingSpaceEventHandler(_arg1:EventSet):void{
            var _local2:Object;
            switch (_arg1.type){
                case "set_size":
                    _local2 = this._settingSpace.videoSize;
                    if (((((!((_local2["ratio"] == this._setSizeInfo["ratio"]))) || (!((_local2["size"] == this._setSizeInfo["size"]))))) || (true))){
                        this._setSizeInfo["ratio"] = _local2["ratio"];
                        this._setSizeInfo["size"] = _local2["size"];
                        this.updateVideoSizeFun();
                    };
                    break;
            };
        }
        private function changeQualityHandler(_arg1:SetQulityEvent):void{
            var _local2:int;
            var _local3:String;
            var _local4:Number;
            switch (_arg1.type){
                case "lower_qulity":
                    this._ctrBar.changeToNextFormat();
                    this._ctrBar.isClickBarSeek = false;
                    this._isPressKeySeek = false;
                    break;
                case "has_qulity":
                    this._noticeBar.setContent(this._noticeMsgArr[2]);
                    break;
                case "no_qulity":
                    this._noticeBar.setContent(this._noticeMsgArr[1]);
                    break;
                case "change_quilty":
                    this.isChangeQuality = true;
                    this._ctrBar.isClickBarSeek = false;
                    this._isPressKeySeek = false;
                    break;
                case "autio_qulity":
                    this._bufferTip.autioChangeQuality();
                    break;
                case "init_qulity":
                    _local2 = this._player.currentQuality;
                    _local3 = this._player.currentQulityStr;
                    _local4 = this._player.currentQualityType;
                    this._bufferTip.setQulityType(_local3, _local2);
                    break;
                case "pause_for_quality_tip":
                    this._noticeBar.setContent(this._noticeMsgArr[3], false, 15, 3);
                    break;
            };
            _arg1.stopPropagation();
        }
        private function playEventHandler(_arg1:PlayEvent):void{
            var _local2:Number;
            var _local3:String;
            var _local4:Number;
            var _local5:*;
            var _local6:String;
            var _local7:*;
            var _local8:Number;
            var _local9:Number;
            if (_arg1.type != "Progress"){
                JTracer.sendMessage(("PlayerCtrl -> playEventHandler, PlayEvent." + _arg1.type));
            };
            this._videoMask.isBuffer = this._player.isBuffer;
            this._videoMask.bufferHandle(_arg1.type, _arg1.info);
            this._player.playEventHandler(_arg1);
            switch (_arg1.type){
                case "Replay":
                    this.hideNoticeBar();
                    break;
                case "Pause":
                    if (this._toolTopFace.hidden){
                        this._toolTopFace.show();
                    };
                    break;
                case "Play":
                    if (!this._toolTopFace.hidden){
                        this._toolTopFace.hide();
                    };
                    break;
                case "Seek":
                    _local2 = this._player.onSeekTime;
                    _local3 = Tools.getUserInfo("ygcid");
                    Tools.stat(((("b=drag&gcid=" + _local3) + "&t=") + this.getPlayProgress(true)));
                    ExternalInterface.call("flv_playerEvent", "onSeek", _local2);
                    break;
                case "Stop":
                    this._settingSpace.visible = false;
                    this._toolRightArrow.x = stage.stageWidth;
                    this._toolRightArrow.hide(true);
                    this._toolRightFace.x = stage.stageWidth;
                    this._toolRightFace.hide(true);
                    this._toolTopFace.y = -25;
                    this._toolTopFace.hide(true);
                    this._captionFace.showFace(false);
                    this._fileListFace.showFace(false);
                    this.hideNoticeBar();
                    if (this.isChangeQuality == false){
                        this._ctrBar.onStop();
                        this.isFirstLoad = true;
                        this._videoMask.bufferHandle("Stop");
                    };
                    this._isBuffering = false;
                    this._player.isBuffer = false;
                    this._ctrBar.isClickBarSeek = false;
                    this._isPressKeySeek = false;
                    this._ctrBar.show(true);
                    this._noticeBar.show(true);
                    this._isFirstTips = true;
                    this._isFirstListTips = true;
                    this._isFirstRemainTips = true;
                    this._isPlayStart = false;
                    break;
                case "PlayNewUrl":
                    if (this.isChangeQuality == true){
                        this._videoMask.showLoadingQuality();
                    } else {
                        this._videoMask.showProcessLoading();
                    };
                    JTracer.sendMessage(("PlayerCtrl -> playEventHandler, isChangeQuality:" + this.isChangeQuality));
                    break;
                case "PlayForStage":
                    this._ctrBar.dispatchPlay();
                    break;
                case "PauseForStage":
                    this._ctrBar.dispatchPause();
                    break;
                case "PlayStart":
                    this._isPlayStart = true;
                    this._bufferTip.clearBreakCount();
                    GlobalVars.instance.isFirstBuffer302 = false;
                    GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeCustom;
                    JTracer.sendMessage(("PlayerCtrl -> playEventHandler, PlayEvent.PlayStart, set bufferType:" + GlobalVars.instance.bufferType));
                    _local4 = Number(Tools.getUserInfo("vodPermit"));
                    if ((((((((_local4 == 7)) || ((_local4 == 9)))) || ((_local4 == 11)))) && (!((Tools.getUserInfo("from") == GlobalVars.instance.fromXLPan))))){
                        this._remainTimes = 0;
                        this._isFlowChecked = true;
                    };
                    this.checkIsShouldPause();
                    if (this._isFirstListTips){
                        this._isFirstListTips = false;
                        if (!this.isChangeQuality){
                            _local5 = Cookies.getCookie("isNoticeList");
                            if (((((!((Tools.getUserInfo("urlType") == "url"))) && ((this._fileListFace.filelistLength > 1)))) && (!((_local5 === false))))){
                                this._ctrBar.showFilelistTips(this._fileListFace.filelistLength);
                            };
                        };
                    };
                    if (this._isFirstTips){
                        this._isFirstTips = false;
                        if (!this.isChangeQuality){
                            _local6 = Tools.formatTimes(this._player.getFirstStartTime());
                            if (_local6 != "00:00:00"){
                                this._noticeBar.setContent((("已从上次观看时间点（" + _local6) + "）播放，<a href='event:replay'>我要从头看</a>"), false, 5);
                            } else {
                                if (!this._player.isResetStart){
                                    if (GlobalVars.instance.isHasAutoloadCaption){
                                    };
                                };
                            };
                        };
                    };
                    this.showAutoloadTips();
                    this.initSnpt();
                    if (!this.isFirstLoad){
                        this._mouseControl.Timer2.reset();
                        this._mouseControl.Timer2.start();
                    };
                    this.isFirstLoad = false;
                    this.isChangeQuality = false;
                    this._toolRightArrow.hide(true);
                    this._toolRightFace.hide(true);
                    this._toolTopFace.hide(true);
                    this._player.isBuffer = false;
                    this._isBuffering = false;
                    break;
                case "Progress":
                    if (this._player.streamInPlay){
                        if (((this._ctrBar.isClickBarSeek) || (this._isPressKeySeek))){
                            _local9 = ((this._player.streamInPlay.bufferTime / this._player.totalTime) * this._player.totalByte);
                            _local9 = (((((this._player.streamInPlay.bytesTotal == 0)) || ((this._player.streamInPlay.bytesTotal > _local9)))) ? _local9 : this._player.streamInPlay.bytesTotal);
                            _local8 = (this._player.streamInPlay.bytesLoaded / _local9);
                        } else {
                            _local8 = (this._player.streamInPlay.bufferLength / this._player.streamInPlay.bufferTime);
                        };
                        this._videoMask.updateProgress((((_local8 < 0)) ? 0 : _local8));
                    };
                    break;
                case "BufferStart":
                    this._player.is_invalid_time = true;
                    this._isBuffering = true;
                    JTracer.sendMessage(((("PlayerCtrl -> playEventHandler, isBuffer:" + this._player.isBuffer) + ", isInvalidTime:") + this._player.isInvalidTime));
                    if (((!(this._player.isBuffer)) || (this._player.isInvalidTime))){
                        this._bufferTip.addBreakCount(this._player.time);
                    };
                    if (!this.isFirstLoad){
                        this.normalPlayProgressBar();
                    };
                    break;
                case "BufferEnd":
                    this._ctrBar.isClickBarSeek = false;
                    this._isPressKeySeek = false;
                    this._player.streamInPlay.resume();
                    if (this._player.isPause){
                        this._player.streamInPlay.pause();
                    };
                    break;
                case "OpenWindow":
                    this._isStopNormal = false;
                    this._isShowStopFace = false;
                    this._ctrBar.dispatchStop();
                    this._videoMask.showErrorNotice();
                    break;
            };
        }
        private function onDoubleClickHandle(_arg1:MouseEvent):void{
            this._isDoubleClick = true;
            ExternalInterface.call("flv_playerEvent", "onDoubleClick");
            stage.displayState = (((stage.displayState == StageDisplayState.FULL_SCREEN)) ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN);
            _arg1.updateAfterEvent();
        }
        private function onStartPlayClick(_arg1:Event):void{
            this.onClickHandle(null);
        }
        private function onRefresh(_arg1:Event):void{
            if (this._videoMask.currentInfo == "refreshPage"){
                JTracer.sendMessage("refresh");
                ExternalInterface.call("function(){window.location.reload();}");
                return;
            };
            this.checkIsValid();
        }
        private function onClickHandle(_arg1:MouseEvent):void{
            if (this._isValid){
                this.checkSuccess();
            } else {
                this.checkIsValid();
            };
        }
        private function checkSuccess():void{
            var _time:* = null;
            this._isDoubleClick = false;
            if (stage.frameRate == 10){
                _time = new Timer(700, 1);
            } else {
                _time = new Timer(260, 1);
            };
            _time.addEventListener(TimerEvent.TIMER, function (_arg1:TimerEvent):void{
                if (!_isDoubleClick){
                    ExternalInterface.call("flv_playerEvent", "onClick");
                    if (!_player.isPause){
                        if (_player.isStartPause){
                            _player.isStartPause = false;
                            _player.dispatchEvent(new PlayEvent(PlayEvent.PLAY_4_STAGE));
                        } else {
                            _player.dispatchEvent(new PlayEvent(PlayEvent.PAUSE_4_STAGE));
                        };
                    } else {
                        _player.dispatchEvent(new PlayEvent(PlayEvent.PLAY_4_STAGE));
                    };
                };
            });
            _time.start();
        }
        private function onMouseWheel(_arg1:MouseEvent):void{
            if (((this._captionFace.visible) && (this._captionFace.isThumbIconActive))){
                if (_arg1.delta > 0){
                    this._captionFace.addDeltaByMouse(0.1);
                    this._curMouseDelta = (this._curMouseDelta + _arg1.delta);
                } else {
                    this._captionFace.subDeltaByMouse(0.1);
                    this._curMouseDelta = (this._curMouseDelta - _arg1.delta);
                };
                clearInterval(this._timeIntervalID);
                this._timeIntervalID = setInterval(this.stopTimeMouseWheel, 2000);
                return;
            };
            if (((this._settingSpace.visible) && (this._settingSpace.isThumbIconActive))){
                if (_arg1.delta > 0){
                    this._settingSpace.addDeltaByMouse(1);
                } else {
                    this._settingSpace.subDeltaByMouse(1);
                };
                clearInterval(this._filterIntervalID);
                this._filterIntervalID = setInterval(this.stopFilterMouseWheel, 2000);
                return;
            };
            if (this._isFullScreen){
                if (_arg1.delta > 0){
                    this._ctrBar.handleVolumeFromKey(true);
                } else {
                    this._ctrBar.handleVolumeFromKey(false);
                };
            };
        }
        private function stopTimeMouseWheel():void{
            if (this._lastMouseDelta != this._curMouseDelta){
                this._lastMouseDelta = this._curMouseDelta;
                Tools.hideToolTip();
                this._subTitle.saveTimeDelta();
                if (GlobalVars.instance.isStat){
                    Tools.stat("f=changeSubtitleTimeByMouse");
                };
            };
        }
        private function stopFilterMouseWheel():void{
            Tools.hideToolTip();
        }
        private function keyUpFunc(_arg1:KeyboardEvent):void{
            if (((_arg1.shiftKey) && ((_arg1.keyCode == 219)))){
                trace("shift + [");
                this._captionFace.subTimeDeltaByKey(0.5);
                this._curKeyDelta++;
                clearInterval(this._keyDeltaID);
                this._keyDeltaID = setInterval(this.stopKeyPress, 3000);
            };
            if (((_arg1.shiftKey) && ((_arg1.keyCode == 221)))){
                trace("shift + ]");
                this._captionFace.addTimeDeltaByKey(0.5);
                this._curKeyDelta--;
                clearInterval(this._keyDeltaID);
                this._keyDeltaID = setInterval(this.stopKeyPress, 3000);
            };
        }
        private function stopKeyPress():void{
            if (this._lastKeyDelta != this._curKeyDelta){
                this._lastKeyDelta = this._curKeyDelta;
                Tools.hideToolTip();
                this._subTitle.saveTimeDelta();
                if (GlobalVars.instance.isStat){
                    Tools.stat("f=changeSubtitleTimeByKey");
                };
            };
        }
        private function keyDownFunc(_arg1:KeyboardEvent):void{
            var seekTime:* = NaN;
            var idx:* = 0;
            var event:* = _arg1;
            trace(event.keyCode);
            switch (event.keyCode){
                case 32:
                    if (!this._player.isPause){
                        this._player.dispatchEvent(new PlayEvent(PlayEvent.PAUSE_4_STAGE));
                    } else {
                        this._player.dispatchEvent(new PlayEvent(PlayEvent.PLAY_4_STAGE));
                    };
                    break;
                case 37:
                    if (GlobalVars.instance.isUseHttpSocket){
                        this._isPressKeySeek = false;
                    } else {
                        this._isPressKeySeek = true;
                    };
                    trace("<-----");
                    if (((((((this._player.isStop) || (!(this._player.streamInPlay)))) || ((this._player.time <= 0)))) || (this._isNoEnoughBytes))){
                        return;
                    };
                    if ((((this._ctrBar._barBg.height == this.SMALL_PROGRESSBAR_HEIGTH)) && (!(this._isFullScreen)))){
                        this.normalPlayProgressBar();
                    };
                    if (this._player.streamInPlay){
                        this._player.streamInPlay.pause();
                    };
                    this._ctrBar._timerBP.stop();
                    this._mouseControl.Timer2.stop();
                    seekTime = (this._player.time - 5);
                    if (seekTime < 0){
                        seekTime = 0;
                    };
                    idx = (this._player.getNearIndex(this._player.dragTime, seekTime, 1, (this._player.dragTime.length - 1)) - 1);
                    seekTime = this._player.dragTime[idx];
                    this._ctrBar._barSlider.x = (((this._ctrBar._barWidth - 16) * seekTime) / this._player.totalTime);
                    if (this._ctrBar._barSlider.x < 0){
                        this._ctrBar._barSlider.x = 0;
                    } else {
                        if (this._ctrBar._barSlider.x > (this._ctrBar._barWidth - 16)){
                            this._ctrBar._barSlider.x = (this._ctrBar._barWidth - 16);
                        };
                    };
                    this._ctrBar._barPlay.width = ((this._ctrBar._barSlider.x - this._ctrBar._barPlay.x) + 6);
                    if (this._seekDelayTimer){
                        this._seekDelayTimer.reset();
                        this._seekDelayTimer.stop();
                    };
                    if (((this._seekDelayTimer2) && (this._seekDelayTimer2.running))){
                        this._seekDelayTimer2.reset();
                        this._seekDelayTimer2.start();
                    } else {
                        this._seekDelayTimer2 = new Timer(50, 1);
                        this._seekDelayTimer2.addEventListener(TimerEvent.TIMER_COMPLETE, function ():void{
                            _bufferTip.clearBreakCount();
                            GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeKeyPress;
                            JTracer.sendMessage(("PlayerCtrl -> keyDownFunc, set bufferType:" + GlobalVars.instance.bufferType));
                            _player.seek(seekTime);
                            _ctrBar._timerBP.start();
                        });
                        this._seekDelayTimer2.start();
                    };
                    this._mouseControl.Timer2.start();
                    break;
                case 39:
                    if (GlobalVars.instance.isUseHttpSocket){
                        this._isPressKeySeek = false;
                    } else {
                        this._isPressKeySeek = true;
                    };
                    trace("----->");
                    if (((((((this._player.isStop) || (!(this._player.streamInPlay)))) || ((this._player.time <= 0)))) || (this._isNoEnoughBytes))){
                        return;
                    };
                    if ((((this._ctrBar._barBg.height == this.SMALL_PROGRESSBAR_HEIGTH)) && (!(this._isFullScreen)))){
                        this.normalPlayProgressBar();
                    };
                    if (this._player.streamInPlay){
                        this._player.streamInPlay.pause();
                    };
                    this._ctrBar._timerBP.stop();
                    this._mouseControl.Timer2.stop();
                    seekTime = (this._player.time + 5);
                    if (seekTime > this._player.totalTime){
                        seekTime = this._player.totalTime;
                    };
                    idx = (this._player.getNearIndex(this._player.dragTime, seekTime, 0, (this._player.dragTime.length - 2)) + 1);
                    seekTime = this._player.dragTime[idx];
                    this._ctrBar._barSlider.x = (((this._ctrBar._barWidth - 16) * seekTime) / this._player.totalTime);
                    if (this._ctrBar._barSlider.x < 0){
                        this._ctrBar._barSlider.x = 0;
                    } else {
                        if (this._ctrBar._barSlider.x > (this._ctrBar._barWidth - 16)){
                            this._ctrBar._barSlider.x = (this._ctrBar._barWidth - 16);
                        };
                    };
                    this._ctrBar._barPlay.width = ((this._ctrBar._barSlider.x - this._ctrBar._barPlay.x) + 6);
                    if (this._seekDelayTimer2){
                        this._seekDelayTimer2.reset();
                        this._seekDelayTimer2.stop();
                    };
                    if (((this._seekDelayTimer) && (this._seekDelayTimer.running))){
                        this._seekDelayTimer.reset();
                        this._seekDelayTimer.start();
                    } else {
                        this._seekDelayTimer = new Timer(50, 1);
                        this._seekDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function ():void{
                            _bufferTip.clearBreakCount();
                            GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeKeyPress;
                            JTracer.sendMessage(("PlayerCtrl -> keyDownFunc, set bufferType:" + GlobalVars.instance.bufferType));
                            _player.seek(seekTime);
                            _ctrBar._timerBP.start();
                        });
                        this._seekDelayTimer.start();
                    };
                    this._mouseControl.Timer2.start();
                    break;
                case 38:
                    if (this._player.isStop){
                        return;
                    };
                    this._ctrBar.handleVolumeFromKey(true);
                    break;
                case 40:
                    if (this._player.isStop){
                        return;
                    };
                    this._ctrBar.handleVolumeFromKey(false);
                    break;
                case 107:
                    if (this._player.isStop){
                        return;
                    };
                    this._ctrBar.handleVolumeFromKey(true);
                    break;
                case 109:
                    if (this._player.isStop){
                        return;
                    };
                    this._ctrBar.handleVolumeFromKey(false);
                    break;
            };
        }
        private function handleAutoPlay(_arg1:Event):void{
            this._ctrBar.setPlayStatus();
        }
        private function handleInitPause(_arg1:Event):void{
            this._videoMask.showInitPauseLogo();
        }
        private function handleSetQuality(_arg1:Event):void{
            var _local2:int = _arg1.target.currentQuality;
            this._player.visible = false;
            this._bufferTip.visible = false;
        }
        private function handleMouseShow(_arg1:Event):void{
            this.showSide();
            this.normalPlayProgressBar();
        }
        private function handleMouseMove(_arg1:Event):void{
            this.showSide();
            this.normalPlayProgressBar();
        }
        private function handleMouseMoveOut(_arg1:Event):void{
        }
        private function handleMouseHide(_arg1:Event):void{
            this.hideSide();
            if (!this._ctrBar.beMouseOnFormat){
                this._ctrBar.hideFormatSelector();
            };
        }
        private function handleMouseHide2(_arg1:Event):void{
            this.smallPlayProgressBar();
        }
        private function showSide():void{
            if (((((this._player.isStartPause) || (this._isStopNormal))) || ((this._player.time <= 0)))){
                return;
            };
            if (((this._ctrBar._beFullscreen) && (this._ctrBar.hidden))){
                this._ctrBar.show();
                this._noticeBar.show();
            };
            if (this.mouseX > (stage.stageWidth - 150)){
                if (this._toolRightFace.hidden){
                    this._toolRightFace.show();
                };
                if (this._toolRightArrow.visible){
                    this._toolRightArrow.visible = false;
                    this._toolRightArrow.hide(true);
                };
            } else {
                if (!this._toolRightFace.hidden){
                    this._toolRightFace.hide();
                };
                if (!this._toolRightArrow.visible){
                    this._toolRightArrow.visible = true;
                    this._toolRightArrow.show();
                };
            };
            if (this._toolRightArrow.hidden){
                this._toolRightArrow.show();
            };
        }
        private function hideSide(_arg1:Boolean=false):void{
            if (((((this._player.isStartPause) || (this._isStopNormal))) || ((this._player.time <= 0)))){
                return;
            };
            if (((this._ctrBar._beFullscreen) && (!(this._ctrBar.beMouseOn)))){
                this._ctrBar.hide();
                this._noticeBar.hide();
            };
            if (this._ctrBar.beMouseOn){
                Mouse.show();
            };
            if (((!(this._toolRightFace.hidden)) && (!(this._toolRightFace.beMouseOn)))){
                this._toolRightFace.hide();
            };
            if (this._toolRightFace.beMouseOn){
                Mouse.show();
            };
            if (!this._toolRightArrow.hidden){
                this._toolRightArrow.hide();
            };
            if (this._settingSpace.beMouseOn){
                Mouse.show();
            };
        }
        private function checkToolBarPosition():void{
            if ((((this._toolRightFace.x < stage.stageWidth)) || ((stage.displayState == StageDisplayState.FULL_SCREEN)))){
                JTracer.sendLoaclMsg(((("_toolRightFace.x:" + this._toolRightFace.x) + ",stage.stageWidth:") + stage.stageWidth));
                this.hideSide(true);
            };
        }
        private function normalPlayProgressBar():void{
            if (this._ctrBar._barBg.height == this.SMALL_PROGRESSBAR_HEIGTH){
                if (this._seekEnable){
                    this._ctrBar._barSlider.visible = true;
                };
                this._ctrBar._barBg.height = this.NORMAL_PROGRESSBAR_HEIGTH;
                this._ctrBar._barBuff.height = this.NORMAL_PROGRESSBAR_HEIGTH;
                this._ctrBar._barPlay.height = this.NORMAL_PROGRESSBAR_HEIGTH;
                this._ctrBar._barPreDown.height = this.NORMAL_PROGRESSBAR_HEIGTH;
                this._ctrBar._barBg.y = -6;
                this._ctrBar._barBuff.y = -6;
                this._ctrBar._barPlay.y = -6;
                this._ctrBar._barPreDown.y = -6;
            };
        }
        private function smallPlayProgressBar():void{
            if (this._ctrBar._barBg.height == this.NORMAL_PROGRESSBAR_HEIGTH){
                if (((((!(this._isBuffering)) || (this.isFirstLoad))) || (this._ctrBar._btnPauseBig.visible))){
                    this._ctrBar._barSlider.visible = false;
                    this._ctrBar._barBg.height = this.SMALL_PROGRESSBAR_HEIGTH;
                    this._ctrBar._barBg.y = -2;
                    this._ctrBar._barBuff.height = this.SMALL_PROGRESSBAR_HEIGTH;
                    this._ctrBar._barBuff.y = -2;
                    this._ctrBar._barPlay.height = this.SMALL_PROGRESSBAR_HEIGTH;
                    this._ctrBar._barPlay.y = -2;
                    this._ctrBar._barPreDown.height = this.SMALL_PROGRESSBAR_HEIGTH;
                    this._ctrBar._barPreDown.y = -2;
                };
            };
        }
        private function adaptRealSize():void{
            var _local4:Number;
            var _local5:Number;
            var _local1:int = ((this._isFullScreen) ? stage.stageHeight : (stage.stageHeight - 35));
            var _local2:Number = (_local1 / stage.stageWidth);
            var _local3:Number = this._ratioVideo;
            _local4 = this._player.nomarl_width;
            if (this._setSizeInfo["ratio"] == "4_3"){
                _local5 = ((3 / 4) * this._player.nomarl_width);
            } else {
                if (this._setSizeInfo["ratio"] == "16_9"){
                    _local5 = ((9 / 16) * this._player.nomarl_width);
                } else {
                    if (this._setSizeInfo["ratio"] == "full"){
                        _local5 = (_local2 * this._player.nomarl_width);
                    } else {
                        _local5 = this._player.nomarl_height;
                    };
                };
            };
            if ((_local4 / _local5) > (stage.stageWidth / _local1)){
                _local3 = (((_local3 == 0)) ? (stage.stageWidth / _local4) : _local3);
                this._playerRealWidth = (_local4 * _local3);
                this._playerRealHeight = (_local5 * _local3);
            } else {
                _local3 = (((_local3 == 0)) ? (_local1 / _local5) : _local3);
                this._playerRealHeight = (_local5 * _local3);
                this._playerRealWidth = (_local4 * _local3);
            };
            JTracer.sendMessage(((((((((("_playerRealWidth:" + this._playerRealWidth) + ",_playerRealHeight:") + this._playerRealHeight) + ",_ratio:") + _local3) + ",_player.nomarl_width:") + this._player.nomarl_width) + ",_player.normal_height:") + this._player.nomarl_height));
        }
        private function updateVideoSizeFun():void{
            if (this._setSizeInfo["size"] == "50"){
                this._playerSize = 2;
            } else {
                if (this._setSizeInfo["size"] == "75"){
                    this._playerSize = 1;
                } else {
                    this._playerSize = 0;
                };
            };
            this.changePlayerSize();
        }
        public function resizePlayerSize():void{
            var resizeTimer:* = null;
            resizeTimer = new Timer(0, 1);
            resizeTimer.addEventListener(TimerEvent.TIMER, function ():void{
                changePlayerSize();
            });
            resizeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function ():void{
                resizeTimer.stop();
            });
            resizeTimer.start();
        }
        public function changePlayerSize():void{
            this.adaptRealSize();
            var _local1:Number = 1;
            switch (this._playerSize){
                case 0:
                    _local1 = 1;
                    break;
                case 1:
                    _local1 = 0.75;
                    break;
                case 2:
                    _local1 = 0.5;
                    break;
                default:
                    _local1 = 1;
            };
            var _local2:int = (this._playerRealWidth * _local1);
            var _local3:int = (this._playerRealHeight * _local1);
            this._player.width = _local2;
            this._player.height = _local3;
            this._player.x = ((stage.stageWidth - _local2) / 2);
            this._player.y = ((((this._isFullScreen) ? stage.stageHeight : (stage.stageHeight - 35)) - _local3) / 2);
            JTracer.sendMessage(((((((((((((("prWidth:" + _local2) + ",prHeight:") + _local3) + ",num:") + _local1) + ",sWidth:") + stage.stageWidth) + ",sHeight:") + stage.stageHeight) + "pWidth:") + this._player.width) + ",pHeight:") + this._player.height));
        }
        private function on_stage_FULLSCREEN(_arg1:FullScreenEvent):void{
            JTracer.sendMessage(((("fullScreen=" + _arg1.fullScreen) + ",e.target=") + _arg1.currentTarget));
            this._ctrBar.fullscreen = _arg1.fullScreen;
            this._ctrBar.show(true);
            this._noticeBar.show(true);
            this._mouseControl.fullscreen = _arg1.fullScreen;
            this._toolRightFace.hide(true);
            this._toolTopFace.hide(true);
            if (this._player.time > 0){
                this._toolRightArrow.show(true);
            } else {
                this._toolRightArrow.hide(true);
            };
            this._videoMask.setPosition();
            if (_arg1.fullScreen){
                ExternalInterface.call("flv_playerEvent", "onFullScreen");
                this._isFullScreen = true;
                this.changePlayerSize();
                this._playFullWidth = this._player.width;
                this._playFullHeight = this._player.height;
                this._ctrBar.y = (stage.stageHeight - 33);
                this._toolTopFace.fullScreen();
            } else {
                ExternalInterface.call("flv_playerEvent", "onExitFullScreen");
                this._toolTopFace.normalScreen();
                this._isFullScreen = false;
                this.changePlayerSize();
            };
        }
        public function flv_setFullScreen(_arg1):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_setFullScreen, 设置是否全屏:" + _arg1));
            stage.displayState = ((_arg1) ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL);
        }
        public function flv_play():void{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_play, 播放影片");
            this._ctrBar.available = true;
            this._ctrBar.visible = true;
            this._ctrBar.dispatchPlay();
        }
        public function flv_pause():void{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_pause, 暂停影片");
            if (((!(this._player.isPause)) && (!(this._player.isStartPause)))){
                this._ctrBar.dispatchPause();
            };
        }
        public function flv_stop():void{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_stop, 停止影片");
            this._ctrBar.dispatchStop();
            this._videoMask.bufferHandle("Stop");
        }
        public function flv_close():void{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_close, 停止影片并且关闭流");
            this._player.clearUp();
        }
        public function clearSnpt():void{
            try {
                if (this._iframeLoader){
                    this._iframeLoader.removeEventListener(Event.COMPLETE, this.onIframeComplete);
                    this._iframeLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onIframeIOError);
                    this._iframeLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onIframeSecurityError);
                    this._iframeLoader = null;
                };
            } catch(e:Error) {
            };
            if (this._snptLoader){
                try {
                    this._snptLoader.unloadAndStop();
                } catch(e:Error) {
                };
                this._snptLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onSnptLoaded);
                this._snptLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onSnptIOError);
                this._snptLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onSnptSecurityError);
                this._snptLoader = null;
            };
            this._snptIndex = 0;
            this._snptArray = [];
            this._snptAllArray = [];
            this._snptBmdArray = [];
        }
        public function flv_setPlayeUrl(_arg1:Array):void{
            var _local3:*;
            var _local4:String;
            var _local5:*;
            var _local6:int;
            var _local8:String;
            var _local9:URLRequest;
            var _local2 = "PlayerCtrl -> js回调flv_setPlayeUrl, 设置播放地址:";
            for (_local3 in _arg1[0]) {
                if (_local3 == "pageLoadTime"){
                    _local8 = "";
                    for (_local5 in _arg1[0][_local3]) {
                        _local8 = (_local8 + ((("\n" + _local5) + ":") + _arg1[0][_local3][_local5]));
                    };
                    _local2 = (_local2 + (((("\n" + "arr[0].") + _local3) + ":") + _local8));
                } else {
                    _local2 = (_local2 + (((("\n" + "arr[0].") + _local3) + ":") + _arg1[0][_local3]));
                };
            };
            JTracer.sendMessage(_local2);
            this._player.is_invalid_time = true;
            this._isSnptLoaded = false;
            GlobalVars.instance.loadTime = _arg1[0].pageLoadTime;
            GlobalVars.instance.getVodTime = 0;
            GlobalVars.instance.isUseXlpanKanimg = !((int(_arg1[0].useXlpanKanimg) == -1));
            GlobalVars.instance.screenshot_size = ((_arg1[0].screenshot_size) || (GlobalVars.instance.screenshot_size));
            JTracer.sendMessage(((("useXlpanKanimg:" + GlobalVars.instance.isUseXlpanKanimg) + " screenSize:") + GlobalVars.instance.screenshot_size));
            _arg1[0].machines = ((_arg1[0].machines) || ([]));
            GlobalVars.instance.httpSocketMachines = _arg1[0].machines;
            GlobalVars.instance.isUseHttpSocket = false;
            GlobalVars.instance.isHeaderGetted = false;
            StreamList.clearHeader();
            StreamList.clearCurList();
            StreamList.clearNextList();
            GlobalVars.instance.isFirstBuffer302 = true;
            GlobalVars.instance.isReplaceURL = false;
            GlobalVars.instance.isChangeURL = true;
            GlobalVars.instance.vodURLList = [];
            GlobalVars.instance.allURLList = [];
            GlobalVars.instance.isVodGetted = false;
            _local4 = "flv_setPlayeUrl -> play url list:\n";
            for (_local5 in _arg1[0].urls) {
                _local4 = (_local4 + (((("link:" + (_local5 + 1)) + ", url:") + _arg1[0].urls[_local5]) + "\n"));
                GlobalVars.instance.vodURLList.push({
                    url:_arg1[0].urls[_local5],
                    link:(_local5 + 1),
                    isdl:true
                });
                GlobalVars.instance.allURLList.push({
                    url:_arg1[0].urls[_local5],
                    link:(_local5 + 1),
                    isdl:true
                });
            };
            _local4 = (_local4 + ((("link:" + (GlobalVars.instance.vodURLList.length + 1)) + ", url:") + _arg1[0].url));
            JTracer.sendMessage(_local4);
            _local6 = (GlobalVars.instance.vodURLList.length + 1);
            GlobalVars.instance.vodURLList.push({
                url:_arg1[0].url,
                link:_local6,
                isdl:false
            });
            GlobalVars.instance.allURLList.push({
                url:_arg1[0].url,
                link:_local6,
                isdl:false
            });
            GlobalVars.instance.linkNum = ((_arg1[0].urls) ? _arg1[0].urls.length : 0);
            this._player.originGdlUrl = _arg1[0].url;
            this._isPauseForever = false;
            this._isPlayStart = false;
            this._isFlowChecked = false;
            var _local7:Number = Number(Tools.getUserInfo("vodPermit"));
            if ((((((((_local7 == 6)) || ((_local7 == 8)))) || ((_local7 == 10)))) && (!((Tools.getUserInfo("from") == GlobalVars.instance.fromXLPan))))){
                _local9 = new URLRequest(((((GlobalVars.instance.url_check_flow + "userid/") + Tools.getUserInfo("userid")) + "?t=") + new Date().time));
                JTracer.sendMessage(("PlayerCtrl -> flv_setPlayeUrl, 查询时长, url:" + _local9.url));
                this._checkFlowLoader.load(_local9);
            };
            if (!this.isChangeQuality){
                this._bufferTip.clearBreakCount();
                GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeFirstBuffer;
                JTracer.sendMessage(("PlayerCtrl -> flv_setPlayeUrl, set bufferType:" + GlobalVars.instance.bufferType));
                this._videoMask.initInputFace();
            } else {
                this._bufferTip.clearBreakCount();
                GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeChangeFormat;
                this._bufferTip.addBreakCount(_arg1[0].start);
                JTracer.sendMessage(("PlayerCtrl -> flv_setPlayeUrl, set bufferType:" + GlobalVars.instance.bufferType));
            };
            this._isNoEnoughBytes = false;
            this._videoUrlArray = _arg1;
            this._isError = false;
            this._ctrBar.visible = true;
            this._player.retryLastTimeStat = ((_arg1[0].isRetryLastTime) ? "&errorRetry=end" : "");
            this._player.hasNextStream = true;
            this._player.setPlayUrl(_arg1);
            Tools.getFormat();
        }
        public function initSnpt():void{
            var _local1:String;
            if (!this._isSnptLoaded){
                this._isSnptLoaded = true;
                this._snptIndex = 0;
                this._snptBmdArray = [];
                this._isReportedScreenShotError = false;
                if (this._snptAllArray.length == 0){
                    this.clearSnpt();
                    _local1 = ((((GlobalVars.instance.url_iframe + "?userid=") + Tools.getUserInfo("userid")) + "&url=") + encodeURIComponent(Tools.getUserInfo("url")));
                    JTracer.sendMessage(("PlayerCtrl -> iframe url start load, url:" + _local1));
                    this._iframeLoader = new URLLoader();
                    this._iframeLoader.addEventListener(Event.COMPLETE, this.onIframeComplete);
                    this._iframeLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onIframeIOError);
                    this._iframeLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onIframeSecurityError);
                    this._iframeLoader.load(new URLRequest(((_local1 + "&d=") + new Date().time)));
                } else {
                    this._snptArray = this.getCurSnptArray();
                    this.loadSnpt();
                };
            };
        }
        public function flv_stageVideoInfo():int{
            return (0);
        }
        public function flv_getNsCurrentFps():Number{
            var _local1:Number = this._player.nsCurrentFps;
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_getNsCurrentFps, 返回影片帧率:" + _local1));
            return (_local1);
        }
        public function flv_getCurrentFps():Number{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_getCurrentFps, 返回swf帧率:" + stage.frameRate));
            return (stage.frameRate);
        }
        public function flv_changeStageVideoToVideo():void{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_changeStageVideoToVideo, stageVideo to video");
        }
        public function flv_getPlayUrl():String{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_getPlayUrl, 返回播放地址:" + this._player.playUrl));
            return (this._player.playUrl);
        }
        public function flv_getStreamBytesLoaded():Number{
            var _local1:Number = 0;
            if (this._player.streamInPlay){
                _local1 = this._player.streamInPlay.bytesLoaded;
            };
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_getStreamBytesLoaded, 返回影片已下载数:" + _local1));
            return (_local1);
        }
        public function getDuration():int{
            var _local1:Number = this._player.totalTime;
            JTracer.sendMessage(("PlayerCtrl -> js回调getDuration, 返回总时长:" + _local1));
            return (_local1);
        }
        private function flv_getBufferBugInfo():String{
            var _local1 = "";
            if (this._player.streamInPlay){
                _local1 = ((String(this._player.streamInPlay.bufferLength) + "_") + String(this._player.streamInPlay.bufferTime));
            };
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_getBufferBugInfo, 返回:" + _local1));
            return (_local1);
        }
        private function flv_getBufferLength():Number{
            var _local1:Number = this._player.streamBufferTime;
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_getBufferLength, 返回缓冲时长:" + _local1));
            return (_local1);
        }
        public function setBufferTime(_arg1:Number):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调setBufferTime, 设置缓冲时间_player.bufferTime:" + _arg1));
            this._player.bufferTime = _arg1;
        }
        private function flv_changeBufferTime(_arg1:Number):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_changeBufferTime, 设置缓冲时间:" + _arg1));
            this._player.bufferTime = _arg1;
        }
        public function flv_setSeekPos(_arg1:Number):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_setSeekPos, 设置拖动时间点:" + _arg1));
            this._player.setSeekPos(_arg1);
        }
        public function flv_setNoticeMsg(_arg1:String, _arg2:Boolean=false, _arg3:int=15, _arg4:int=1, _arg5:String=null, _arg6:int=0, _arg7:int=0):void{
            JTracer.sendMessage(((((("PlayerCtrl -> js回调flv_setNoticeMsg, 设置提示文字:" + _arg1) + ", 是否一直显示:") + _arg2) + ", 不是一直显示时自动关闭时间:") + _arg3));
            this._noticeBar.setContent(_arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7);
        }
        public function flv_setNoticeCountDown(_arg1:Number):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_setNoticeCountDown, 设置试播倒计时:" + _arg1));
            this._noticeBar.setCountDown(_arg1);
        }
        private function flv_closeNotice():void{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_closeNotice, 关闭提示条");
            this.hideNoticeBar();
        }
        public function hideNoticeBar():void{
            this._noticeBar.hideNoticeBar();
        }
        private function flv_setVideoSize(_arg1:Number):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_setVideoSize, 设置视频比例:" + _arg1));
            if (_arg1 < 0){
                return;
            };
            this._ratioVideo = _arg1;
            this.changePlayerSize();
        }
        private function flv_getRealVideoSize():Object{
            var _local1:Object = {
                realWidth:this._player.nomarl_width,
                realHeight:this._player.nomarl_height
            };
            JTracer.sendMessage((((("PlayerCtrl -> js回调flv_getRealVideoSize, 返回视频宽高object:{'realWidth':" + _local1["realWidth"]) + ", 'realHeight':") + _local1["realHeight"]) + "}"));
            return (_local1);
        }
        private function flv_setIsChangeQuality(_arg1:Boolean):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_setIsChangeQuality, 设置是否切换清晰度:" + _arg1));
            this.isChangeQuality = _arg1;
        }
        private function flv_getSetStatusInfo():Object{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_getSetStatusInfo");
            return ({});
        }
        private function initJsInterface():void{
            if (ExternalInterface.available){
                ExternalInterface.addCallback("flv_getDefaultFormat", this.flv_getDefaultFormat);
                ExternalInterface.addCallback("getDownloadSpeed", this.getDownloadSpeed);
                ExternalInterface.addCallback("getDuration", this.getDuration);
                ExternalInterface.addCallback("flv_play", this.flv_play);
                ExternalInterface.addCallback("flv_pause", this.flv_pause);
                ExternalInterface.addCallback("flv_stop", this.flv_stop);
                ExternalInterface.addCallback("flv_close", this.flv_close);
                ExternalInterface.addCallback("flv_setPlayeUrl", this.flv_setPlayeUrl);
                ExternalInterface.addCallback("getPlayProgress", this.getPlayProgress);
                ExternalInterface.addCallback("getBufferProgress", this.getBufferProgress);
                ExternalInterface.addCallback("setSubTitleUrl", this.setSubTitleUrl);
                ExternalInterface.addCallback("cancelSubTitle", this.cancelSubTitle);
                ExternalInterface.addCallback("getVolume", this.getVolume);
                ExternalInterface.addCallback("setVolume", this.setVolume);
                ExternalInterface.addCallback("getPlayStatus", this.getPlayStatus);
                ExternalInterface.addCallback("getPlaySize", this.getPlaySize);
                ExternalInterface.addCallback("setPlaySize", this.setPlaySize);
                ExternalInterface.addCallback("getErrorInfo", this.getErrorInfo);
                ExternalInterface.addCallback("flv_showErrorInfo", this.flv_showErrorInfo);
                ExternalInterface.addCallback("flv_setFullScreen", this.flv_setFullScreen);
                ExternalInterface.addCallback("setBufferTime", this.setBufferTime);
                ExternalInterface.addCallback("getBufferEnd", this.getBufferEnd);
                ExternalInterface.addCallback("flv_setSeekPos", this.flv_setSeekPos);
                ExternalInterface.addCallback("flv_setNoticeMsg", this.flv_setNoticeMsg);
                ExternalInterface.addCallback("flv_setNoticeCountDown", this.flv_setNoticeCountDown);
                ExternalInterface.addCallback("flv_closeNotice", this.flv_closeNotice);
                ExternalInterface.addCallback("flv_changeBufferTime", this.flv_changeBufferTime);
                ExternalInterface.addCallback("flv_setVideoSize", this.flv_setVideoSize);
                ExternalInterface.addCallback("flv_getRealVideoSize", this.flv_getRealVideoSize);
                ExternalInterface.addCallback("flv_setIsChangeQuality", this.flv_setIsChangeQuality);
                ExternalInterface.addCallback("flv_getSetStatusInfo", this.flv_getSetStatusInfo);
                ExternalInterface.addCallback("flv_getBufferLength", this.flv_getBufferLength);
                ExternalInterface.addCallback("flv_getBufferBugInfo", this.flv_getBufferBugInfo);
                ExternalInterface.addCallback("flv_stageVideoInfo", this.flv_stageVideoInfo);
                ExternalInterface.addCallback("flv_getNsCurrentFps", this.flv_getNsCurrentFps);
                ExternalInterface.addCallback("flv_getCurrentFps", this.flv_getCurrentFps);
                ExternalInterface.addCallback("flv_changeStageVideoToVideo", this.flv_changeStageVideoToVideo);
                ExternalInterface.addCallback("flv_getPlayUrl", this.flv_getPlayUrl);
                ExternalInterface.addCallback("flv_getStreamBytesLoaded", this.flv_getStreamBytesLoaded);
                ExternalInterface.addCallback("flv_closeNetConnection", this.flv_closeNetConnection);
                ExternalInterface.addCallback("flv_showFormats", this.flv_showFormats);
                ExternalInterface.addCallback("flv_seek", this.flv_seek);
                ExternalInterface.addCallback("flv_setBarAvailable", this.flv_setBarAvailable);
                ExternalInterface.addCallback("flv_setIsShowNoticeClose", this.flv_setIsShowNoticeClose);
                ExternalInterface.addCallback("flv_getFlashVersion", this.flv_getFlashVersion);
                ExternalInterface.addCallback("flv_setCaptionParam", this.flv_setCaptionParam);
                ExternalInterface.addCallback("flv_getTimePlayed", this.flv_getTimePlayed);
                ExternalInterface.addCallback("flv_setFeeParam", this.flv_setFeeParam);
                ExternalInterface.addCallback("flv_playOtherFail", this.flv_playOtherFail);
                ExternalInterface.addCallback("flv_setShareLink", this.flv_setShareLink);
                ExternalInterface.addCallback("flv_showBarNotice", this.flv_showBarNotice);
                ExternalInterface.addCallback("flv_setToolBarEnable", this.flv_setToolBarEnable);
                ExternalInterface.addCallback("flv_showFeedbackFace", this.flv_showFeedbackFace);
                ExternalInterface.addCallback("flv_ready", this.flv_ready);
            };
        }
        public function flv_ready():Boolean{
            return (this._isInitialize);
        }
        public function flv_getDefaultFormat():String{
            var _local1:String = Cookies.getCookie("defaultFormat");
            if (((!(_local1)) || ((_local1 === "")))){
                _local1 = "p";
            };
            var _local2:String = ("PlayerCtrl -> js回调flv_getDefaultFormat, 取得默认清晰度:" + _local1);
            JTracer.sendMessage(_local2);
            return (_local1);
        }
        public function flv_showFeedbackFace():void{
            var _local1 = "PlayerCtrl -> js回调flv_showFeedbackFace, 显示问题反馈面板";
            JTracer.sendMessage(_local1);
            this._feedbackFace.visible = false;
            this.showFeedbackFace("webpage");
        }
        public function flv_showErrorInfo():void{
            var _local1 = "PlayerCtrl -> js回调flv_showErrorInfo, 显示204后三次重试失败界面";
            JTracer.sendMessage(_local1);
            if (!this._player.playEnd){
                this.showPlayError(null);
            };
        }
        public function flv_showBarNotice(_arg1:String, _arg2:uint=0):void{
            var _local3:String = ((("PlayerCtrl -> js回调flv_showBarNotice, 显示ctrBar提示，提示文字:" + _arg1) + ", 显示时间:") + _arg2);
            JTracer.sendMessage(_local3);
            this._ctrBar.showBarNotice(_arg1, _arg2);
        }
        public function flv_setShareLink(_arg1:String, _arg2:String):void{
            var _local3:String = ((("PlayerCtrl -> js回调flv_setShareLink, 设置分享地址, title:" + _arg1) + ", url:") + _arg2);
            JTracer.sendMessage(_local3);
            var _local4:TextFormat = new TextFormat("宋体");
            this._shareFace.url_txt.text = _arg2;
            this._shareFace.url_txt.setTextFormat(_local4);
        }
        public function flv_playOtherFail(_arg1:Boolean, _arg2:String=""):void{
            var _local4:Object;
            var _local3:String = ((("PlayerCtrl -> js回调flv_playOtherFail, 切换新视频, 是否切换成功:" + _arg1) + ", tips:") + _arg2);
            JTracer.sendMessage(_local3);
            GlobalVars.instance.isExchangeError = !(_arg1);
            this.cancelSubTitle();
            if (!_arg1){
                this._isStopNormal = false;
                this._isShowStopFace = false;
                this._ctrBar.dispatchStop();
                this._videoMask.showErrorNotice(VideoMask.exchangeError, null, _arg2);
                _local4 = {
                    y:{
                        checked:false,
                        enable:false
                    },
                    c:{
                        checked:false,
                        enable:false
                    },
                    p:{
                        checked:false,
                        enable:false
                    },
                    g:{
                        checked:false,
                        enable:false
                    }
                };
                this._ctrBar.showFormatLayer(_local4);
            };
        }
        public function flv_setFeeParam(_arg1:Object):void{
            var _local3:*;
            var _local4:String;
            var _local5:Array;
            var _local6:Array;
            var _local7:String;
            var _local2 = "PlayerCtrl -> js回调flv_setFeeParam, 设置扣费参数:";
            for (_local3 in _arg1) {
                _local2 = (_local2 + (((("\n" + "obj.") + _local3) + ":") + _arg1[_local3]));
            };
            JTracer.sendMessage(_local2);
            this._toolTopFace.infoObj = _arg1;
            GlobalVars.instance.curFileInfo = _arg1;
            if (_arg1.url.indexOf("bt://") == 0){
                Tools.setUserInfo("urlType", "bt");
            } else {
                if (_arg1.url.indexOf("magnet:?") == 0){
                    Tools.setUserInfo("urlType", "magnet");
                    _local4 = _arg1.url.substr(_arg1.url.indexOf("xt=urn:btih:"));
                    _local5 = _local4.split("&");
                    _local6 = _local5[0].toString().split(":");
                    Tools.setUserInfo("info_hash", _local6[(_local6.length - 1)].toUpperCase());
                } else {
                    Tools.setUserInfo("urlType", "url");
                };
            };
            if (!this._isReported){
                this._isReported = true;
                _local7 = ExternalInterface.call("function(){return document.location.href;}");
                Tools.stat(("f=quoteURL&url=" + _local7));
            };
            GlobalVars.instance.hasSubtitle = (((Number(_arg1.subtitle) == 1)) ? true : false);
            if (this._ctrBar){
                if (!GlobalVars.instance.hasSubtitle){
                    this._ctrBar.showCaptionBtn();
                } else {
                    this._ctrBar.hideCaptionBtn();
                };
            };
            GlobalVars.instance.isCaptionListLoaded = false;
            GlobalVars.instance.isCaptionStyleLoaded = false;
            GlobalVars.instance.isHasAutoloadCaption = false;
            this._captionFace.loadLastload();
            if (this._fileListFace){
                this._fileListFace.resetReqOffset();
                this._fileListFace.resetListArray();
                this._fileListFace.loadFileList();
            };
        }
        public function flv_getTimePlayed():Object{
            var _local1:Number = (this._player.timePlayed / 1000);
            var _local2:Number = ((((_local1 * this._player.totalByte) / this._player.totalTime)) || (0));
            var _local3:Number = this._player.downloadBytes;
            JTracer.sendMessage(((((("PlayerCtrl -> js回调flv_getTimePlayed, 获取播放时长, timePlayed:" + _local1) + ", bytePlayed:") + _local2) + ", byteDownload:") + _local3));
            return ({
                playedtime:_local1,
                playedbyte:_local2,
                downloadbyte:_local3
            });
        }
        public function flv_setToolBarEnable(_arg1:Object):void{
            var _local3:*;
            var _local2 = "PlayerCtrl -> js回调flv_setToolBarEnable, 设置工具栏按钮是否可点:";
            for (_local3 in _arg1) {
                _local2 = (_local2 + (((("\n" + "obj.") + _local3) + ":") + _arg1[_local3]));
            };
            JTracer.sendMessage(_local2);
            GlobalVars.instance.enableShare = _arg1.enableShare;
            if (this._toolRightFace){
                this._toolRightFace.enableObj = _arg1;
            };
            if (this._ctrBar){
                this._ctrBar.enableFileList = ((_arg1.enableFileList) || (false));
            };
            if (this._toolTopFace){
                this._toolTopFace.visible = _arg1.enableTopBar;
            };
        }
        public function flv_setCaptionParam(_arg1:Object):void{
            var _local3:*;
            var _local2 = "PlayerCtrl -> js回调flv_setCaptionParam, 设置字幕上传参数:";
            for (_local3 in _arg1) {
                _local2 = (_local2 + (((("\n" + "obj.") + _local3) + ":") + _arg1[_local3]));
            };
            JTracer.sendMessage(_local2);
            this._captionFace.setOuterParam(_arg1);
        }
        public function flv_getFlashVersion():String{
            var _local1:String = Capabilities.version;
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_getFlashVersion, 获取flashplayer版本号, 版本号为:" + _local1));
            return (_local1);
        }
        public function flv_setIsShowNoticeClose(_arg1:Boolean):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_setIsShowNoticeClose, 设置是否显示关闭按钮:" + _arg1));
            if (this._noticeBar){
                this._noticeBar.showCloseBtn(_arg1);
            };
        }
        public function flv_setBarAvailable(_arg1:Boolean):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调flv_setBarAvailable, 设置控制条是否可拖动:" + _arg1));
            if (this._ctrBar){
                this._ctrBar.barEnabled = _arg1;
            };
        }
        public function setSubTitleUrl(_arg1:String):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调setSubTitleUrl, 设置字幕url:" + _arg1));
            this._subTitle.loadContent({
                surl:_arg1,
                scid:null,
                sname:null,
                isSaveAutoload:false,
                isRetry:false,
                gradeTime:180
            });
        }
        public function cancelSubTitle():void{
            JTracer.sendMessage("PlayerCtrl -> js回调cancelSubTitle, 取消字幕");
            this._subTitle.hideCaption({
                surl:null,
                scid:null
            });
        }
        public function getDownloadSpeed():Number{
            var _local1:Number = this._player.downloadSpeed;
            JTracer.sendMessage(("PlayerCtrl -> js回调getDownloadSpeed, 返回下载速度:" + _local1));
            return (_local1);
        }
        private function getErrorInfo():String{
            var _local1:String;
            _local1 = this._player.errorInfo;
            if (_local1 == ""){
                _local1 = this._ctrBar.errorInfo();
            };
            JTracer.sendMessage(("PlayerCtrl -> js回调getErrorInfo, 返回错误码:" + _local1));
            return (_local1);
        }
        private function setPlaySize(_arg1:Number, _arg2:Number):void{
            JTracer.sendMessage(((("PlayerCtrl -> js回调setPlaySize, 设置影片宽:" + _arg1) + ", 高:") + _arg2));
            this._player.width = _arg1;
            this._player.height = _arg2;
            this._player.x = ((stage.stageWidth - this._player.width) / 2);
            if (stage.displayState == StageDisplayState.NORMAL){
                this._player.y = ((stage.stageHeight - this._player.height) / 2);
            } else {
                this._player.y = (((stage.stageHeight - this._player.height) + 40) / 2);
            };
        }
        private function getPlaySize():String{
            var _local1:Number;
            var _local2:Number;
            if (stage.displayState == StageDisplayState.NORMAL){
                _local1 = this._player.nomarl_width;
                _local2 = this._player.nomarl_height;
            } else {
                _local1 = this._playFullWidth;
                _local2 = this._playFullHeight;
            };
            JTracer.sendMessage(((("PlayerCtrl -> js回调getPlaySize, 返回影片宽,高:" + _local1) + ",") + _local2));
            return (((_local1 + ",") + _local2));
        }
        private function getPlayStatus():Number{
            var _local1:Number = this._ctrBar.getPlayStatus();
            JTracer.sendMessage(("PlayerCtrl -> js回调getPlayStatus, 返回播放状态:" + _local1));
            return (_local1);
        }
        private function setVolume(_arg1:Number):void{
            JTracer.sendMessage(("PlayerCtrl -> js回调setVolume, 设置音量:" + _arg1));
            this._ctrBar.setVolume(_arg1);
        }
        private function getVolume():Number{
            var _local1:Number = this._ctrBar.getVolume();
            JTracer.sendMessage(("PlayerCtrl -> js回调getVolume, 返回音量:" + _local1));
            return (_local1);
        }
        private function getBufferProgress():Number{
            var _local1:Number = this._ctrBar.getBufferProgress();
            JTracer.sendMessage(("PlayerCtrl -> js回调getBufferProgress, 返回缓冲进度为:" + _local1));
            return (_local1);
        }
        private function getPlayProgress(_arg1:Boolean):Number{
            var _local2:Number = this._ctrBar.getPlayProgress(_arg1);
            JTracer.sendMessage(((("PlayerCtrl -> js回调getPlayProgress, 设置是否返回播放时间(false返回播放百分比):" + _arg1) + ", 返回的播放时间或播放百分比为:") + _local2));
            return (_local2);
        }
        private function getBufferEnd():Number{
            var _local1:Number = this._player.bufferEndTime;
            JTracer.sendMessage(("PlayerCtrl -> js回调getBufferEnd, 返回_player.bufferEnd:" + _local1));
            return (_local1);
        }
        private function on_stage_RESIZE(_arg1:Event):void{
            this.initializePlayCtrl();
        }
        private function hideSideChangeQuilty():void{
            if (this._ctrBar._beFullscreen){
                this._ctrBar.hide();
                this._noticeBar.hide();
            };
            if (!this._toolTopFace.hidden){
                this._toolTopFace.hide();
            };
            if (!this._toolRightFace.hidden){
                this._toolRightFace.hide();
            };
            if (!this._toolRightArrow.hidden){
                this._toolRightArrow.hide();
            };
        }
        public function hideAllLayer():void{
            if (this._settingSpace.visible){
                this._settingSpace.showSetFace();
                this.reportSetStat();
            };
            if (this._captionFace.visible){
                this._captionFace.showFace(false);
            };
            if (this._fileListFace.visible){
                this._fileListFace.showFace(false);
            };
            if (this._shareFace){
                this._shareFace.showFace(false);
            };
            if (this._feedbackFace){
                this._feedbackFace.showFace(false);
            };
            if (this._downloadFace.visible){
                this._downloadFace.showFace(false);
            };
        }
        private function setObjectLayer():void{
            var _local1:Array = [];
            _local1.push(getChildIndex(this._settingSpace));
            _local1.push(getChildIndex(this._ctrBar));
            _local1.sort(this.orderArrFun);
            if (getChildIndex(this._ctrBar) != _local1[0]){
                setChildIndex(this._ctrBar, _local1[0]);
            };
            if (getChildIndex(this._settingSpace) != _local1[1]){
                setChildIndex(this._settingSpace, _local1[1]);
            };
        }
        private function orderArrFun(_arg1:Number, _arg2:Number):int{
            if (_arg1 > _arg2){
                return (-1);
            };
            if (_arg2 > _arg1){
                return (1);
            };
            return (0);
        }
        public function set isFirstLoad(_arg1:Boolean):void{
            this._isFirstLoad = _arg1;
            this._videoMask.isFirstLoading = _arg1;
        }
        public function get isFirstLoad():Boolean{
            return (this._isFirstLoad);
        }
        public function set isChangeQuality(_arg1:Boolean):void{
            this._isChangeQuality = _arg1;
            this._player.isChangeQuality = _arg1;
            this._videoMask.isQualityLoading = _arg1;
            this._ctrBar.isChangeQuality = _arg1;
        }
        public function get isChangeQuality():Boolean{
            return (this._isChangeQuality);
        }
        public function flv_closeNetConnection():void{
            JTracer.sendMessage("PlayerCtrl -> js回调flv_closeNetConnection, 关闭连接");
            this._player.closeNetConnection();
        }
        public function flv_showFormats(_arg1:Object):void{
            var _local2 = "PlayerCtrl -> js回调flv_showFormats, 设置formats:";
            _local2 = (_local2 + ("\n" + JSON.serialize(_arg1)));
            JTracer.sendMessage(_local2);
            this._formatsObj = _arg1;
            this._ctrBar.showFormatLayer(_arg1);
            this._downloadFace.setDownloadFormat(_arg1);
        }
        public function flv_seek(_arg1:Number=0):void{
            if (!this._isNoEnoughBytes){
                JTracer.sendMessage(("PlayerCtrl -> js回调flv_seek, 设置拖动的时间点:" + _arg1));
                GlobalVars.instance.isVodGetted = false;
                this._bufferTip.clearBreakCount();
                GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeError;
                JTracer.sendMessage(("PlayerCtrl -> flv_seek, set bufferType:" + GlobalVars.instance.bufferType));
                this._player.seek(_arg1, true);
            };
        }
        public function get isBuffering():Boolean{
            return (this._isBuffering);
        }
        public function get isValid():Boolean{
            return (this._isValid);
        }
        public function set isValid(_arg1:Boolean):void{
            this._isValid = _arg1;
        }
        public function get isNoEnoughBytes():Boolean{
            return (this._isNoEnoughBytes);
        }
        public function set isNoEnoughBytes(_arg1:Boolean):void{
            this._isNoEnoughBytes = _arg1;
        }
        public function get isStopNormal():Boolean{
            return (this._isStopNormal);
        }
        public function set isStopNormal(_arg1:Boolean):void{
            this._isStopNormal = _arg1;
        }
        public function get isPlayStart():Boolean{
            return (this._isPlayStart);
        }
        public function get isShowStopFace():Boolean{
            return (this._isShowStopFace);
        }
        public function set isShowStopFace(_arg1:Boolean):void{
            this._isShowStopFace = _arg1;
        }
        public function get isHasNext():Boolean{
            var _local1:Boolean = this._fileListFace.isHasNext;
            return (_local1);
        }
        public function get snptBmdArray():Array{
            return (this._snptBmdArray);
        }
        public function get isFirstOnplaying():Boolean{
            return (this._isFirstOnplaying);
        }
        public function set isFirstOnplaying(_arg1:Boolean):void{
            this._isFirstOnplaying = _arg1;
        }
        public function showLowSpeedTips():void{
            var _local1:GlobalVars = GlobalVars.instance;
            _local1.isHideLowSpeedTips = Cookies.getCookie("hideLowSpeedTips");
            if (_local1.isHideLowSpeedTips){
                return;
            };
            this._noticeBar.setContent("当前网速较慢，建议暂停缓冲一会再播放", false, 12);
            this._noticeBar.setRightContent("<a href='event:hideLowSpeedTips'>不再提示</a>");
        }
        public function showHighSpeedTips(_arg1:String, _arg2:Number):void{
            var _local3:GlobalVars = GlobalVars.instance;
            _local3.isHideHighSpeedTips = Cookies.getCookie("hideHighSpeedTips");
            if (_local3.isHideHighSpeedTips){
                return;
            };
            if (_arg1 == "g"){
                this._noticeBar.setContent("该视频支持更高清晰度，切换到 <a href='event:goToGaoQing'>高清</a>", false, 12);
                this._noticeBar.setRightContent("<a href='event:hideHighSpeedTips'>不再提示</a>");
            } else {
                if (_arg1 == "c"){
                    this._noticeBar.setContent("该视频支持更高清晰度，切换到 <a href='event:goToChaoQing'>超清</a>", false, 12);
                    this._noticeBar.setRightContent("<a href='event:hideHighSpeedTips'>不再提示</a>");
                };
            };
        }
        public function get isHasLowerFormat():Boolean{
            var _local1:GlobalVars = GlobalVars.instance;
            if ((((_local1.movieFormat == "c")) || ((_local1.movieFormat == "g")))){
                return (true);
            };
            return (false);
        }
        public function get isHasHigherFormat():Boolean{
            var _local1:GlobalVars = GlobalVars.instance;
            if ((((((((_local1.movieFormat == "p")) && (this._formatsObj))) && (this._formatsObj["g"]))) && (this._formatsObj["g"].enable))){
                return (true);
            };
            if ((((((((_local1.movieFormat == "g")) && (this._formatsObj))) && (this._formatsObj["c"]))) && (this._formatsObj["c"].enable))){
                return (true);
            };
            return (false);
        }
        public function get isStartPlayLoading():Boolean{
            return (this._videoMask.isStartPlayLoading);
        }

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class VolumeCtr extends MovieClip {

        public var unget:MovieClip;
        public var scroll:SimpleButton;
        public var mask1:MovieClip;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetSelectedOptionBack extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class FilterControlBtn extends MovieClip {

        public function FilterControlBtn(){
            addFrameScript(0, this.frame1, 1, this.frame2);
        }
        function frame1(){
            stop();
        }
        function frame2(){
            stop();
        }

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class StartPlayButton extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class PlayButton extends SimpleButton {

    }
}//package 
﻿package vodPlayer_2_fla {
    import flash.display.*;

    public dynamic class cycle2_stage2_50 extends MovieClip {

        public function cycle2_stage2_50(){
            addFrameScript(24, this.frame25);
        }
        function frame25(){
            gotoAndPlay("loop");
        }

    }
}//package vodPlayer_2_fla 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class CaptionBtnTips extends MovieClip {

        public var txt:TextField;
        public var close_btn:SimpleButton;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class Volume extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class VolumeButton extends MovieClip {

        public function VolumeButton(){
            addFrameScript(0, this.frame1);
        }
        function frame1(){
            stop();
        }

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class ShortcutsTips extends MovieClip {

        public var info_txt:TextField;
        public var know_txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class CommonBackGround extends MovieClip {

    }
}//package 
﻿package ctr.tip {
    import flash.display.*;
    import com.common.*;
    import flash.text.*;

    public class BtnTip extends Sprite {

        private var _txt:TextField;
        private var _bg:Sprite;
        private var _bgBmd:BtnTipsBg;

        public function BtnTip(){
            this._bgBmd = new BtnTipsBg(44, 32);
            this._bg = new BitmapScale9Grid(this._bgBmd, 4, 28, 4, 40);
            this.addChild(this._bg);
            var _local1:TextFormat = new TextFormat();
            _local1.align = "center";
            this._txt = new TextField();
            this._txt.defaultTextFormat = _local1;
            this._txt.y = 8;
            this._txt.selectable = false;
            this._txt.text = "播放";
            this._txt.height = (this._txt.textHeight + 5);
            this._txt.setTextFormat(new TextFormat("宋体", 12, 0x8E8E8E));
            this.addChild(this._txt);
        }
        public function set bgWidth(_arg1:Number):void{
            this._bg.width = _arg1;
            this._txt.width = _arg1;
        }
        public function set text(_arg1){
            this._txt.text = _arg1;
            this._txt.setTextFormat(new TextFormat("宋体", 12, 0x8E8E8E));
        }
        public function get text(){
            return (this._txt.text);
        }

    }
}//package ctr.tip 
﻿package ctr.tip {
    import flash.display.*;
    import flash.text.*;

    public class VolumeTips extends Sprite {

        private var volumeBg:Volume;
        private var txt:TextField;

        public function VolumeTips(){
            this.volumeBg = new Volume();
            this.addChild(this.volumeBg);
            this.txt = new TextField();
            this.txt.autoSize = TextFieldAutoSize.CENTER;
            this.txt.width = 40;
            this.txt.selectable = false;
            this.addChild(this.txt);
            this.txt.x = 21;
            this.txt.y = 2;
            this.txt.setTextFormat(new TextFormat("Arial", 12, 0x8E8E8E));
        }
        public function set text(_arg1:String):void{
            this.txt.text = _arg1;
            this.txt.setTextFormat(new TextFormat("Arial", 12, 0x8E8E8E));
        }
        public function get text():String{
            return (this.txt.text);
        }

    }
}//package ctr.tip 
﻿package ctr.tip {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.media.*;
    import com.common.*;
    import com.greensock.*;
    import flash.text.*;

    public class McTimeTip extends Sprite {

        private var _txt:TextField;
        private var _borderMc:Sprite;
        private var _normalWidth:Number = 160;
        private var _normalHeight:Number = 90;
        private var _bigWidth:Number = 190;
        private var _bigHeight:Number = 108;
        private var _defaultWidth:Number = 48;
        private var _defaultHeight:Number = 25;
        private var _cn:NetConnection;
        private var _stream:NetStream;
        private var _video:Video;
        private var _loading:TimeTipsLoading;
        private var _timeBgMc:Sprite;
        private var _scaleType:uint;
        private var _curTime:Number;
        private var _curStageX:Number;
        private var _curMouseX:Number;
        private var _isScale:Boolean;
        private var _hasSnapShot:Boolean;
        private var _snptBm:Bitmap;
        private var _showLoading:Boolean;

        public function McTimeTip(){
            this.mouseChildren = false;
            var _local1:BitmapData = new TimeTipsBorder(47, 25);
            this._borderMc = new BitmapScale9Grid(_local1, 2, 23, 2, 45);
            addChild(this._borderMc);
            var _local2:TextFormat = new TextFormat();
            _local2.align = "center";
            _local2.font = "Arial";
            _local2.color = 0x9F9F9F;
            _local2.size = 10;
            this._txt = new TextField();
            this._txt.defaultTextFormat = _local2;
            this._txt.width = 48;
            this._txt.height = 18;
            this._txt.x = (-(this._txt.width) / 2);
            this._txt.y = -21;
            this._txt.selectable = false;
            addChild(this._txt);
            this._cn = new NetConnection();
            this._cn.connect(null);
            this._stream = new NetStream(this._cn);
            this._stream.bufferTime = 1;
            this._stream.soundTransform = new SoundTransform(0);
            this._stream.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
            this._stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.asyncErrorHandler);
            this.init();
        }
        public function init():void{
            this._borderMc.width = this._defaultWidth;
            this._borderMc.height = this._defaultHeight;
            this._borderMc.x = (-(this._defaultWidth) / 2);
            this._borderMc.y = -(this._defaultHeight);
            this.clear();
            this.killAllTweens();
        }
        public function get hasSnapShot():Boolean{
            return (this._hasSnapShot);
        }
        public function set hasSnapShot(_arg1:Boolean):void{
            this._hasSnapShot = _arg1;
        }
        public function get isScale():Boolean{
            return (this._isScale);
        }
        public function set isScale(_arg1:Boolean):void{
            this._isScale = _arg1;
        }
        public function get curTime():Number{
            return (this._curTime);
        }
        public function set curTime(_arg1:Number):void{
            this._curTime = _arg1;
        }
        public function get curStageX():Number{
            return (this._curStageX);
        }
        public function set curStageX(_arg1:Number):void{
            this._curStageX = _arg1;
        }
        public function get curMouseX():Number{
            return (this._curMouseX);
        }
        public function set curMouseX(_arg1:Number):void{
            this._curMouseX = _arg1;
        }
        override public function get width():Number{
            return (this._borderMc.width);
        }
        override public function get height():Number{
            return (this._borderMc.height);
        }
        public function set text(_arg1:String):void{
            this._txt.text = _arg1;
        }
        public function get text():String{
            return (this._txt.text);
        }
        public function get scaleType():uint{
            return (this._scaleType);
        }
        public function set scaleType(_arg1:uint):void{
            this._scaleType = _arg1;
        }
        public function showSnap(_arg1:BitmapData):void{
            if (this._snptBm){
                this._snptBm.smoothing = true;
                this._snptBm.bitmapData = _arg1;
            };
        }
        public function playStream(_arg1:String, _arg2:String):void{
            var gdlURl:* = null;
            var url:* = _arg1;
            var suffix:* = _arg2;
            gdlURl = (url + suffix);
            if (GlobalVars.instance.isUseSocket){
                GetNextVodSocket.instance.connect(url, function (_arg1:String, _arg2:String, _arg3:String, _arg4:int){
                    if (((!(_arg1)) || ((_arg1 == "")))){
                        JTracer.sendMessage(("McTimeTip -> playStream, get vod url fail, gdl url:" + gdlURl));
                        if (_stream){
                            _stream.play(gdlURl);
                        };
                    } else {
                        JTracer.sendMessage((("McTimeTip -> playStream, get vod url success, vod url:" + _arg1) + suffix));
                        if (_stream){
                            _stream.play((_arg1 + suffix));
                        };
                    };
                });
            } else {
                if (this._stream){
                    this._stream.play(gdlURl);
                };
            };
        }
        public function initDisplay():void{
            this.newSnptBm();
            if (this._showLoading){
                this.newLoading();
            };
            this.newVideo();
            this.newTimeBgMc();
            setChildIndex(this._txt, (numChildren - 1));
        }
        public function showLoading(_arg1:Boolean):void{
            this._showLoading = _arg1;
        }
        public function setDisplayAlpha(_arg1:Number):void{
            this._snptBm.alpha = _arg1;
            if (this._showLoading){
                this._loading.alpha = _arg1;
            };
            this._video.alpha = _arg1;
            this._timeBgMc.alpha = _arg1;
        }
        public function scaleNormal(_arg1:Boolean=false):void{
            if (_arg1){
                this._snptBm.width = (this._normalWidth - 4);
                this._snptBm.height = (this._normalHeight - 4);
                this._snptBm.x = (-((this._normalWidth - 4)) / 2);
                this._snptBm.y = (-(this._normalHeight) + 2);
                this._snptBm.alpha = 1;
                if (this._showLoading){
                    this._loading.y = (-(this._normalHeight) / 2);
                    this._loading.alpha = 1;
                };
                this._video.width = (this._normalWidth - 4);
                this._video.height = (this._normalHeight - 4);
                this._video.x = (-((this._normalWidth - 4)) / 2);
                this._video.y = (-(this._normalHeight) + 2);
                this._video.alpha = 1;
                this._timeBgMc.width = (this._normalWidth - 4);
                this._timeBgMc.alpha = 1;
                this._borderMc.width = this._normalWidth;
                this._borderMc.height = this._normalHeight;
                this._borderMc.x = (-(this._normalWidth) / 2);
                this._borderMc.y = -(this._normalHeight);
            } else {
                TweenLite.to(this._snptBm, 0.2, {
                    width:(this._normalWidth - 4),
                    height:(this._normalHeight - 4),
                    x:(-((this._normalWidth - 4)) / 2),
                    y:(-(this._normalHeight) + 2),
                    alpha:1
                });
                if (this._showLoading){
                    TweenLite.to(this._loading, 0.2, {
                        y:(-(this._normalHeight) / 2),
                        alpha:1
                    });
                };
                TweenLite.to(this._video, 0.2, {
                    width:(this._normalWidth - 4),
                    height:(this._normalHeight - 4),
                    x:(-((this._normalWidth - 4)) / 2),
                    y:(-(this._normalHeight) + 2),
                    alpha:1
                });
                TweenLite.to(this._timeBgMc, 0.2, {
                    width:(this._normalWidth - 4),
                    alpha:1
                });
                TweenLite.to(this._borderMc, 0.2, {
                    width:this._normalWidth,
                    height:this._normalHeight,
                    x:(-(this._normalWidth) / 2),
                    y:-(this._normalHeight)
                });
            };
        }
        public function scaleBig(_arg1:Boolean=false):void{
            if (_arg1){
                this._snptBm.width = (this._bigWidth - 4);
                this._snptBm.height = (this._bigHeight - 4);
                this._snptBm.x = (-((this._bigWidth - 4)) / 2);
                this._snptBm.y = (-(this._bigHeight) + 2);
                this._snptBm.alpha = 1;
                if (this._showLoading){
                    this._loading.y = (-(this._bigHeight) / 2);
                    this._loading.alpha = 1;
                };
                this._video.width = (this._bigWidth - 4);
                this._video.height = (this._bigHeight - 4);
                this._video.x = (-((this._bigWidth - 4)) / 2);
                this._video.y = (-(this._bigHeight) + 2);
                this._video.alpha = 1;
                this._timeBgMc.width = (this._bigWidth - 4);
                this._timeBgMc.alpha = 1;
                this._borderMc.width = this._bigWidth;
                this._borderMc.height = this._bigHeight;
                this._borderMc.x = (-(this._bigWidth) / 2);
                this._borderMc.y = -(this._bigHeight);
            } else {
                TweenLite.to(this._snptBm, 0.2, {
                    width:(this._bigWidth - 4),
                    height:(this._bigHeight - 4),
                    x:(-((this._bigWidth - 4)) / 2),
                    y:(-(this._bigHeight) + 2),
                    alpha:1
                });
                if (this._showLoading){
                    TweenLite.to(this._loading, 0.2, {
                        y:(-(this._bigHeight) / 2),
                        alpha:1
                    });
                };
                TweenLite.to(this._video, 0.2, {
                    width:(this._bigWidth - 4),
                    height:(this._bigHeight - 4),
                    x:(-((this._bigWidth - 4)) / 2),
                    y:(-(this._bigHeight) + 2),
                    alpha:1
                });
                TweenLite.to(this._timeBgMc, 0.2, {
                    width:(this._bigWidth - 4),
                    alpha:1
                });
                TweenLite.to(this._borderMc, 0.2, {
                    width:this._bigWidth,
                    height:this._bigHeight,
                    x:(-(this._bigWidth) / 2),
                    y:-(this._bigHeight)
                });
            };
        }
        public function scaleDefault():void{
            this.removeLoading();
            if (this._video){
                TweenLite.to(this._video, 0.2, {
                    width:(this._defaultWidth - 4),
                    height:(this._defaultHeight - 4),
                    x:(-((this._defaultWidth - 4)) / 2),
                    y:(-(this._defaultHeight) + 2),
                    alpha:0,
                    onComplete:this.removeVideoTips
                });
            };
            if (this._snptBm){
                TweenLite.to(this._snptBm, 0.2, {
                    width:(this._defaultWidth - 4),
                    height:(this._defaultHeight - 4),
                    x:(-((this._defaultWidth - 4)) / 2),
                    y:(-(this._defaultHeight) + 2),
                    alpha:0,
                    onComplete:this.removeSnptBm
                });
            };
            if (this._timeBgMc){
                TweenLite.to(this._timeBgMc, 0.2, {
                    width:(this._defaultWidth - 4),
                    alpha:0,
                    onComplete:this.removeTimeBgMc
                });
            };
            TweenLite.to(this._borderMc, 0.2, {
                width:this._defaultWidth,
                height:this._defaultHeight,
                x:(-(this._defaultWidth) / 2),
                y:-(this._defaultHeight)
            });
        }
        private function newSnptBm():void{
            if (!this._snptBm){
                this._snptBm = new Bitmap();
                this._snptBm.smoothing = true;
                this._snptBm.width = (this._defaultWidth - 4);
                this._snptBm.height = (this._defaultHeight - 4);
                this._snptBm.x = (-((this._defaultWidth - 4)) / 2);
                this._snptBm.y = (-(this._defaultHeight) + 2);
                addChild(this._snptBm);
            };
        }
        private function removeSnptBm():void{
            if (this._snptBm){
                removeChild(this._snptBm);
                this._snptBm = null;
            };
        }
        private function newTimeBgMc():void{
            if (!this._timeBgMc){
                this._timeBgMc = new Sprite();
                this._timeBgMc.graphics.beginFill(0, 0.5);
                this._timeBgMc.graphics.drawRect((-((this._defaultWidth - 4)) / 2), 0, (this._defaultWidth - 4), 20);
                this._timeBgMc.graphics.endFill();
                this._timeBgMc.y = -22;
                addChild(this._timeBgMc);
            };
        }
        private function removeTimeBgMc():void{
            if (this._timeBgMc){
                removeChild(this._timeBgMc);
                this._timeBgMc = null;
            };
        }
        private function newLoading():void{
            if (!this._loading){
                this._loading = new TimeTipsLoading();
                this._loading.x = 0;
                this._loading.y = (-(this._defaultHeight) / 2);
                addChild(this._loading);
            };
        }
        private function removeLoading():void{
            if (this._loading){
                removeChild(this._loading);
                this._loading = null;
            };
        }
        private function newVideo():void{
            if (!this._video){
                this._video = new Video((this._defaultWidth - 4), (this._defaultHeight - 4));
                this._video.x = (-((this._defaultWidth - 4)) / 2);
                this._video.y = (-(this._defaultHeight) + 2);
                this._video.smoothing = true;
                this._video.attachNetStream(this._stream);
                addChild(this._video);
            };
        }
        private function removeVideo():void{
            if (this._video){
                this._video.clear();
                removeChild(this._video);
                this._video = null;
            };
        }
        private function removeVideoTips():void{
            this.removeVideo();
            this._stream.close();
        }
        public function clear():void{
            this.removeSnptBm();
            this.removeLoading();
            this.removeVideoTips();
            this.removeTimeBgMc();
        }
        private function killAllTweens():void{
            if (this._loading){
                TweenLite.killTweensOf(this._loading);
            };
            if (this._video){
                TweenLite.killTweensOf(this._video);
            };
            if (this._snptBm){
                TweenLite.killTweensOf(this._snptBm);
            };
            if (this._timeBgMc){
                TweenLite.killTweensOf(this._timeBgMc);
            };
            TweenLite.killTweensOf(this._borderMc);
        }
        private function netStatusHandler(_arg1:NetStatusEvent):void{
            if (_arg1.info.code == "NetStream.Buffer.Full"){
            } else {
                if (_arg1.info.code == "NetStream.Play.Start"){
                } else {
                    if (_arg1.info.code == "NetStream.Play.StreamNotFound"){
                    } else {
                        if (_arg1.info.code == "NetStream.Play.Stop"){
                            this._stream.seek(0);
                        };
                    };
                };
            };
        }
        private function asyncErrorHandler(_arg1:AsyncErrorEvent):void{
        }

    }
}//package ctr.tip 
﻿package ctr.tip {
    import flash.events.*;
    import flash.display.*;
    import flash.filters.*;
    import flash.text.*;

    public class ToolTip extends Sprite {

        private static var _instance:ToolTip;

        private var _label:TextField;
        private var _base:Sprite;

        public function ToolTip(_arg1:Sprite){
            this._base = _arg1;
            this._label = new TextField();
            this._label.autoSize = TextFieldAutoSize.LEFT;
            this._label.textColor = 0x333333;
            this._label.text = " ";
            this._label.selectable = false;
            this._label.x = 3;
            this._label.y = 2;
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
﻿package ctr.tip {
    import flash.display.*;
    import flash.text.*;

    public class Volume100Tips extends Sprite {

        private var volumeBg:Volume100;
        private var txt:TextField;

        public function Volume100Tips(){
            this.volumeBg = new Volume100();
            this.addChild(this.volumeBg);
            this.txt = new TextField();
            this.txt.x = 30;
            this.txt.y = 2;
            this.txt.autoSize = TextFieldAutoSize.CENTER;
            this.txt.selectable = false;
            this.addChild(this.txt);
            this.txt.setTextFormat(new TextFormat("Arial", 12, 0x8E8E8E));
            this.txt.text = "100%(按↑键继续放大音量)";
        }
        public function set text(_arg1:String):void{
            this.txt.text = _arg1;
            this.txt.setTextFormat(new TextFormat("Arial", 12, 0x8E8E8E));
        }
        public function get text():String{
            return (this.txt.text);
        }

    }
}//package ctr.tip 
﻿package ctr.tip {
    import flash.display.*;

    public class TimeTipsArrow extends MovieClip {

        public function showBg():void{
            this.graphics.clear();
            this.graphics.beginFill(0xFFFFFF, 0);
            this.graphics.drawRect(0, 1, 7, 12);
            this.graphics.endFill();
        }
        public function hideBg():void{
            this.graphics.clear();
        }
        override public function get width():Number{
            return (7);
        }

    }
}//package ctr.tip 
﻿package ctr.toolBarRight {
    import flash.events.*;
    import flash.display.*;
    import com.greensock.*;

    public class ToolBarRightArrow extends MovieClip {

        public var hidden:Boolean;
        private var _target:PlayerCtrl;
        private var _beMouseOn:Boolean;

        public function ToolBarRightArrow(_arg1:PlayerCtrl){
            this._target = _arg1;
            this._target.addChild(this);
            this.visible = false;
        }
        public function setPosition():void{
            this.x = stage.stageWidth;
            this.y = int((((stage.stageHeight - this.height) - 36) / 2));
            stage.addEventListener(Event.RESIZE, this.resizeHandler);
        }
        public function show(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.x = ((stage.stageWidth - this.width) - 5);
            } else {
                TweenLite.to(this, 0.5, {x:((stage.stageWidth - this.width) - 5)});
            };
            this.hidden = false;
        }
        public function hide(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.x = stage.stageWidth;
            } else {
                TweenLite.to(this, 0.5, {x:stage.stageWidth});
            };
            this.hidden = true;
        }
        private function resizeHandler(_arg1:Event):void{
            this.x = ((stage.stageWidth - this.width) - 5);
            this.y = int((((stage.stageHeight - this.height) - 36) / 2));
        }

    }
}//package ctr.toolBarRight 
﻿package ctr.toolBarRight {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import com.greensock.*;
    import eve.*;
    import flash.text.*;
    import flash.external.*;

    public class ToolBarRight extends Sprite {

        public var hidden:Boolean;
        private var _background:RightMenuBg;
        private var _target:PlayerCtrl;
        private var _beMouseOn:Boolean;
        private var _btnArray:Array;

        public function ToolBarRight(_arg1:PlayerCtrl){
            this._target = _arg1;
            this._background = new RightMenuBg();
            addChild(this._background);
            this._btnArray = [];
            this._btnArray.push({btn:this.drawToolBtn(BtnDownload, this.actionFunction, "download")});
            this._btnArray.push({btn:this.drawToolBtn(BtnWindow, this.actionFunction, "window")});
            this._btnArray.push({btn:this.drawToolBtn(BtnCaption, this.actionFunction, "caption")});
            this._btnArray.push({btn:this.drawToolBtn(BtnSet, this.actionFunction, "set")});
            this._btnArray.push({btn:this.drawToolBtn(BtnFeedback, this.actionFunction, "feedback")});
            var _local2 = 1;
            while (_local2 < this.numChildren) {
                this.getChildAt(_local2).y = (((_local2 - 1) * 60) + 10);
                this.getChildAt(_local2).x = 16;
                _local2++;
            };
            this._background.height = ((this.getChildAt((this.numChildren - 1)).y + this.getChildAt((this.numChildren - 1)).height) + 5);
            this._target.addChild(this);
            this.addEventListener(MouseEvent.MOUSE_OVER, this.handleMouseOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, this.handleMouseOut);
        }
        public function set enableObj(_arg1:Object):void{
            this.setBtnStatus([((_arg1.enableDownload) || (false)), ((_arg1.enableOpenWindow) || (false)), ((_arg1.enableCaption) || (false)), ((_arg1.enableSet) || (false)), ((_arg1.enableFeedback) || (false))]);
        }
        public function show(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.x = (stage.stageWidth - this.width);
            } else {
                TweenLite.to(this, 0.5, {x:(stage.stageWidth - this.width)});
            };
            this.hidden = false;
        }
        public function hide(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.x = stage.stageWidth;
            } else {
                TweenLite.to(this, 0.5, {x:stage.stageWidth});
            };
            this.hidden = true;
        }
        public function get beMouseOn():Boolean{
            return (this._beMouseOn);
        }
        private function drawToolBtn(_arg1:Class, _arg2:Function, _arg3:String):MovieClip{
            var classRef:* = _arg1;
            var action:* = _arg2;
            var evt:* = _arg3;
            var tf:* = new TextFormat();
            tf.font = "宋体";
            var btn:* = new (classRef)();
            btn.txt.defaultTextFormat = tf;
            btn.gotoAndStop(3);
            btn.buttonMode = false;
            btn.mouseChildren = false;
            btn.mouseEnabled = false;
            btn.addEventListener(MouseEvent.MOUSE_OVER, this.onBtnOver);
            btn.addEventListener(MouseEvent.MOUSE_OUT, this.onBtnOut);
            btn.addEventListener(MouseEvent.CLICK, function (_arg1:MouseEvent):void{
                action(evt);
            });
            addChild(btn);
            return (btn);
        }
        private function setBtnStatus(_arg1:Array):void{
            var _local3:*;
            var _local2:TextFormat = new TextFormat();
            _local2.font = "宋体";
            for (_local3 in _arg1) {
                if (_arg1[_local3]){
                    this._btnArray[_local3]["btn"].gotoAndStop(1);
                } else {
                    this._btnArray[_local3]["btn"].gotoAndStop(3);
                };
                this._btnArray[_local3]["btn"].txt.setTextFormat(_local2);
                this._btnArray[_local3]["btn"].buttonMode = _arg1[_local3];
                this._btnArray[_local3]["btn"].mouseEnabled = _arg1[_local3];
            };
        }
        private function handleMouseOver(_arg1:MouseEvent):void{
            this._beMouseOn = true;
        }
        private function handleMouseOut(_arg1:MouseEvent):void{
            this._beMouseOn = false;
        }
        private function onBtnOver(_arg1:MouseEvent):void{
            var _local2:TextFormat = new TextFormat();
            _local2.font = "宋体";
            var _local3:MovieClip = (_arg1.currentTarget as MovieClip);
            _local3.gotoAndStop(2);
            _local3.txt.setTextFormat(_local2);
        }
        private function onBtnOut(_arg1:MouseEvent):void{
            var _local2:TextFormat = new TextFormat();
            _local2.font = "宋体";
            var _local3:MovieClip = (_arg1.currentTarget as MovieClip);
            _local3.gotoAndStop(1);
            _local3.txt.setTextFormat(_local2);
        }
        private function actionFunction(_arg1:String):void{
            if (_arg1 == "feedback"){
                if (stage.displayState == StageDisplayState.FULL_SCREEN){
                    stage.displayState = StageDisplayState.NORMAL;
                };
            };
            if (_arg1 == "window"){
                this.clickWindow();
                return;
            };
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, _arg1));
        }
        private function clickWindow():void{
            var _local1:String = Tools.getUserInfo("from");
            var _local2:String = encodeURIComponent(Tools.getUserInfo("name"));
            var _local3:Number = new Date().getTime();
            var _local4:String = Tools.getUserInfo("ygcid");
            var _local5:String = Tools.getUserInfo("filesize");
            var _local6:String = Tools.getUserInfo("ycid");
            var _local7:String = encodeURIComponent(Tools.getUserInfo("url"));
            var _local8:Number = this._target._player.time;
            var _local9:String = GlobalVars.instance.movieFormat;
            var _local10:String = ((((Tools.getUserInfo("userid") + "_") + Tools.getUserInfo("userType")) + "_") + Tools.getUserInfo("sessionid"));
            var _local11:String = ((((((((((((((((((("from=" + _local1) + "&filename=") + _local2) + "&t=") + _local3) + "&uvs=") + _local10) + "&gcid=") + _local4) + "&filesize=") + _local5) + "&cid=") + _local6) + "&url=") + _local7) + "&start=") + _local8) + "&format=") + _local9);
            ExternalInterface.call("XL_CLOUD_FX_INSTANCE.openMini", _local11);
            if (GlobalVars.instance.isStat){
                Tools.stat("b=openmini");
            };
            JTracer.sendMessage(("ToolBarRight -> openURL:" + _local11));
            dispatchEvent(new PlayEvent(PlayEvent.OPEN_WINDOW));
        }
        private function resizeHandler(_arg1:Event):void{
            this.x = stage.stageWidth;
            this.y = int((((stage.stageHeight - this.height) - 36) / 2));
        }
        public function setPosition():void{
            stage.addEventListener(Event.RESIZE, this.resizeHandler);
            this.resizeHandler(null);
        }

    }
}//package ctr.toolBarRight 
﻿package ctr.statuMenu {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.common.*;
    import com.greensock.*;
    import eve.*;
    import flash.text.*;
    import flash.external.*;
    import flash.system.*;

    public class VideoMask extends Sprite {

        public static var noEnoughBytes:String = "noEnoughBytes";
        public static var invalidLogin:String = "invalidLogin";
        public static var refreshPage:String = "refreshPage";
        public static var exchangeError:String = "exchangeError";
        public static var playError:String = "playError";
        public static var noPrivilege:String = "noPrivilege";

        private var _qualityLoading:QualityLoading;
        private var _processLoading:ProcessLoading;
        private var _bufferLoading:BufferLoading;
        private var _startPlayBtn:StartPlayButton;
        private var _isBuffer:Boolean = false;
        private var _isFirstLoading:Boolean = true;
        private var _isQualityLoading:Boolean = false;
        private var _movieType:String;
        private var _mask:Sprite;
        private var _delayTimer:Timer;
        private var _cacheStreamPercent:Number = 0;
        private var _isFirstInit:Boolean = true;
        private var _logoEnd:LogoEnd;
        private var _invalidText:TextField;
        private var _mainMc:PlayerCtrl;
        private var _style:StyleSheet;
        private var _currentInfo:String = "";

        public function VideoMask(_arg1:PlayerCtrl, _arg2:String="movie"){
            this._delayTimer = new Timer(800, 0);
            super();
            this._mainMc = _arg1;
            this._movieType = _arg2;
            this._style = new StyleSheet();
            this._style.setStyle(".style", {
                color:"#ffffff",
                fontSize:"14",
                textAlign:"center",
                fontFamily:"宋体"
            });
            this._style.setStyle("a", {
                color:"#097BB3",
                fontSize:"14",
                textAlign:"center",
                fontFamily:"宋体",
                textDecoration:"underline"
            });
        }
        public function get currentInfo():String{
            var _local1:String = this._currentInfo;
            this._currentInfo = "";
            return (_local1);
        }
        public function bufferHandle(_arg1:String, _arg2:String=null):void{
            switch (_arg1){
                case "PlayStart":
                    this.onplay();
                    break;
                case "BufferStart":
                    if ((((this._isQualityLoading == false)) && ((this._isFirstLoading == false)))){
                        this.showLoadingBuffer();
                    };
                    break;
                case "Stop":
                    if (!this._isFirstInit){
                        this.showStopLogo();
                    };
                    break;
                case "Error":
                case "BufferEnd":
                    this.hideAll();
                    break;
            };
        }
        public function showErrorNotice(_arg1:String="", _arg2:String="", _arg3:String=""):void{
            var _local4:String;
            switch (_arg1){
                case noEnoughBytes:
                    _local4 = "<span class='style'>您的播放时长剩余0，迅雷白金会员不限时长，</span><a href='event:buyVIP13FluxOut'>加5元升级为白金</a>";
                    break;
                case invalidLogin:
                    _local4 = "<span class='style'>检测到您未登录或登录异常，请重新登录后从列表页点播</span>";
                    break;
                case refreshPage:
                    _local4 = (((("<span class='style'>检测到您未登录或登录异常，请</span> <a href='event:login'>" + "重新登录") + "</a> <span class='style'>后刷新此页面</span>\n\n<a href='event:refresh'>") + "刷新页面") + "</a>");
                    break;
                case exchangeError:
                    _local4 = (("<span class='style'>" + _arg3) + "</span>");
                    break;
                case playError:
                    if (_arg2){
                        _local4 = (("<span class='style'>播放异常，错误代码：" + _arg2) + "</span>\n\n<span class='style'>请检查网络连接或重试！</span> <a href='event:feedback'>问题反馈</a>");
                    } else {
                        _local4 = "<span class='style'>播放异常，请检查网络连接或重试！</span> <a href='event:feedback'>问题反馈</a>";
                    };
                    break;
                case noPrivilege:
                    _local4 = "<span class='style'>播放连接超时，已</span><a href='event:buyVIP11'>开通迅雷云播</a><span class='style'>用户请点击</span><a href='event:refreshWholePage'>重新获取</a>";
                    break;
                default:
                    _local4 = "";
            };
            this.hideAll();
            this.drawMask();
            if (!this._invalidText){
                this._invalidText = new TextField();
            } else {
                this._invalidText.visible = true;
            };
            this._invalidText.selectable = false;
            this._invalidText.styleSheet = this._style;
            this._invalidText.htmlText = _local4;
            this._invalidText.width = (this._invalidText.textWidth + 4);
            this._invalidText.height = (this._invalidText.textHeight + 4);
            this._invalidText.addEventListener(TextEvent.LINK, this.onTextLink);
            this.addChild(this._invalidText);
            this.setPosition();
        }
        public function showInputFace():void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            this.hideAll();
            this.drawMask();
            Tools.windowOpen(GlobalVars.instance.url_chome, "_self");
        }
        public function initInputFace():void{
        }
        public function showInitPauseLogo():void{
            this.hideAll();
            if (this._startPlayBtn == null){
                this._startPlayBtn = new StartPlayButton();
                this._startPlayBtn.gotoAndStop(1);
                this._startPlayBtn.buttonMode = true;
                this._startPlayBtn.mouseChildren = false;
                this._startPlayBtn.addEventListener(MouseEvent.CLICK, this.onStartPlayClick);
                this._startPlayBtn.addEventListener(MouseEvent.MOUSE_OVER, this.onStartPlayOver);
                this._startPlayBtn.addEventListener(MouseEvent.MOUSE_OUT, this.onStartPlayOut);
            } else {
                this._startPlayBtn.visible = true;
            };
            this.addChild(this._startPlayBtn);
            this.setPosition();
        }
        private function onTextLink(_arg1:TextEvent):void{
            switch (_arg1.text){
                case "login":
                    this.login();
                    break;
                case "refresh":
                    this.refresh(1);
                    break;
                case "refreshWholePage":
                    this.refresh(2);
                    break;
                case "buyVIP11":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {refer:"XV_34"}));
                    break;
                case "buyVIP13FluxOut":
                    this.buyVIP13FluxOut();
                    break;
                case "feedback":
                    this.feedback();
                    break;
            };
        }
        private function login():void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            if (GlobalVars.instance.platform == "client"){
                Tools.windowOpen(GlobalVars.instance.url_login, "_blank", "jump");
            } else {
                Tools.windowOpen(GlobalVars.instance.url_login);
            };
        }
        private function refresh(_arg1:int):void{
            var _local2:Event = new Event("Refresh");
            switch (_arg1){
                case 1:
                    break;
                case 2:
                    this._currentInfo = "refreshPage";
                    break;
            };
            dispatchEvent(_local2);
        }
        private function buyVIP13FluxOut():void{
            var _local1:String = GlobalVars.instance.paypos_tryfinish;
            dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                refer:"XV_13",
                paypos:_local1,
                hasBytes:false
            }));
        }
        private function feedback():void{
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "feedbackFromTips"));
        }
        private function onStartPlayClick(_arg1:MouseEvent):void{
            dispatchEvent(new Event("StartPlayClick"));
        }
        private function onStartPlayOver(_arg1:MouseEvent):void{
            this._startPlayBtn.gotoAndStop(2);
        }
        private function onStartPlayOut(_arg1:MouseEvent):void{
            this._startPlayBtn.gotoAndStop(1);
        }
        public function get isStartPlayLoading():Boolean{
            if (((this._processLoading) && (this._processLoading.visible))){
                return (true);
            };
            if (((this._qualityLoading) && (this._qualityLoading.visible))){
                return (true);
            };
            return (false);
        }
        public function showProcessLoading():void{
            this.hideAll();
            if (this._processLoading){
                this._processLoading.visible = true;
            } else {
                this._processLoading = new ProcessLoading();
            };
            this._processLoading.changeTips();
            this._processLoading.progress = 0;
            this.addChild(this._processLoading);
            this.addEventListener(Event.ENTER_FRAME, this.fnEnterFrameBytesLoaded);
            this.setPosition();
            if (this._isFirstInit){
                this._isFirstInit = false;
            } else {
                this.graphics.clear();
                this.graphics.beginFill(0);
                this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
                this.graphics.endFill();
            };
        }
        private function showStopLogo():void{
            this.hideAll();
            if ((((this._isQualityLoading == true)) || (!(this._mainMc.isShowStopFace)))){
                return;
            };
            this.drawMask();
            if (this._logoEnd){
                this._logoEnd.visible = true;
            } else {
                this._logoEnd = new LogoEnd();
                this._logoEnd.replay_btn.buttonMode = true;
                this._logoEnd.replay_btn.mouseChildren = false;
                this._logoEnd.replay_btn.addEventListener(MouseEvent.CLICK, this.onReplayClick);
                this._logoEnd.replay_btn.addEventListener(MouseEvent.MOUSE_OVER, this.onBtnOver);
                this._logoEnd.replay_btn.addEventListener(MouseEvent.MOUSE_OUT, this.onBtnOut);
                if (GlobalVars.instance.platform == "client"){
                    this._logoEnd.removeChild(this._logoEnd.share_btn);
                } else {
                    if (GlobalVars.instance.enableShare){
                        this._logoEnd.share_btn.gotoAndStop(1);
                        this._logoEnd.share_btn.buttonMode = true;
                        this._logoEnd.share_btn.mouseChildren = false;
                        this._logoEnd.share_btn.addEventListener(MouseEvent.CLICK, this.onShareClick);
                        this._logoEnd.share_btn.addEventListener(MouseEvent.MOUSE_OVER, this.onBtnOver);
                        this._logoEnd.share_btn.addEventListener(MouseEvent.MOUSE_OUT, this.onBtnOut);
                    } else {
                        this._logoEnd.share_btn.gotoAndStop(2);
                    };
                };
            };
            this.addChild(this._logoEnd);
            this.setPosition();
        }
        private function onBtnOver(_arg1:MouseEvent):void{
            var _local2:MovieClip = (_arg1.target as MovieClip);
            TweenLite.to(_local2.bg_mc, 0.2, {
                width:85,
                height:85
            });
        }
        private function onBtnOut(_arg1:MouseEvent):void{
            var _local2:MovieClip = (_arg1.target as MovieClip);
            TweenLite.to(_local2.bg_mc, 0.2, {
                width:78.75,
                height:78.75
            });
        }
        private function onReplayClick(_arg1:MouseEvent):void{
            ExternalInterface.call("flv_playerEvent", "onRePlay");
        }
        private function onShareClick(_arg1:MouseEvent):void{
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "share"));
        }
        private function showLoadingBuffer():void{
            var _local1:TextFormat;
            this.hideAll();
            this._cacheStreamPercent = 0;
            if (!this._bufferLoading){
                _local1 = new TextFormat("微软雅黑");
                this._bufferLoading = new BufferLoading();
                this._bufferLoading.loadingtext.defaultTextFormat = _local1;
                this._bufferLoading.loadingtext.setTextFormat(_local1);
            };
            this._bufferLoading.visible = false;
            this.addChild(this._bufferLoading);
            this.addEventListener(Event.ENTER_FRAME, this.fnEnterFrameBytesLoaded);
            this.setPosition();
        }
        public function showLoadingQuality():void{
            var _local1:TextFormat;
            this.hideAll();
            if (this._qualityLoading){
                this._qualityLoading.visible = true;
            } else {
                _local1 = new TextFormat("微软雅黑");
                this._qualityLoading = new QualityLoading();
                this._qualityLoading.change_txt.defaultTextFormat = _local1;
                this._qualityLoading.change_txt.setTextFormat(_local1);
            };
            addChild(this._qualityLoading);
            this.addEventListener(Event.ENTER_FRAME, this.fnEnterFrameBytesLoaded);
            this.setPosition();
        }
        private function drawMask():void{
            this._mask = new Sprite();
            this._mask.graphics.beginFill(0xFFFFFF, 0);
            this._mask.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
            addChild(this._mask);
        }
        private function fnEnterFrameBytesLoaded(_arg1:Event):void{
            dispatchEvent(new PlayEvent(PlayEvent.PROGRESS));
        }
        public function updateProgress(_arg1:Number):void{
            var _local2:Number = _arg1;
            if (_local2 >= 1){
                _local2 = 1;
            };
            _local2 = (((_local2 > this._cacheStreamPercent)) ? _local2 : this._cacheStreamPercent);
            if (this._processLoading){
                this._processLoading.progress = int((_local2 * 100));
            };
            if (((this._bufferLoading) && ((_local2 < 1)))){
                this._bufferLoading.visible = true;
                this._bufferLoading.loadingtext.text = (("" + int((_local2 * 100))) + "%");
            };
            if (_local2 == 1){
                this.removeEventListener(Event.ENTER_FRAME, this.fnEnterFrameBytesLoaded);
                this._cacheStreamPercent = 0;
                this.hideAll();
                JTracer.sendMessage(((("VideoMask -> updateProgress :" + _arg1) + " streamPercent:") + _local2));
                dispatchEvent(new PlayEvent(PlayEvent.BUFFER_END));
            };
        }
        private function delayTimerHandler(_arg1:TimerEvent):void{
            if (this._delayTimer.currentCount > 1){
                this._cacheStreamPercent = (this._cacheStreamPercent + ((Math.random() * 6) / 100));
                this._cacheStreamPercent = (((this._cacheStreamPercent > 0.99)) ? 0.99 : this._cacheStreamPercent);
            };
        }
        private function stopDelayTimer():void{
            this._delayTimer.stop();
            this._delayTimer.reset();
            if (this._delayTimer.hasEventListener(TimerEvent.TIMER)){
                this._delayTimer.removeEventListener(TimerEvent.TIMER, this.delayTimerHandler);
            };
        }
        private function onplay():void{
            var _local1:String;
            var _local2:String;
            var _local3:Number;
            var _local4:String;
            var _local5:String;
            var _local6:*;
            var _local7:String;
            var _local8:String;
            var _local9:String;
            this.hideAll();
            this.removeEventListener(Event.ENTER_FRAME, this.fnEnterFrameBytesLoaded);
            if (((!(this._isBuffer)) || ((this._isFirstLoading == true)))){
                if (this._mainMc.isFirstOnplaying){
                    this._mainMc.isFirstOnplaying = false;
                    _local1 = Tools.getUserInfo("gcid");
                    _local2 = Tools.getUserInfo("ygcid");
                    _local3 = Number(Tools.getUserInfo("userType"));
                    if ((((_local3 == 0)) || ((_local3 == 1)))){
                        _local4 = "0";
                    } else {
                        _local4 = "2";
                    };
                    _local5 = "";
                    for (_local6 in GlobalVars.instance.loadTime) {
                        _local5 = (_local5 + ((("&" + _local6) + "=") + GlobalVars.instance.loadTime[_local6]));
                    };
                    _local7 = ("&gdlConnectTime=" + GlobalVars.instance.connectGldTime);
                    _local8 = (((GlobalVars.instance.vodAddr == "")) ? "&vod=null" : ("&vod=" + GlobalVars.instance.vodAddr));
                    _local9 = GlobalVars.instance.statCC;
                    JTracer.sendMessage((((((((((((((("f=firstbuffer&gcid=" + _local1) + "&ygcid=") + _local2) + "&time=") + (getTimer() - this._mainMc._player.startTimer)) + "&playtype=") + _local4) + "&flashversion=") + Capabilities.version) + "&getVodTime=") + GlobalVars.instance.getVodTime) + _local5) + _local7) + _local8));
                    Tools.stat((((((((((((((("f=firstbuffer&gcid=" + _local1) + "&ygcid=") + _local2) + "&time=") + (getTimer() - this._mainMc._player.startTimer)) + "&playtype=") + _local4) + "&flashversion=") + Capabilities.version) + "&getVodTime=") + GlobalVars.instance.getVodTime) + _local5) + _local7) + _local8));
                };
                ExternalInterface.call("flv_playerEvent", "onplaying");
                JTracer.sendMessage("VideoMask -> onplaying");
            };
            JTracer.sendMessage(("isBuffer:" + this._isBuffer));
        }
        private function hideAll():void{
            this.graphics.clear();
            this.stopDelayTimer();
            while (numChildren > 0) {
                getChildAt((numChildren - 1)).visible = false;
                removeChild(getChildAt((numChildren - 1)));
            };
            this._cacheStreamPercent = 0;
        }
        public function setPosition():void{
            if (this._mask){
                this._mask.width = this.width;
                this._mask.height = this.height;
            };
            if (((((this._processLoading) && (this._processLoading.visible))) && (!(this._isFirstInit)))){
                this.graphics.clear();
                this.graphics.beginFill(0);
                this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
                this.graphics.endFill();
            };
            var _local1:int = this.numChildren;
            var _local2:int;
            while (_local2 < _local1) {
                if (getChildAt(_local2) === this._qualityLoading){
                    getChildAt(_local2).x = int(((this.stage.stageWidth - 315) / 2));
                    getChildAt(_local2).y = int((((this.stage.stageHeight - 41) - 33) / 2));
                } else {
                    getChildAt(_local2).x = int(((this.stage.stageWidth - getChildAt(_local2).width) / 2));
                    getChildAt(_local2).y = int((((this.stage.stageHeight - getChildAt(_local2).height) - 33) / 2));
                };
                _local2++;
            };
        }
        public function set isBuffer(_arg1:Boolean):void{
            this._isBuffer = _arg1;
        }
        public function set isQualityLoading(_arg1:Boolean):void{
            this._isQualityLoading = _arg1;
        }
        public function set isFirstLoading(_arg1:Boolean):void{
            this._isFirstLoading = _arg1;
        }

    }
}//package ctr.statuMenu 
﻿package ctr.statuMenu {
    import flash.display.*;
    import flash.utils.*;
    import flash.text.*;

    public class ProcessLoading extends MovieClip {

        public var _progress:TextField;
        private var isTipsChanged:Boolean;

        public function ProcessLoading(){
            var _local1:TextFormat = new TextFormat("微软雅黑");
            _local1.bold = true;
            this._progress.defaultTextFormat = _local1;
        }
        public function changeTips():void{
            this.isTipsChanged = false;
            setTimeout(this.onChangeTips, 1000);
        }
        public function set progress(_arg1:Number):void{
            if (!this.isTipsChanged){
                this._progress.text = "正在从原始地址下载...";
                return;
            };
            if (_arg1 <= 0){
                this._progress.text = "已下载到云空间并转码，正在准备数据... 　";
            } else {
                if (_arg1 >= 100){
                    this._progress.text = "已下载到云空间并转码，正在准备数据...99%";
                } else {
                    this._progress.text = (("已下载到云空间并转码，正在准备数据..." + String(_arg1)) + (((_arg1 < 10)) ? "% " : "%"));
                };
            };
        }
        public function set process(_arg1:String):void{
            this._progress.text = _arg1;
        }
        private function onChangeTips():void{
            this.isTipsChanged = true;
        }

    }
}//package ctr.statuMenu 
﻿package ctr.contextMenu {
    import flash.display.*;
    import flash.ui.*;

    public class CreateContextMenu {

        private static var _menu:ContextMenu;
        private static var _target:Sprite;

        public static function createMenu(_arg1:Sprite):void{
            if (_menu == null){
                _menu = new ContextMenu();
                _target = _arg1;
            };
            _menu.hideBuiltInItems();
            _target.contextMenu = _menu;
        }
        public static function addItem(_arg1:String, _arg2:Boolean, _arg3:Boolean, _arg4:Function):void{
            var _local5:int = getIndex(_arg1);
            var _local6:CreateMenuItem = new CreateMenuItem(_arg1, _arg2, _arg3, _arg4);
            if (_local5 != -1){
                _menu.customItems[_local5] = _local6.menuItem;
            } else {
                _menu.customItems.push(_local6.menuItem);
            };
        }
        public static function delItem(_arg1:String):void{
            var _local2:int = getIndex(_arg1);
            if (_local2 != -1){
                _menu.customItems.slice(_local2, 1);
            };
        }
        public static function setEnabled(_arg1:String, _arg2:Boolean):void{
            var _local3:int = getIndex(_arg1);
            if (_local3 != -1){
                _menu.customItems[_local3].enabled = _arg2;
            };
        }
        private static function getIndex(_arg1:String):int{
            var _local2 = -1;
            var _local3:int;
            var _local4:int = _menu.customItems.length;
            while (_local3 < _local4) {
                if (_arg1 == _menu.customItems[_local3].caption){
                    _local2 = _local3;
                    break;
                };
                _local3++;
            };
            return (_local2);
        }

    }
}//package ctr.contextMenu 
﻿package ctr.contextMenu {
    import flash.events.*;
    import flash.ui.*;

    public class CreateMenuItem extends EventDispatcher {

        private var _menuItem:ContextMenuItem;
        private var _action:Function;

        public function CreateMenuItem(_arg1:String, _arg2:Boolean, _arg3:Boolean, _arg4:Function){
            this._menuItem = new ContextMenuItem(_arg1, _arg2, _arg3);
            this._menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, this.menuItemSelectedHandler, false, 0, false);
            this._action = _arg4;
        }
        public function get menuItem():ContextMenuItem{
            return (this._menuItem);
        }
        private function menuItemSelectedHandler(_arg1:ContextMenuEvent):void{
            if (((!((this._action == null))) && ((this._action is Function)))){
                this._action();
            };
        }

    }
}//package ctr.contextMenu 
﻿package ctr.question {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import eve.*;
    import com.serialization.json.*;
    import flash.text.*;

    public class FeedbackFace extends MovieClip {

        public var email_txt:TextField;
        public var info_txt:TextField;
        public var info_bg:MovieClip;
        public var submit_btn:SimpleButton;
        public var close_btn:SetCloseButton;
        private var qArray:Array;
        private var itemArray:Array;
        private var loadLoader:URLLoader;
        private var info_tips:String = "补充问题描述，或提交您所遇见的其它问题或建议。";
        private var email_tips:String = "请留下您的邮箱地址/QQ号，方便我们联系您。";
        private var isLoaded:Boolean;
        private var mainMc:PlayerCtrl;
        private var defaultEmail:String = "";
        private var defaultInfo:String = "";
        private var tf:TextFormat;

        public function FeedbackFace(_arg1:PlayerCtrl){
            this.qArray = [];
            this.itemArray = [];
            super();
            this.mainMc = _arg1;
            this.tf = new TextFormat("宋体");
            this.showFace(false);
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
            this.submit_btn.alpha = 0.4;
            this.submit_btn.mouseEnabled = false;
            this.submit_btn.addEventListener(MouseEvent.CLICK, this.onSubmitClick);
            this.initInfoInputText();
            this.initEmailInputText();
        }
        public function showFace(_arg1:Boolean):void{
            this.visible = _arg1;
            if (((_arg1) && (!(this.isLoaded)))){
                this.loadData();
            };
        }
        public function setPosition():void{
            this.x = int(((stage.stageWidth - 460) / 2));
            this.y = int((((stage.stageHeight - 300) - 33) / 2));
        }
        private function loadData():void{
            var _local1:URLRequest = new URLRequest(GlobalVars.instance.url_feedback);
            this.loadLoader = new URLLoader();
            this.loadLoader.addEventListener(Event.COMPLETE, this.onDataLoaded);
            this.loadLoader.load(_local1);
        }
        private function onDataLoaded(_arg1:Event):void{
            var _local4:*;
            var _local5:Object;
            this.isLoaded = true;
            var _local2:String = _arg1.target.data;
            var _local3:Object = JSON.deserialize(_local2);
            for (_local4 in _local3) {
                _local5 = new Object();
                _local5.id = _local4;
                _local5.label = _local3[_local4];
                _local5.selected = false;
                this.qArray.push(_local5);
                JTracer.sendMessage((((("FeedbackFace -> id:" + _local4) + ", label:") + _local3[_local4]) + "\n"));
            };
            this.initCheckbox();
            this.initInfoInputText();
        }
        private function onSubmitClick(_arg1:MouseEvent):void{
            var _local3:*;
            var _local4:String;
            var _local5:String;
            var _local6:String;
            var _local2:Array = [];
            for (_local3 in this.qArray) {
                if (this.qArray[_local3].selected){
                    _local2.push(this.qArray[_local3].id);
                };
            };
            _local4 = _local2.join(",");
            _local5 = encodeURI(this.defaultInfo);
            _local6 = encodeURI(this.defaultEmail);
            Tools.stat(((((((("b=feedback&gdl=" + encodeURIComponent(this.mainMc._player.playUrl)) + "&prob=") + _local4) + "&op=") + _local5) + "&contact=") + _local6));
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "feedback"));
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "feedback"));
        }
        private function initCheckbox():void{
            var _local1:*;
            var _local2:CheckboxItem;
            for (_local1 in this.qArray) {
                _local2 = new CheckboxItem();
                _local2.name_txt.text = this.qArray[_local1].label;
                _local2.name_txt.setTextFormat(this.tf);
                _local2.name = this.qArray[_local1].id;
                _local2.name_txt.width = (_local2.name_txt.textWidth + 10);
                _local2.name_txt.height = (_local2.name_txt.textHeight + 4);
                _local2.x = (((_local1 % 2) * 200) + 45);
                _local2.y = ((Math.floor((_local1 / 2)) * 25) + 40);
                _local2.cb_mc.gotoAndStop(1);
                _local2.bg_mc.width = _local2.name_txt.width;
                _local2.mouseChildren = false;
                _local2.buttonMode = true;
                _local2.addEventListener(MouseEvent.CLICK, this.onItemClick);
                addChild(_local2);
                this.itemArray.push(_local2);
            };
        }
        private function initInfoInputText():void{
            var _local1:int = Math.ceil((this.qArray.length / 2));
            var _local2:Number = ((_local1 * 25) + 40);
            this.info_bg.width = 424;
            this.info_bg.height = (225 - _local2);
            this.info_bg.x = ((460 - this.info_bg.width) / 2);
            this.info_bg.y = _local2;
            this.info_txt.width = (this.info_bg.width - 6);
            this.info_txt.height = (this.info_bg.height - 6);
            this.info_txt.x = (this.info_bg.x + 3);
            this.info_txt.y = (this.info_bg.y + 3);
            this.info_txt.defaultTextFormat = this.tf;
            this.info_txt.text = this.info_tips;
            this.info_txt.addEventListener(FocusEvent.FOCUS_IN, this.onInInfoText);
            this.info_txt.addEventListener(FocusEvent.FOCUS_OUT, this.onOutInfoText);
            this.info_txt.addEventListener(Event.CHANGE, this.onInfoTextChange);
        }
        private function initEmailInputText():void{
            this.email_txt.defaultTextFormat = this.tf;
            this.email_txt.text = this.email_tips;
            this.email_txt.addEventListener(FocusEvent.FOCUS_IN, this.onInEmailText);
            this.email_txt.addEventListener(FocusEvent.FOCUS_OUT, this.onOutEmailText);
            this.email_txt.addEventListener(Event.CHANGE, this.onEmailTextChange);
        }
        private function onInInfoText(_arg1:FocusEvent):void{
            if (this.defaultInfo == ""){
                this.info_txt.text = "";
            };
        }
        private function onOutInfoText(_arg1:FocusEvent):void{
            if (this.defaultInfo == ""){
                this.info_txt.text = this.info_tips;
            };
        }
        private function onInfoTextChange(_arg1:Event):void{
            this.defaultInfo = this.info_txt.text;
            this.setSubmitStatus();
        }
        private function onInEmailText(_arg1:FocusEvent):void{
            if (this.defaultEmail == ""){
                this.email_txt.text = "";
            };
        }
        private function onOutEmailText(_arg1:FocusEvent):void{
            if (this.defaultEmail == ""){
                this.email_txt.text = this.email_tips;
            };
        }
        private function onEmailTextChange(_arg1:Event):void{
            this.defaultEmail = this.email_txt.text;
            this.setSubmitStatus();
        }
        private function setSubmitStatus():void{
            var _local1:Boolean = this.checkHasText();
            if (_local1){
                this.submit_btn.alpha = 1;
                this.submit_btn.mouseEnabled = true;
            } else {
                this.submit_btn.alpha = 0.4;
                this.submit_btn.mouseEnabled = false;
            };
        }
        private function checkHasText():Boolean{
            var _local1:Boolean;
            var _local2:*;
            var _local3:Boolean;
            for (_local2 in this.qArray) {
                if (this.qArray[_local2].selected){
                    _local1 = true;
                    break;
                };
            };
            _local3 = !((this.defaultInfo == ""));
            if (((_local3) || (_local1))){
                return (true);
            };
            return (false);
        }
        private function onItemClick(_arg1:MouseEvent):void{
            var _local2:CheckboxItem = (_arg1.currentTarget as CheckboxItem);
            var _local3:int = this.findIndex(_local2);
            if (_local2.cb_mc.currentFrame == 1){
                _local2.cb_mc.gotoAndStop(2);
                if (_local3 != -1){
                    this.qArray[_local3].selected = true;
                };
            } else {
                _local2.cb_mc.gotoAndStop(1);
                if (_local3 != -1){
                    this.qArray[_local3].selected = false;
                };
            };
            this.setSubmitStatus();
        }
        private function findIndex(_arg1:CheckboxItem):int{
            var _local2:*;
            for (_local2 in this.qArray) {
                if (this.qArray[_local2].id == _arg1.name){
                    return (_local2);
                };
            };
            return (-1);
        }

    }
}//package ctr.question 
﻿package ctr.toolBarTop {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import com.greensock.*;
    import flash.text.*;
    import flash.external.*;

    public class ToolBarTop extends Sprite {

        public var hidden:Boolean;
        private var _target:PlayerCtrl;
        private var _beMouseOn:Boolean;
        private var _urlTxt:TextField;
        private var _playBtn:PlayButtonTop;
        private var _outString:String = "";
        private var _overString:String = "输入视频下载链接点击播放";
        private var _playUrl:String;
        private var _inputUrl:String;
        private var _systemTimeTxt:TextField;
        private var _isFocusIn:Boolean;

        public function ToolBarTop(_arg1:PlayerCtrl){
            this._target = _arg1;
            this._target.addChild(this);
            this.drawInputBg();
            var _local2:TextFormat = new TextFormat("宋体");
            this._urlTxt = new TextField();
            this._urlTxt.defaultTextFormat = _local2;
            this._urlTxt.type = TextFieldType.INPUT;
            this._urlTxt.textColor = 0x787878;
            this._urlTxt.wordWrap = false;
            this._urlTxt.multiline = false;
            this._urlTxt.width = (stage.stageWidth - 80);
            this._urlTxt.height = (this._urlTxt.textHeight + 4);
            this._urlTxt.x = 15;
            this._urlTxt.y = 3;
            this._urlTxt.addEventListener(MouseEvent.MOUSE_OVER, this.onOverUrlTxt);
            this._urlTxt.addEventListener(MouseEvent.MOUSE_OUT, this.onOutUrlTxt);
            this._urlTxt.addEventListener(FocusEvent.FOCUS_IN, this.onFocusInUrlTxt);
            this._urlTxt.addEventListener(FocusEvent.FOCUS_OUT, this.onFocusOutUrlTxt);
            this._urlTxt.addEventListener(MouseEvent.CLICK, this.onClickUrlTxt);
            this._urlTxt.addEventListener(Event.CHANGE, this.onChangeUrlTxt);
            addChild(this._urlTxt);
            this._playBtn = new PlayButtonTop();
            this._playBtn.x = ((stage.stageWidth - this._playBtn.width) - 8);
            this._playBtn.y = 3;
            this._playBtn.addEventListener(MouseEvent.CLICK, this.playNewUrl);
            addChild(this._playBtn);
            this._systemTimeTxt = new TextField();
            this._systemTimeTxt.selectable = false;
            this._systemTimeTxt.textColor = 0xFFFFFF;
            this._systemTimeTxt.visible = false;
            addChild(this._systemTimeTxt);
            this.addEventListener(MouseEvent.MOUSE_OVER, this.handleMouseOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, this.handleMouseOut);
        }
        public function fullScreen():void{
            this._urlTxt.visible = false;
            this._playBtn.visible = false;
            this._systemTimeTxt.visible = true;
            this.drawBg();
        }
        public function normalScreen():void{
            this._urlTxt.visible = true;
            this._playBtn.visible = true;
            this._systemTimeTxt.visible = false;
            this.drawInputBg();
        }
        public function setSystemTime(_arg1:String):void{
            this._systemTimeTxt.htmlText = (("<font size='18'>" + _arg1) + "</font>");
            this._systemTimeTxt.width = (this._systemTimeTxt.textWidth + 10);
            this._systemTimeTxt.height = (this._systemTimeTxt.textHeight + 4);
            this._systemTimeTxt.x = (stage.stageWidth - this._systemTimeTxt.width);
            this._systemTimeTxt.y = 2;
        }
        public function set infoObj(_arg1:Object):void{
            var str:* = null;
            var obj:* = _arg1;
            try {
                str = decodeURI(obj.name);
            } catch(e:Error) {
                str = obj.name;
                JTracer.sendMessage("ToolBarTop -> decodeURI发生错误");
            };
            this._urlTxt.text = str;
            this._outString = str;
            this._playUrl = obj.url;
            this._inputUrl = obj.url;
            this._playBtn.mouseEnabled = true;
        }
        public function show(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.y = 0;
            } else {
                TweenLite.to(this, 0.5, {y:0});
            };
            this.hidden = false;
        }
        public function hide(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.y = -25;
            } else {
                TweenLite.to(this, 0.5, {y:-25});
            };
            this.hidden = true;
        }
        public function setPosition():void{
            stage.addEventListener(Event.RESIZE, this.resizeHandler);
            this.resizeHandler(null);
        }
        public function get beMouseOn():Boolean{
            return (this._beMouseOn);
        }
        private function playNewUrl(_arg1:MouseEvent):void{
            if (this._inputUrl == this._playUrl){
                dispatchEvent(new Event("ShowPlayingTips"));
                return;
            };
            this._target.clearSnpt();
            if (GlobalVars.instance.isStat){
                Tools.stat("b=topBarPlay");
            };
            this._playBtn.mouseEnabled = false;
            ExternalInterface.call("XL_CLOUD_FX_INSTANCE.playOther", true, this._inputUrl);
        }
        private function onOverUrlTxt(_arg1:MouseEvent):void{
            if (this._isFocusIn){
                return;
            };
            this._urlTxt.text = this._overString;
            this._urlTxt.setSelection(this._overString.length, this._overString.length);
        }
        private function onOutUrlTxt(_arg1:MouseEvent):void{
            if (this._isFocusIn){
                return;
            };
            this._urlTxt.text = this._outString;
            this._urlTxt.setSelection(this._outString.length, this._outString.length);
        }
        private function onFocusInUrlTxt(_arg1:FocusEvent):void{
            this._isFocusIn = true;
            this._urlTxt.text = "";
        }
        private function onFocusOutUrlTxt(_arg1:FocusEvent):void{
            this._isFocusIn = false;
            this._urlTxt.text = this._outString;
            this._urlTxt.setSelection(this._outString.length, this._outString.length);
        }
        private function onClickUrlTxt(_arg1:MouseEvent):void{
            this._urlTxt.text = "";
        }
        private function onChangeUrlTxt(_arg1:Event):void{
            this._outString = this._urlTxt.text;
            this._inputUrl = this._urlTxt.text;
        }
        private function drawInputBg():void{
            this.graphics.clear();
            this.graphics.beginFill(2368550);
            this.graphics.drawRect(0, 0, stage.stageWidth, 25);
            this.graphics.beginFill(0xC8C8C8);
            this.graphics.drawRoundRect(10, 3, (stage.stageWidth - 70), 19, 4, 4);
            this.graphics.endFill();
        }
        private function drawBg():void{
            this.graphics.clear();
            this.graphics.beginFill(2368550);
            this.graphics.drawRect(0, 0, stage.stageWidth, 25);
            this.graphics.endFill();
        }
        private function resizeHandler(_arg1:Event):void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                this.drawBg();
            } else {
                this.drawInputBg();
            };
            this.x = 0;
            this.y = -25;
            this._urlTxt.width = (stage.stageWidth - 80);
            this._playBtn.x = ((stage.stageWidth - this._playBtn.width) - 8);
            this._systemTimeTxt.x = (stage.stageWidth - this._systemTimeTxt.width);
        }
        private function handleMouseOver(_arg1:MouseEvent):void{
            this._beMouseOn = true;
        }
        private function handleMouseOut(_arg1:MouseEvent):void{
            this._beMouseOn = false;
        }

    }
}//package ctr.toolBarTop 
﻿package ctr.volume {
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;
    import eve.*;

    public class McVolume extends MovieClip {

        public var ctrB;
        private var _volumeBg:MovieClip;
        private var _volumeProgress:MovieClip;
        private var _btnVolume:SimpleButton;
        private var _currentVolume:Number = 0.5;
        private var _volumeMask:MovieClip;
        private var _so:SharedObject;
        private var _volumeCtr:VolumeCtr;
        private var _isShow:Boolean = false;

        public function McVolume(_arg1){
            this.ctrB = _arg1;
            this._volumeCtr = new VolumeCtr();
            this.addChild(this._volumeCtr);
            this._volumeBg = this._volumeCtr.unget;
            this._volumeMask = this._volumeCtr.mask1;
            this._btnVolume = this._volumeCtr.scroll;
            this._volumeBg.mask = this._volumeMask;
            this._btnVolume.y = 0;
            this._volumeBg.buttonMode = true;
            this._volumeBg.useHandCursor = true;
            this._btnVolume.addEventListener(MouseEvent.MOUSE_DOWN, this.handleBtnVolumeMouseDown);
            this.addEventListener(MouseEvent.CLICK, this.handleMouseClick);
            this.init();
        }
        private function showHandler(_arg1:MouseEvent):void{
            switch (_arg1.type){
                case "mouseOver":
                    this.visible = true;
                    this._isShow = true;
                    break;
                case "mouseOut":
                    this.visible = false;
                    this._isShow = false;
                    break;
            };
        }
        public function get show():Boolean{
            return (this._isShow);
        }
        private function handleMouseClick(_arg1:MouseEvent):void{
            var _local2:Number = _arg1.stageX;
            var _local3:Number = _arg1.stageY;
            this._btnVolume.x = this.globalToLocal(new Point(_local2, _local3)).x;
            if (this._btnVolume.x >= 45){
                this._btnVolume.x = 45;
            };
            if (this._btnVolume.x <= 0){
                this._btnVolume.x = 0;
            };
            this._volumeMask.width = ((53 - this._btnVolume.x) - 1);
            this._volumeMask.x = (this._btnVolume.x + 1);
            this._currentVolume = (this._btnVolume.x / 45);
            this.dispatchEvent(new VolumeEvent(VolumeEvent.VOLUME_CHANGE, String(this._currentVolume)));
            this.saveVV();
        }
        public function handleVolumeBar(_arg1:Number):void{
            this._currentVolume = _arg1;
            if (this._currentVolume > 1){
                this._btnVolume.x = 45;
            } else {
                this._btnVolume.x = (this._currentVolume * 45);
            };
            this._volumeMask.width = ((53 - this._btnVolume.x) - 1);
            this._volumeMask.x = (this._btnVolume.x + 1);
            this.saveVV();
        }
        private function handleBtnVolumeMouseMove(_arg1:MouseEvent):void{
            var _local2:Number = _arg1.stageX;
            var _local3:Number = _arg1.stageY;
            this._btnVolume.x = this.globalToLocal(new Point(_local2, _local3)).x;
            if (this._btnVolume.x >= 45){
                this._btnVolume.x = 45;
            };
            if (this._btnVolume.x <= 0){
                this._btnVolume.x = 0;
            };
            this._volumeMask.width = ((53 - this._btnVolume.x) - 1);
            this._volumeMask.x = (this._btnVolume.x + 1);
            this._currentVolume = (this._btnVolume.x / 45);
            this.dispatchEvent(new VolumeEvent(VolumeEvent.VOLUME_CHANGE, String(this._currentVolume)));
        }
        private function handleBtnVolumeMouseDown(_arg1:MouseEvent):void{
            this._btnVolume.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.handleBtnVolumeMouseMove);
            this._btnVolume.stage.addEventListener(MouseEvent.MOUSE_UP, this.handleBtnVolumeMouseUp);
        }
        private function handleBtnVolumeMouseUp(_arg1:MouseEvent):void{
            this._btnVolume.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.handleBtnVolumeMouseMove);
            this._btnVolume.stage.removeEventListener(MouseEvent.MOUSE_UP, this.handleBtnVolumeMouseUp);
            if ((((((((this.mouseY < 0)) || ((this.mouseY > 12)))) || ((this.mouseX < 0)))) || ((this.mouseX > 53)))){
                this.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
            };
            this.saveVV();
        }
        public function get currentVolume():Number{
            return (this._currentVolume);
        }
        override public function set width(_arg1:Number):void{
            this._currentVolume = (_arg1 / 45);
            this._btnVolume.x = (((_arg1 > 45)) ? 45 : _arg1);
            this._volumeMask.width = ((53 - this._btnVolume.x) - 1);
            this._volumeMask.x = (this._btnVolume.x + 1);
            dispatchEvent(new VolumeEvent(VolumeEvent.VOLUME_CHANGE, String(this._currentVolume)));
        }
        private function init():void{
            this._so = SharedObject.getLocal("kkV");
            if (this._so.data.v){
                this.width = (this._so.data.v * 45);
            } else {
                this.width = (0.5 * 45);
            };
        }
        private function saveVV():void{
            this._so = SharedObject.getLocal("kkV");
            var _local1:* = this._currentVolume;
            if (_local1 <= 0){
                _local1 = 0;
            };
            this._so.data.v = _local1;
            this._so.flush();
        }

    }
}//package ctr.volume 
﻿package ctr.download {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.common.*;
    import eve.*;
    import flash.external.*;

    public class DownloadFace extends MovieClip {

        public var download_btn:MovieClip;
        public var close_btn:SetCloseButton;
        private var _constArray:Array;
        private var _itemDiction:Dictionary;
        private var _currentFormat:String;

        public function DownloadFace(){
            var _local1:uint;
            var _local3:Object;
            var _local4:CheckBoxItem;
            this._constArray = [{
                format:"c",
                label:"超清(1080P)",
                tips:"适合电视、电脑等高分辨率大屏幕"
            }, {
                format:"g",
                label:"高清(720P)",
                tips:"适合iPad等大尺寸移动设备"
            }, {
                format:"p",
                label:"流畅(480P)",
                tips:"适合iPhone等高分辨率手机"
            }, {
                format:"y",
                label:"原始版本",
                tips:"原始清晰度"
            }];
            super();
            this.visible = false;
            this._itemDiction = new Dictionary(true);
            var _local2:uint = this._constArray.length;
            _local1 = 0;
            while (_local1 < _local2) {
                _local3 = this._constArray[_local1];
                _local4 = new CheckBoxItem();
                _local4.format = _local3.format;
                _local4.formatText = _local3.label;
                _local4.tipsText = _local3.tips;
                _local4.enabled = false;
                _local4.x = 50;
                _local4.y = (50 + (_local1 * 25));
                _local4.addEventListener("SelectItem", this.onSelectItem);
                addChild(_local4);
                this._itemDiction[_local3.format] = _local4;
                _local1++;
            };
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
            this.download_btn.buttonMode = true;
            this.download_btn.mouseChildren = false;
            this.download_btn.alpha = 0.6;
            this.download_btn.mouseEnabled = false;
            this.download_btn.gotoAndStop(1);
            this.download_btn.addEventListener(MouseEvent.MOUSE_OVER, this.onDownloadOver);
            this.download_btn.addEventListener(MouseEvent.MOUSE_OUT, this.onDownloadOut);
            this.download_btn.addEventListener(MouseEvent.CLICK, this.onDownloadClick);
        }
        public function setDownloadFormat(_arg1:Object):void{
            var _local2:*;
            var _local3:CheckBoxItem;
            if (!_arg1){
                return;
            };
            for (_local2 in _arg1) {
                _local3 = (this._itemDiction[_local2] as CheckBoxItem);
                if (_local2 == "y"){
                    _local3.enabled = true;
                } else {
                    _local3.enabled = _arg1[_local2].enable;
                };
            };
            this.selectFirstEnableItem();
        }
        public function setPosition():void{
            this.x = int(((stage.stageWidth - 460) / 2));
            this.y = int((((stage.stageHeight - 228) - 33) / 2));
        }
        public function showFace(_arg1:Boolean):void{
            this.visible = _arg1;
            if (_arg1){
                this.setNonSelected();
                this.selectFirstEnableItem();
            };
        }
        public function setAllDisabled():void{
            var _local1:*;
            var _local2:CheckBoxItem;
            for (_local1 in this._itemDiction) {
                _local2 = (this._itemDiction[_local1] as CheckBoxItem);
                _local2.enabled = false;
            };
            this.download_btn.alpha = 0.6;
            this.download_btn.mouseEnabled = false;
        }
        private function selectFirstEnableItem():void{
            var _local1:*;
            var _local2:CheckBoxItem;
            for (_local1 in this._constArray) {
                _local2 = (this._itemDiction[this._constArray[_local1].format] as CheckBoxItem);
                if (_local2.enabled){
                    _local2.selected = true;
                    this._currentFormat = _local2.format;
                    break;
                };
            };
            this.download_btn.alpha = 1;
            this.download_btn.mouseEnabled = true;
        }
        private function setNonSelected():void{
            var _local1:*;
            var _local2:CheckBoxItem;
            for (_local1 in this._itemDiction) {
                _local2 = (this._itemDiction[_local1] as CheckBoxItem);
                if (_local2.enabled){
                    _local2.selected = false;
                };
            };
        }
        private function onSelectItem(_arg1:Event):void{
            this.setNonSelected();
            var _local2:CheckBoxItem = (_arg1.currentTarget as CheckBoxItem);
            _local2.selected = true;
            this._currentFormat = _local2.format;
            this.download_btn.alpha = 1;
            this.download_btn.mouseEnabled = true;
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "download"));
        }
        private function onDownloadClick(_arg1:MouseEvent):void{
            var _local2:String;
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            if (this._currentFormat == "c"){
                _local2 = "chaoqing";
            } else {
                if (this._currentFormat == "g"){
                    _local2 = "gaoqing";
                } else {
                    if (this._currentFormat == "p"){
                        _local2 = "liuchang";
                    } else {
                        if (this._currentFormat == "y"){
                            _local2 = "yuanshi";
                        };
                    };
                };
            };
            if (GlobalVars.instance.isStat){
                Tools.stat(("b=download&dwType=" + _local2));
            };
            ExternalInterface.call("XL_CLOUD_FX_INSTANCE.download", this._currentFormat);
        }
        private function onDownloadOver(_arg1:MouseEvent):void{
            this.download_btn.gotoAndStop(2);
        }
        private function onDownloadOut(_arg1:MouseEvent):void{
            this.download_btn.gotoAndStop(1);
        }

    }
}//package ctr.download 
﻿package ctr.download {
    import flash.events.*;
    import flash.display.*;
    import flash.text.*;

    public class CheckBoxItem extends MovieClip {

        public var check_mc:MovieClip;
        public var select_btn:SimpleButton;
        public var tips_txt:TextField;
        public var format_txt:TextField;
        private var _normalFormat:TextFormat;
        private var _disableFormat:TextFormat;
        private var _selected:Boolean;
        private var _enable:Boolean;
        private var _format:String;

        public function CheckBoxItem(){
            this._normalFormat = new TextFormat();
            this._normalFormat.color = 0xFFFFFF;
            this._normalFormat.size = 12;
            this._normalFormat.font = "宋体";
            this._disableFormat = new TextFormat();
            this._disableFormat.color = 0x353535;
            this._disableFormat.size = 12;
            this._disableFormat.font = "宋体";
            this.select_btn.mouseEnabled = false;
            this.select_btn.addEventListener(MouseEvent.MOUSE_OVER, this.onOver);
            this.select_btn.addEventListener(MouseEvent.MOUSE_OUT, this.onOut);
            this.select_btn.addEventListener(MouseEvent.CLICK, this.onClick);
        }
        public function set formatText(_arg1:String):void{
            this.format_txt.defaultTextFormat = this._disableFormat;
            this.format_txt.selectable = false;
            this.format_txt.text = _arg1;
            this.format_txt.width = (this.format_txt.textWidth + 10);
            this.select_btn.width = (this.format_txt.x + this.format_txt.textWidth);
        }
        public function set tipsText(_arg1:String):void{
            this.tips_txt.defaultTextFormat = this._disableFormat;
            this.tips_txt.selectable = false;
            this.tips_txt.text = _arg1;
            this.tips_txt.width = (this.tips_txt.textWidth + 10);
            this.tips_txt.x = 110;
        }
        override public function set enabled(_arg1:Boolean):void{
            this._enable = _arg1;
            if (_arg1){
                this.select_btn.mouseEnabled = true;
                this.check_mc.gotoAndStop(1);
                this.format_txt.setTextFormat(this._normalFormat);
            } else {
                this.select_btn.mouseEnabled = false;
                this.check_mc.gotoAndStop(3);
                this.format_txt.setTextFormat(this._disableFormat);
            };
        }
        override public function get enabled():Boolean{
            return (this._enable);
        }
        public function set selected(_arg1:Boolean):void{
            this._selected = _arg1;
            if (_arg1){
                this.check_mc.gotoAndStop(2);
            } else {
                this.check_mc.gotoAndStop(1);
            };
        }
        public function get selected():Boolean{
            return (this._selected);
        }
        public function set format(_arg1:String):void{
            this._format = _arg1;
        }
        public function get format():String{
            return (this._format);
        }
        private function onOver(_arg1:MouseEvent):void{
        }
        private function onOut(_arg1:MouseEvent):void{
        }
        private function onClick(_arg1:MouseEvent):void{
            dispatchEvent(new Event("SelectItem"));
        }

    }
}//package ctr.download 
﻿package ctr.addBytes {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import eve.*;
    import flash.text.*;

    public class AddBytesFace extends MovieClip {

        public var close_btn:SimpleButton;
        public var addBytes_btn:SimpleButton;
        public var info_txt:TextField;
        public var remind_txt:TextField;
        public var progress_mc:MovieClip;

        public function AddBytesFace(){
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
            this.addBytes_btn.addEventListener(MouseEvent.CLICK, this.onAddBytes);
        }
        public function setInfo(_arg1:String, _arg2:String, _arg3:Number):void{
            this.info_txt.text = (("播放本次视频需流量" + _arg1) + "，扩充流量即可观看。");
            this.remind_txt.text = ("剩余" + _arg2);
            this.progress_mc.mask_mc.width = (234 * _arg3);
        }
        public function setPosition():void{
            this.x = ((stage.stageWidth - 358) / 2);
            this.y = (((stage.stageHeight - 218) - 33) / 2);
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new Event("CloseAddBytesFace"));
        }
        private function onAddBytes(_arg1:MouseEvent):void{
            var _local2:String = GlobalVars.instance.paypos_trystop;
            dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                refer:"XV_13",
                paypos:_local2,
                hasBytes:true
            }));
        }

    }
}//package ctr.addBytes 
﻿package ctr.addBytes {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import eve.*;
    import flash.text.*;

    public class NoEnoughBytesFace extends MovieClip {

        private var _style:StyleSheet;
        public var close_btn:SimpleButton;
        public var know_btn:SimpleButton;
        public var info_txt:TextField;

        public function NoEnoughBytesFace(){
            this._style = new StyleSheet();
            this._style.setStyle(".style", {
                color:"#ffffff",
                fontSize:"14",
                textAlign:"center",
                fontFamily:"宋体"
            });
            this._style.setStyle("a", {
                color:"#097BB3",
                fontSize:"14",
                textAlign:"center",
                fontFamily:"宋体",
                textDecoration:"underline"
            });
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
            this.know_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
            this.info_txt.styleSheet = this._style;
            this.info_txt.htmlText = "<span class='style'>您的播放时长剩余0，迅雷白金会员不限时长，</span><a href='event:th'>加5元升级为白金</a>";
            this.info_txt.addEventListener(MouseEvent.CLICK, this.onAddBytes);
        }
        public function setPosition():void{
            this.x = ((stage.stageWidth - 358) / 2);
            this.y = (((stage.stageHeight - 173) - 33) / 2);
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new Event("CloseNoEnoughFace"));
        }
        private function onAddBytes(_arg1:MouseEvent):void{
            var _local2:String = GlobalVars.instance.paypos_tryfinish;
            dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                refer:"XV_13",
                paypos:_local2,
                hasBytes:false
            }));
        }

    }
}//package ctr.addBytes 
﻿package ctr.format {
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import eve.*;

    public class FormatShowBtn extends Sprite {

        public static const TEXT_CLICK:String = "text click";

        private var _biaoqingdetail:FormatShowDetailBtn;
        private var _gaoqingdetail:FormatShowDetailBtn;
        private var _chaoqingdetail:FormatShowDetailBtn;
        private var _bg:FormatBg;

        public function FormatShowBtn(){
            this._bg = new FormatBg();
            addChild(this._bg);
            this._biaoqingdetail = new FormatShowDetailBtn("流畅");
            this._biaoqingdetail.x = 7;
            this._biaoqingdetail.y = -60;
            this._biaoqingdetail.addEventListener(MouseEvent.CLICK, this.mouseClickHandler);
            addChild(this._biaoqingdetail);
            this._gaoqingdetail = new FormatShowDetailBtn("高清");
            this._gaoqingdetail.x = 7;
            this._gaoqingdetail.y = -40;
            this._gaoqingdetail.addEventListener(MouseEvent.CLICK, this.mouseClickHandler);
            addChild(this._gaoqingdetail);
            this._chaoqingdetail = new FormatShowDetailBtn("超清");
            this._chaoqingdetail.x = 7;
            this._chaoqingdetail.y = -20;
            this._chaoqingdetail.addEventListener(MouseEvent.CLICK, this.mouseClickHandler);
            addChild(this._chaoqingdetail);
        }
        private function mouseClickHandler(_arg1:MouseEvent):void{
            var _local2:SetQulityEvent = new SetQulityEvent(SetQulityEvent.CLICK_QULITY);
            dispatchEvent(_local2);
            var _local3:String = SetQulityEvent.NORMAL_QULITY;
            if (_arg1.target == this._biaoqingdetail){
                if (!this._biaoqingdetail.isEnable){
                    return;
                };
                JTracer.sendMessage("mouseClickHandler点到标清了...");
                this._biaoqingdetail.setSelected(true);
                this._gaoqingdetail.setSelected(false);
                this._chaoqingdetail.setSelected(false);
                _local3 = SetQulityEvent.STANDARD_QULITY;
            } else {
                if (_arg1.target == this._gaoqingdetail){
                    if (!this._gaoqingdetail.isEnable){
                        return;
                    };
                    JTracer.sendMessage("mouseClickHandler点到高清了...");
                    this._biaoqingdetail.setSelected(false);
                    this._gaoqingdetail.setSelected(true);
                    this._chaoqingdetail.setSelected(false);
                    _local3 = SetQulityEvent.HEIGH_QULITY;
                } else {
                    if (_arg1.target == this._chaoqingdetail){
                        if (!this._chaoqingdetail.isEnable){
                            return;
                        };
                        JTracer.sendMessage("mouseClickHandler点到超清了...");
                        this._biaoqingdetail.setSelected(false);
                        this._gaoqingdetail.setSelected(false);
                        this._chaoqingdetail.setSelected(true);
                        _local3 = SetQulityEvent.SUPERHEIGH_QULITY;
                    };
                };
            };
            var _local4:SetQulityEvent = new SetQulityEvent(SetQulityEvent.CHANGE_QUILTY, _local3);
            dispatchEvent(_local4);
        }
        public function showLayer(_arg1:Object):void{
            var _local2:*;
            for (_local2 in _arg1) {
                trace(((("item:" + _local2) + "---") + _arg1[_local2]));
            };
            if (((((_arg1) && (_arg1.p))) && (_arg1.p.enable))){
                this._biaoqingdetail.setEnable(true);
            } else {
                this._biaoqingdetail.setEnable(false);
            };
            if (((((_arg1) && (_arg1.g))) && (_arg1.g.enable))){
                this._gaoqingdetail.setEnable(true);
            } else {
                this._gaoqingdetail.setEnable(false);
            };
            if (((((_arg1) && (_arg1.c))) && (_arg1.c.enable))){
                this._chaoqingdetail.setEnable(true);
            } else {
                this._chaoqingdetail.setEnable(false);
            };
        }
        public function set detail(_arg1:String):void{
            if (_arg1 == "p"){
                this._biaoqingdetail.setSelected(true);
                this._biaoqingdetail.setCurrentEnable(false);
                this._gaoqingdetail.setSelected(false);
                this._chaoqingdetail.setSelected(false);
            } else {
                if (_arg1 == "g"){
                    this._biaoqingdetail.setSelected(false);
                    this._gaoqingdetail.setSelected(true);
                    this._gaoqingdetail.setCurrentEnable(false);
                    this._chaoqingdetail.setSelected(false);
                } else {
                    if (_arg1 == "c"){
                        this._biaoqingdetail.setSelected(false);
                        this._gaoqingdetail.setSelected(false);
                        this._chaoqingdetail.setSelected(true);
                        this._chaoqingdetail.setCurrentEnable(false);
                    } else {
                        this._biaoqingdetail.setSelected(false);
                        this._gaoqingdetail.setSelected(false);
                        this._chaoqingdetail.setSelected(false);
                    };
                };
            };
        }

    }
}//package ctr.format 
﻿package ctr.format {
    import flash.events.*;
    import flash.display.*;
    import flash.text.*;

    public class CurrentFormatBtn extends MovieClip {

        public var arrow_mc:MovieClip;
        private var _showText:TextField;
        private var _selectFormat:TextFormat;
        private var _disableFormat:TextFormat;
        private var _curFormat:String;
        private var _isEnabled:Boolean;

        public function CurrentFormatBtn(){
            this._selectFormat = new TextFormat("宋体", 12, 954585, false);
            this._disableFormat = new TextFormat("宋体", 12, 0x444444, false);
            this._showText = new TextField();
            this._showText.width = 45;
            this._showText.height = 18;
            this._showText.x = 7;
            this._showText.y = 4;
            addChild(this._showText);
            this._curFormat = "流畅";
            this._showText.text = this._curFormat;
            this.isEnabled = false;
        }
        public function set isClicked(_arg1:Boolean):void{
            if (_arg1){
                if (this._isEnabled){
                    this.arrow_mc.gotoAndStop(4);
                } else {
                    this.arrow_mc.gotoAndStop(3);
                };
            } else {
                if (this._isEnabled){
                    this.arrow_mc.gotoAndStop(4);
                } else {
                    this.arrow_mc.gotoAndStop(3);
                };
            };
        }
        public function showLayer(_arg1:Object):void{
            this._curFormat = "";
            if (((((_arg1) && (_arg1.g))) && ((_arg1.g.checked == true)))){
                this._curFormat = "高清";
            } else {
                if (((((_arg1) && (_arg1.p))) && ((_arg1.p.checked == true)))){
                    this._curFormat = "流畅";
                } else {
                    if (((((_arg1) && (_arg1.y))) && ((_arg1.y.checked == true)))){
                        this._curFormat = "原始";
                    } else {
                        if (((((_arg1) && (_arg1.c))) && ((_arg1.c.checked == true)))){
                            this._curFormat = "超清";
                        };
                    };
                };
            };
            if (this._curFormat == ""){
                this._curFormat = "流畅";
                this._showText.text = this._curFormat;
                this.isEnabled = false;
                return;
            };
            this._showText.text = this._curFormat;
            this.isEnabled = true;
        }
        public function set showBtn(_arg1:String):void{
            this._curFormat = "";
            switch (_arg1){
                case "y":
                    this._curFormat = "原始";
                    break;
                case "p":
                    this._curFormat = "流畅";
                    break;
                case "g":
                    this._curFormat = "高清";
                    break;
                case "c":
                    this._curFormat = "超清";
                    break;
            };
            if (this._curFormat == ""){
                this._curFormat = "流畅";
                this._showText.text = this._curFormat;
                this.isEnabled = false;
                return;
            };
            this._showText.text = this._curFormat;
            this.isEnabled = true;
        }
        private function get isEnabled():Boolean{
            return (this._isEnabled);
        }
        private function set isEnabled(_arg1:Boolean):void{
            this._isEnabled = _arg1;
            if (_arg1){
                this.mouseChildren = false;
                this.buttonMode = true;
                this.mouseEnabled = true;
                this._showText.setTextFormat(this._selectFormat);
                this.arrow_mc.gotoAndStop(4);
                this.addEventListener(MouseEvent.CLICK, this.clickFormatBtn);
            } else {
                this.mouseChildren = false;
                this.buttonMode = false;
                this.mouseEnabled = false;
                this._showText.setTextFormat(this._disableFormat);
                this.arrow_mc.gotoAndStop(3);
                this.removeEventListener(MouseEvent.CLICK, this.clickFormatBtn);
            };
        }
        private function clickFormatBtn(_arg1:MouseEvent):void{
            dispatchEvent(new Event("clickCurrentFormat"));
        }

    }
}//package ctr.format 
﻿package ctr.format {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import eve.*;

    public class FormatBtn extends Sprite {

        private var _formatShowBtn:FormatShowBtn;
        private var _curFormat:String = "";

        public function FormatBtn(){
            this._formatShowBtn = new FormatShowBtn();
            this._formatShowBtn.addEventListener(SetQulityEvent.CHANGE_QUILTY, this.formatShowBtnHandler);
            this._formatShowBtn.addEventListener(SetQulityEvent.CLICK_QULITY, this.formatClickHandler);
            addChild(this._formatShowBtn);
        }
        public function get curFormat():String{
            return (this._curFormat);
        }
        private function formatClickHandler(_arg1:SetQulityEvent):void{
            dispatchEvent(new Event("clickFormat"));
        }
        private function formatShowBtnHandler(_arg1:SetQulityEvent):void{
            var _local2:Object = new Object();
            _local2.checked = true;
            var _local3:String = _arg1.qulity;
            if (_local3 == SetQulityEvent.NORMAL_QULITY){
                _local2.format = "y";
            } else {
                if (_local3 == SetQulityEvent.STANDARD_QULITY){
                    _local2.format = "p";
                } else {
                    if (_local3 == SetQulityEvent.HEIGH_QULITY){
                        _local2.format = "g";
                    } else {
                        if (_local3 == SetQulityEvent.SUPERHEIGH_QULITY){
                            _local2.format = "c";
                        };
                    };
                };
            };
            if (GlobalVars.instance.isStat){
                Tools.stat(((((("b=changeformat&gcid=" + Tools.getUserInfo("ygcid")) + "&format=") + _local2.format) + "&lastformat=") + GlobalVars.instance.movieFormat));
            };
            Tools.setFormatCallBack(_local2.format, _local2.checked);
        }
        public function changeToNextFormat():void{
            var _local1:Object = new Object();
            _local1.checked = true;
            this._formatShowBtn.detail = (_local1.format = (this._curFormat = "p"));
            dispatchEvent(new SetQulityEvent(SetQulityEvent.CHANGE_QUILTY));
            Tools.setFormatCallBack(_local1.format, _local1.checked);
        }
        public function showLayer(_arg1:Object):void{
            JTracer.sendMessage(("setFormats:" + _arg1));
            this._formatShowBtn.showLayer(_arg1);
            this._curFormat = "";
            if (((((_arg1) && (_arg1.g))) && ((_arg1.g.checked == true)))){
                this._curFormat = "g";
            } else {
                if (((((_arg1) && (_arg1.p))) && ((_arg1.p.checked == true)))){
                    this._curFormat = "p";
                } else {
                    if (((((_arg1) && (_arg1.y))) && ((_arg1.y.checked == true)))){
                        this._curFormat = "y";
                    } else {
                        if (((((_arg1) && (_arg1.c))) && ((_arg1.c.checked == true)))){
                            this._curFormat = "c";
                        };
                    };
                };
            };
            this._formatShowBtn.detail = this._curFormat;
            GlobalVars.instance.movieFormat = this._curFormat;
        }
        public function set showBtn(_arg1:String):void{
            this._curFormat = _arg1;
            this._formatShowBtn.detail = this._curFormat;
            GlobalVars.instance.movieFormat = this._curFormat;
        }

    }
}//package ctr.format 
﻿package ctr.format {
    import flash.events.*;
    import flash.display.*;
    import flash.text.*;

    public class FormatShowDetailBtn extends MovieClip {

        private var _showText:TextField;
        private var _count:Number = 0;
        private var _blueCircle:BlueCircle;
        private var _selectFormat:TextFormat;
        private var _noselectFormat:TextFormat;
        private var _disableFormat:TextFormat;
        private var _isEnable:Boolean = true;

        public function FormatShowDetailBtn(_arg1:String){
            this._selectFormat = new TextFormat("宋体", 12, 954585, false);
            this._noselectFormat = new TextFormat("宋体", 12, 0x9B9B9B, false);
            this._disableFormat = new TextFormat("宋体", 12, 0x333333, false);
            this._blueCircle = new BlueCircle();
            this._blueCircle.gotoAndStop(3);
            this._blueCircle.visible = false;
            this._blueCircle.x = 36;
            this._blueCircle.y = 8;
            addChild(this._blueCircle);
            this._showText = new TextField();
            this._showText.defaultTextFormat = this._disableFormat;
            this._showText.width = 45;
            this._showText.height = 18;
            this._showText.text = _arg1;
            addChild(this._showText);
            this.mouseChildren = false;
            this.buttonMode = true;
            this.setEnable(false);
            this.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);
            this.addEventListener(MouseEvent.MOUSE_UP, this.mouseEventHandler);
            this.addEventListener(MouseEvent.MOUSE_OUT, this.mouseEventHandler);
        }
        private function mouseEventHandler(_arg1:MouseEvent):void{
            switch (_arg1.type){
                case MouseEvent.MOUSE_DOWN:
                    this._count++;
                    this._count = Math.min(this._count, 1);
                    this.x = (this.x + this._count);
                    this.y = (this.y + this._count);
                    break;
                case MouseEvent.MOUSE_UP:
                case MouseEvent.MOUSE_OUT:
                    this.x = (this.x - this._count);
                    this.y = (this.y - this._count);
                    this._count--;
                    this._count = Math.max(this._count, 0);
                    break;
            };
        }
        public function set text(_arg1:String):void{
            this._showText.text = _arg1;
        }
        public function get isEnable():Boolean{
            return (this._isEnable);
        }
        public function setSelected(_arg1:Boolean):void{
            if (_arg1){
                this._showText.defaultTextFormat = this._selectFormat;
                this._showText.setTextFormat(this._selectFormat);
                this._blueCircle.gotoAndStop(2);
                this._blueCircle.visible = true;
            } else {
                if (this._isEnable){
                    this._showText.defaultTextFormat = this._noselectFormat;
                    this._showText.setTextFormat(this._noselectFormat);
                    this._blueCircle.gotoAndStop(1);
                    this._blueCircle.visible = false;
                } else {
                    this._showText.defaultTextFormat = this._disableFormat;
                    this._showText.setTextFormat(this._disableFormat);
                    this._blueCircle.gotoAndStop(3);
                    this._blueCircle.visible = false;
                };
            };
        }
        public function setEnable(_arg1:Boolean):void{
            if (_arg1){
                this._isEnable = true;
                this.buttonMode = true;
            } else {
                this._isEnable = false;
                this.buttonMode = false;
            };
        }
        public function setCurrentEnable(_arg1:Boolean):void{
            if (_arg1){
                this._isEnable = true;
                this.buttonMode = true;
            } else {
                this._isEnable = false;
                this.buttonMode = false;
            };
        }

    }
}//package ctr.format 
﻿package ctr.subtitle {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.*;
    import com.common.*;
    import eve.*;
    import flash.filters.*;
    import flash.text.*;
    import flash.external.*;
    import flash.system.*;

    public class Subtitle extends Sprite {

        private var _player:Player;
        private var _currentWidth:Number;
        private var _currentHeight:Number;
        private var _txtSubTitle:TextField;
        private var _normalTextFormat:TextFormat;
        private var _normalTextFilter:GlowFilter;
        private var _arrList:Array;
        private var _lastTime:uint = 0;
        private var _lastIndex:uint = 0;
        private var _getTitleTimer:Timer;
        private var _captionStamp:Number = 0;
        private var _mainMc:PlayerCtrl;
        private var _fontSize:Number = 25;
        private var _scid:String;
        private var _surl:String;
        private var _sname:String;
        private var _sdata:ByteArray;
        private var _isSaveAutoload:Boolean;
        private var _isRetry:Boolean;
        private var _reg_html:RegExp;
        private var _reg_rn:RegExp;
        private var _reg_r:RegExp;
        private var _reg_n:RegExp;
        private var _reg_N:RegExp;
        private var _startTime:Number;
        private var _endTime:Number;
        private var _curTime:Number;
        private var _totalTime:Number = 180000;
        private var _timeInterval:Number;
        private var _isGrade:Boolean;

        public function Subtitle(_arg1:PlayerCtrl, _arg2:Player, _arg3:Number=352, _arg4:Number=293){
            this.visible = false;
            this._mainMc = _arg1;
            this._mainMc.addChild(this);
            this._player = _arg2;
            this._currentWidth = _arg3;
            this._currentHeight = _arg4;
            this.initializeViews();
            this.initializeGetSubtitleTimer();
            this.initRegExp();
        }
        public function get hasSubtitle():Boolean{
            if (((this._arrList) && ((this._arrList.length > 0)))){
                return (true);
            };
            return (false);
        }
        public function setStyle(_arg1:Object):void{
            this._normalTextFormat.color = _arg1.fontColor;
            this._normalTextFormat.size = _arg1.fontSize;
            this._fontSize = Number(this._normalTextFormat.size);
            this._normalTextFormat.size = int(((this._fontSize / 500) * stage.stageHeight));
            this._normalTextFilter.color = _arg1.filterColor;
            this._txtSubTitle.defaultTextFormat = this._normalTextFormat;
            this._txtSubTitle.setTextFormat(this._normalTextFormat);
            this._txtSubTitle.filters = [this._normalTextFilter];
            this._txtSubTitle.height = (this._txtSubTitle.textHeight + 10);
            this.y = ((stage.stageHeight - this._txtSubTitle.textHeight) - 50);
        }
        public function setTimeDelta(_arg1:Number):void{
            this._captionStamp = _arg1;
        }
        public function loadContent(_arg1:Object):void{
            var _local2:URLRequest;
            var _local3:URLLoader;
            var _local4:String;
            this._arrList = [];
            this._surl = _arg1.surl;
            this._scid = _arg1.scid;
            this._sname = _arg1.sname;
            this._sdata = _arg1.sdata;
            this._isSaveAutoload = _arg1.isSaveAutoload;
            this._isRetry = Boolean(_arg1.isRetry);
            this._totalTime = (Number(_arg1.gradeTime) * 1000);
            if (this._scid){
                _local4 = ((this._isRetry) ? ("&t=" + new Date().time) : "");
                _local2 = new URLRequest((((GlobalVars.instance.url_subtitle_content + "?scid=") + this._scid) + _local4));
                _local3 = new URLLoader();
                _local3.addEventListener(Event.COMPLETE, this.onLoadComplete);
                _local3.addEventListener(IOErrorEvent.IO_ERROR, this.onLoadError);
                _local3.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLoadSecurityError);
                _local3.addEventListener(HTTPStatusEvent.HTTP_STATUS, this.onLoadStatusError);
                _local3.load(_local2);
                return;
            };
            if (this._sdata){
                this.applyContent(this._sdata);
                return;
            };
        }
        public function hideCaption(_arg1:Object):void{
            this.visible = false;
            this._getTitleTimer.stop();
            this._arrList = [];
            this._surl = _arg1.surl;
            this._scid = _arg1.scid;
            this._txtSubTitle.htmlText = "";
            this.saveAutoload("0");
        }
        public function setContent(_arg1:String):void{
            if (_arg1 != ""){
                this._arrList = this.parseCaptions(_arg1);
            };
            if (this._arrList.length > 0){
                this._getTitleTimer.start();
                ExternalInterface.call("G_PLAYER_INSTANCE.captionCallback", 1);
                dispatchEvent(new CaptionEvent(CaptionEvent.APPLY_SUCCESS));
            } else {
                ExternalInterface.call("G_PLAYER_INSTANCE.captionCallback", 5);
                dispatchEvent(new CaptionEvent(CaptionEvent.APPLY_ERROR));
            };
        }
        public function saveStyle():void{
            var _local1:GlobalVars = GlobalVars.instance;
            if (Tools.getUserInfo("userid") == "0"){
                JTracer.sendMessage("Subtitle -> saveStyle, userid is empty");
                return;
            };
            var _local2:String = Tools.getUserInfo("userid");
            var _local3:String = this._scid;
            var _local4:String = this._fontSize.toString();
            var _local5:String = this.toARGB(uint(this._normalTextFormat.color));
            var _local6:String = this.toARGB(uint(this._normalTextFilter.color));
            var _local7:URLVariables = new URLVariables();
            _local7.font_size = _local4;
            _local7.font_color = _local5;
            _local7.background_color = _local6;
            var _local8:URLRequest = new URLRequest(((_local1.url_subtitle_style + "?userid=") + _local2));
            _local8.method = URLRequestMethod.POST;
            _local8.data = _local7;
            JTracer.sendMessage(((("Subtitle -> saveStyle, url:" + _local8.url) + ", params:") + _local7));
            sendToURL(_local8);
        }
        public function saveTimeDelta():void{
            if (!this._scid){
                return;
            };
            var _local1:GlobalVars = GlobalVars.instance;
            if ((((((Tools.getUserInfo("ygcid") == null)) || ((Tools.getUserInfo("ycid") == null)))) || ((Tools.getUserInfo("userid") == "0")))){
                JTracer.sendMessage("Subtitle -> saveTimeDelta, userid is empty");
                return;
            };
            var _local2:String = Tools.getUserInfo("ygcid");
            var _local3:String = Tools.getUserInfo("ycid");
            var _local4:String = Tools.getUserInfo("userid");
            var _local5:String = this._scid;
            var _local6:URLVariables = new URLVariables();
            _local6.time_delta = this._captionStamp;
            var _local7:URLRequest = new URLRequest(((((((((_local1.url_subtitle_time + "?gcid=") + _local2) + "&cid=") + _local3) + "&userid=") + _local4) + "&scid=") + _local5));
            _local7.method = URLRequestMethod.POST;
            _local7.data = _local6;
            JTracer.sendMessage(((("Subtitle -> saveTimeDelta, url:" + _local7.url) + ", params:") + _local6));
            sendToURL(_local7);
        }
        private function getFontFamily():String{
            var _local2:*;
            var _local3:*;
            var _local4:Array;
            var _local1:Object = {
                微软雅黑:["Windows Vista", "Windows 7", "Windows 8"],
                幼圆:["Windows XP"]
            };
            for (_local2 in _local1) {
                _local4 = _local1[_local2];
                for (_local3 in _local4) {
                    if (_local4[_local3].indexOf(Capabilities.os) > -1){
                        return (_local2);
                    };
                };
            };
            return ("宋体");
        }
        private function initializeViews():void{
            var _local1:String = this.getFontFamily();
            this._normalTextFormat = new TextFormat();
            this._normalTextFormat.color = 0xFFFFFF;
            this._normalTextFormat.size = int(((this._fontSize / 500) * stage.stageHeight));
            this._normalTextFormat.font = _local1;
            this._normalTextFormat.align = "center";
            this._normalTextFormat.bold = true;
            this._normalTextFilter = new GlowFilter(0, 1, 2, 2, 5, BitmapFilterQuality.HIGH);
            this._txtSubTitle = new TextField();
            this._txtSubTitle.wordWrap = true;
            this._txtSubTitle.multiline = true;
            this._txtSubTitle.defaultTextFormat = this._normalTextFormat;
            this._txtSubTitle.selectable = false;
            this._txtSubTitle.width = (this._currentWidth - 40);
            this._txtSubTitle.x = 20;
            this._txtSubTitle.filters = [this._normalTextFilter];
            addChild(this._txtSubTitle);
        }
        private function initializeGetSubtitleTimer():void{
            this._getTitleTimer = new Timer(50);
            this._getTitleTimer.addEventListener(TimerEvent.TIMER, this.handlGetTitleTimer);
        }
        private function initRegExp():void{
            this._reg_html = new RegExp("<([S|/]*?)[^/>]*>.*?|<.*? />", "g");
            this._reg_rn = /\\r\\n/g;
            this._reg_r = /\\r/g;
            this._reg_n = /\\n/g;
            this._reg_N = /\\N/g;
        }
        private function handlGetTitleTimer(_arg1:TimerEvent):void{
            var _local4:String;
            var _local5:String;
            var _local6:String;
            var _local7:URLVariables;
            var _local8:URLRequest;
            if (this._mainMc.isStartPlayLoading){
                this._txtSubTitle.text = "";
                return;
            };
            var _local2:Number = this._player.time;
            var _local3:String = this.getText(((_local2 * 1000) - this._captionStamp));
            this._txtSubTitle.htmlText = _local3;
            this._txtSubTitle.height = (this._txtSubTitle.textHeight + 10);
            this.y = ((stage.stageHeight - this._txtSubTitle.textHeight) - 50);
            this._endTime = getTimer();
            this._timeInterval = (this._endTime - this._startTime);
            this._startTime = this._endTime;
            if (((((((!(this._scid)) || (this._player.isPause))) || (this._player.isStop))) || (this._player.main_mc.isBuffering))){
                return;
            };
            this._curTime = (this._curTime + this._timeInterval);
            if ((((this._curTime > this._totalTime)) && (!(this._isGrade)))){
                this._isGrade = true;
                _local4 = Tools.getUserInfo("ygcid");
                _local5 = Tools.getUserInfo("ycid");
                _local6 = this._scid;
                _local7 = new URLVariables();
                _local7.a = "";
                _local8 = new URLRequest((((((((GlobalVars.instance.url_subtitle_grade + "?gcid=") + _local4) + "&cid=") + _local5) + "&scid=") + _local6) + "&type=0"));
                _local8.method = URLRequestMethod.POST;
                _local8.data = _local7;
                JTracer.sendMessage(((("Subtitle -> subtitle grade, end timer, getTimer():" + this._curTime) + ", url:") + _local8.url));
                sendToURL(_local8);
            };
        }
        private function toARGB(_arg1:uint):String{
            var _local2:uint = ((_arg1 >> 16) & 0xFF);
            var _local3:uint = ((_arg1 >> 8) & 0xFF);
            var _local4:uint = (_arg1 & 0xFF);
            return (((((_local2 + ",") + _local3) + ",") + _local4));
        }
        private function saveAutoload(_arg1:String):void{
            if (!this._scid){
                return;
            };
            var _local2:GlobalVars = GlobalVars.instance;
            if ((((((Tools.getUserInfo("ygcid") == null)) || ((Tools.getUserInfo("ycid") == null)))) || ((Tools.getUserInfo("userid") == "0")))){
                JTracer.sendMessage("Subtitle -> saveStyle, userid is empty");
                return;
            };
            var _local3:String = Tools.getUserInfo("ygcid");
            var _local4:String = Tools.getUserInfo("ycid");
            var _local5:String = Tools.getUserInfo("userid");
            var _local6:String = this._scid;
            var _local7:String = this._sname;
            var _local8:URLVariables = new URLVariables();
            _local8.autoload = _arg1;
            var _local9:URLRequest = new URLRequest(((((((((((_local2.url_subtitle_autoload + "?gcid=") + _local3) + "&cid=") + _local4) + "&userid=") + _local5) + "&scid=") + _local6) + "&sname=") + encodeURIComponent(_local7)));
            _local9.method = URLRequestMethod.POST;
            _local9.data = _local8;
            JTracer.sendMessage(((("Subtitle -> saveAutoload, url:" + _local9.url) + ", params:") + _local8));
            sendToURL(_local9);
        }
        private function onLoadComplete(_arg1:Event):void{
            var _local2:URLLoader = URLLoader(_arg1.target);
            this.applyContent(_local2.data);
        }
        private function applyContent(_arg1:Object):void{
            var _local2:String = _arg1.toString();
            if (_local2 != ""){
                this._arrList = this.parseCaptions(_local2);
            };
            if (this._arrList.length > 0){
                this._isGrade = false;
                this._startTime = getTimer();
                this._curTime = 0;
                JTracer.sendMessage(("Subtitle -> subtitle grade, start timer, getTimer():" + this._startTime));
                this._getTitleTimer.start();
                this.visible = true;
                if (this._isSaveAutoload){
                    this.saveAutoload("1");
                };
                ExternalInterface.call("G_PLAYER_INSTANCE.captionCallback", 1);
                dispatchEvent(new CaptionEvent(CaptionEvent.APPLY_SUCCESS));
            } else {
                ExternalInterface.call("G_PLAYER_INSTANCE.captionCallback", 5);
                dispatchEvent(new CaptionEvent(CaptionEvent.APPLY_ERROR));
            };
        }
        private function parseCaptions(_arg1:String):Array{
            var _local4:uint;
            var _local6:Object;
            var _local2:Array = [];
            _arg1 = this.trim(_arg1);
            var _local3:Array = _arg1.split("\r\n\r\n");
            if (_local3.length == 1){
                _local3 = _arg1.split("\n\n");
            };
            var _local5:uint = _local3.length;
            _local4 = 0;
            while (_local4 < _local5) {
                _local6 = this.parseCaption(_local3[_local4]);
                if (((((_local6.bt) && (_local6.et))) && (_local6.txt))){
                    _local2.push(_local6);
                };
                _local4++;
            };
            return (_local2);
        }
        private function parseCaption(_arg1:String):Object{
            var _local4:Number;
            var _local5:uint;
            var _local6:uint;
            _arg1 = this.trim(_arg1);
            var _local2:Object = new Object();
            var _local3:Array = _arg1.split("\r\n");
            if (_local3.length == 1){
                _local3 = _arg1.split("\n");
            };
            try {
                _local4 = _local3[1].indexOf("-->");
                if (_local4 > 0){
                    _local2["bt"] = this.parseTime(_local3[1].substr(0, _local4));
                    _local2["et"] = this.parseTime(_local3[1].substr((_local4 + 3)));
                };
                if (_local3[2]){
                    _local2["txt"] = _local3[2].replace(this._reg_html, "");
                    _local6 = _local3.length;
                    _local5 = 3;
                    while (_local5 < _local6) {
                        _local2["txt"] = (_local2["txt"] + ("<br/>" + _local3[_local5]));
                        _local5++;
                    };
                    _local2["txt"] = _local2["txt"].replace(this._reg_rn, "<br/>");
                    _local2["txt"] = _local2["txt"].replace(this._reg_r, "<br/>");
                    _local2["txt"] = _local2["txt"].replace(this._reg_n, "<br/>");
                    _local2["txt"] = _local2["txt"].replace(this._reg_N, "<br/>");
                };
            } catch(err:Error) {
            };
            return (_local2);
        }
        private function trim(_arg1:String):String{
            return (_arg1.replace(/^\s+/, "").replace(/\s+$/, ""));
        }
        private function onLoadError(_arg1:IOErrorEvent):void{
            ExternalInterface.call("G_PLAYER_INSTANCE.captionCallback", 2);
            dispatchEvent(new CaptionEvent(CaptionEvent.APPLY_ERROR));
        }
        private function onLoadSecurityError(_arg1:SecurityErrorEvent):void{
            ExternalInterface.call("G_PLAYER_INSTANCE.captionCallback", 3);
            dispatchEvent(new CaptionEvent(CaptionEvent.APPLY_ERROR));
        }
        private function onLoadStatusError(_arg1:HTTPStatusEvent):void{
            ExternalInterface.call("G_PLAYER_INSTANCE.captionCallback", 4);
        }
        private function parseTime(_arg1:String):uint{
            var _local3:Array;
            var _local4:uint;
            var _local5:Array;
            var _local6:uint;
            var _local7:uint;
            var _local8:uint;
            var _local2:uint;
            if (_arg1 != ""){
                _local3 = _arg1.split(",");
                _local4 = parseInt(_local3[1]);
                _local5 = _local3[0].split(":");
                _local6 = parseInt(_local5[0]);
                _local7 = parseInt(_local5[1]);
                _local8 = parseInt(_local5[2]);
                _local2 = (_local2 + (_local8 * 1000));
                _local2 = (_local2 + ((_local7 * 60) * 1000));
                _local2 = (_local2 + (((_local6 * 60) * 60) * 1000));
                _local2 = (_local2 + _local4);
            };
            trace(("parseTime:" + _local2));
            return (_local2);
        }
        private function getText(_arg1:uint):String{
            var _local3:uint;
            var _local5:Object;
            var _local2 = "";
            var _local4:uint = this._arrList.length;
            _local3 = 0;
            while (_local3 < _local4) {
                _local5 = this._arrList[_local3];
                if ((((_local5.bt <= _arg1)) && ((_arg1 <= _local5.et)))){
                    _local2 = _local5.txt;
                    break;
                };
                _local3++;
            };
            trace(("getText:" + _local2));
            return (_local2);
        }
        public function handleStageResize(_arg1:Number, _arg2:Number, _arg3:Boolean=false):void{
            this._normalTextFormat.size = int(((this._fontSize / 500) * _arg2));
            this._txtSubTitle.defaultTextFormat = this._normalTextFormat;
            this._txtSubTitle.setTextFormat(this._normalTextFormat);
            this._txtSubTitle.width = (_arg1 - 40);
            this._txtSubTitle.height = (this._txtSubTitle.textHeight + 10);
            this.y = ((_arg2 - this._txtSubTitle.textHeight) - 50);
            this._currentWidth = _arg1;
            this._currentHeight = _arg2;
        }

    }
}//package ctr.subtitle 
﻿package ctr.subtitle {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import eve.*;
    import ctr.setting.*;
    import com.serialization.json.*;
    import flash.text.*;

    public class SetCaptionStyleFace extends Sprite {

        private var _sizeSlider:CommonSlider;
        private var _timeSlider:CommonSlider;
        private var _styleTxt:TextField;
        private var _fontSize:Number = 25;
        private var _fontColor:uint = 0xFFFFFF;
        private var _filterColor:uint = 0;
        private var _timeStamp:Number = 0;
        private var _controllType:String;
        private var _lastFontSize:Number;
        private var _lastFontColor:uint;
        private var _lastFilterColor:uint;
        private var _lastTimeStamp:Number;
        private var _btnArray:Array;
        private var _styleLoader:URLLoader;
        private var _timeLoader:URLLoader;

        public function SetCaptionStyleFace(){
            this._lastFontSize = this._fontSize;
            this._lastFontColor = this._fontColor;
            this._lastFilterColor = this._filterColor;
            this._lastTimeStamp = this._timeStamp;
            this._btnArray = [];
            super();
            this._sizeSlider = new CommonSlider();
            addChild(this._sizeSlider);
            this._sizeSlider.title = "字体大小";
            this._sizeSlider.x = 30;
            this._sizeSlider.y = 10;
            this._sizeSlider.minValue = 10;
            this._sizeSlider.maxValue = 36;
            this._sizeSlider.snapInterval = 1;
            this._sizeSlider.clickInterval = 1;
            this._sizeSlider.decimalNum = 0;
            this._sizeSlider.isShowToolTip = true;
            this._sizeSlider.isThumbIconHasStatus = true;
            this._sizeSlider.currentValue = this._fontSize;
            this._sizeSlider.addEventListener(CommonSlider.CHANGE_VALUE, this.changeSizeHandler);
            this._timeSlider = new CommonSlider();
            addChild(this._timeSlider);
            this._timeSlider.title = "字幕同步";
            this._timeSlider.minValue = -200;
            this._timeSlider.maxValue = 200;
            this._timeSlider.snapInterval = 0.1;
            this._timeSlider.clickInterval = 0.5;
            this._timeSlider.decimalNum = 1;
            this._timeSlider.isShowToolTip = true;
            this._timeSlider.isFormatTip = true;
            this._timeSlider.isSupportHover = true;
            this._timeSlider.isThumbIconHasStatus = true;
            this._timeSlider.prefixTip = "提前|推迟";
            this._timeSlider.unit = "秒";
            this._timeSlider.currentValue = this._timeStamp;
            this._timeSlider.addEventListener(CommonSlider.CHANGE_VALUE, this.changeTimeHandler);
            this._timeSlider.x = 30;
            this._timeSlider.y = 50;
            var _local1:TextFormat = new TextFormat("宋体");
            this._styleTxt = new TextField();
            this._styleTxt.textColor = 0xC1C1C1;
            this._styleTxt.selectable = false;
            this._styleTxt.text = "样式风格";
            this._styleTxt.setTextFormat(_local1);
            this._styleTxt.width = (this._styleTxt.textWidth + 10);
            this._styleTxt.height = (this._styleTxt.textHeight + 5);
            this._styleTxt.x = 48;
            this._styleTxt.y = 85;
            addChild(this._styleTxt);
            this._btnArray = [];
            this._btnArray.push(this.drawToolBtn("黑/黄", 0, 0xFFFF00, false, this.actionFunction));
            this._btnArray.push(this.drawToolBtn("白/粉", 0xFFFFFF, 0xFF00FF, false, this.actionFunction));
            this._btnArray.push(this.drawToolBtn("白/蓝", 0xFFFFFF, 0xFF, false, this.actionFunction));
            this._btnArray.push(this.drawToolBtn("黑/白", 0, 0xFFFFFF, true, this.actionFunction));
            var _local2 = 3;
            while (_local2 < this.numChildren) {
                this.getChildAt(_local2).y = 84;
                this.getChildAt(_local2).x = (123 + ((_local2 - 3) * 60));
                _local2++;
            };
            var _local3:StyleSheet = new StyleSheet();
            _local3.setStyle("a", {
                color:"#097BB3",
                fontSize:"12",
                textAlign:"center",
                fontFamily:"宋体"
            });
            var _local4:TextField = new TextField();
            _local4.x = 380;
            _local4.y = 100;
            _local4.selectable = false;
            _local4.styleSheet = _local3;
            _local4.text = "<a href='event:default'>恢复默认</a>";
            _local4.width = (_local4.textWidth + 4);
            _local4.addEventListener(TextEvent.LINK, this.onDefaultClick);
            addChild(_local4);
            var _local5:SetCommitButton = new SetCommitButton();
            _local5.y = 141;
            _local5.x = 170;
            _local5.addEventListener(MouseEvent.CLICK, this.commitButtonClickHandler);
            addChild(_local5);
            this.deactiveThumbIcon();
        }
        public function deactiveThumbIcon():void{
            this._sizeSlider.isThumbIconActive = false;
            this._timeSlider.isThumbIconActive = false;
        }
        public function get isThumbIconActive():Boolean{
            if (((this._sizeSlider.isThumbIconActive) || (this._timeSlider.isThumbIconActive))){
                return (true);
            };
            return (false);
        }
        public function subDeltaByMouse(_arg1:Number):void{
            if (this._sizeSlider.isThumbIconActive){
                this._sizeSlider.subTimeDelta(1, true, this._sizeSlider.controllBtn);
            };
            if (this._timeSlider.isThumbIconActive){
                this._timeSlider.subTimeDelta(_arg1, true, this._timeSlider.controllBtn);
            };
        }
        public function addDeltaByMouse(_arg1:Number):void{
            if (this._sizeSlider.isThumbIconActive){
                this._sizeSlider.addTimeDelta(1, true, this._sizeSlider.controllBtn);
            };
            if (this._timeSlider.isThumbIconActive){
                this._timeSlider.addTimeDelta(_arg1, true, this._timeSlider.controllBtn);
            };
        }
        public function subTimeDeltaByKey(_arg1:Number, _arg2:Boolean):void{
            this._timeSlider.subTimeDelta(_arg1, _arg2, this._timeSlider.controllBtn, "key");
        }
        public function addTimeDeltaByKey(_arg1:Number, _arg2:Boolean):void{
            this._timeSlider.addTimeDelta(_arg1, _arg2, this._timeSlider.controllBtn, "key");
        }
        public function set showFace(_arg1:Boolean):void{
            var _local2:*;
            this.visible = _arg1;
            if (!_arg1){
                this.deactiveThumbIcon();
                this.commitInterfaceFunction();
            } else {
                this.loadStyle();
                _local2 = Cookies.getCookie("hideShortcutsTips");
                if (!_local2){
                    this._timeSlider.showShortcuts();
                };
            };
        }
        public function initRecordStatus():void{
        }
        public function commitInterfaceFunction():void{
            this.checkValueChanged();
            this._lastFontSize = this._fontSize;
            this._lastFontColor = this._fontColor;
            this._lastFilterColor = this._filterColor;
            this._lastTimeStamp = this._timeStamp;
        }
        public function cancleInterfaceFunction():void{
            var _local1:Object = {
                fontColor:this._lastFontColor,
                fontSize:this._lastFontSize,
                filterColor:this._lastFilterColor
            };
            this.setStyle(_local1);
            dispatchEvent(new CaptionEvent(CaptionEvent.SET_STYLE, _local1));
            this._timeSlider.currentValue = this._lastTimeStamp;
            dispatchEvent(new CaptionEvent(CaptionEvent.SET_TIME, {
                time:(this._lastTimeStamp * 1000),
                type:null
            }));
        }
        public function loadStyle():void{
            var _local2:String;
            var _local3:String;
            var _local4:String;
            var _local5:URLRequest;
            var _local1:GlobalVars = GlobalVars.instance;
            if (!_local1.isCaptionStyleLoaded){
                _local1.isCaptionStyleLoaded = true;
                JTracer.sendMessage("SetCaptionStyleFace -> loadCaptionStyle");
                if ((((((Tools.getUserInfo("ygcid") == null)) || ((Tools.getUserInfo("ycid") == null)))) || ((Tools.getUserInfo("userid") == "0")))){
                    JTracer.sendMessage("SetCaptionStyleFace -> loadCaptionStyle, curFileInfo is null");
                    return;
                };
                _local2 = Tools.getUserInfo("ygcid");
                _local3 = Tools.getUserInfo("ycid");
                _local4 = Tools.getUserInfo("userid");
                _local5 = new URLRequest(((((_local1.url_subtitle_style + "?userid=") + _local4) + "&t=") + new Date().time));
                this._styleLoader = new URLLoader();
                this._styleLoader.addEventListener(Event.COMPLETE, this.onStyleLoaded);
                this._styleLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onStyleIOError);
                this._styleLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onStyleSecurityError);
                this._styleLoader.load(_local5);
            };
        }
        public function loadTime(_arg1:Object):void{
            var _local3:String;
            var _local4:String;
            var _local5:String;
            var _local6:String;
            var _local7:URLRequest;
            var _local2:GlobalVars = GlobalVars.instance;
            if (!_local2.isCaptionTimeLoaded){
                _local2.isCaptionTimeLoaded = true;
                JTracer.sendMessage("SetCaptionStyleFace -> loadCaptionTime");
                if ((((((((((Tools.getUserInfo("ygcid") == null)) || ((Tools.getUserInfo("ycid") == null)))) || ((Tools.getUserInfo("userid") == "0")))) || (!(_arg1.scid)))) || ((_arg1.scid == "")))){
                    JTracer.sendMessage("SetCaptionStyleFace -> loadCaptionTime, curFileInfo is null");
                    return;
                };
                _local3 = Tools.getUserInfo("ygcid");
                _local4 = Tools.getUserInfo("ycid");
                _local5 = Tools.getUserInfo("userid");
                _local6 = _arg1.scid;
                _local7 = new URLRequest(((((((((((_local2.url_subtitle_time + "?gcid=") + _local3) + "&cid=") + _local4) + "&userid=") + _local5) + "&scid=") + _local6) + "&t=") + new Date().time));
                this._timeLoader = new URLLoader();
                this._timeLoader.addEventListener(Event.COMPLETE, this.onTimeDeltaLoaded);
                this._timeLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onTimeDeltaIOError);
                this._timeLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onTimeDeltaSecurityError);
                this._timeLoader.load(_local7);
            };
        }
        private function checkValueChanged():void{
            if (((((!((this._lastFontSize == this._fontSize))) || (!((this._lastFontColor == this._fontColor))))) || (!((this._lastFilterColor == this._filterColor))))){
                GlobalVars.instance.captionStyleChanged = true;
            };
            if (this._lastTimeStamp != this._timeStamp){
                GlobalVars.instance.captionTimeChanged = true;
            };
        }
        private function commitButtonClickHandler(_arg1:MouseEvent):void{
            this.commitInterfaceFunction();
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "caption"));
        }
        private function cancelLoadStyle():void{
            if (this._styleLoader){
                this._styleLoader.removeEventListener(Event.COMPLETE, this.onStyleLoaded);
                this._styleLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onStyleIOError);
                this._styleLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onStyleSecurityError);
                try {
                    this._styleLoader.close();
                    this._styleLoader = null;
                } catch(e:Error) {
                };
            };
        }
        private function onStyleLoaded(_arg1:Event):void{
            var _local4:String;
            var _local5:Array;
            var _local6:String;
            var _local7:Array;
            var _local8:Object;
            JTracer.sendMessage(("SetCaptionStyleFace -> onStyleLoaded, data:" + _arg1.target.data));
            var _local2:String = String(_arg1.target.data);
            var _local3:Object = ((JSON.deserialize(_local2)) || ({}));
            if (String(_local3.ret) == "0"){
                JTracer.sendMessage("SetCaptionStyleFace -> onStyleLoaded, get style complete, ret:0");
                GlobalVars.instance.isCaptionStyleLoaded = true;
                _local4 = ((_local3.preference.font_color) ? _local3.preference.font_color : "255,255,255");
                _local5 = _local4.split(",");
                this._fontSize = ((_local3.preference.font_size) ? uint(_local3.preference.font_size) : 25);
                this._fontColor = this.toDec(uint(_local5[0]), uint(_local5[1]), uint(_local5[2]));
                _local6 = ((_local3.preference.background_color) ? _local3.preference.background_color : "0,0,0");
                _local7 = _local6.split(",");
                this._filterColor = this.toDec(uint(_local7[0]), uint(_local7[1]), uint(_local7[2]));
                this._lastFontSize = this._fontSize;
                this._lastFontColor = this._fontColor;
                this._lastFilterColor = this._filterColor;
                _local8 = {
                    fontColor:this._fontColor,
                    fontSize:this._fontSize,
                    filterColor:this._filterColor
                };
                this.setStyle(_local8);
                dispatchEvent(new CaptionEvent(CaptionEvent.SET_STYLE, _local8));
            } else {
                JTracer.sendMessage(("SetCaptionStyleFace -> onStyleLoaded, get style complete, ret:" + _local3.ret));
                GlobalVars.instance.isCaptionStyleLoaded = false;
            };
        }
        private function onStyleIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("SetCaptionStyleFace -> onStyleIOError, get style IOError");
            GlobalVars.instance.isCaptionStyleLoaded = false;
        }
        private function onStyleSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("SetCaptionStyleFace -> onStyleSecurityError, get style SecurityError");
            GlobalVars.instance.isCaptionStyleLoaded = false;
        }
        private function setStyle(_arg1:Object):void{
            var _local2:*;
            var _local3:CaptionStyleBtn;
            this._fontSize = _arg1.fontSize;
            this._fontColor = _arg1.fontColor;
            this._filterColor = _arg1.filterColor;
            this._sizeSlider.currentValue = this._fontSize;
            for (_local2 in this._btnArray) {
                _local3 = (this._btnArray[_local2] as CaptionStyleBtn);
                if ((((_local3.fontColor == this._fontColor)) && ((_local3.filterColor == this._filterColor)))){
                    _local3.selected = true;
                    _local3.gotoAndStop(1);
                } else {
                    _local3.selected = false;
                    _local3.gotoAndStop(3);
                };
            };
        }
        private function onTimeDeltaLoaded(_arg1:Event):void{
            JTracer.sendMessage(("SetCaptionStyleFace -> onTimeDeltaLoaded, data:" + _arg1.target.data));
            var _local2:String = String(_arg1.target.data);
            var _local3:Object = ((JSON.deserialize(_local2)) || ({}));
            if (String(_local3.ret) == "0"){
                JTracer.sendMessage("SetCaptionStyleFace -> onTimeDeltaLoaded, load time delta complete, ret:0");
                this._timeStamp = (_local3.time_delta / 1000);
                this._lastTimeStamp = this._timeStamp;
                this._timeSlider.currentValue = (_local3.time_delta / 1000);
                dispatchEvent(new CaptionEvent(CaptionEvent.SET_TIME, {
                    time:_local3.time_delta,
                    type:null
                }));
            } else {
                JTracer.sendMessage(("SetCaptionStyleFace -> onTimeDeltaLoaded, load time delta complete, ret:" + _local3.ret));
                GlobalVars.instance.isCaptionTimeLoaded = false;
            };
        }
        private function onTimeDeltaIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("SetCaptionStyleFace -> onTimeDeltaIOError, load time delta IOError");
            GlobalVars.instance.isCaptionTimeLoaded = false;
        }
        private function onTimeDeltaSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("SetCaptionStyleFace -> onTimeDeltaSecurityError, load time delta SecurityError");
            GlobalVars.instance.isCaptionTimeLoaded = false;
        }
        private function cancelLoadTime():void{
            if (this._timeLoader){
                this._timeLoader.removeEventListener(Event.COMPLETE, this.onTimeDeltaLoaded);
                this._timeLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.onTimeDeltaIOError);
                this._timeLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onTimeDeltaSecurityError);
                try {
                    this._timeLoader.close();
                    this._timeLoader = null;
                } catch(e:Error) {
                };
            };
        }
        private function toDec(_arg1:uint, _arg2:uint, _arg3:uint, _arg4:uint=0xFF):uint{
            var _local5:uint = (_arg1 << 16);
            var _local6:uint = (_arg2 << 8);
            return (((_local5 | _local6) | _arg3));
        }
        private function changeSizeHandler(_arg1:Event):void{
            this._fontSize = this._sizeSlider.currentValue;
            this.changeFontSize();
        }
        private function changeTimeHandler(_arg1:Event):void{
            this._timeStamp = this._timeSlider.currentValue;
            this._controllType = this._timeSlider.controllType;
            this.changeTimeStamp();
        }
        private function changeFontSize():void{
            this.cancelLoadStyle();
            JTracer.sendMessage(((((("SetCaptionStyleFace -> change caption style, fontSize:" + this._fontSize) + ", fontColor:") + this._fontColor) + ", filterColor:") + this._filterColor));
            dispatchEvent(new CaptionEvent(CaptionEvent.SET_STYLE, {
                fontColor:this._fontColor,
                fontSize:this._fontSize,
                filterColor:this._filterColor
            }));
        }
        private function changeTimeStamp():void{
            this.cancelLoadTime();
            JTracer.sendMessage(("SetCaptionStyleFace -> change caption time, time:" + (this._timeStamp * 1000)));
            dispatchEvent(new CaptionEvent(CaptionEvent.SET_TIME, {
                time:(this._timeStamp * 1000),
                type:this._controllType
            }));
            this._controllType = null;
            this._timeSlider.controllType = null;
        }
        private function drawToolBtn(_arg1:String, _arg2:uint, _arg3:uint, _arg4:Boolean, _arg5:Function):MovieClip{
            var lable:* = _arg1;
            var filterColor:* = _arg2;
            var fontColor:* = _arg3;
            var selected:* = _arg4;
            var action:* = _arg5;
            var btn:* = new CaptionStyleBtn();
            btn.buttonMode = true;
            btn.mouseChildren = false;
            btn.selected = selected;
            btn.fontColor = fontColor;
            btn.filterColor = filterColor;
            btn.color_txt.text = lable;
            btn.gotoAndStop(((selected) ? 1 : 3));
            btn.addEventListener(MouseEvent.MOUSE_OVER, this.onBtnOver);
            btn.addEventListener(MouseEvent.MOUSE_OUT, this.onBtnOut);
            btn.addEventListener(MouseEvent.CLICK, function (_arg1:MouseEvent):void{
                action(_arg1);
            });
            addChild(btn);
            return (btn);
        }
        private function onBtnOver(_arg1:MouseEvent):void{
            var _local2:CaptionStyleBtn = (_arg1.currentTarget as CaptionStyleBtn);
            _local2.gotoAndStop(((_local2.selected) ? 2 : 4));
        }
        private function onBtnOut(_arg1:MouseEvent):void{
            var _local2:CaptionStyleBtn = (_arg1.currentTarget as CaptionStyleBtn);
            _local2.gotoAndStop(((_local2.selected) ? 1 : 3));
        }
        private function actionFunction(_arg1:MouseEvent):void{
            var _local2:CaptionStyleBtn;
            var _local3:*;
            var _local4:CaptionStyleBtn;
            for (_local3 in this._btnArray) {
                _local2 = (this._btnArray[_local3] as CaptionStyleBtn);
                _local2.selected = false;
                _local2.gotoAndStop(3);
            };
            _local4 = (_arg1.currentTarget as CaptionStyleBtn);
            _local4.selected = true;
            _local4.gotoAndStop(2);
            this._fontColor = _local4.fontColor;
            this._filterColor = _local4.filterColor;
            this.changeFontSize();
        }
        private function onDefaultClick(_arg1:TextEvent):void{
            var _local2:CaptionStyleBtn;
            var _local3:*;
            var _local4:CaptionStyleBtn;
            if (_arg1.text == "default"){
                this._fontSize = 25;
                this._fontColor = 0xFFFFFF;
                this._filterColor = 0;
                for (_local3 in this._btnArray) {
                    _local2 = (this._btnArray[_local3] as CaptionStyleBtn);
                    _local2.selected = false;
                    _local2.gotoAndStop(3);
                };
                _local4 = (this._btnArray[3] as CaptionStyleBtn);
                _local4.selected = true;
                _local4.gotoAndStop(2);
                this._sizeSlider.currentValue = 25;
                this._timeSlider.currentValue = 0;
                this.changeFontSize();
            };
        }

    }
}//package ctr.subtitle 
﻿package ctr.subtitle {
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    import com.common.*;
    import eve.*;

    public class FileUploader extends EventDispatcher {

        private var file:FileReference;
        private var timer:Timer;
        private var item:CaptionItem;

        public function FileUploader(_arg1:Number){
            this.file = new FileReference();
            this.file.addEventListener(Event.SELECT, this.onSelectFile);
            this.file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.onUploadComplete);
            this.file.addEventListener(ProgressEvent.PROGRESS, this.onUploadProgress);
            this.file.addEventListener(IOErrorEvent.IO_ERROR, this.onUploadIOError);
            this.file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onUploadSecurityError);
            this.file.addEventListener(Event.COMPLETE, this.onLoadComplete);
            this.timer = new Timer((_arg1 * 1000), 1);
            this.timer.addEventListener(TimerEvent.TIMER, this.onTimeout);
        }
        public function browse(_arg1:Array):void{
            this.file.browse(_arg1);
        }
        public function upload(_arg1:String):void{
            this.file.upload(new URLRequest(_arg1));
            this.timer.reset();
            this.timer.start();
        }
        public function load():void{
            this.file.load();
        }
        public function set uploadItem(_arg1:CaptionItem):void{
            this.item = _arg1;
        }
        private function onSelectFile(_arg1:Event):void{
            dispatchEvent(new CaptionEvent(CaptionEvent.SELECT_FILE, {
                uploadItem:this.item,
                fileName:this.file.name,
                fileSize:this.file.size
            }));
        }
        private function onUploadComplete(_arg1:DataEvent):void{
            this.timer.stop();
            dispatchEvent(new CaptionEvent(CaptionEvent.UPLOAD_COMPLETE, {
                uploadItem:this.item,
                fileName:this.file.name,
                data:_arg1.data
            }));
        }
        private function onUploadProgress(_arg1:ProgressEvent):void{
        }
        private function onUploadIOError(_arg1:IOErrorEvent):void{
            this.timer.stop();
            this.file.cancel();
            dispatchEvent(new CaptionEvent(CaptionEvent.UPLOAD_ERROR, {uploadItem:this.item}));
        }
        private function onUploadSecurityError(_arg1:SecurityErrorEvent):void{
            this.timer.stop();
            this.file.cancel();
            dispatchEvent(new CaptionEvent(CaptionEvent.UPLOAD_ERROR, {uploadItem:this.item}));
        }
        private function onLoadComplete(_arg1:Event):void{
            if (Tools.getUserInfo("userid") != "0"){
                dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_COMPLETE, {
                    uploadItem:this.item,
                    fileName:this.file.name,
                    data:this.file.data
                }));
            };
        }
        private function onTimeout(_arg1:TimerEvent):void{
            this.timer.stop();
            this.file.cancel();
            dispatchEvent(new CaptionEvent(CaptionEvent.UPLOAD_ERROR, {uploadItem:this.item}));
        }

    }
}//package ctr.subtitle 
﻿package ctr.subtitle {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.common.*;
    import eve.*;
    import com.serialization.json.*;
    import flash.text.*;

    public class SetCaptionFace extends Sprite {

        private var _fileFilter:FileFilter;
        private var _limitSize:Number;
        private var _timeOut:Number;
        private var _uploadURL:String;
        private var _listMc:Sprite;
        private var _listArray:Array;
        private var _itemArray:Array;
        private var _fileName:String;
        private var _timer:Timer;
        private var _overTF:TextFormat;
        private var _outTF:TextFormat;
        private var _noCaptionTips:NoCaptionTips;
        private var _uploadItem:CaptionItem;
        private var _uploadBtn:UploadCaptionBtn;
        private var _autoloadScid:String;
        private var _lastScid:String;

        public function SetCaptionFace(){
            this._listArray = [];
            this._itemArray = [];
            super();
            this._overTF = new TextFormat();
            this._overTF.color = 0x646464;
            this._outTF = new TextFormat();
            this._outTF.color = 0xAAAAAA;
            this._listMc = new Sprite();
            this._listMc.x = 3;
            this._listMc.y = 0;
            addChild(this._listMc);
            var _local1:StyleSheet = new StyleSheet();
            _local1.setStyle("a", {
                color:"#097BB3",
                fontSize:"12",
                textAlign:"center",
                fontFamily:"宋体",
                textDecoration:"underline"
            });
            var _local2:TextField = new TextField();
            _local2.x = 280;
            _local2.y = 153;
            _local2.selectable = false;
            _local2.styleSheet = _local1;
            _local2.text = "<a href='event:search'>去射手网搜索字幕</a>";
            _local2.width = (_local2.textWidth + 4);
            _local2.addEventListener(TextEvent.LINK, this.onSearchClick);
            addChild(_local2);
            this._uploadBtn = new UploadCaptionBtn();
            this._uploadBtn.x = 162;
            this._uploadBtn.y = 141;
            addChild(this._uploadBtn);
            this.showEmptyListTips();
        }
        public function clear():void{
            this.removeCaptions(0);
            this.showEmptyListTips();
        }
        public function setOuterParam(_arg1:Object):void{
            if (((((((((!(_arg1)) || (!(_arg1.description)))) || (!(_arg1.extension)))) || (!(_arg1.uploadURL)))) || (!(_arg1.limitSize)))){
                return;
            };
            this._uploadURL = _arg1.uploadURL;
            this._limitSize = _arg1.limitSize;
            this._timeOut = _arg1.timeOut;
            this._fileFilter = new FileFilter(_arg1.description, _arg1.extension);
            this._uploadBtn.addEventListener(MouseEvent.CLICK, this.onUploadClick);
        }
        public function set showFace(_arg1:Boolean):void{
            this.visible = _arg1;
            if (!_arg1){
                this.commitInterfaceFunction();
            } else {
                this.loadCaptionList();
            };
        }
        public function setPosition():void{
            this.x = int(((stage.stageWidth - 460) / 2));
            this.y = int((((stage.stageHeight - 228) - 33) / 2));
        }
        public function get listLength():uint{
            return (((this._listArray.length) || (0)));
        }
        public function showCompStatus():void{
            var _local1:*;
            var _local2:CaptionItem;
            for (_local1 in this._itemArray) {
                _local2 = (this._itemArray[_local1] as CaptionItem);
                if (_local2.selected){
                    this._lastScid = _local2.scid;
                    _local2.status_mc.visible = true;
                    _local2.status_mc.gotoAndStop(2);
                    _local2.status_txt.text = "取消";
                    Tools.stat(("b=tjzm&e=0&gcid=" + Tools.getUserInfo("ygcid")));
                } else {
                    _local2.status_mc.visible = false;
                    _local2.status_mc.gotoAndStop(1);
                    _local2.status_txt.text = "";
                };
            };
        }
        public function showErrorStatus():void{
            var _local1:*;
            var _local2:CaptionItem;
            for (_local1 in this._itemArray) {
                _local2 = (this._itemArray[_local1] as CaptionItem);
                if (_local2.selected){
                    this._lastScid = null;
                    _local2.selected = false;
                    _local2.status_mc.visible = true;
                    _local2.status_mc.gotoAndStop(3);
                    _local2.status_txt.text = "重试";
                    Tools.stat(("b=tjzm&e=-1&gcid=" + Tools.getUserInfo("ygcid")));
                } else {
                    _local2.status_mc.visible = false;
                    _local2.status_mc.gotoAndStop(1);
                    _local2.status_txt.text = "";
                };
            };
        }
        private function removeCaptions(_arg1:int):void{
            var _local2:CaptionItem;
            while (this._itemArray.length > _arg1) {
                _local2 = (this._itemArray.pop() as CaptionItem);
                this.removeCaption(_local2);
            };
        }
        private function removeCaption(_arg1:CaptionItem):void{
            if (((_arg1) && (this._listMc.contains(_arg1)))){
                _arg1.removeEventListener(MouseEvent.CLICK, this.onItemClick);
                _arg1.removeEventListener(MouseEvent.MOUSE_OVER, this.onItemOver);
                _arg1.removeEventListener(MouseEvent.MOUSE_OUT, this.onItemOut);
                _arg1.removeEventListener(MouseEvent.MOUSE_MOVE, this.onItemMove);
                this._listMc.removeChild(_arg1);
                _arg1 = null;
            };
        }
        public function initRecordStatus():void{
        }
        public function commitInterfaceFunction():void{
        }
        public function cancleInterfaceFunction():void{
        }
        private function getCaption(_arg1:String):CaptionItem{
            var _local2:*;
            for (_local2 in this._itemArray) {
                if (this._itemArray[_local2].scid == _arg1){
                    return (this._itemArray[_local2]);
                };
            };
            return (null);
        }
        private function getSameContentCount(_arg1:ByteArray):int{
            var _local3:*;
            var _local2:int;
            for (_local3 in this._itemArray) {
                if (((this._itemArray[_local3].data) && ((this._itemArray[_local3].data.toString() == _arg1.toString())))){
                    _local2++;
                };
            };
            JTracer.sendMessage(("SetCaptionFace -> getSameContentCount, count:" + _local2));
            return (_local2);
        }
        private function getCaptionByData(_arg1:ByteArray):CaptionItem{
            var _local3:*;
            var _local2:int = this.getSameContentCount(_arg1);
            if (_local2 <= 1){
                return (null);
            };
            for (_local3 in this._itemArray) {
                if (((this._itemArray[_local3].data) && ((this._itemArray[_local3].data.toString() == _arg1.toString())))){
                    return (this._itemArray[_local3]);
                };
            };
            return (null);
        }
        private function createCaption(_arg1:Object):CaptionItem{
            var _local2:CaptionItem = new CaptionItem();
            this.setCaptionProp(_local2, _arg1);
            this._listMc.addChild(_local2);
            this._itemArray.push(_local2);
            return (_local2);
        }
        private function setCaptionProp(_arg1:CaptionItem, _arg2:Object):void{
            _arg1.row = _arg2.row;
            _arg1.row_txt.text = _arg2.rname;
            _arg1.name_txt.text = decodeURI(_arg2.sname);
            _arg1.name_txt.width = (_arg1.name_txt.textWidth + 4);
            _arg1.surl = _arg2.surl;
            _arg1.scid = _arg2.scid;
            _arg1.fullname = _arg2.fname;
            _arg1.manual = _arg2.manual;
            _arg1.selected = _arg2.selected;
            _arg1.buttonMode = _arg2.enable;
            _arg1.y = (_arg2.row * 30);
            _arg1.mouseChildren = false;
            _arg1.bg_mc.visible = false;
            _arg1.status_mc.visible = false;
            _arg1.status_mc.gotoAndStop(1);
            _arg1.status_txt.text = "";
            _arg1.status_txt.x = ((_arg1.name_txt.x + _arg1.name_txt.textWidth) + 20);
            _arg1.addEventListener(MouseEvent.CLICK, this.onItemClick);
            _arg1.addEventListener(MouseEvent.MOUSE_OVER, this.onItemOver);
            _arg1.addEventListener(MouseEvent.MOUSE_OUT, this.onItemOut);
            _arg1.addEventListener(MouseEvent.MOUSE_MOVE, this.onItemMove);
        }
        private function showEmptyListTips():void{
            if (!this._noCaptionTips){
                this._noCaptionTips = new NoCaptionTips();
                this._noCaptionTips.x = 15;
                this._noCaptionTips.y = 40;
                addChild(this._noCaptionTips);
            };
        }
        private function hideNoCaptionTips():void{
            if (this._noCaptionTips){
                removeChild(this._noCaptionTips);
                this._noCaptionTips = null;
            };
        }
        public function loadLastload():void{
            JTracer.sendMessage("SetCaptionFace -> loadLastload, get lastload caption start");
            this._autoloadScid = "";
            if ((((((Tools.getUserInfo("ygcid") == null)) || ((Tools.getUserInfo("ycid") == null)))) || ((Tools.getUserInfo("userid") == null)))){
                JTracer.sendMessage("SetCaptionFace -> loadLastload, curFileInfo is null");
                return;
            };
            var _local1:String = Tools.getUserInfo("ygcid");
            var _local2:String = Tools.getUserInfo("ycid");
            var _local3:String = Tools.getUserInfo("userid");
            var _local4:URLRequest = new URLRequest(((((((((GlobalVars.instance.url_subtitle_lastload + "?gcid=") + _local1) + "&cid=") + _local2) + "&userid=") + _local3) + "&t=") + new Date().time));
            var _local5:URLLoader = new URLLoader();
            _local5.addEventListener(Event.COMPLETE, this.onLastloadLoaded);
            _local5.addEventListener(IOErrorEvent.IO_ERROR, this.onLastloadIOError);
            _local5.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onLastloadSecurityError);
            _local5.load(_local4);
        }
        private function onLastloadLoaded(_arg1:Event):void{
            var _local4:String;
            JTracer.sendMessage(("SetCaptionFace -> onLastloadLoaded, data:" + _arg1.target.data));
            var _local2:String = String(_arg1.target.data);
            var _local3:Object = ((JSON.deserialize(_local2)) || ({}));
            if (String(_local3.ret) == "0"){
                JTracer.sendMessage("SetCaptionFace -> onLastloadLoaded, get lastload caption complete, ret:0");
                this._autoloadScid = _local3.subtitle.scid;
                _local4 = _local3.subtitle.sname;
                if (((this._autoloadScid) && (!((this._autoloadScid == ""))))){
                    JTracer.sendMessage(("SetCaptionFace -> onLastloadLoaded, has lastload scid, scid:" + this._autoloadScid));
                    GlobalVars.instance.isHasAutoloadCaption = true;
                    dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_STYLE));
                    GlobalVars.instance.isCaptionTimeLoaded = false;
                    dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_TIME, {scid:this._autoloadScid}));
                    dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_CONTENT, {
                        surl:null,
                        scid:this._autoloadScid,
                        sname:_local4,
                        sdata:null,
                        isSaveAutoload:false,
                        gradeTime:180
                    }));
                } else {
                    JTracer.sendMessage("SetCaptionFace -> onLastloadLoaded, don't has lastload scid");
                    if (!GlobalVars.instance.hasSubtitle){
                        this.loadAutoload();
                    };
                };
            } else {
                JTracer.sendMessage(("SetCaptionFace -> onLastloadLoaded, get lastload caption complete, ret:" + _local3.ret));
                if (!GlobalVars.instance.hasSubtitle){
                    this.loadAutoload();
                };
            };
        }
        private function onLastloadIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("SetCaptionFace -> onLastloadIOError, get lastload caption IOError");
        }
        private function onLastloadSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("SetCaptionFace -> onLastloadSecurityError, get lastload caption SecurityError");
        }
        public function loadAutoload():void{
            JTracer.sendMessage("SetCaptionFace -> loadAutoload, get autoload caption start");
            this._autoloadScid = "";
            if ((((((Tools.getUserInfo("ygcid") == null)) || ((Tools.getUserInfo("ycid") == null)))) || ((Tools.getUserInfo("userid") == null)))){
                JTracer.sendMessage("SetCaptionFace -> loadAutoload, curFileInfo is null");
                return;
            };
            var _local1:String = Tools.getUserInfo("ygcid");
            var _local2:String = Tools.getUserInfo("ycid");
            var _local3:String = Tools.getUserInfo("userid");
            var _local4:URLRequest = new URLRequest(((((((((GlobalVars.instance.url_subtitle_autoload + "?gcid=") + _local1) + "&cid=") + _local2) + "&userid=") + _local3) + "&t=") + new Date().time));
            var _local5:URLLoader = new URLLoader();
            _local5.addEventListener(Event.COMPLETE, this.onAutoloadLoaded);
            _local5.addEventListener(IOErrorEvent.IO_ERROR, this.onAutoloadIOError);
            _local5.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onAutoloadSecurityError);
            _local5.load(_local4);
        }
        private function onAutoloadLoaded(_arg1:Event):void{
            var _local4:String;
            var _local5:uint;
            var _local6:uint;
            JTracer.sendMessage(("SetCaptionFace -> onAutoloadLoaded, data:" + _arg1.target.data));
            var _local2:String = String(_arg1.target.data);
            var _local3:Object = ((JSON.deserialize(_local2)) || ({}));
            if (String(_local3.ret) == "0"){
                JTracer.sendMessage("SetCaptionFace -> onAutoloadLoaded, get autoload caption complete, ret:0");
                this._autoloadScid = _local3.subtitle.scid;
                _local4 = _local3.subtitle.sname;
                if (((this._autoloadScid) && (!((this._autoloadScid == ""))))){
                    _local5 = _local3.subtitle.reliable;
                    if (_local5 == 1){
                        _local6 = 180;
                    } else {
                        _local6 = 600;
                    };
                    JTracer.sendMessage(((("SetCaptionFace -> onAutoloadLoaded, has autoload scid, scid:" + this._autoloadScid) + ", reliable:") + _local5));
                    GlobalVars.instance.isHasAutoloadCaption = true;
                    dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_STYLE));
                    GlobalVars.instance.isCaptionTimeLoaded = false;
                    dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_TIME, {scid:this._autoloadScid}));
                    dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_CONTENT, {
                        surl:null,
                        scid:this._autoloadScid,
                        sname:_local4,
                        sdata:null,
                        isSaveAutoload:false,
                        gradeTime:_local6
                    }));
                } else {
                    JTracer.sendMessage("SetCaptionFace -> onAutoloadLoaded, don't has autoload scid");
                };
            } else {
                JTracer.sendMessage(("SetCaptionFace -> onAutoloadLoaded, get autoload caption complete, ret:" + _local3.ret));
            };
        }
        private function onAutoloadIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("SetCaptionFace -> onAutoloadIOError, get autoload caption IOError");
        }
        private function onAutoloadSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("SetCaptionFace -> onAutoloadSecurityError, get autoload caption SecurityError");
        }
        public function loadCaptionList():void{
            var _local2:String;
            var _local3:String;
            var _local4:String;
            var _local5:URLRequest;
            var _local6:URLLoader;
            var _local1:GlobalVars = GlobalVars.instance;
            if (!_local1.isCaptionListLoaded){
                _local1.isCaptionListLoaded = true;
                JTracer.sendMessage("SetCaptionFace -> loadCaptionList, load caption list start");
                if ((((Tools.getUserInfo("ygcid") == null)) || ((Tools.getUserInfo("ycid") == null)))){
                    JTracer.sendMessage("SetCaptionFace -> loadCaptionList, curFileInfo is null");
                    return;
                };
                _local2 = Tools.getUserInfo("ygcid");
                _local3 = Tools.getUserInfo("ycid");
                _local4 = Tools.getUserInfo("userid");
                _local5 = new URLRequest(((((((((_local1.url_subtitle_list + "?gcid=") + _local2) + "&cid=") + _local3) + "&userid=") + _local4) + "&t=") + new Date().time));
                _local6 = new URLLoader();
                _local6.addEventListener(Event.COMPLETE, this.onListLoaded);
                _local6.addEventListener(IOErrorEvent.IO_ERROR, this.onListIOError);
                _local6.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onListSecurityError);
                _local6.load(_local5);
            };
        }
        private function onListLoaded(_arg1:Event):void{
            var _local4:Array;
            var _local5:CaptionItem;
            JTracer.sendMessage(("SetCaptionFace -> onListLoaded, data:" + _arg1.target.data));
            var _local2:String = String(_arg1.target.data);
            var _local3:Object = ((JSON.deserialize(_local2)) || ({}));
            if (String(_local3.ret) == "0"){
                JTracer.sendMessage("SetCaptionFace -> onListLoaded, load caption list complete, ret:0");
                GlobalVars.instance.isCaptionListLoaded = true;
                _local4 = _local3.sublist;
                this.setCaptionList(_local4);
                JTracer.sendMessage("SetCaptionFace -> onListLoaded, apply autoload caption");
                _local5 = this.getCaption(this._autoloadScid);
                if (_local5){
                    JTracer.sendMessage("SetCaptionFace -> onListLoaded, has autoload caption item");
                    _local5.selected = true;
                    this.showCompStatus();
                } else {
                    JTracer.sendMessage("SetCaptionFace -> onListLoaded, don't has autoload caption item");
                };
            } else {
                JTracer.sendMessage(("SetCaptionFace -> onListLoaded, load caption list complete, ret:" + _local3.ret));
                GlobalVars.instance.isCaptionListLoaded = false;
                this.setCaptionList([]);
            };
        }
        private function onListIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("SetCaptionFace -> onListIOError, load caption IOError");
            GlobalVars.instance.isCaptionListLoaded = false;
            this.setCaptionList([]);
        }
        private function onListSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("SetCaptionFace -> onListSecurityError, load caption SecurityError");
            GlobalVars.instance.isCaptionListLoaded = false;
            this.setCaptionList([]);
        }
        private function setCaptionList(_arg1:Array):void{
            var _local2:*;
            var _local3:String;
            var _local4:String;
            var _local5:String;
            var _local6:String;
            var _local7:String;
            var _local8:Object;
            this.removeCaptions(0);
            this.hideNoCaptionTips();
            this._listArray = ((_arg1) || ([]));
            this._itemArray = [];
            if (((!(this._listArray)) || ((this._listArray.length == 0)))){
                this.showEmptyListTips();
                return;
            };
            while (this._listArray.length > 4) {
                this._listArray.pop();
            };
            for (_local2 in this._listArray) {
                _local3 = (("在线字幕" + (_local2 + 1)) + "：");
                _local4 = this.sliceSname(this._listArray[_local2].sname);
                _local5 = this._listArray[_local2].sname;
                _local6 = this._listArray[_local2].surl;
                _local7 = this._listArray[_local2].scid;
                _local8 = {
                    rname:_local3,
                    sname:_local4,
                    fname:_local5,
                    surl:_local6,
                    scid:_local7,
                    manual:false,
                    selected:false,
                    enable:true,
                    row:_local2
                };
                this.createCaption(_local8);
            };
        }
        private function onSearchClick(_arg1:TextEvent):void{
            switch (_arg1.text){
                case "search":
                    if (stage.displayState == StageDisplayState.FULL_SCREEN){
                        stage.displayState = StageDisplayState.NORMAL;
                    };
                    Tools.windowOpen(GlobalVars.instance.url_search_subtitle);
                    break;
            };
        }
        private function onItemClick(_arg1:MouseEvent):void{
            var _local2:CaptionItem = (_arg1.currentTarget as CaptionItem);
            var _local3 = (_local2.status_txt.text == "重试");
            if (!_local2.buttonMode){
                return;
            };
            if (((this._lastScid) && (!((this._lastScid == _local2.scid))))){
                JTracer.sendMessage(("SetCaptionFace -> onItemClick, subtitle grade, isRetry:" + _local3));
                this.gradeCaption();
            };
            this._lastScid = null;
            this.clearStatus();
            this.loadContent(_local2, _local3);
        }
        private function gradeCaption():void{
            var _local1:String = Tools.getUserInfo("ygcid");
            var _local2:String = Tools.getUserInfo("ycid");
            var _local3:String = this._lastScid;
            if (((((!(_local1)) || (!(_local2)))) || (!(_local3)))){
                JTracer.sendMessage("SetCaptionFace -> subtitle grade, curFileInfo is null");
                return;
            };
            var _local4:URLVariables = new URLVariables();
            _local4.a = "";
            var _local5:URLRequest = new URLRequest((((((((GlobalVars.instance.url_subtitle_grade + "?gcid=") + _local1) + "&cid=") + _local2) + "&scid=") + _local3) + "&type=1"));
            _local5.method = URLRequestMethod.POST;
            _local5.data = _local4;
            JTracer.sendMessage(("SetCaptionFace -> subtitle grade, url:" + _local5.url));
            sendToURL(_local5);
        }
        private function onItemOver(_arg1:MouseEvent):void{
            var _local2:CaptionItem = (_arg1.currentTarget as CaptionItem);
            _local2.bg_mc.visible = true;
            _local2.name_txt.setTextFormat(this._overTF);
            Tools.showToolTip(decodeURI(_local2.fullname));
            Tools.moveToolTip();
        }
        private function onItemOut(_arg1:MouseEvent):void{
            var _local2:CaptionItem = (_arg1.currentTarget as CaptionItem);
            _local2.bg_mc.visible = false;
            _local2.name_txt.setTextFormat(this._outTF);
            Tools.hideToolTip();
        }
        private function onItemMove(_arg1:MouseEvent):void{
            Tools.moveToolTip();
        }
        private function clearStatus():void{
            var _local1:*;
            var _local2:CaptionItem;
            for (_local1 in this._itemArray) {
                _local2 = (this._itemArray[_local1] as CaptionItem);
                _local2.status_mc.visible = false;
                _local2.status_txt.text = "";
            };
        }
        private function loadContent(_arg1:CaptionItem, _arg2:Boolean):void{
            if (_arg1.selected){
                _arg1.selected = false;
                _arg1.status_mc.visible = false;
                _arg1.status_mc.gotoAndStop(1);
                _arg1.status_txt.text = "";
                dispatchEvent(new CaptionEvent(CaptionEvent.HIDE_CAPTION, {
                    surl:_arg1.surl,
                    scid:_arg1.scid,
                    sdata:_arg1.data
                }));
                Tools.stat(("b=qxzm&e=0&gcid=" + Tools.getUserInfo("ygcid")));
            } else {
                this.deselect();
                _arg1.selected = true;
                _arg1.status_mc.visible = true;
                _arg1.status_mc.gotoAndStop(1);
                _arg1.status_txt.text = "加载中...";
                dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_STYLE));
                GlobalVars.instance.isCaptionTimeLoaded = false;
                dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_TIME, {scid:_arg1.scid}));
                dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_CONTENT, {
                    surl:_arg1.surl,
                    scid:_arg1.scid,
                    sname:_arg1.fullname,
                    sdata:_arg1.data,
                    isSaveAutoload:true,
                    isRetry:_arg2,
                    gradeTime:180
                }));
            };
        }
        private function deselect():void{
            var _local1:*;
            var _local2:CaptionItem;
            for (_local1 in this._itemArray) {
                _local2 = (this._itemArray[_local1] as CaptionItem);
                _local2.selected = false;
            };
        }
        private function onUploadClick(_arg1:MouseEvent):void{
            if (stage.displayState == StageDisplayState.FULL_SCREEN){
                stage.displayState = StageDisplayState.NORMAL;
            };
            var _local2:FileUploader = new FileUploader(this._timeOut);
            _local2.addEventListener(CaptionEvent.SELECT_FILE, this.selectFile);
            _local2.addEventListener(CaptionEvent.UPLOAD_COMPLETE, this.uploadComplete);
            _local2.addEventListener(CaptionEvent.UPLOAD_ERROR, this.uploadError);
            _local2.addEventListener(CaptionEvent.LOAD_COMPLETE, this.loadComplete);
            _local2.browse([this._fileFilter]);
        }
        private function selectFile(_arg1:CaptionEvent):void{
            var _local5:*;
            var _local6:CaptionItem;
            var _local7:String;
            var _local8:Object;
            var _local9:CaptionItem;
            var _local10:Date;
            var _local11:String;
            var _local12:String;
            var _local2:FileUploader = (_arg1.currentTarget as FileUploader);
            var _local3:String = _arg1.info.fileName;
            var _local4:Number = _arg1.info.fileSize;
            this.hideNoCaptionTips();
            for (_local5 in this._itemArray) {
                _local6 = (this._itemArray[_local5] as CaptionItem);
                if (_local6.selected){
                    dispatchEvent(new CaptionEvent(CaptionEvent.HIDE_CAPTION, {
                        surl:_local6.surl,
                        scid:_local6.scid,
                        sdata:_local6.data
                    }));
                    Tools.stat(("b=qxzm&e=0&gcid=" + Tools.getUserInfo("ygcid")));
                    break;
                };
            };
            this.removeCaptions(3);
            _local7 = this.sliceSname(_local3);
            _local8 = {
                rname:"上传字幕：",
                sname:_local7,
                fname:_local3,
                surl:"",
                scid:"",
                manual:true,
                selected:true,
                enable:false,
                row:this._itemArray.length,
                data:null
            };
            _local9 = this.createCaption(_local8);
            _local2.uploadItem = _local9;
            if (_local4 > this._limitSize){
                this.uploadError(_arg1);
                return;
            };
            if (Tools.getUserInfo("userid") != "0"){
                _local10 = new Date();
                _local11 = this.formatUrl(this._uploadURL);
                _local12 = (((((this._uploadURL + _local11) + "sname=") + encodeURIComponent(_local3)) + "&t=") + _local10.getTime());
                _local2.upload(_local12);
            } else {
                _local2.load();
            };
            this.showUploadStatus(_local9, "正在上传...");
        }
        private function formatUrl(_arg1:String):String{
            var _local2 = "";
            if (_arg1.indexOf("?") != -1){
                _local2 = "&";
            } else {
                _local2 = "?";
            };
            return (_local2);
        }
        private function uploadComplete(_arg1:CaptionEvent):void{
            var _local6:String;
            var _local7:String;
            var _local8:String;
            var _local9:String;
            var _local10:String;
            var _local11:CaptionItem;
            var _local12:Object;
            this.deselect();
            var _local2:String = ((_arg1.info.data) ? String(_arg1.info.data) : "");
            var _local3:CaptionItem = (_arg1.info.uploadItem as CaptionItem);
            var _local4:String = _arg1.info.fileName;
            JTracer.sendMessage(("上传字幕后的返回值:" + _local2));
            if (((!(_local2)) || ((_local2 == "")))){
                this.uploadError(_arg1);
                return;
            };
            var _local5:Object = ((JSON.deserialize(_local2)) || ({}));
            if (((_local5) && ((_local5.ret == 0)))){
                GlobalVars.instance.isCaptionListLoaded = true;
                _local6 = "上传字幕：";
                _local7 = this.sliceSname(_local4);
                _local8 = _local4;
                _local9 = _local5.surl;
                _local10 = _local5.scid;
                _local11 = this.getCaption(_local10);
                if (_local11){
                    this.removeCaption(_local3);
                    this._itemArray.pop();
                    _local3 = _local11;
                };
                _local12 = {
                    rname:_local6,
                    sname:_local7,
                    fname:_local8,
                    surl:_local9,
                    scid:_local10,
                    manual:true,
                    selected:true,
                    enable:true,
                    row:_local3.row
                };
                this.setCaptionProp(_local3, _local12);
                dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_STYLE));
                GlobalVars.instance.isCaptionTimeLoaded = false;
                dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_TIME, {scid:_local10}));
                dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_CONTENT, {
                    surl:_local9,
                    scid:_local10,
                    sname:_local8,
                    sdata:null,
                    isSaveAutoload:true,
                    gradeTime:180
                }));
                Tools.stat(("b=sczm&e=0&gcid=" + Tools.getUserInfo("ygcid")));
            } else {
                this.uploadError(_arg1);
            };
        }
        private function loadComplete(_arg1:CaptionEvent):void{
            this.deselect();
            var _local2:ByteArray = _arg1.info.data;
            var _local3:CaptionItem = (_arg1.info.uploadItem as CaptionItem);
            _local3.data = _local2;
            var _local4:String = _arg1.info.fileName;
            GlobalVars.instance.isCaptionListLoaded = true;
            var _local5 = "上传字幕：";
            var _local6:String = this.sliceSname(_local4);
            var _local7:String = _local4;
            var _local8 = "";
            var _local9 = "";
            var _local10:CaptionItem = this.getCaptionByData(_local2);
            if (_local10){
                this.removeCaption(_local3);
                this._itemArray.pop();
                _local3 = _local10;
            };
            var _local11:Object = {
                rname:_local5,
                sname:_local6,
                fname:_local7,
                surl:_local8,
                scid:_local9,
                manual:true,
                selected:true,
                enable:true,
                row:_local3.row,
                data:_local3.data
            };
            this.setCaptionProp(_local3, _local11);
            dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_STYLE));
            GlobalVars.instance.isCaptionTimeLoaded = false;
            dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_TIME, {scid:_local9}));
            dispatchEvent(new CaptionEvent(CaptionEvent.LOAD_CONTENT, {
                surl:_local8,
                scid:_local9,
                sname:_local7,
                sdata:_local3.data,
                isSaveAutoload:false,
                gradeTime:180
            }));
        }
        private function uploadError(_arg1:CaptionEvent):void{
            this.showUploadStatus(_arg1.info.uploadItem, "上传失败");
            Tools.stat(("b=sczm&e=-1&gcid=" + Tools.getUserInfo("ygcid")));
        }
        private function showUploadStatus(_arg1:CaptionItem, _arg2:String):void{
            _arg1.status_txt.text = _arg2;
        }
        private function sliceSname(_arg1:String):String{
            var _local2:int;
            var _local3:int;
            var _local4:String;
            var _local5:String;
            if (this.getStringLength(_arg1) > 24){
                _local2 = this.getStartIndex(_arg1);
                _local3 = this.getEndIndex(_arg1);
                _local4 = _arg1.slice(0, _local2);
                _local5 = _arg1.slice(_local3);
                _arg1 = ((_local4 + "...") + _local5);
            };
            return (_arg1);
        }
        private function getStringLength(_arg1:String):Number{
            var _local2:ByteArray = new ByteArray();
            _local2.writeMultiByte(_arg1, "gb2312");
            return (_local2.length);
        }
        private function getStartIndex(_arg1:String):int{
            var _local2:int = _arg1.length;
            var _local3:int;
            while (_local3 < _local2) {
                if (this.getStringLength(_arg1.slice(0, _local3)) > 11){
                    return (_local3);
                };
                _local3++;
            };
            return (0);
        }
        private function getEndIndex(_arg1:String):int{
            var _local2:int = _arg1.length;
            var _local3:int = (_local2 - 1);
            while (_local3 >= 0) {
                if (this.getStringLength(_arg1.slice(_local3)) > 11){
                    return (_local3);
                };
                _local3--;
            };
            return ((_local2 - 1));
        }

    }
}//package ctr.subtitle 
﻿package ctr.subtitle {
    import flash.display.*;
    import flash.utils.*;
    import flash.text.*;

    public class CaptionItem extends MovieClip {

        public var status_mc:MovieClip;
        public var name_txt:TextField;
        public var status_txt:TextField;
        public var row_txt:TextField;
        public var bg_mc:MovieClip;
        public var surl:String;
        public var scid:String;
        public var fullname:String;
        public var manual:Boolean;
        public var selected:Boolean;
        public var row:Number;
        public var data:ByteArray;

        public function CaptionItem(){
            var _local1:TextFormat = new TextFormat();
            _local1.font = "微软雅黑";
            this.row_txt.defaultTextFormat = _local1;
            this.row_txt.setTextFormat(_local1);
            this.name_txt.defaultTextFormat = _local1;
            this.name_txt.setTextFormat(_local1);
            this.status_txt.defaultTextFormat = _local1;
            this.status_txt.setTextFormat(_local1);
        }
    }
}//package ctr.subtitle 
﻿package ctr.subtitle {
    import flash.events.*;
    import flash.display.*;
    import eve.*;
    import ctr.setting.*;

    public class CaptionFace extends Sprite {

        private static const WIDTH_NORMAL:Number = 460;
        private static const HEIGHT_NORMAL:Number = 260;
        private static const OPTION_WIDTH:Number = 84;

        private var _currentHeight:Number = 228;
        private var _filterTarget;
        private var _setBackSpace:SetDrawBackground;
        private var _setCloseButton:SetCloseButton;
        private var _optionDetailFace:Sprite;
        private var _optionArr:Array;
        private var _currentOption;
        private var _setCaptionFace:SetCaptionFace;
        private var _captionStyleFace:SetCaptionStyleFace;
        private var _setBorder:CommonBorder;
        private var _beMouseOn:Boolean;
        private var _optionBorder:Shape;

        public function CaptionFace(){
            this._setCloseButton = new SetCloseButton();
            this._optionDetailFace = new Sprite();
            this._optionArr = [];
            super();
            this._setBackSpace = new SetDrawBackground("字幕", WIDTH_NORMAL, HEIGHT_NORMAL);
            addChild(this._setBackSpace);
            this._setBorder = new CommonBorder();
            addChild(this._setBorder);
            this._setCloseButton.x = (WIDTH_NORMAL - 25);
            this._setCloseButton.y = 10;
            this._setCloseButton.addEventListener(MouseEvent.CLICK, this.closeButtonClickHandler);
            addChild(this._setCloseButton);
            this._optionDetailFace.x = 16;
            this._optionDetailFace.y = 75;
            addChild(this._optionDetailFace);
            this.updateOptionObject();
            this.visible = false;
            this.addEventListener(MouseEvent.MOUSE_OVER, this.handleMouseOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, this.handleMouseOut);
        }
        public function clearCaption():void{
            this._setCaptionFace.clear();
        }
        public function showCompStatus():void{
            this._setCaptionFace.showCompStatus();
        }
        public function showErrorStatus():void{
            this._setCaptionFace.showErrorStatus();
        }
        public function get listLength():uint{
            return (this._setCaptionFace.listLength);
        }
        public function loadLastload():void{
            this._setCaptionFace.loadLastload();
        }
        public function loadAutoload():void{
            this._setCaptionFace.loadAutoload();
        }
        public function setOuterParam(_arg1:Object):void{
            this._setCaptionFace.setOuterParam(_arg1);
        }
        public function subDeltaByMouse(_arg1:Number):void{
            if (this._captionStyleFace.isThumbIconActive){
                this._captionStyleFace.subDeltaByMouse(_arg1);
            };
        }
        public function addDeltaByMouse(_arg1:Number):void{
            if (this._captionStyleFace.isThumbIconActive){
                this._captionStyleFace.addDeltaByMouse(_arg1);
            };
        }
        public function loadCaptionStyle():void{
            this._captionStyleFace.loadStyle();
        }
        public function loadCaptionTime(_arg1:Object):void{
            this._captionStyleFace.loadTime(_arg1);
        }
        public function subTimeDeltaByKey(_arg1:Number):void{
            this._captionStyleFace.subTimeDeltaByKey(_arg1, ((this.visible) && (this._captionStyleFace.visible)));
        }
        public function addTimeDeltaByKey(_arg1:Number):void{
            this._captionStyleFace.addTimeDeltaByKey(_arg1, ((this.visible) && (this._captionStyleFace.visible)));
        }
        public function get isThumbIconActive():Boolean{
            if (this._captionStyleFace.isThumbIconActive){
                return (true);
            };
            return (false);
        }
        private function updateOptionObject():void{
            var _local1:int;
            var _local2:int = this._optionArr.length;
            while (_local1 < _local2) {
                this.removeChild(this._optionArr[_local1]["option"]);
                this._optionDetailFace.removeChild(this._optionArr[_local1]["detail"]);
                _local1++;
            };
            this._optionArr = [];
            this._setCaptionFace = new SetCaptionFace();
            this.addOption("在线字幕", this._setCaptionFace);
            this._captionStyleFace = new SetCaptionStyleFace();
            this.addOption("字幕调节", this._captionStyleFace);
            this.showOption(this._optionArr[0]["option"]);
            this.updateOptionPosition(WIDTH_NORMAL, HEIGHT_NORMAL);
        }
        private function addOption(_arg1:String, _arg2):void{
            var _local3:SetDrawOption = new SetDrawOption(_arg1);
            var _local4:Object = {};
            _local4["name"] = _arg1;
            _local4["option"] = _local3;
            _local4["detail"] = _arg2;
            _local3.addEventListener(SetDrawOption.SELECTED, this.optionClickHandler);
            addChild(_local3);
            if (_arg2 != null){
                this._optionDetailFace.addChild(_arg2);
            };
            this._optionArr.push(_local4);
        }
        private function optionClickHandler(_arg1:Event):void{
            if (this._currentOption == _arg1.target){
                return;
            };
            this.showOption(_arg1.target);
        }
        private function showOption(_arg1):void{
            var _local2:*;
            this._currentOption = _arg1;
            for (_local2 in this._optionArr) {
                if (this._optionArr[_local2]["option"] != _arg1){
                    this._optionArr[_local2]["option"].optionFocus = false;
                    this._optionArr[_local2]["detail"].showFace = false;
                } else {
                    this._optionArr[_local2]["option"].optionFocus = true;
                    this._optionArr[_local2]["detail"].showFace = true;
                };
            };
            this.setButtonStatus();
        }
        private function setButtonStatus():void{
            var _local2:*;
            var _local1 = "";
            for (_local2 in this._optionArr) {
                if (this._optionArr[_local2]["option"] == this._currentOption){
                    _local1 = this._optionArr[_local2]["name"];
                };
            };
            this.updateDetailPosition(WIDTH_NORMAL, HEIGHT_NORMAL);
        }
        private function closeButtonClickHandler(_arg1:MouseEvent):void{
            var _local2:*;
            for (_local2 in this._optionArr) {
                if (this._optionArr[_local2]["option"] == this._currentOption){
                    this._optionArr[_local2]["detail"].cancleInterfaceFunction();
                };
            };
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "caption"));
        }
        private function updateOptionPosition(_arg1:Number, _arg2:Number):void{
            var _local3:int = this._optionArr.length;
            var _local4:Number = 15;
            var _local5:int;
            while (_local5 < _local3) {
                (this._optionArr[_local5]["option"] as SetDrawOption).y = 35;
                (this._optionArr[_local5]["option"] as SetDrawOption).x = (_local4 + (_local5 * OPTION_WIDTH));
                _local5++;
            };
            this._optionBorder = new Shape();
            this._optionBorder.graphics.clear();
            this._optionBorder.graphics.lineStyle(1, 0x373737);
            this._optionBorder.graphics.moveTo(0, 62);
            this._optionBorder.graphics.lineTo(_arg1, 62);
            addChildAt(this._optionBorder, getChildIndex(this._optionDetailFace));
        }
        private function updateDetailPosition(_arg1:Number, _arg2:Number):void{
            this._setBackSpace.setSize(_arg1, _arg2);
            this._setBorder.width = _arg1;
            this._setBorder.height = _arg2;
            this._currentHeight = _arg2;
            this.resizeHandler();
        }
        public function setPosition():void{
            stage.addEventListener(Event.RESIZE, this.resizeHandler);
            this.resizeHandler();
        }
        public function showFace(_arg1:Boolean):void{
            this.visible = _arg1;
            if (!_arg1){
                this._captionStyleFace.deactiveThumbIcon();
            } else {
                if (this._setCaptionFace.visible){
                    this._setCaptionFace.loadCaptionList();
                };
                if (this._captionStyleFace.visible){
                    this._captionStyleFace.loadStyle();
                };
            };
        }
        private function resizeHandler(_arg1:Event=null):void{
            if (stage){
                this.x = int(((stage.stageWidth - WIDTH_NORMAL) / 2));
                this.y = int((((stage.stageHeight - this._currentHeight) - 33) / 2));
            };
        }
        private function handleMouseOver(_arg1:MouseEvent):void{
            this._beMouseOn = true;
        }
        private function handleMouseOut(_arg1:MouseEvent):void{
            this._beMouseOn = false;
        }
        public function get beMouseOn():Boolean{
            return (this._beMouseOn);
        }

    }
}//package ctr.subtitle 
﻿package ctr.setting {
    import flash.display.*;
    import flash.text.*;

    public class SetDrawCheckButton extends Sprite {

        private var _checkButton:SetCheckButton;
        private var _checkButtonText:TextField;
        private var _checkTipsText:TextField;
        private var _msg = null;
        private var _isFocus:Boolean = false;
        private var _isEnabled:Boolean = true;

        public function SetDrawCheckButton(_arg1:String, _arg2=null, _arg3:String=null){
            this._checkButton = new SetCheckButton();
            this._checkButtonText = new TextField();
            this._checkTipsText = new TextField();
            super();
            this._msg = _arg2;
            this._checkButtonText.text = _arg1;
            this._checkButtonText.width = (this._checkButtonText.textWidth + 10);
            this._checkButtonText.height = 16;
            this._checkButtonText.x = 20;
            this._checkButtonText.selectable = false;
            addChild(this._checkButtonText);
            if (_arg3){
                this._checkTipsText.defaultTextFormat = new TextFormat("宋体", 12, 0x666666);
                this._checkTipsText.text = _arg3;
                this._checkTipsText.width = (this._checkTipsText.textWidth + 10);
                this._checkTipsText.height = 16;
                this._checkTipsText.x = (this._checkButtonText.x + this._checkButtonText.textWidth);
                this._checkTipsText.selectable = false;
                addChild(this._checkTipsText);
            };
            addChild(this._checkButton);
            this.setNormalStyle();
        }
        private function setNormalStyle():void{
            this.mouseChildren = true;
            this.mouseEnabled = true;
            this._checkButtonText.setTextFormat(new TextFormat("宋体", 12, 0xC1C1C1));
            this._checkButton.gotoAndStop(1);
        }
        private function setFocusStyle():void{
            this.mouseChildren = true;
            this.mouseEnabled = true;
            this._checkButtonText.setTextFormat(new TextFormat("宋体", 12, 0xC1C1C1));
            this._checkButton.gotoAndStop(2);
        }
        private function setDisableStyle():void{
            this.mouseChildren = false;
            this.mouseEnabled = false;
            this._checkButtonText.setTextFormat(new TextFormat("宋体", 12, 0x666666));
            this._checkButton.gotoAndStop(3);
        }
        public function get buttonMessage(){
            return (this._msg);
        }
        public function set setFocus(_arg1:Boolean):void{
            this._isFocus = _arg1;
            if (this._isEnabled){
                if (this._isFocus){
                    this.setFocusStyle();
                } else {
                    this.setNormalStyle();
                };
            };
        }
        public function set setEnabled(_arg1:Boolean):void{
            this._isEnabled = _arg1;
            if (this._isEnabled){
                this.setNormalStyle();
            } else {
                this.setDisableStyle();
            };
        }

    }
}//package ctr.setting 
﻿package ctr.setting {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import eve.*;
    import flash.text.*;
    import flash.external.*;

    public class SetDefaultFormatFace extends Sprite {

        private var _formatArray:Array;
        private var _tipsTxt:TextField;
        private var _radioItemArr:Array;
        private var _curFormat:String;
        private var _defaultFormat:String;
        private var _commitBtn:SetCommitButton;

        public function SetDefaultFormatFace(){
            var _local2:uint;
            var _local3:SetDrawCheckButton;
            this._formatArray = [{
                format:"p",
                label:"流畅",
                tips:"(1M带宽)"
            }, {
                format:"g",
                label:"高清",
                tips:"(2M带宽)"
            }, {
                format:"c",
                label:"超清",
                tips:"(4M带宽)"
            }];
            this._radioItemArr = [];
            super();
            var _local1:TextFormat = new TextFormat("宋体", 12, 0xC1C1C1);
            this._tipsTxt = new TextField();
            this._tipsTxt.selectable = false;
            this._tipsTxt.defaultTextFormat = _local1;
            this._tipsTxt.text = "优先为我选择(下次播放时生效)";
            this._tipsTxt.width = (this._tipsTxt.textWidth + 10);
            this._tipsTxt.height = (this._tipsTxt.textHeight + 5);
            this._tipsTxt.x = 15;
            this._tipsTxt.y = 15;
            addChild(this._tipsTxt);
            _local2 = 0;
            while (_local2 < 3) {
                _local3 = new SetDrawCheckButton(this._formatArray[_local2].label, this._formatArray[_local2].format, this._formatArray[_local2].tips);
                _local3.x = (35 + (125 * _local2));
                _local3.y = 50;
                _local3.addEventListener(MouseEvent.CLICK, this.onRadioItemClick);
                addChild(_local3);
                this._radioItemArr.push(_local3);
                _local2++;
            };
            this._commitBtn = new SetCommitButton();
            this._commitBtn.x = 170;
            this._commitBtn.y = 141;
            this._commitBtn.addEventListener(MouseEvent.CLICK, this.onCommitClick);
            addChild(this._commitBtn);
        }
        private function onCommitClick(_arg1:MouseEvent):void{
            if (this._curFormat != this._defaultFormat){
                this._defaultFormat = this._curFormat;
                GlobalVars.instance.defaultFormatChanged = true;
                ExternalInterface.call("G_PLAYER_INSTANCE.setStorageData", ("defaultFormat=" + this._curFormat));
                JTracer.sendMessage(("SetDefaultFormatFace -> set default format, defaultFormat:" + this._curFormat));
            };
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "set"));
        }
        private function onRadioItemClick(_arg1:MouseEvent):void{
            this._curFormat = (_arg1.currentTarget as SetDrawCheckButton).buttonMessage;
            this.showCurrentFormat(this._curFormat);
        }
        public function showCurrentFormat(_arg1:String):void{
            var _local2:*;
            var _local3:SetDrawCheckButton;
            var _local4:SetDrawCheckButton;
            for (_local2 in this._radioItemArr) {
                _local3 = (this._radioItemArr[_local2] as SetDrawCheckButton);
                _local3.setFocus = false;
            };
            _local4 = this.getRadioItem(_arg1);
            _local4.setFocus = true;
        }
        private function getRadioItem(_arg1:String):SetDrawCheckButton{
            var _local2:*;
            var _local3:SetDrawCheckButton;
            for (_local2 in this._radioItemArr) {
                _local3 = (this._radioItemArr[_local2] as SetDrawCheckButton);
                if (_local3.buttonMessage == _arg1){
                    return (_local3);
                };
            };
            return (null);
        }
        public function get defaultFormat():String{
            return (this._defaultFormat);
        }
        public function set showFace(_arg1:Boolean):void{
            var isValidFormat:* = false;
            var i:* = 0;
            var isShow:* = _arg1;
            if (isShow == true){
                this.visible = true;
                try {
                    this._defaultFormat = ExternalInterface.call("G_PLAYER_INSTANCE.getStorageData", "defaultFormat");
                } catch(e:Error) {
                    _defaultFormat = "p";
                };
                JTracer.sendMessage(("SetDefaultFormatFace -> get default format, defaultFormat:" + this._defaultFormat));
                isValidFormat = false;
                i = 0;
                while (i < this._formatArray.length) {
                    JTracer.sendMessage(((("format:" + this._formatArray[i]["format"]) + " _defaultFormat:") + this._defaultFormat));
                    if (this._defaultFormat == this._formatArray[i]["format"]){
                        isValidFormat = true;
                        break;
                    };
                    i = (i + 1);
                };
                if (!isValidFormat){
                    this._defaultFormat = "p";
                };
                this.showCurrentFormat(this._defaultFormat);
            } else {
                this.visible = false;
            };
        }
        public function initRecordStatus():void{
        }
        public function commitInterfaceFunction():void{
        }
        public function cancleInterfaceFunction():void{
        }

    }
}//package ctr.setting 
﻿package ctr.setting {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import eve.*;

    public class SetVideoSizeFace extends Sprite {

        private var _ratioButtonCommon:SetDrawCheckButton;
        private var _ratioButton4_3:SetDrawCheckButton;
        private var _ratioButton16_9:SetDrawCheckButton;
        private var _ratioButtonFull:SetDrawCheckButton;
        private var _commitButton:SetCommitButton;
        private var _ratioButtonArr:Array;
        private var _setInfo:Object;
        private var _recordSetInfo:Object;

        public function SetVideoSizeFace(){
            var _local1:*;
            this._ratioButtonArr = [];
            this._setInfo = {
                ratio:"common",
                size:"100"
            };
            this._recordSetInfo = {
                ratio:"common",
                size:"100"
            };
            super();
            this._ratioButtonCommon = new SetDrawCheckButton("原始", "common");
            this._ratioButton4_3 = new SetDrawCheckButton("4：3", "4_3");
            this._ratioButton16_9 = new SetDrawCheckButton("16：9", "16_9");
            this._ratioButtonFull = new SetDrawCheckButton("满屏", "full");
            this._ratioButtonArr.push(this._ratioButtonCommon);
            this._ratioButtonArr.push(this._ratioButton4_3);
            this._ratioButtonArr.push(this._ratioButton16_9);
            this._ratioButtonArr.push(this._ratioButtonFull);
            for (_local1 in this._ratioButtonArr) {
                this._ratioButtonArr[_local1].x = (35 + (100 * _local1));
                this._ratioButtonArr[_local1].y = 50;
                this._ratioButtonArr[_local1].addEventListener(MouseEvent.CLICK, this.ratioButtonClickHandler);
                addChild(this._ratioButtonArr[_local1]);
            };
            this.showRatioButton(this._ratioButtonArr[0]);
            this._commitButton = new SetCommitButton();
            this._commitButton.y = 141;
            this._commitButton.x = 170;
            this._commitButton.addEventListener(MouseEvent.CLICK, this.commitButtonClickHandler);
            addChild(this._commitButton);
        }
        private function commitButtonClickHandler(_arg1:MouseEvent):void{
            this.commitInterfaceFunction();
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "set"));
        }
        private function ratioButtonClickHandler(_arg1:MouseEvent):void{
            this.showRatioButton(_arg1.currentTarget);
        }
        private function showRatioButton(_arg1):void{
            var _local2:*;
            for (_local2 in this._ratioButtonArr) {
                if (this._ratioButtonArr[_local2] == _arg1){
                    this._ratioButtonArr[_local2].setFocus = true;
                } else {
                    this._ratioButtonArr[_local2].setFocus = false;
                };
            };
            this._setInfo["ratio"] = _arg1.buttonMessage;
            dispatchEvent(new EventSet(EventSet.SET_SIZE));
        }
        private function checkValueChanged():void{
            if (((!((this._recordSetInfo["ratio"] == this._setInfo["ratio"]))) || (!((this._recordSetInfo["size"] == this._setInfo["size"]))))){
                GlobalVars.instance.ratioChanged = true;
            };
        }
        public function setFaceStatus(_arg1:Object):void{
            if (_arg1["ratio"] == "4_3"){
                this.showRatioButton(this._ratioButton4_3);
            } else {
                if (_arg1["ratio"] == "16_9"){
                    this.showRatioButton(this._ratioButton16_9);
                } else {
                    if (_arg1["ratio"] == "common"){
                        this.showRatioButton(this._ratioButtonCommon);
                    } else {
                        this.showRatioButton(this._ratioButtonFull);
                    };
                };
            };
            this._setInfo["ratio"] = (this._recordSetInfo["ratio"] = _arg1["ratio"]);
            this._setInfo["size"] = (this._recordSetInfo["size"] = _arg1["size"]);
        }
        public function set showFace(_arg1:Boolean):void{
            if (_arg1 == true){
                this.visible = true;
            } else {
                this.visible = false;
                this.commitInterfaceFunction();
            };
        }
        public function get setInfo():Object{
            return (this._setInfo);
        }
        public function initRecordStatus():void{
            this._recordSetInfo["ratio"] = "common";
            this._recordSetInfo["size"] = "100";
            this.setFaceStatus(this._recordSetInfo);
        }
        public function commitInterfaceFunction():void{
            this.checkValueChanged();
            this._recordSetInfo["ratio"] = this._setInfo["ratio"];
            this._recordSetInfo["size"] = this._setInfo["size"];
        }
        public function cancleInterfaceFunction():void{
            this.setFaceStatus(this._recordSetInfo);
        }

    }
}//package ctr.setting 
﻿package ctr.setting {
    import flash.events.*;
    import flash.display.*;
    import flash.text.*;

    public class SetDrawOption extends Sprite {

        public static const SELECTED:String = "selected";

        private var _isFocus:Boolean = false;
        private var _optionFace:Sprite;
        private var _optionText:TextField;
        private var _defaultBack:SetDefaultOptionBack;
        private var _selectedBack:SetSelectedOptionBack;

        public function SetDrawOption(_arg1:String){
            this._optionFace = new Sprite();
            this._optionText = new TextField();
            this._defaultBack = new SetDefaultOptionBack();
            this._selectedBack = new SetSelectedOptionBack();
            super();
            this._optionText.text = _arg1;
            this._optionText.setTextFormat(new TextFormat("宋体", 12, 0x444444, false));
            this._optionText.width = 72;
            this._optionText.height = 27;
            this._optionText.x = 2;
            this._optionText.y = 4;
            this._optionText.autoSize = TextFieldAutoSize.CENTER;
            this._optionFace.graphics.beginFill(0xFFFFFF, 0);
            this._optionFace.graphics.drawRect(0, 0, 72, 27);
            this._optionFace.graphics.endFill();
            this._optionFace.buttonMode = true;
            this._optionFace.addEventListener(MouseEvent.CLICK, this.optionClickHandler);
            this._optionFace.addEventListener(MouseEvent.MOUSE_OVER, this.optionMouseOverHandler);
            this._optionFace.addEventListener(MouseEvent.MOUSE_OUT, this.optionMouseOutHandler);
            addChild(this._defaultBack);
            addChild(this._selectedBack);
            addChild(this._optionText);
            addChild(this._optionFace);
            this._defaultBack.visible = true;
            this._selectedBack.visible = false;
        }
        private function optionClickHandler(_arg1:MouseEvent):void{
            this._optionFace.buttonMode = false;
            this._defaultBack.visible = false;
            this._selectedBack.visible = true;
            this._optionText.setTextFormat(new TextFormat("宋体", 12, 0xFFFFFF, true));
            dispatchEvent(new Event(SELECTED));
        }
        private function optionMouseOutHandler(_arg1:MouseEvent):void{
            if (this._optionFace.buttonMode){
                this._optionText.setTextFormat(new TextFormat("宋体", 12, 0x444444, false));
            };
        }
        private function optionMouseOverHandler(_arg1:MouseEvent):void{
            if (this._optionFace.buttonMode){
                this._optionText.setTextFormat(new TextFormat("宋体", 12, 4821990, false));
            };
        }
        public function set optionFocus(_arg1:Boolean):void{
            if (_arg1){
                this._optionFace.buttonMode = false;
                this._defaultBack.visible = false;
                this._selectedBack.visible = true;
                this._optionText.setTextFormat(new TextFormat("宋体", 12, 0xFFFFFF, true));
            } else {
                this._optionFace.buttonMode = true;
                this._defaultBack.visible = true;
                this._selectedBack.visible = false;
                this._optionText.setTextFormat(new TextFormat("宋体", 12, 0x444444, false));
            };
            this._isFocus = _arg1;
        }
        public function get optionText():String{
            return (this._optionText.text);
        }

    }
}//package ctr.setting 
﻿package ctr.setting {
    import flash.display.*;
    import flash.text.*;

    public class CaptionStyleBtn extends MovieClip {

        public var color_txt:TextField;
        private var _selected:Boolean;
        private var _fontColor:uint;
        private var _filterColor:uint;

        public function CaptionStyleBtn(){
            var _local1:TextFormat = new TextFormat("微软雅黑");
            this.color_txt.defaultTextFormat = _local1;
        }
        public function set fontColor(_arg1:uint):void{
            this._fontColor = _arg1;
        }
        public function get fontColor():uint{
            return (this._fontColor);
        }
        public function set filterColor(_arg1:uint):void{
            this._filterColor = _arg1;
        }
        public function get filterColor():uint{
            return (this._filterColor);
        }
        public function set selected(_arg1:Boolean):void{
            this._selected = _arg1;
        }
        public function get selected():Boolean{
            return (this._selected);
        }

    }
}//package ctr.setting 
﻿package ctr.setting {
    import flash.display.*;
    import flash.text.*;

    public class SetDrawBackground extends Sprite {

        private static const TITLE_HEIGHT:Number = 30;
        private static const TITLE_STYLE:TextFormat = new TextFormat("宋体", 13, 3837407, true, null, null, null, null, "left");
        private static const MARGIN:Number = 15;
        private static const BACKGROUND_COLOR:int = 921102;
        private static const BACKGROUND_ALPHA:Number = 0.8;
        private static const BORDER_COLOR:int = 0x2B2B2B;

        private var _title:TextField;
        private var _bg:CommonBackGround;

        public function SetDrawBackground(_arg1:String, _arg2:Number, _arg3:Number){
            this.drawBackground(_arg2, _arg3);
            this._title = new TextField();
            this._title.defaultTextFormat = TITLE_STYLE;
            this._title.selectable = false;
            this._title.text = _arg1;
            this._title.width = (this._title.textWidth + 4);
            this._title.height = 20;
            addChild(this._title);
            this.updateTitlePosition();
        }
        private function drawBackground(_arg1:Number, _arg2:Number):void{
            if (!this._bg){
                this._bg = new CommonBackGround();
                addChild(this._bg);
            };
            this._bg.width = _arg1;
            this._bg.height = _arg2;
        }
        private function updateTitlePosition():void{
            this._title.x = 10;
            this._title.y = 9;
        }
        public function setTitle(_arg1:String):void{
            this._title.text = _arg1;
        }
        public function setSize(_arg1:Number, _arg2:Number):void{
            this.drawBackground(_arg1, _arg2);
            this.updateTitlePosition();
        }

    }
}//package ctr.setting 
﻿package ctr.setting {
    import flash.events.*;
    import flash.display.*;
    import eve.*;
    import ctr.filter.*;

    public class SettingSpace extends Sprite {

        private static const WIDTH_NORMAL:Number = 460;
        private static const HEIGHT_NORMAL:Number = 260;
        private static const OPTION_WIDTH:Number = 84;

        private var _currentHeight:Number = 228;
        private var _filterTarget;
        private var _setBackSpace:SetDrawBackground;
        private var _setCloseButton:SetCloseButton;
        private var _optionDetailFace:Sprite;
        private var _optionArr:Array;
        private var _currentOption;
        private var _mouseMoveSizeObject:Object;
        private var _defaultFormatFace:SetDefaultFormatFace;
        private var _videoSizeFace:SetVideoSizeFace;
        public var _filterFace:Filter;
        private var _setBorder:CommonBorder;
        private var _beMouseOn:Boolean;
        private var _optionBorder:Shape;

        public function SettingSpace(_arg1){
            this._setCloseButton = new SetCloseButton();
            this._optionDetailFace = new Sprite();
            this._optionArr = [];
            this._mouseMoveSizeObject = {};
            super();
            this._filterTarget = _arg1;
            this._setBackSpace = new SetDrawBackground("画面", WIDTH_NORMAL, HEIGHT_NORMAL);
            addChild(this._setBackSpace);
            this._setBorder = new CommonBorder();
            addChild(this._setBorder);
            this._setCloseButton.x = (WIDTH_NORMAL - 25);
            this._setCloseButton.y = 10;
            this._setCloseButton.addEventListener(MouseEvent.CLICK, this.closeButtonClickHandler);
            addChild(this._setCloseButton);
            this._optionDetailFace.x = 16;
            this._optionDetailFace.y = 75;
            addChild(this._optionDetailFace);
            this.updateOptionObject();
            this.visible = false;
            this.addEventListener(MouseEvent.MOUSE_OVER, this.handleMouseOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, this.handleMouseOut);
        }
        private function updateOptionObject():void{
            var _local1:int;
            var _local2:int = this._optionArr.length;
            while (_local1 < _local2) {
                this.removeChild(this._optionArr[_local1]["option"]);
                this._optionDetailFace.removeChild(this._optionArr[_local1]["detail"]);
                _local1++;
            };
            this._optionArr = [];
            this._defaultFormatFace = new SetDefaultFormatFace();
            this.addOption("默认清晰度", this._defaultFormatFace);
            this._videoSizeFace = new SetVideoSizeFace();
            this.addOption("画面比例", this._videoSizeFace);
            this._filterFace = new Filter(this._filterTarget);
            this.addOption("色彩调节", this._filterFace);
            this.updateOptionPosition(WIDTH_NORMAL, HEIGHT_NORMAL);
        }
        private function addOption(_arg1:String, _arg2):void{
            var _local3:SetDrawOption = new SetDrawOption(_arg1);
            var _local4:Object = {};
            _local4["name"] = _arg1;
            _local4["option"] = _local3;
            _local4["detail"] = _arg2;
            _local3.addEventListener(SetDrawOption.SELECTED, this.optionClickHandler);
            addChild(_local3);
            if (_arg2 != null){
                this._optionDetailFace.addChild(_arg2);
            };
            this._optionArr.push(_local4);
        }
        private function optionClickHandler(_arg1:Event):void{
            if (this._currentOption == _arg1.target){
                return;
            };
            this.showOption(_arg1.target);
        }
        private function showOption(_arg1):void{
            var _local2:*;
            this._currentOption = _arg1;
            for (_local2 in this._optionArr) {
                if (this._optionArr[_local2]["option"] != _arg1){
                    this._optionArr[_local2]["option"].optionFocus = false;
                    this._optionArr[_local2]["detail"].showFace = false;
                } else {
                    this._optionArr[_local2]["option"].optionFocus = true;
                    this._optionArr[_local2]["detail"].showFace = true;
                };
            };
            this.setButtonStatus();
        }
        private function setButtonStatus():void{
            var _local2:*;
            var _local1 = "";
            for (_local2 in this._optionArr) {
                if (this._optionArr[_local2]["option"] == this._currentOption){
                    _local1 = this._optionArr[_local2]["name"];
                };
            };
            this.updateDetailPosition(WIDTH_NORMAL, HEIGHT_NORMAL);
        }
        private function closeButtonClickHandler(_arg1:MouseEvent):void{
            var _local2:*;
            for (_local2 in this._optionArr) {
                if (this._optionArr[_local2]["option"] == this._currentOption){
                    this._optionArr[_local2]["detail"].cancleInterfaceFunction();
                };
            };
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "set"));
        }
        private function updateOptionPosition(_arg1:Number, _arg2:Number):void{
            var _local3:int = this._optionArr.length;
            var _local4:Number = 15;
            var _local5:int;
            while (_local5 < _local3) {
                (this._optionArr[_local5]["option"] as SetDrawOption).y = 35;
                (this._optionArr[_local5]["option"] as SetDrawOption).x = (_local4 + (_local5 * OPTION_WIDTH));
                _local5++;
            };
            this._optionBorder = new Shape();
            this._optionBorder.graphics.clear();
            this._optionBorder.graphics.lineStyle(1, 0x373737);
            this._optionBorder.graphics.moveTo(0, 62);
            this._optionBorder.graphics.lineTo(_arg1, 62);
            addChild(this._optionBorder);
        }
        private function updateDetailPosition(_arg1:Number, _arg2:Number):void{
            this._setBackSpace.setSize(_arg1, _arg2);
            this._setBorder.width = _arg1;
            this._setBorder.height = _arg2;
            this._currentHeight = _arg2;
            this.resizeHandler();
        }
        public function get isThumbIconActive():Boolean{
            if (this._filterFace.isThumbIconActive){
                return (true);
            };
            return (false);
        }
        public function subDeltaByMouse(_arg1:Number):void{
            if (this._filterFace.isThumbIconActive){
                this._filterFace.subDeltaByMouse(_arg1);
            };
        }
        public function addDeltaByMouse(_arg1:Number):void{
            if (this._filterFace.isThumbIconActive){
                this._filterFace.addDeltaByMouse(_arg1);
            };
        }
        public function setPosition():void{
            stage.addEventListener(Event.RESIZE, this.resizeHandler);
            this.resizeHandler();
        }
        public function showSetFace():void{
            if (this.visible == true){
                this.visible = false;
            } else {
                this.resizeHandler();
                this._mouseMoveSizeObject = {};
                this.visible = true;
                this.showOption(this._optionArr[0]["option"]);
            };
        }
        private function resizeHandler(_arg1:Event=null):void{
            if (stage){
                this.x = int(((stage.stageWidth - WIDTH_NORMAL) / 2));
                this.y = int((((stage.stageHeight - this._currentHeight) - 33) / 2));
            };
        }
        private function handleMouseOver(_arg1:MouseEvent):void{
            this._beMouseOn = true;
        }
        private function handleMouseOut(_arg1:MouseEvent):void{
            this._beMouseOn = false;
        }
        public function get beMouseOn():Boolean{
            return (this._beMouseOn);
        }
        public function set videoSize(_arg1:Object):void{
            this._videoSizeFace.setFaceStatus(_arg1);
        }
        public function get videoSize():Object{
            return (this._videoSizeFace.setInfo);
        }

    }
}//package ctr.setting 
﻿package ctr.setting {
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;
    import com.common.*;
    import flash.text.*;

    public class CommonSlider extends Sprite {

        public static const CHANGE_VALUE:String = "change_value";

        private var _controlTxt:TextField;
        private var _controlBar:FilterControlBar;
        private var _controlBtn:FilterControlBtn;
        private var _controlUpBtn:Sprite;
        private var _controlDownBtn:Sprite;
        private var _barWidth:Number = 234;
        private var _btnWidth:Number = 12;
        private var _btnHeight:Number = 12;
        private var _minValue:Number;
        private var _maxValue:Number;
        private var _snapInterval:Number;
        private var _clickInterval:Number;
        private var _currentX:Number;
        private var _currentValue:Number;
        private var _isShowToolTip:Boolean;
        private var _isFormatTip:Boolean;
        private var _isSupportHover:Boolean;
        private var _isThumbIconHasStatus:Boolean;
        private var _prefixTip:String = "";
        private var _unit:String = "";
        private var _mouseX:Number;
        private var _decimalNum:int;
        private var _shortcuts:ShortcutsTips;
        private var _defLevel:Number;
        private var _aveLevel:Number;
        private var _controllType:String;

        public function CommonSlider(){
            this.initControlUI();
        }
        private function initControlUI():void{
            this._controlBar = new FilterControlBar();
            this._controlBar.width = this._barWidth;
            this._controlBar.buttonMode = true;
            this._controlBar.x = 92;
            this._controlBar.y = -6;
            this._controlBar.addEventListener(MouseEvent.CLICK, this.barClickHandler);
            this._controlBar.addEventListener(MouseEvent.MOUSE_OVER, this.barOverHandler);
            this._controlBar.addEventListener(MouseEvent.MOUSE_OUT, this.barOutHandler);
            addChild(this._controlBar);
            this._controlBtn = new FilterControlBtn();
            this._controlBtn.x = ((this._controlBar.x + (this._barWidth / 2)) - (this._controlBtn.width / 2));
            this._controlBtn.y = -7;
            this._controlBtn.buttonMode = true;
            this._controlBtn.addEventListener(MouseEvent.MOUSE_DOWN, this.btnMouseDownHandler);
            this._controlBtn.addEventListener(MouseEvent.MOUSE_OVER, this.btnOverHandler);
            this._controlBtn.addEventListener(MouseEvent.MOUSE_OUT, this.btnOutHandler);
            addChild(this._controlBtn);
            this._controlDownBtn = this.drawDownBtn();
            this._controlDownBtn.x = 74;
            this._controlDownBtn.y = -7;
            this._controlDownBtn.addEventListener(MouseEvent.MOUSE_DOWN, this.controlDownHandler);
            addChild(this._controlDownBtn);
            this._controlUpBtn = this.drawUpBtn();
            this._controlUpBtn.x = ((this._controlBar.x + this._barWidth) + 5);
            this._controlUpBtn.y = -7;
            this._controlUpBtn.addEventListener(MouseEvent.MOUSE_DOWN, this.controlUpHandler);
            addChild(this._controlUpBtn);
            if (stage){
                this.initStage();
            } else {
                addEventListener(Event.ADDED_TO_STAGE, this.initStage);
            };
        }
        public function subTimeDelta(_arg1:Number, _arg2:Boolean=true, _arg3:DisplayObject=null, _arg4:String=""):void{
            this._controllType = _arg4;
            stage.addEventListener(MouseEvent.MOUSE_UP, this.controlMouseUpHandler);
            this.currentValue = (this.currentValue - _arg1);
            if (this.currentValue < this._minValue){
                this.currentValue = this._minValue;
            };
            if (_arg2){
                this.showToolTip(_arg3);
            };
        }
        public function addTimeDelta(_arg1:Number, _arg2:Boolean=true, _arg3:DisplayObject=null, _arg4:String=""):void{
            this._controllType = _arg4;
            stage.addEventListener(MouseEvent.MOUSE_UP, this.controlMouseUpHandler);
            this.currentValue = (this.currentValue + _arg1);
            if (this.currentValue > this._maxValue){
                this.currentValue = this._maxValue;
            };
            if (_arg2){
                this.showToolTip(_arg3);
            };
        }
        private function drawDownBtn():Sprite{
            var _local1:Sprite = new Sprite();
            var _local2:Sprite = this.drawRect(this._btnWidth, this._btnHeight, 0xFFFFFF, 0);
            var _local3:Sprite = this.drawRect((this._btnWidth - 3), 1, 7105387, 1);
            _local3.x = 1;
            _local3.y = 7;
            _local1.addChild(_local2);
            _local1.addChild(_local3);
            _local1.buttonMode = true;
            _local1.mouseChildren = false;
            return (_local1);
        }
        private function drawUpBtn():Sprite{
            var _local1:Sprite = new Sprite();
            var _local2:Sprite = this.drawRect(this._btnWidth, this._btnHeight, 0xFFFFFF, 0);
            var _local3:Sprite = this.drawRect((this._btnWidth - 3), 1, 7105387, 1);
            _local3.x = 1;
            _local3.y = 7;
            var _local4:Sprite = this.drawRect((this._btnWidth - 3), 1, 7105387, 1);
            _local4.rotation = 90;
            _local4.x = 6;
            _local4.y = 3;
            _local1.addChild(_local2);
            _local1.addChild(_local3);
            _local1.addChild(_local4);
            _local1.buttonMode = true;
            _local1.mouseChildren = false;
            return (_local1);
        }
        private function drawRect(_arg1:Number, _arg2:Number, _arg3:uint, _arg4:Number):Sprite{
            var _local5:Sprite = new Sprite();
            _local5.graphics.beginFill(_arg3, _arg4);
            _local5.graphics.drawRect(0, 0, _arg1, _arg2);
            _local5.graphics.endFill();
            return (_local5);
        }
        private function initStage(_arg1:Event=null):void{
            removeEventListener(Event.ADDED_TO_STAGE, this.initStage);
            stage.addEventListener(MouseEvent.CLICK, this.stageClickHandler);
        }
        private function stageClickHandler(_arg1:MouseEvent):void{
            if (_arg1.target != this._controlBtn){
                this.isThumbIconActive = false;
            } else {
                if (!this.isThumbIconActive){
                    this.isThumbIconActive = !(this.isThumbIconActive);
                };
            };
        }
        private function barClickHandler(_arg1:MouseEvent):void{
            this._mouseX = (this.mouseX - (this._controlBtn.width / 2));
            if (this._mouseX <= this._controlBar.x){
                this._mouseX = this._controlBar.x;
            };
            if (this._mouseX >= ((this._controlBar.x + this._barWidth) - this._controlBtn.width)){
                this._mouseX = ((this._controlBar.x + this._barWidth) - this._controlBtn.width);
            };
            this.currentValue = ((((this._maxValue - this._minValue) * (this._mouseX - this._controlBar.x)) / (this._barWidth - this._controlBtn.width)) + this._minValue);
        }
        private function barOverHandler(_arg1:MouseEvent):void{
            if (this._isSupportHover){
                this.showToolTip(this._controlBtn);
            };
        }
        private function barOutHandler(_arg1:MouseEvent):void{
            if (this._isSupportHover){
                this.hideToolTip();
            };
        }
        private function btnMouseDownHandler(_arg1:MouseEvent):void{
            this.stageClickHandler(_arg1);
            this.showToolTip(this._controlBtn);
            stage.addEventListener(MouseEvent.MOUSE_MOVE, this.btnMouseMoveHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP, this.btnMouseUpHandler);
        }
        private function btnOverHandler(_arg1:MouseEvent):void{
            if (this._isSupportHover){
                this.showToolTip(this._controlBtn);
            };
        }
        private function btnOutHandler(_arg1:MouseEvent):void{
            if (this._isSupportHover){
                this.hideToolTip();
            };
        }
        private function btnMouseMoveHandler(_arg1:MouseEvent):void{
            this._mouseX = (this.mouseX - (this._controlBtn.width / 2));
            if (this._mouseX <= this._controlBar.x){
                this._mouseX = this._controlBar.x;
            };
            if (this._mouseX >= ((this._controlBar.x + this._barWidth) - this._controlBtn.width)){
                this._mouseX = ((this._controlBar.x + this._barWidth) - this._controlBtn.width);
            };
            this.currentValue = ((((this._maxValue - this._minValue) * (this._mouseX - this._controlBar.x)) / (this._barWidth - this._controlBtn.width)) + this._minValue);
            this.showToolTip(this._controlBtn);
        }
        private function btnMouseUpHandler(_arg1:MouseEvent):void{
            this.hideToolTip();
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.btnMouseMoveHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP, this.btnMouseUpHandler);
        }
        private function controlDownHandler(_arg1:MouseEvent):void{
            this.subTimeDelta(this._clickInterval, true, this._controlDownBtn);
        }
        private function controlUpHandler(_arg1:MouseEvent):void{
            this.addTimeDelta(this._clickInterval, true, this._controlUpBtn);
        }
        private function controlMouseUpHandler(_arg1:MouseEvent):void{
            this.hideToolTip();
            stage.removeEventListener(MouseEvent.MOUSE_UP, this.controlMouseUpHandler);
        }
        private function setControllBtnPos(_arg1:Number):void{
            this._controlBtn.x = _arg1;
            if (this._controlBtn.x <= this._controlBar.x){
                this._controlBtn.x = this._controlBar.x;
            };
            if (this._controlBtn.x >= ((this._controlBar.x + this._barWidth) - this._controlBtn.width)){
                this._controlBtn.x = ((this._controlBar.x + this._barWidth) - this._controlBtn.width);
            };
            this._controlBar.mask_mc.width = ((this._controlBtn.x - this._controlBar.x) + (this._controlBtn.width / 2));
            if (this._shortcuts){
                this.setShortcutsPos();
            };
        }
        private function showToolTip(_arg1:DisplayObject):void{
            var _local2:Point;
            var _local3:Array;
            var _local4:String;
            if (this._shortcuts){
                return;
            };
            if (this._isShowToolTip){
                _local2 = _arg1.localToGlobal(new Point(0, 0));
                _local3 = this._prefixTip.split("|");
                _local4 = ((this._isFormatTip) ? (((this._currentValue < 0)) ? ((_local3[0] + Math.abs(this._currentValue).toString()) + this._unit) : ((_local3[1] + Math.abs(this._currentValue).toString()) + this._unit)) : this._currentValue.toString());
                Tools.showToolTip((("   " + _local4) + "   "));
                Tools.moveToolTipToPoint(((_local2.x + (_arg1.width / 2)) - (Tools.toolTipWidth / 2)), (_local2.y - 1));
            };
        }
        private function hideToolTip():void{
            if (this._isShowToolTip){
                Tools.hideToolTip();
            };
        }
        private function setShortcutsPos():void{
            this._shortcuts.x = ((this._controlBtn.x + (this._controlBtn.width / 2)) - 41);
            this._shortcuts.y = (this._controlBtn.y - 68);
        }
        private function hideShortcuts(_arg1:TextEvent=null):void{
            if (this._shortcuts){
                removeChild(this._shortcuts);
                this._shortcuts = null;
            };
            Cookies.setCookie("hideShortcutsTips", true);
        }
        public function showShortcuts():void{
            var _local1:StyleSheet;
            var _local2:TextFormat;
            if (!this._shortcuts){
                _local1 = new StyleSheet();
                _local1.setStyle("a", {
                    textDecoration:"underline",
                    fontFamily:"宋体"
                });
                _local2 = new TextFormat();
                _local2.font = "宋体";
                this._shortcuts = new ShortcutsTips();
                this._shortcuts.info_txt.defaultTextFormat = _local2;
                this._shortcuts.info_txt.setTextFormat(_local2);
                this._shortcuts.know_txt.htmlText = " <a href='event:hide'>我知道了</a>";
                this._shortcuts.know_txt.styleSheet = _local1;
                this._shortcuts.know_txt.height = 20;
                this._shortcuts.know_txt.addEventListener(TextEvent.LINK, this.hideShortcuts);
                addChild(this._shortcuts);
                this.setShortcutsPos();
            };
        }
        public function set title(_arg1:String):void{
            var _local2:TextFormat = new TextFormat("宋体");
            this._controlTxt = new TextField();
            this._controlTxt.text = _arg1;
            this._controlTxt.setTextFormat(_local2);
            this._controlTxt.x = 18;
            this._controlTxt.y = -8;
            this._controlTxt.width = (this._controlTxt.textWidth + 10);
            this._controlTxt.height = 25;
            this._controlTxt.textColor = 0xC1C1C1;
            this._controlTxt.selectable = false;
            addChild(this._controlTxt);
        }
        public function get currentValue():Number{
            return (this._currentValue);
        }
        public function set currentValue(_arg1:Number):void{
            this._currentValue = Number(_arg1.toFixed(this._decimalNum));
            if (this.currentValue < this._minValue){
                this.currentValue = this._minValue;
            };
            if (this.currentValue > this._maxValue){
                this.currentValue = this._maxValue;
            };
            this._currentX = (this._controlBar.x + (((this._currentValue - this._minValue) / (this._maxValue - this._minValue)) * (this._barWidth - this._controlBtn.width)));
            this.setControllBtnPos(this._currentX);
            dispatchEvent(new Event(CHANGE_VALUE));
        }
        public function get minValue():Number{
            return (this._minValue);
        }
        public function set minValue(_arg1:Number):void{
            this._minValue = _arg1;
        }
        public function get maxValue():Number{
            return (this._maxValue);
        }
        public function set maxValue(_arg1:Number):void{
            this._maxValue = _arg1;
        }
        public function get snapInterval():Number{
            return (this._snapInterval);
        }
        public function set snapInterval(_arg1:Number):void{
            this._snapInterval = _arg1;
        }
        public function get clickInterval():Number{
            return (this._clickInterval);
        }
        public function set clickInterval(_arg1:Number):void{
            this._clickInterval = _arg1;
        }
        public function get decimalNum():int{
            return (this._decimalNum);
        }
        public function set decimalNum(_arg1:int):void{
            this._decimalNum = _arg1;
        }
        public function get isShowToolTip():Boolean{
            return (this._isShowToolTip);
        }
        public function set isShowToolTip(_arg1:Boolean):void{
            this._isShowToolTip = _arg1;
        }
        public function get isFormatTip():Boolean{
            return (this._isFormatTip);
        }
        public function set isFormatTip(_arg1:Boolean):void{
            this._isFormatTip = _arg1;
        }
        public function get prefixTip():String{
            return (this._prefixTip);
        }
        public function set prefixTip(_arg1:String):void{
            this._prefixTip = _arg1;
        }
        public function get unit():String{
            return (this._unit);
        }
        public function set unit(_arg1:String):void{
            this._unit = _arg1;
        }
        public function get isSupportHover():Boolean{
            return (this._isSupportHover);
        }
        public function set isSupportHover(_arg1:Boolean):void{
            this._isSupportHover = _arg1;
        }
        public function get isThumbIconHasStatus():Boolean{
            return (this._isThumbIconHasStatus);
        }
        public function set isThumbIconHasStatus(_arg1:Boolean):void{
            this._isThumbIconHasStatus = _arg1;
        }
        public function get isThumbIconActive():Boolean{
            if (((this._isThumbIconHasStatus) && ((this._controlBtn.currentFrame == 2)))){
                return (true);
            };
            return (false);
        }
        public function set isThumbIconActive(_arg1:Boolean):void{
            if (this._isThumbIconHasStatus){
                this._controlBtn.gotoAndStop(((_arg1) ? 2 : 1));
            };
        }
        public function get controllBtn():DisplayObject{
            return (this._controlBtn);
        }
        public function get controllType():String{
            return (this._controllType);
        }
        public function set controllType(_arg1:String):void{
            this._controllType = _arg1;
        }
        public function get defLevel():Number{
            return (this._defLevel);
        }
        public function set defLevel(_arg1:Number):void{
            this._defLevel = _arg1;
        }
        public function get aveLevel():Number{
            return (this._aveLevel);
        }
        public function set aveLevel(_arg1:Number):void{
            this._aveLevel = ((_arg1 * 2) / this._barWidth);
        }
        public function get level():Number{
            return (((((this._currentValue * this._aveLevel) * 95) / 100) + this._defLevel));
        }

    }
}//package ctr.setting 
﻿package ctr.filter {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import com.*;
    import com.common.*;
    import eve.*;
    import ctr.setting.*;
    import flash.filters.*;

    public class Filter extends Sprite {

        private var _player:Player;
        private var _nRed:Number = 0.3086;
        private var _nGreen:Number = 0.6094;
        private var _nBlue:Number = 0.082;
        private var _resetAllBtn:Sprite;
        private var _sSaturation:CommonSlider;
        private var _sTint:CommonSlider;
        private var _sBrighten:CommonSlider;
        private var _sContrast:CommonSlider;
        private var _commitButton:SetCommitButton;
        private var _recordFiltersArr:Array;
        private var _filtersArr:Array;
        private var _filtersObj:Object;
        private var _lastTint:Number;
        private var _lastBrighten:Number;
        private var _lastContrast:Number;
        private var _lastSaturation:Number;
        public var _filterMode:FilterMode;

        public function Filter(_arg1:Player){
            this._recordFiltersArr = [];
            this._filtersArr = [];
            this._filtersObj = {};
            super();
            this._player = _arg1;
            this.init();
        }
        private function init():void{
            this._sTint = new CommonSlider();
            this._sTint.title = "色　调";
            this._sTint.x = 30;
            this._sTint.y = 10;
            this._sTint.defLevel = 1;
            this._sTint.aveLevel = 1;
            this._sTint.minValue = -113;
            this._sTint.maxValue = 114;
            this._sTint.snapInterval = 1;
            this._sTint.clickInterval = 1;
            this._sTint.decimalNum = 0;
            this._sTint.isShowToolTip = true;
            this._sTint.isThumbIconHasStatus = true;
            this._sTint.currentValue = 0;
            this._sTint.addEventListener(CommonSlider.CHANGE_VALUE, this.changeFilterHandler);
            this._sBrighten = new CommonSlider();
            addChild(this._sBrighten);
            this._sBrighten.title = "亮　度";
            this._sBrighten.x = 30;
            this._sBrighten.y = 10;
            this._sBrighten.defLevel = 1;
            this._sBrighten.aveLevel = 2;
            this._sBrighten.minValue = -113;
            this._sBrighten.maxValue = 114;
            this._sBrighten.snapInterval = 1;
            this._sBrighten.clickInterval = 1;
            this._sBrighten.decimalNum = 0;
            this._sBrighten.isShowToolTip = true;
            this._sBrighten.isThumbIconHasStatus = true;
            this._sBrighten.currentValue = 0;
            this._sBrighten.addEventListener(CommonSlider.CHANGE_VALUE, this.changeFilterHandler);
            this._sContrast = new CommonSlider();
            addChild(this._sContrast);
            this._sContrast.title = "对比度";
            this._sContrast.x = 30;
            this._sContrast.y = (26 + 10);
            this._sContrast.defLevel = 0.1;
            this._sContrast.aveLevel = 0.9;
            this._sContrast.minValue = -113;
            this._sContrast.maxValue = 114;
            this._sContrast.snapInterval = 1;
            this._sContrast.clickInterval = 1;
            this._sContrast.decimalNum = 0;
            this._sContrast.isShowToolTip = true;
            this._sContrast.isThumbIconHasStatus = true;
            this._sContrast.currentValue = 0;
            this._sContrast.addEventListener(CommonSlider.CHANGE_VALUE, this.changeFilterHandler);
            this._sSaturation = new CommonSlider();
            addChild(this._sSaturation);
            this._sSaturation.title = "饱和度";
            this._sSaturation.x = 30;
            this._sSaturation.y = ((26 * 2) + 10);
            this._sSaturation.defLevel = 1;
            this._sSaturation.aveLevel = 1;
            this._sSaturation.minValue = -113;
            this._sSaturation.maxValue = 114;
            this._sSaturation.snapInterval = 1;
            this._sSaturation.clickInterval = 1;
            this._sSaturation.decimalNum = 0;
            this._sSaturation.isShowToolTip = true;
            this._sSaturation.isThumbIconHasStatus = true;
            this._sSaturation.currentValue = 0;
            this._sSaturation.addEventListener(CommonSlider.CHANGE_VALUE, this.changeFilterHandler);
            this._lastTint = this._sTint.currentValue;
            this._lastBrighten = this._sBrighten.currentValue;
            this._lastContrast = this._sContrast.currentValue;
            this._lastSaturation = this._sSaturation.currentValue;
            this._filterMode = new FilterMode();
            addChild(this._filterMode);
            this._filterMode.y = 85;
            this._filterMode.x = (((this.width - this._filterMode.width) / 2) + 20);
            this._filterMode.addEventListener(EventFilter.FILTER_MINGLIANG, this.filterModeEventHandler);
            this._filterMode.addEventListener(EventFilter.FILTER_ROUHUO, this.filterModeEventHandler);
            this._filterMode.addEventListener(EventFilter.FILTER_FUGU, this.filterModeEventHandler);
            this._filterMode.addEventListener(EventFilter.FILTER_BIAOZHUN, this.filterModeEventHandler);
            this._commitButton = new SetCommitButton();
            this._commitButton.y = 141;
            this._commitButton.x = 170;
            this._commitButton.addEventListener(MouseEvent.CLICK, this.commitButtonClickHandler);
            addChild(this._commitButton);
        }
        private function commitButtonClickHandler(_arg1:MouseEvent):void{
            this.commitInterfaceFunction();
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "set"));
        }
        private function filterModeEventHandler(_arg1:EventFilter):void{
            switch (_arg1.type){
                case "filter_mingLiang":
                    this.filterModeMingLiang();
                    break;
                case "filter_rouHuo":
                    this.filterModeRouHuo();
                    break;
                case "filter_fugu":
                    this.filterModeFuGu();
                    break;
                case "filter_biaoZhun":
                    this.filterModeBiaoZhun();
                    break;
            };
        }
        private function changeFilterHandler(_arg1:Event):void{
            var _local2:Number = _arg1.currentTarget.level;
            switch (_arg1.target){
                case this._sTint:
                    this.cmfTint(_local2);
                    break;
                case this._sBrighten:
                    this.cmfBrighten(_local2);
                    break;
                case this._sContrast:
                    this.cmfContrast(_local2);
                    break;
                case this._sSaturation:
                    this.cmfSaturation(_local2);
                    break;
            };
            JTracer.sendMessage(((((((("Filter -> 饱和度, 亮度, 对比度, 色相: " + this._sSaturation.currentValue) + ", ") + this._sBrighten.currentValue) + ", ") + this._sContrast.currentValue) + ", ") + this._sTint.currentValue));
        }
        private function filterModeBiaoZhun():void{
            this._filterMode.changeButtonStatus("filter_biaoZhun");
            this._sTint.currentValue = 0;
            this._sBrighten.currentValue = 0;
            this._sContrast.currentValue = 0;
            this._sSaturation.currentValue = 0;
        }
        private function filterModeMingLiang():void{
            this._filterMode.changeButtonStatus("filter_mingLiang");
            this._sTint.currentValue = 17;
            this._sBrighten.currentValue = 11;
            this._sContrast.currentValue = 0;
            this._sSaturation.currentValue = 17;
        }
        private function filterModeRouHuo():void{
            this._filterMode.changeButtonStatus("filter_rouHuo");
            this._sTint.currentValue = 0;
            this._sBrighten.currentValue = 0;
            this._sContrast.currentValue = 0;
            this._sSaturation.currentValue = -15;
        }
        private function filterModeFuGu():void{
            this._filterMode.changeButtonStatus("filter_fuGu");
            this._sTint.currentValue = 0;
            this._sBrighten.currentValue = 0;
            this._sContrast.currentValue = 0;
            this._sSaturation.currentValue = -113;
        }
        private function resetAllHandler():void{
            this._player.filters = [];
            this._filtersArr = [];
            this._filtersObj = {};
            this._sTint.currentValue = this._lastTint;
            this._sBrighten.currentValue = this._lastBrighten;
            this._sContrast.currentValue = this._lastContrast;
            this._sSaturation.currentValue = this._lastSaturation;
            this.recordAllPosition();
        }
        private function recordAllPosition():void{
            this._lastTint = this._sTint.currentValue;
            this._lastBrighten = this._sBrighten.currentValue;
            this._lastContrast = this._sContrast.currentValue;
            this._lastSaturation = this._sSaturation.currentValue;
            if (this._recordFiltersArr != this._filtersArr){
                this._recordFiltersArr = this._filtersArr;
                GlobalVars.instance.colorChanged = true;
            };
        }
        private function restoreAllPosition():void{
            this._sSaturation.currentValue = this._lastSaturation;
            this._sBrighten.currentValue = this._lastBrighten;
            this._sContrast.currentValue = this._lastContrast;
            this._sTint.currentValue = this._lastTint;
            this._filtersArr = this._recordFiltersArr;
            this._player.filters = this._filtersArr;
        }
        private function cmfDigitalNegative():void{
            var _local1:ColorMatrixFilter = new ColorMatrixFilter([-1, 0, 0, 0, 0xFF, 0, -1, 0, 0, 0xFF, 0, 0, -1, 0, 0xFF, 0, 0, 0, 1, 0]);
            this._player.filters = [_local1];
        }
        private function cmfGrayscale():void{
            var _local1:ColorMatrixFilter = new ColorMatrixFilter([this._nRed, this._nGreen, this._nBlue, 0, 0, this._nRed, this._nGreen, this._nBlue, 0, 0, this._nRed, this._nGreen, this._nBlue, 0, 0, 0, 0, 0, 1, 0]);
            this._player.filters = [_local1];
        }
        private function cmfSaturation(_arg1:Number=1):void{
            var _local2:Number = (((1 - _arg1) * this._nRed) + _arg1);
            var _local3:Number = ((1 - _arg1) * this._nGreen);
            var _local4:Number = ((1 - _arg1) * this._nBlue);
            var _local5:Number = ((1 - _arg1) * this._nRed);
            var _local6:Number = (((1 - _arg1) * this._nGreen) + _arg1);
            var _local7:Number = ((1 - _arg1) * this._nBlue);
            var _local8:Number = ((1 - _arg1) * this._nRed);
            var _local9:Number = ((1 - _arg1) * this._nGreen);
            var _local10:Number = (((1 - _arg1) * this._nBlue) + _arg1);
            var _local11:ColorMatrixFilter = new ColorMatrixFilter([_local2, _local3, _local4, 0, 0, _local5, _local6, _local7, 0, 0, _local8, _local9, _local10, 0, 0, 0, 0, 0, 1, 0]);
            this._filtersObj["fStaturation"] = _local11;
            this.objToArray();
        }
        private function cmfTint(_arg1:Number):void{
            var _local2:ColorMatrixFilter = new ColorMatrixFilter([_arg1, 0, 0, 0, 0, 0, _arg1, 0, 0, 0, 0, 0, _arg1, 0, 0, 0, 0, 0, _arg1, 0]);
            this._filtersObj["fTint"] = _local2;
            this.objToArray();
        }
        private function cmfBrighten(_arg1:Number=1):void{
            var _local2:ColorMatrixFilter = new ColorMatrixFilter([_arg1, 0, 0, 0, 0, 0, _arg1, 0, 0, 0, 0, 0, _arg1, 0, 0, 0, 0, 0, _arg1, 0]);
            this._filtersObj["fBrighten"] = _local2;
            this.objToArray();
        }
        private function cmfContrast(_arg1:Number=0.1):void{
            var _local2:Number = (_arg1 * 11);
            var _local3:Number = (63.5 - (_arg1 * 698.5));
            var _local4:ColorMatrixFilter = new ColorMatrixFilter([_local2, 0, 0, 0, _local3, 0, _local2, 0, 0, _local3, 0, 0, _local2, 0, _local3, 0, 0, 0, 1, 0]);
            this._filtersObj["fContrast"] = _local4;
            this.objToArray();
        }
        private function objToArray():void{
            this._filtersArr = [];
            if (((this._filtersObj["fContrast"]) && (!((this._filtersObj["fContrast"] == null))))){
                this._filtersArr.push(this._filtersObj["fContrast"]);
            };
            if (((this._filtersObj["fBrighten"]) && (!((this._filtersObj["fBrighten"] == null))))){
                this._filtersArr.push(this._filtersObj["fBrighten"]);
            };
            if (((this._filtersObj["fTint"]) && (!((this._filtersObj["fTint"] == null))))){
                this._filtersArr.push(this._filtersObj["fTint"]);
            };
            if (((this._filtersObj["fStaturation"]) && (!((this._filtersObj["fStaturation"] == null))))){
                this._filtersArr.push(this._filtersObj["fStaturation"]);
            };
            this._player.filters = this._filtersArr;
        }
        public function get isThumbIconActive():Boolean{
            if (((((((this._sTint.isThumbIconActive) || (this._sBrighten.isThumbIconActive))) || (this._sContrast.isThumbIconActive))) || (this._sSaturation.isThumbIconActive))){
                return (true);
            };
            return (false);
        }
        public function subDeltaByMouse(_arg1:Number):void{
            if (this._sTint.isThumbIconActive){
                this._sTint.subTimeDelta(_arg1, true, this._sTint.controllBtn);
            };
            if (this._sBrighten.isThumbIconActive){
                this._sBrighten.subTimeDelta(_arg1, true, this._sBrighten.controllBtn);
            };
            if (this._sContrast.isThumbIconActive){
                this._sContrast.subTimeDelta(_arg1, true, this._sContrast.controllBtn);
            };
            if (this._sSaturation.isThumbIconActive){
                this._sSaturation.subTimeDelta(_arg1, true, this._sSaturation.controllBtn);
            };
        }
        public function addDeltaByMouse(_arg1:Number):void{
            if (this._sTint.isThumbIconActive){
                this._sTint.addTimeDelta(_arg1, true, this._sTint.controllBtn);
            };
            if (this._sBrighten.isThumbIconActive){
                this._sBrighten.addTimeDelta(_arg1, true, this._sBrighten.controllBtn);
            };
            if (this._sContrast.isThumbIconActive){
                this._sContrast.addTimeDelta(_arg1, true, this._sContrast.controllBtn);
            };
            if (this._sSaturation.isThumbIconActive){
                this._sSaturation.addTimeDelta(_arg1, true, this._sSaturation.controllBtn);
            };
        }
        public function set showFace(_arg1:Boolean):void{
            if (_arg1 == false){
                this.visible = false;
            } else {
                this.visible = true;
                this.commitInterfaceFunction();
            };
        }
        public function initRecordStatus():void{
            this.resetAllHandler();
        }
        public function commitInterfaceFunction():void{
            this.recordAllPosition();
        }
        public function cancleInterfaceFunction():void{
            this.restoreAllPosition();
        }

    }
}//package ctr.filter 
﻿package ctr.filter {
    import flash.events.*;
    import flash.display.*;
    import eve.*;
    import flash.text.*;

    public class FilterMode extends Sprite {

        private var _filterModeBtnArr:Array;
        private var _restoreButton:SimpleButton;
        private var _cacheButton:SimpleButton;

        public function FilterMode(){
            this._filterModeBtnArr = [];
            super();
            var _local1:TextField = new TextField();
            _local1.text = "色彩模式：";
            _local1.width = 60;
            _local1.height = 23;
            _local1.setTextFormat(new TextFormat("宋体", 12, 0xC1C1C1));
            _local1.selectable = false;
            this._filterModeBtnArr.push({
                btn:this.drawFilterModeButton(SetMingLiangButton, this.actionFunction),
                mode:"明亮",
                eve:EventFilter.FILTER_MINGLIANG
            });
            this._filterModeBtnArr.push({
                btn:this.drawFilterModeButton(SetRouHuoButton, this.actionFunction),
                mode:"柔和",
                eve:EventFilter.FILTER_ROUHUO
            });
            this._filterModeBtnArr.push({
                btn:this.drawFilterModeButton(SetFuGuButton, this.actionFunction),
                mode:"复古",
                eve:EventFilter.FILTER_FUGU
            });
            this._filterModeBtnArr.push({
                btn:this.drawFilterModeButton(SetBiaoZhunButton, this.actionFunction),
                mode:"标准",
                eve:EventFilter.FILTER_BIAOZHUN
            });
            this.setButtonPosition();
            this._restoreButton = this._filterModeBtnArr[0]["btn"];
            this.changeButtonStatusWidthTarget(this._filterModeBtnArr[0]["btn"]);
        }
        private function setButtonPosition():void{
            var _local1:int;
            while (_local1 < this._filterModeBtnArr.length) {
                this._filterModeBtnArr[_local1]["btn"].x = (_local1 * 70);
                addChild(this._filterModeBtnArr[_local1]["btn"]);
                _local1++;
            };
        }
        private function drawFilterModeButton(_arg1:Class, _arg2:Function):SimpleButton{
            var classRef:* = _arg1;
            var action:* = _arg2;
            var btnSprite:* = new (classRef)();
            btnSprite.addEventListener(MouseEvent.CLICK, function (_arg1:MouseEvent):void{
                action(_arg1.currentTarget);
            });
            return (btnSprite);
        }
        private function actionFunction(_arg1:SimpleButton):void{
            var _local2:int;
            while (_local2 < this._filterModeBtnArr.length) {
                if (this._filterModeBtnArr[_local2]["btn"] == _arg1){
                    this._cacheButton = _arg1;
                    dispatchEvent(new EventFilter(this._filterModeBtnArr[_local2]["eve"]));
                };
                _local2++;
            };
        }
        private function changeButtonStatusWidthTarget(_arg1:SimpleButton):void{
            var _local2:int;
            while (_local2 < this._filterModeBtnArr.length) {
                if (this._filterModeBtnArr[_local2]["btn"] == _arg1){
                    this._cacheButton = _arg1;
                };
                _local2++;
            };
        }
        public function resizeButton():void{
        }
        public function restoreButtonFunction():void{
        }
        public function commitButtonFunction():void{
            this._restoreButton = this._cacheButton;
        }
        public function changeButtonStatus(_arg1:String):void{
            var _local2:SimpleButton;
            switch (_arg1){
                case "filter_mingLiang":
                    _local2 = this._filterModeBtnArr[0]["btn"];
                    break;
                case "filter_rouHuo":
                    _local2 = this._filterModeBtnArr[1]["btn"];
                    break;
                case "filter_fugu":
                    _local2 = this._filterModeBtnArr[2]["btn"];
                    break;
                case "filter_biaoZhun":
                    _local2 = this._filterModeBtnArr[3]["btn"];
                    break;
                default:
                    _local2 = this._filterModeBtnArr[3]["btn"];
            };
            this.changeButtonStatusWidthTarget(_local2);
        }

    }
}//package ctr.filter 
﻿package ctr.share {
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.common.*;
    import eve.*;
    import flash.text.*;
    import flash.system.*;

    public class ShareFace extends MovieClip {

        public var url_txt:TextField;
        public var copy_btn:SimpleButton;
        public var tips_txt:TextField;
        public var close_btn:SetCloseButton;

        public function ShareFace(){
            this.visible = false;
            this.close_btn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
            this.copy_btn.addEventListener(MouseEvent.CLICK, this.onCopyClick);
        }
        public function showFace(_arg1:Boolean):void{
            this.visible = _arg1;
        }
        public function setPosition():void{
            this.x = int(((stage.stageWidth - 460) / 2));
            this.y = int((((stage.stageHeight - 228) - 33) / 2));
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "share"));
        }
        private function onCopyClick(_arg1:MouseEvent):void{
            if (this.url_txt.text.length > 0){
                System.setClipboard(this.url_txt.text);
                this.tips_txt.text = "复制成功";
                setTimeout(this.clearTips, 1000);
                Tools.stat("b=share");
            };
        }
        private function clearTips():void{
            this.tips_txt.text = "";
        }

    }
}//package ctr.share 
﻿package ctr.fileList {
    import flash.events.*;
    import flash.display.*;

    public class PageNavigator extends Sprite {

        private var _totalNum:uint;
        private var _pagePerNum:uint;
        private var _totalPage:uint;
        private var _showItemNum:uint = 7;
        private var _currentPageNum:uint;
        private var _labelArray:Array;

        public function setOuterParam(_arg1:uint, _arg2:uint, _arg3:uint):void{
            var _local4:uint;
            var _local5:String;
            var _local6:uint;
            var _local7:uint;
            this._totalNum = _arg1;
            this._totalPage = _arg2;
            this._pagePerNum = _arg3;
            this._labelArray = [];
            var _local8:uint = (this._totalNum - ((this._totalPage - 1) * this._pagePerNum));
            _local4 = 0;
            while (_local4 < this._totalPage) {
                _local6 = ((_local4 * this._pagePerNum) + 1);
                if (_local4 == (this._totalPage - 1)){
                    _local7 = ((_local4 * this._pagePerNum) + _local8);
                } else {
                    _local7 = ((_local4 * this._pagePerNum) + this._pagePerNum);
                };
                _local5 = ((_local6 + "-") + _local7);
                this._labelArray.push(_local5);
                _local4++;
            };
        }
        public function set showItemNum(_arg1:Number):void{
            this._showItemNum = _arg1;
        }
        private function update():void{
            var _local1:PageNavItem;
            var _local6:uint;
            var _local7:PageNavItem;
            var _local8:PageNavItem;
            var _local9:PageNavItem;
            while (this.numChildren) {
                _local1 = (this.removeChildAt(0) as PageNavItem);
                _local1 = null;
            };
            var _local2:uint = Math.floor(((this._showItemNum - 2) / 2));
            var _local3:uint = Math.max(1, (this._currentPageNum - _local2));
            var _local4:uint = Math.max(1, ((this._totalPage - 1) - (this._showItemNum - 2)));
            _local3 = Math.min(_local3, _local4);
            var _local5:uint = Math.min(this._showItemNum, this._labelArray.length);
            var _local10:Number = 0;
            var _local11:uint;
            var _local12:uint = 55;
            var _local13:uint = 5;
            _local6 = 0;
            while (_local6 < _local5) {
                _local7 = new PageNavItem(_local12);
                if (_local6 == 0){
                    _local7.pageNum = _local6;
                    _local7.setLabel(this._labelArray[_local6]);
                    _local7.enabled = true;
                    _local7.x = _local10;
                    _local10 = ((_local7.x + _local7.width) + _local11);
                    if (this._labelArray.length > 1){
                        _local9 = new PageNavItem(_local13);
                        _local9.x = _local10;
                        _local9.setLabel("|");
                        addChild(_local9);
                        _local10 = ((_local9.x + _local9.width) + _local11);
                    };
                } else {
                    if (_local6 == (_local5 - 1)){
                        _local7.pageNum = (this._totalPage - 1);
                        _local7.setLabel(this._labelArray[(this._totalPage - 1)]);
                        _local7.enabled = true;
                        _local7.x = _local10;
                        _local10 = ((_local7.x + _local7.width) + _local11);
                    } else {
                        _local7.pageNum = ((_local3 + _local6) - 1);
                        _local7.setLabel(this._labelArray[((_local3 + _local6) - 1)]);
                        _local7.enabled = true;
                        if ((((_local6 == 1)) && ((_local3 > 1)))){
                            _local8 = new PageNavItem(_local12);
                            _local8.x = _local10;
                            _local8.setLabel("......");
                            addChild(_local8);
                            _local10 = ((_local8.x + _local8.width) + _local11);
                            _local9 = new PageNavItem(_local13);
                            _local9.x = _local10;
                            _local9.setLabel("|");
                            addChild(_local9);
                            _local10 = ((_local9.x + _local9.width) + _local11);
                            _local7.x = _local10;
                            _local10 = ((_local7.x + _local7.width) + _local11);
                            _local9 = new PageNavItem(_local13);
                            _local9.x = _local10;
                            _local9.setLabel("|");
                            addChild(_local9);
                            _local10 = ((_local9.x + _local9.width) + _local11);
                        } else {
                            if ((((_local6 == (_local5 - 2))) && (((((_local3 + _local5) - 2) - 1) < (this._totalPage - 2))))){
                                _local7.x = _local10;
                                _local10 = ((_local7.x + _local7.width) + _local11);
                                _local9 = new PageNavItem(_local13);
                                _local9.x = _local10;
                                _local9.setLabel("|");
                                addChild(_local9);
                                _local10 = ((_local9.x + _local9.width) + _local11);
                                _local8 = new PageNavItem(_local12);
                                _local8.x = _local10;
                                _local8.setLabel("......");
                                addChild(_local8);
                                _local10 = ((_local8.x + _local8.width) + _local11);
                                _local9 = new PageNavItem(_local13);
                                _local9.x = _local10;
                                _local9.setLabel("|");
                                addChild(_local9);
                                _local10 = ((_local9.x + _local9.width) + _local11);
                            } else {
                                _local7.x = _local10;
                                _local10 = ((_local7.x + _local7.width) + _local11);
                                _local9 = new PageNavItem(_local13);
                                _local9.x = _local10;
                                _local9.setLabel("|");
                                addChild(_local9);
                                _local10 = ((_local9.x + _local9.width) + _local11);
                            };
                        };
                    };
                };
                if (_local7.pageNum == this._currentPageNum){
                    _local7.selected = true;
                } else {
                    _local7.selected = false;
                };
                _local7.addEventListener("SelectPageItem", this.selectPageItem);
                addChild(_local7);
                _local6++;
            };
        }
        public function set currentPageNum(_arg1:uint):void{
            this._currentPageNum = _arg1;
            this.update();
        }
        public function get currentPageNum():uint{
            return (this._currentPageNum);
        }
        public function clear():void{
            while (this.numChildren) {
                this.removeChildAt(0);
            };
        }
        private function selectPageItem(_arg1:Event):void{
            var _local2:PageNavItem = (_arg1.currentTarget as PageNavItem);
            this.currentPageNum = _local2.pageNum;
            dispatchEvent(new Event("SelectPage"));
        }

    }
}//package ctr.fileList 
﻿package ctr.fileList {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.common.*;
    import com.greensock.*;
    import com.serialization.json.*;
    import flash.text.*;
    import flash.external.*;

    public class FileListFace extends Sprite {

        private var _prevBtn:PageNavBtn;
        private var _nextBtn:PageNavBtn;
        private var _itemsPerPage:uint = 0;
        private var _curPageNum:uint = 0;
        private var _curVodPageNum:uint = 0;
        private var _totalPageNum:uint;
        private var _itemArray:Array;
        private var _listLength:uint;
        private var _listArray:Array;
        private var _padding:Number = 5;
        private var _listWidth:Number = 0;
        private var _itemWidth:Number = 83;
        private var _isPrevClick:Boolean;
        private var _pageNavigator:PageNavigator;
        private var _closeBtn:CloseBtn;
        private var _totalText:TextField;
        private var _totalTF:TextFormat;
        private var _mainMc:PlayerCtrl;
        private var _nextID:int;
        private var _spacing:Number = 0;
        private var _paddingTop:Number = 5;
        private var _reqOffset:uint = 0;
        private var _reqNum:uint = 30;
        private var __old__imgLoader:URLLoader;
        private var __old__imgDictionary:Dictionary;

        public function FileListFace(_arg1:PlayerCtrl){
            this._itemArray = [];
            this._listArray = [];
            super();
            this._mainMc = _arg1;
            this.visible = false;
            this._prevBtn = new PageNavBtn();
            this._prevBtn.rotation = 180;
            this._prevBtn.gotoAndStop(3);
            this._prevBtn.x = ((10 + int((this._prevBtn.width / 2))) + this._spacing);
            this._prevBtn.y = (this._paddingTop + 55);
            this._prevBtn.buttonMode = true;
            this._prevBtn.mouseChildren = false;
            this._prevBtn.mouseEnabled = false;
            this._prevBtn.addEventListener(MouseEvent.CLICK, this.onPrevClick);
            this._prevBtn.addEventListener(MouseEvent.MOUSE_OVER, this.onBtnOver);
            this._prevBtn.addEventListener(MouseEvent.MOUSE_OUT, this.onBtnOut);
            addChild(this._prevBtn);
            this._nextBtn = new PageNavBtn();
            this._nextBtn.gotoAndStop(3);
            this._nextBtn.y = (this._paddingTop + 55);
            this._nextBtn.buttonMode = true;
            this._nextBtn.mouseChildren = false;
            this._nextBtn.mouseEnabled = false;
            this._nextBtn.addEventListener(MouseEvent.CLICK, this.onNextClick);
            this._nextBtn.addEventListener(MouseEvent.MOUSE_OVER, this.onBtnOver);
            this._nextBtn.addEventListener(MouseEvent.MOUSE_OUT, this.onBtnOut);
            addChild(this._nextBtn);
            this._closeBtn = new CloseBtn();
            this._closeBtn.addEventListener(MouseEvent.CLICK, this.onCloseClick);
            this._closeBtn.y = 4;
            addChild(this._closeBtn);
            this._totalTF = new TextFormat();
            this._totalTF.color = 0x454545;
            this._totalTF.size = 13;
            this._totalTF.font = "宋体";
            this._totalText = new TextField();
            this._totalText.selectable = false;
            this._totalText.defaultTextFormat = this._totalTF;
            this._totalText.x = (20 + this._spacing);
            this._totalText.y = this._paddingTop;
            addChild(this._totalText);
            this._pageNavigator = new PageNavigator();
            this._pageNavigator.addEventListener("SelectPage", this.selectPage);
            this._pageNavigator.y = this._paddingTop;
            addChild(this._pageNavigator);
            this.__old__imgLoader = new URLLoader();
            this.__old__imgLoader.addEventListener(Event.COMPLETE, this.__old__onImgLoaded);
            this.__old__imgLoader.addEventListener(IOErrorEvent.IO_ERROR, this.__old__onImgIOError);
            this.__old__imgLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.__old__onImgSecurityError);
        }
        public function resetReqOffset():void{
            this._reqOffset = 0;
        }
        public function resetListArray():void{
            this._listArray = [];
        }
        public function loadFileList():void{
            var _local2:String;
            var _local3:URLRequest;
            var _local4:URLLoader;
            var _local1:String = Tools.getUserInfo("urlType");
            if (_local1 == "url"){
                JTracer.sendMessage("FileListFace -> start load url file");
                this._listArray = [{
                    gcid:Tools.getUserInfo("gcid"),
                    url_hash:Tools.getUserInfo("url_hash"),
                    name:Tools.getUserInfo("name"),
                    index:0
                }];
                this._listLength = 1;
                this.updateView();
            } else {
                _local2 = ((((("http://i.vod.xunlei.com/req_subBT/info_hash/" + Tools.getUserInfo("info_hash")) + "/req_num/") + this._reqNum) + "/req_offset/") + this._reqOffset);
                _local3 = new URLRequest(_local2);
                JTracer.sendMessage(((("FileListFace -> start load " + _local1) + " file, url:") + _local2));
                _local4 = new URLLoader();
                _local4.addEventListener(Event.COMPLETE, this.onListLoaded);
                _local4.addEventListener(IOErrorEvent.IO_ERROR, this.onListIOError);
                _local4.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onListSecurityError);
                _local4.load(_local3);
            };
        }
        public function clear():void{
            this._prevBtn.mouseEnabled = false;
            this._nextBtn.mouseEnabled = false;
            this._totalText.text = "";
            this._pageNavigator.clear();
            this.clearAllItem();
            this._listArray = [];
        }
        public function get filelistLength():uint{
            return (((this._listLength) || (0)));
        }
        public function setPosition():void{
            this.graphics.clear();
            this.graphics.beginFill(0, 0.8);
            this.graphics.drawRect(this._spacing, 0, (stage.stageWidth - (this._spacing * 2)), (145 + this._paddingTop));
            this.graphics.endFill();
            this.y = ((stage.stageHeight - 145) - this._paddingTop);
            this._closeBtn.x = int(((stage.stageWidth - this._spacing) - 20));
            this._nextBtn.x = int((((stage.stageWidth - this._spacing) - 10) - (this._nextBtn.width / 2)));
            this._listWidth = ((this._nextBtn.x - this._prevBtn.x) - this._prevBtn.width);
            this._itemsPerPage = (Math.floor((this._listWidth / this._itemWidth)) - 1);
            if (this.visible){
                this.getCurrentVodPageNum();
                this._curPageNum = this._curVodPageNum;
                this._isPrevClick = true;
                this.updateView();
            };
        }
        public function hide(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.y = ((stage.stageHeight - 110) - this._paddingTop);
            } else {
                TweenLite.to(this, 0.3, {y:((stage.stageHeight - 110) - this._paddingTop)});
            };
        }
        public function show(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.y = ((stage.stageHeight - 145) - this._paddingTop);
            } else {
                TweenLite.to(this, 0.3, {y:((stage.stageHeight - 145) - this._paddingTop)});
            };
        }
        public function showFace(_arg1:Boolean):void{
            this.visible = _arg1;
            if (_arg1){
                this.getCurrentVodPageNum();
                this._curPageNum = this._curVodPageNum;
                this._isPrevClick = true;
                this.updateView();
            };
        }
        public function get isHasNext():Boolean{
            var _local1:int = this.getIndex();
            if ((((_local1 == -1)) || ((_local1 >= (this._listLength - 1))))){
                this._nextID = -1;
                return (false);
            };
            this._nextID = _local1;
            return (true);
        }
        public function playNext():void{
            var _local1:Object = this._listArray[(this._nextID + 1)];
            this.exchangeVideo(_local1);
        }
        private function getIndex():int{
            var _local1:*;
            for (_local1 in this._listArray) {
                if ((((Tools.getUserInfo("url_hash") == this._listArray[_local1].url_hash)) || ((Tools.getUserInfo("index") == this._listArray[_local1].index)))){
                    return (int(_local1));
                };
            };
            return (-1);
        }
        private function __old__onImgLoaded(_arg1:Event):void{
            var _local7:*;
            var _local8:Object;
            var _local9:*;
            var _local10:ListItem;
            var _local11:int;
            var _local12:String;
            var _local2:String = _arg1.target.data;
            _local2 = _local2.substring(4, (_local2.length - 1));
            var _local3:Object = JSON.deserialize(_local2);
            if (((((!(_local3)) || (!(_local3.resp)))) || (!(_local3.resp.screenshot_list)))){
                return;
            };
            this.__old__imgDictionary = new Dictionary();
            var _local4:Object = _local3.resp.screenshot_list;
            var _local5:String = ("_X" + GlobalVars.instance.screenshot_size);
            var _local6:* = "";
            for (_local7 in _local4) {
                _local8 = _local4[_local7];
                _local11 = parseInt(_local8.gcid.charAt(0), 15);
                _local11 = (_local11 % 5);
                _local12 = "";
                if (Tools.getUserInfo("urlType") == "url"){
                    this.__old__imgDictionary[0] = _local8.smallshot_url;
                } else {
                    this.__old__imgDictionary[_local8.idx] = _local8.smallshot_url;
                };
            };
            for (_local9 in this._itemArray) {
                _local10 = (this._itemArray[_local9] as ListItem);
                if (!_local10.isImgLoaded){
                    if (Tools.getUserInfo("urlType") == "url"){
                        _local10.setImgInfo(this.__old__imgDictionary[0]);
                    } else {
                        _local10.setImgInfo(this.__old__imgDictionary[_local10.itemObj.index]);
                    };
                };
            };
        }
        private function __old__onImgIOError(_arg1:IOErrorEvent):void{
        }
        private function __old__onImgSecurityError(_arg1:SecurityErrorEvent):void{
        }
        private function updateView():void{
            this._totalText.text = (((this._listLength == 0)) ? (("共" + this._listLength) + "个视频") : (("共" + this._listLength) + "个视频，"));
            this._totalText.width = (this._totalText.textWidth + 5);
            this._totalText.height = (this._totalText.textHeight + 5);
            this._pageNavigator.x = ((this._totalText.x + this._totalText.width) - 20);
            this._totalPageNum = Math.ceil((this._listLength / this._itemsPerPage));
            this._pageNavigator.setOuterParam(this._listLength, this._totalPageNum, this._itemsPerPage);
            this._prevBtn.mouseEnabled = false;
            if (this._totalPageNum > 1){
                this._nextBtn.mouseEnabled = true;
            } else {
                this._nextBtn.mouseEnabled = false;
            };
            this.killAllAlphaTween();
            this._pageNavigator.showItemNum = Math.max(2, (Math.floor(((stage.stageWidth - this._pageNavigator.x) / 62)) - 2));
            this._pageNavigator.currentPageNum = this._curPageNum;
            this.setBtnStatus();
            if (GlobalVars.instance.isUseXlpanKanimg){
                JTracer.sendMessage("use xlpan kanimg");
                this.updateFileList();
            } else {
                JTracer.sendMessage("use old screenshot_list api.");
                this.__old__updateFileList();
            };
            this.applyAlphaTween();
        }
        private function onListLoaded(_arg1:Event):void{
            JTracer.sendMessage(((("FileListFace -> " + Tools.getUserInfo("urlType")) + " list loaded, req_offset:") + this._reqOffset));
            var _local2:String = _arg1.target.data;
            var _local3:Object = JSON.deserialize(_local2);
            if (((((!(_local3)) || (!(_local3.resp)))) || (!(_local3.resp.subfile_list)))){
                return;
            };
            JTracer.sendMessage((("FileListFace -> parse " + Tools.getUserInfo("urlType")) + " list json complete"));
            if (_local3.resp.subfile_list.length > 0){
                this._listArray = this._listArray.concat(_local3.resp.subfile_list);
                this._listLength = _local3.resp.record_num;
                if (this._listArray.length < this._listLength){
                    this._reqOffset = (this._reqOffset + this._reqNum);
                    this.loadFileList();
                };
            };
        }
        private function onListIOError(_arg1:IOErrorEvent):void{
        }
        private function onListSecurityError(_arg1:SecurityErrorEvent):void{
        }
        private function getCurrentVodPageNum():void{
            var _local1:*;
            var _local2:Object;
            for (_local1 in this._listArray) {
                _local2 = this._listArray[_local1];
                if ((((_local2.url_hash == Tools.getUserInfo("url_hash"))) || ((_local2.index == Tools.getUserInfo("index"))))){
                    this._curVodPageNum = Math.floor((_local1 / this._itemsPerPage));
                    break;
                };
            };
        }
        private function onPrevClick(_arg1:MouseEvent):void{
            this._curPageNum--;
            this._isPrevClick = true;
            this.updateView();
        }
        private function onNextClick(_arg1:MouseEvent):void{
            this._curPageNum++;
            this._isPrevClick = false;
            this.updateView();
        }
        private function selectPage(_arg1:Event):void{
            this._curPageNum = this._pageNavigator.currentPageNum;
            this._isPrevClick = true;
            this.updateView();
        }
        private function onCloseClick(_arg1:MouseEvent):void{
            this.showFace(false);
        }
        private function onBtnOver(_arg1:MouseEvent):void{
            var _local2:MovieClip = (_arg1.currentTarget as MovieClip);
            if (_local2.mouseEnabled){
                _local2.gotoAndStop(2);
            };
        }
        private function onBtnOut(_arg1:MouseEvent):void{
            var _local2:MovieClip = (_arg1.currentTarget as MovieClip);
            if (_local2.mouseEnabled){
                _local2.gotoAndStop(1);
            };
        }
        private function setBtnStatus():void{
            if (this._curPageNum < 1){
                this._prevBtn.gotoAndStop(3);
                this._prevBtn.mouseEnabled = false;
            } else {
                this._prevBtn.gotoAndStop(1);
                this._prevBtn.mouseEnabled = true;
            };
            if (this._curPageNum < (this._totalPageNum - 1)){
                this._nextBtn.gotoAndStop(1);
                this._nextBtn.mouseEnabled = true;
            } else {
                this._nextBtn.gotoAndStop(3);
                this._nextBtn.mouseEnabled = false;
            };
        }
        private function updateFileList():void{
            var _local3:uint;
            var _local4:ListItem;
            var _local6:Object;
            var _local8:String;
            var _local10:String;
            var _local11:*;
            var _local12:String;
            var _local13:int;
            this.clearAllItem();
            if (this._listArray.length == 0){
                return;
            };
            var _local1:uint = (this._curPageNum * this._itemsPerPage);
            var _local2:uint = Math.min(((this._curPageNum + 1) * this._itemsPerPage), this._listLength);
            var _local5:Number = (((this._listWidth - (2 * this._padding)) - (this._itemsPerPage * this._itemWidth)) / (this._itemsPerPage - 1));
            var _local7:Array = [];
            var _local9:Number = (((this._listWidth - (2 * this._padding)) - (((_local2 - _local1) * (this._itemWidth + _local5)) - _local5)) / 2);
            _local3 = _local1;
            while (_local3 < _local2) {
                _local6 = this._listArray[_local3];
                _local4 = new ListItem();
                _local4.setItemInfo(_local6, _local3);
                _local4.x = Math.round((((this._prevBtn.x + (this._prevBtn.width / 2)) + this._padding) + ((this._itemWidth + _local5) * (_local3 - _local1))));
                _local4.y = (this._paddingTop + 25);
                _local4.alpha = 0;
                if ((((_local6.url_hash == Tools.getUserInfo("url_hash"))) || ((_local6.index == Tools.getUserInfo("index"))))){
                    _local4.selected = true;
                    _local4.buttonMode = false;
                    _local4.removeEventListener(MouseEvent.CLICK, this.onItemClick);
                } else {
                    _local4.selected = false;
                    _local4.buttonMode = true;
                    _local4.addEventListener(MouseEvent.CLICK, this.onItemClick);
                };
                _local4.addEventListener(MouseEvent.MOUSE_OVER, this.onItemOver);
                _local4.addEventListener(MouseEvent.MOUSE_OUT, this.onItemOut);
                _local4.addEventListener(MouseEvent.MOUSE_MOVE, this.onItemMove);
                addChildAt(_local4, 0);
                this._itemArray.push(_local4);
                _local7.push(_local6.index);
                if (this.visible){
                    _local10 = ("_X" + GlobalVars.instance.screenshot_size);
                    _local11 = "";
                    _local12 = "";
                    _local13 = parseInt(_local6.gcid.charAt(0), 15);
                    _local13 = (_local13 % 5);
                    if (GlobalVars.instance.isUseXlpanKanimg){
                        _local12 = ((((GlobalVars.instance.url_new_screen_shot.replace(/{n}/g, _local13) + _local6.gcid) + _local10) + _local11) + ".jpg");
                        JTracer.sendMessage(("FileListFace -> image url:" + _local12));
                    };
                    _local4.setImgInfo(_local12);
                };
                _local3++;
            };
        }
        private function __old__updateFileList():void{
            var _local3:uint;
            var _local4:ListItem;
            var _local6:Object;
            var _local8:String;
            var _local10:String;
            this.clearAllItem();
            if (this._listArray.length == 0){
                return;
            };
            var _local1:uint = (this._curPageNum * this._itemsPerPage);
            var _local2:uint = Math.min(((this._curPageNum + 1) * this._itemsPerPage), this._listLength);
            var _local5:Number = (((this._listWidth - (2 * this._padding)) - (this._itemsPerPage * this._itemWidth)) / (this._itemsPerPage - 1));
            var _local7:Array = [];
            var _local9:Number = (((this._listWidth - (2 * this._padding)) - (((_local2 - _local1) * (this._itemWidth + _local5)) - _local5)) / 2);
            _local3 = _local1;
            while (_local3 < _local2) {
                _local6 = this._listArray[_local3];
                _local4 = new ListItem();
                _local4.setItemInfo(_local6, _local3);
                _local4.x = Math.round((((this._prevBtn.x + (this._prevBtn.width / 2)) + this._padding) + ((this._itemWidth + _local5) * (_local3 - _local1))));
                _local4.y = (this._paddingTop + 25);
                _local4.alpha = 0;
                if ((((_local6.url_hash == Tools.getUserInfo("url_hash"))) || ((_local6.index == Tools.getUserInfo("index"))))){
                    _local4.selected = true;
                    _local4.buttonMode = false;
                    _local4.removeEventListener(MouseEvent.CLICK, this.onItemClick);
                } else {
                    _local4.selected = false;
                    _local4.buttonMode = true;
                    _local4.addEventListener(MouseEvent.CLICK, this.onItemClick);
                };
                _local4.addEventListener(MouseEvent.MOUSE_OVER, this.onItemOver);
                _local4.addEventListener(MouseEvent.MOUSE_OUT, this.onItemOut);
                _local4.addEventListener(MouseEvent.MOUSE_MOVE, this.onItemMove);
                addChildAt(_local4, 0);
                this._itemArray.push(_local4);
                _local7.push(_local6.index);
                _local3++;
            };
            _local8 = _local7.join("/");
            if (Tools.getUserInfo("urlType") == "url"){
                _local10 = ((GlobalVars.instance.url_screen_shot + "&req_list=") + Tools.getUserInfo("ygcid"));
                JTracer.sendMessage(("FileListFace -> 缩略图, url, url=" + _local10));
            } else {
                _local10 = ((((GlobalVars.instance.bt_screen_shot + "&info_hash=") + Tools.getUserInfo("info_hash")) + "&req_list=") + _local8);
                JTracer.sendMessage(((("FileListFace -> 缩略图, " + Tools.getUserInfo("urlType")) + ", url=") + _local10));
            };
            var _local11:URLRequest = new URLRequest(_local10);
            if (this.visible){
                JTracer.sendMessage("FileListFace -> 加载缩略图");
                this.__old__imgLoader.load(_local11);
            };
        }
        private function onItemOver(_arg1:MouseEvent):void{
            var _local3:String;
            var _local2:ListItem = (_arg1.currentTarget as ListItem);
            _local2.itemOver();
            if (_arg1.target == _local2.nameMc){
                _local3 = decodeURI(_local2.itemObj.name);
                Tools.showToolTip(_local3);
                Tools.moveToolTip();
            };
        }
        private function onItemOut(_arg1:MouseEvent):void{
            var _local2:ListItem = (_arg1.currentTarget as ListItem);
            _local2.itmeOut();
            if (_arg1.target == _local2.nameMc){
                Tools.hideToolTip();
            };
        }
        private function onItemMove(_arg1:MouseEvent):void{
            var _local2:ListItem = (_arg1.currentTarget as ListItem);
            if (_arg1.target == _local2.nameMc){
                Tools.moveToolTip();
            };
        }
        private function onItemClick(_arg1:MouseEvent):void{
            this.setAllNonSelect();
            var _local2:ListItem = (_arg1.currentTarget as ListItem);
            _local2.clicked = true;
            _local2.buttonMode = false;
            _local2.removeEventListener(MouseEvent.CLICK, this.onItemClick);
            var _local3:Object = _local2.itemObj;
            this.exchangeVideo(_local3);
        }
        private function exchangeVideo(_arg1:Object):void{
            var _local2:*;
            var _local3:String;
            this._mainMc.exchangeVideo();
            this._mainMc.clearSnpt();
            for (_local2 in _arg1) {
                Tools.setUserInfo(_local2, _arg1[_local2]);
            };
            _local3 = ((("bt://" + Tools.getUserInfo("info_hash")) + "/") + _arg1.index);
            ExternalInterface.call("XL_CLOUD_FX_INSTANCE.playOther", false, _local3, _arg1.url_hash, _arg1.name, _arg1.ygcid, _arg1.cid);
        }
        private function setAllNonSelect():void{
            var _local1:*;
            var _local2:ListItem;
            for (_local1 in this._itemArray) {
                _local2 = (this._itemArray[_local1] as ListItem);
                _local2.selected = false;
                _local2.buttonMode = true;
                _local2.addEventListener(MouseEvent.CLICK, this.onItemClick);
            };
        }
        private function killAllAlphaTween():void{
            var _local1:*;
            var _local2:ListItem;
            for (_local1 in this._itemArray) {
                _local2 = (this._itemArray[_local1] as ListItem);
                TweenLite.killTweensOf(_local2);
            };
        }
        private function applyAlphaTween():void{
            var _local1:uint;
            var _local3:ListItem;
            var _local2:uint = this._itemArray.length;
            if (this._isPrevClick){
                (_local1 == 0);
                while (_local1 < _local2) {
                    _local3 = (this._itemArray[_local1] as ListItem);
                    TweenLite.to(_local3, 0.3, {
                        alpha:1,
                        delay:(_local1 / 10)
                    });
                    _local1++;
                };
            } else {
                (_local1 == 0);
                while (_local1 < _local2) {
                    _local3 = (this._itemArray[((_local2 - 1) - _local1)] as ListItem);
                    TweenLite.to(_local3, 0.3, {
                        alpha:1,
                        delay:(_local1 / 10)
                    });
                    _local1++;
                };
            };
        }
        private function clearAllItem():void{
            var _local1:uint;
            var _local3:ListItem;
            var _local2:uint = this._itemArray.length;
            _local1 = 0;
            while (_local1 < _local2) {
                _local3 = (this._itemArray[_local1] as ListItem);
                _local3.destroy();
                removeChild(_local3);
                _local3 = null;
                _local1++;
            };
            this._itemArray = [];
        }

    }
}//package ctr.fileList 
﻿package ctr.fileList {
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.text.*;

    public class ListItem extends Sprite {

        private var _imgLoader:Loader;
        private var _nameTxt:TextField;
        private var _statusTxt:TextField;
        private var _itemObj:Object;
        private var _selected:Boolean;
        private var _enabledTF:TextFormat;
        private var _disabledTF:TextFormat;
        private var _bgMc:DefaultImg;
        private var _border:FileItemBorder;
        private var _isImgLoaded:Boolean;
        private var _statusMc:Sprite;
        private var _nameMc:Sprite;

        public function ListItem(){
            this._bgMc = new DefaultImg();
            addChild(this._bgMc);
            this._imgLoader = new Loader();
            this._imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onImgLoaded);
            this._imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onImgIOError);
            this._imgLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onImgSecurityError);
            addChild(this._imgLoader);
            this._border = new FileItemBorder();
            this._border.visible = false;
            addChild(this._border);
            this._enabledTF = new TextFormat();
            this._enabledTF.color = 0xEEEEEE;
            this._enabledTF.size = 13;
            this._enabledTF.align = TextFieldAutoSize.CENTER;
            this._enabledTF.font = "宋体";
            this._disabledTF = new TextFormat();
            this._disabledTF.color = 3772639;
            this._disabledTF.size = 13;
            this._disabledTF.align = TextFieldAutoSize.CENTER;
            this._disabledTF.font = "宋体";
        }
        public function setItemInfo(_arg1:Object, _arg2:uint):void{
            if (!_arg1){
                return;
            };
            this._itemObj = _arg1;
            this._nameMc = new Sprite();
            this._nameMc.mouseChildren = false;
            this._nameTxt = new TextField();
            this._nameTxt.defaultTextFormat = this._enabledTF;
            this._nameTxt.selectable = false;
            this._nameTxt.text = ("视频" + (_arg2 + 1));
            this._nameTxt.width = (this._nameTxt.textWidth + 10);
            this._nameTxt.height = (this._nameTxt.textHeight + 4);
            this._nameMc.addChild(this._nameTxt);
            this._nameMc.x = ((this.width - this._nameMc.width) / 2);
            this._nameMc.y = 62;
            this._nameMc.graphics.clear();
            this._nameMc.graphics.beginFill(0xFFFFFF, 0);
            this._nameMc.graphics.drawRect(0, 0, this._nameMc.width, this._nameMc.height);
            this._nameMc.graphics.endFill();
            addChild(this._nameMc);
        }
        public function get nameMc():Sprite{
            return (this._nameMc);
        }
        public function get isImgLoaded():Boolean{
            return (this._isImgLoaded);
        }
        public function set selected(_arg1:Boolean):void{
            var _local2:TextFormat;
            this._selected = _arg1;
            this._border.visible = _arg1;
            if (_arg1){
                this._nameTxt.setTextFormat(this._disabledTF);
                if (!this._statusMc){
                    this._statusMc = new Sprite();
                    this._statusMc.graphics.clear();
                    this._statusMc.graphics.beginFill(0, 0.5);
                    this._statusMc.graphics.drawRect(0, 40, 83, 20);
                    this._statusMc.graphics.endFill();
                    addChild(this._statusMc);
                };
                if (!this._statusTxt){
                    _local2 = new TextFormat("宋体");
                    this._statusTxt = new TextField();
                    this._statusTxt.selectable = false;
                    this._statusTxt.textColor = 11315883;
                    this._statusTxt.text = "播放中...";
                    this._statusTxt.setTextFormat(_local2);
                    this._statusTxt.width = (this._statusTxt.textWidth + 4);
                    this._statusTxt.height = (this._statusTxt.textHeight + 5);
                    this._statusTxt.x = ((83 - this._statusTxt.width) / 2);
                    this._statusTxt.y = ((60 - this._statusTxt.textHeight) - 6);
                    addChild(this._statusTxt);
                };
            } else {
                this._nameTxt.setTextFormat(this._enabledTF);
                if (this._statusTxt){
                    removeChild(this._statusTxt);
                    this._statusTxt = null;
                };
                if (this._statusMc){
                    removeChild(this._statusMc);
                    this._statusMc = null;
                };
            };
        }
        public function get selected():Boolean{
            return (this._selected);
        }
        public function set clicked(_arg1:Boolean):void{
            this._selected = _arg1;
            this._border.visible = _arg1;
        }
        public function itemOver():void{
            if (!this._selected){
                this._border.visible = true;
            };
        }
        public function itmeOut():void{
            if (!this._selected){
                this._border.visible = false;
            };
        }
        public function get itemObj():Object{
            return (this._itemObj);
        }
        public function setImgInfo(_arg1:String):void{
            if (((((!(_arg1)) || ((_arg1 == "")))) || (this.isImgLoaded))){
                return;
            };
            var _local2:URLRequest = new URLRequest(_arg1);
            this._imgLoader.load(_local2);
        }
        public function destroy():void{
            if (this._imgLoader){
                this._imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onImgLoaded);
                this._imgLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.onImgIOError);
                this._imgLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onImgSecurityError);
                this._imgLoader.unloadAndStop();
                removeChild(this._imgLoader);
                this._imgLoader = null;
            };
        }
        private function onImgLoaded(_arg1:Event):void{
            this._isImgLoaded = true;
            this._imgLoader.width = 83;
            this._imgLoader.height = 60;
        }
        private function onImgIOError(_arg1:IOErrorEvent):void{
            this._isImgLoaded = false;
        }
        private function onImgSecurityError(_arg1:SecurityErrorEvent):void{
            this._isImgLoaded = false;
        }

    }
}
//package ctr.fileList 
package ctr.fileList {
    import flash.events.*;
    import flash.display.*;
    import flash.text.*;

    public class PageNavItem extends Sprite {

        private var _pageText:TextField;
        private var _pageNum:uint;
        private var _selected:Boolean;
        private var _enabled:Boolean;
        private var _disabledTF:TextFormat;
        private var _overTF:TextFormat;
        private var _outTF:TextFormat;
        private var _width:Number;

        public function PageNavItem(_arg1:Number){
            this._width = _arg1;
            this._pageText = new TextField();
            this._pageText.width = this._width;
            addChild(this._pageText);
            this.buttonMode = true;
            this.mouseChildren = false;
            this.mouseEnabled = false;
            this.addEventListener(MouseEvent.MOUSE_OVER, this.onOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, this.onOut);
            this.addEventListener(MouseEvent.CLICK, this.onClick);
            this._overTF = new TextFormat();
            this._overTF.color = 3772639;
            this._overTF.underline = true;
            this._overTF.size = 13;
            this._overTF.align = TextFieldAutoSize.CENTER;
            this._overTF.font = "宋体";
            this._outTF = new TextFormat();
            this._outTF.color = 0xEEEEEE;
            this._outTF.underline = false;
            this._outTF.size = 13;
            this._outTF.align = TextFieldAutoSize.CENTER;
            this._outTF.font = "宋体";
            this._disabledTF = new TextFormat();
            this._disabledTF.color = 0x666666;
            this._disabledTF.underline = false;
            this._disabledTF.size = 13;
            this._disabledTF.bold = true;
            this._disabledTF.align = TextFieldAutoSize.CENTER;
            this._disabledTF.font = "宋体";
        }
        public function setLabel(_arg1:String):void{
            this._pageText.defaultTextFormat = this._outTF;
            this._pageText.selectable = false;
            this._pageText.text = _arg1;
            this._pageText.height = (this._pageText.textHeight + 5);
            this._pageText.x = ((this._width - this._pageText.width) / 2);
            this.drawBackground(0xFFFFFF, 0);
        }
        public function set selected(_arg1:Boolean):void{
            this._selected = _arg1;
            this.mouseEnabled = !(_arg1);
            if (_arg1){
                this._pageText.setTextFormat(this._disabledTF);
            } else {
                this._pageText.setTextFormat(this._outTF);
            };
        }
        public function get selected():Boolean{
            return (this._selected);
        }
        public function set enabled(_arg1:Boolean):void{
            this._enabled = _arg1;
            this.mouseEnabled = _arg1;
            this._pageText.setTextFormat(this._outTF);
        }
        public function get enabled():Boolean{
            return (this._enabled);
        }
        public function set pageNum(_arg1:uint):void{
            this._pageNum = _arg1;
        }
        public function get pageNum():uint{
            return (this._pageNum);
        }
        private function onOver(_arg1:MouseEvent):void{
            if (((!(this._selected)) && (this._enabled))){
                this._pageText.setTextFormat(this._overTF);
            };
        }
        private function onOut(_arg1:MouseEvent):void{
            if (((!(this._selected)) && (this._enabled))){
                this._pageText.setTextFormat(this._outTF);
            };
        }
        private function onClick(_arg1:MouseEvent):void{
            dispatchEvent(new Event("SelectPageItem"));
        }
        private function drawBackground(_arg1:uint, _arg2:Number):void{
            this.graphics.clear();
            this.graphics.beginFill(_arg1, _arg2);
            this.graphics.drawRect(0, 0, this._width, 20);
            this.graphics.endFill();
        }

    }
}
//package ctr.fileList 
package ctr.fullScreen {
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;

    public class FullScreenButton extends Sprite {

        private var _ctrBarFullScreenBtn:CtrBarFullScreenBtn;

        public function FullScreenButton(){
            this._ctrBarFullScreenBtn = new CtrBarFullScreenBtn();
            this._ctrBarFullScreenBtn.gotoAndStop(1);
            addChild(this._ctrBarFullScreenBtn);
            this.addEventListener(MouseEvent.ROLL_OVER, this.onMouseOverHandler);
            this.addEventListener(MouseEvent.ROLL_OUT, this.onMouseOutHandler);
            this.mouseChildren = false;
            this.buttonMode = true;
            var _local1:Timer = new Timer(10, 1);
            _local1.addEventListener(TimerEvent.TIMER_COMPLETE, this.initStageEventHandler);
            _local1.start();
        }
        private function initStageEventHandler(_arg1:TimerEvent=null):void{
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, this.fullScreenEventHandler);
        }
        private function fullScreenEventHandler(_arg1:FullScreenEvent):void{
            if (_arg1.fullScreen){
                this._ctrBarFullScreenBtn.gotoAndStop(3);
            } else {
                this._ctrBarFullScreenBtn.gotoAndStop(1);
            };
        }
        private function onMouseOutHandler(_arg1:MouseEvent):void{
            if (stage.displayState == StageDisplayState.NORMAL){
                this._ctrBarFullScreenBtn.gotoAndStop(1);
            } else {
                this._ctrBarFullScreenBtn.gotoAndStop(3);
            };
        }
        private function onMouseOverHandler(_arg1:MouseEvent):void{
            if (stage.displayState == StageDisplayState.NORMAL){
                this._ctrBarFullScreenBtn.gotoAndStop(2);
            } else {
                this._ctrBarFullScreenBtn.gotoAndStop(4);
            };
        }
        override public function get width():Number{
            return (this._ctrBarFullScreenBtn.width);
        }

    }
}
//package ctr.fullScreen 
package {
    import flash.display.*;

    public dynamic class UploadCaptionBtn extends SimpleButton {

    }
}
//package 
package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BtnFeedback extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class FilelistButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class DefaultBar extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class DefaultImg extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetCheckButton extends MovieClip {

        public function SetCheckButton(){
            addFrameScript(0, this.frame1);
        }
        function frame1(){
            stop();
        }

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class PauseButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class CaptionButton extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class QualityLoading extends MovieClip {

        public var change_txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetDefaultOptionBack extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class NoCaptionTips extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BtnDownload extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class Scroll extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class FileItemBorder extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class FilterControlBar extends MovieClip {

        public var mask_mc:MovieClip;
        public var point_mc:MovieClip;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class PlayBar extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class LoadingBar extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetDefaultButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class FilelistTips extends MovieClip {

        public var info_txt:TextField;
        public var know_txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class CtrBarBg extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BtnSet extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class BlueCircle extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetCloseButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetRouHuoButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class GoOnButtonLa extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetMingLiangButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class PreDownBar extends MovieClip {

    }
}//package 
﻿package eve {
    import flash.events.*;

    public class CaptionEvent extends Event {

        public static const SET_STYLE:String = "set_style";
        public static const LOAD_CONTENT:String = "load_content";
        public static const SET_CONTENT:String = "set_content";
        public static const HIDE_CAPTION:String = "hide_caption";
        public static const APPLY_SUCCESS:String = "apply_success";
        public static const APPLY_ERROR:String = "apply_error";
        public static const LOAD_STYLE:String = "load_style";
        public static const SELECT_FILE:String = "select_file";
        public static const UPLOAD_COMPLETE:String = "upload_complete";
        public static const UPLOAD_ERROR:String = "upload_error";
        public static const LOAD_COMPLETE:String = "load_complete";
        public static const LOAD_TIME:String = "load_time";
        public static const SET_TIME:String = "set_time";

        private var _info:Object;

        public function CaptionEvent(_arg1:String, _arg2:Object=null){
            super(_arg1, true);
            this._info = _arg2;
        }
        public function get info():Object{
            return (this._info);
        }

    }
}//package eve 
﻿package eve {
    import flash.events.*;

    public class sizeEvent extends Event {

        public static const BIG_BUTTON_CLICK:String = "big button click";
        public static const SMALL_BUTTON_CLICK:String = "small button click";
        public static const MIDDLE_BUTTON_CLICK:String = "middle button click";
        public static const FULLSCREEN:String = "full screen";
        public static const NORMALSCREEN:String = "normal screen";
        public static const CHANGETITLE:String = "change title";

        private var _size:String;

        public function sizeEvent(_arg1:String, _arg2:String){
            super(_arg1, true);
            this._size = _arg2;
        }
        public function get size():String{
            return (this._size);
        }

    }
}//package eve 
﻿package eve {
    import flash.events.*;

    public class SetQulityEvent extends Event {

        public static const CHANGE_QUILTY:String = "change_quilty";
        public static const SUPERHEIGH_QULITY:String = "super_high_qulity";
        public static const HEIGH_QULITY:String = "high_qulity";
        public static const NORMAL_QULITY:String = "norml_qulity";
        public static const STANDARD_QULITY:String = "standard_qulity";
        public static const INIT_QULITY:String = "init_qulity";
        public static const LOWER_QULITY:String = "lower_qulity";
        public static const HAS_QULITY:String = "has_qulity";
        public static const NO_QULITY:String = "no_qulity";
        public static const AUTIO_QULITY:String = "autio_qulity";
        public static const PAUSE_FOR_QUALITY_TIP:String = "pause_for_quality_tip";
        public static const CLICK_QULITY:String = "click_qulity";

        private var _qulity:String;

        public function SetQulityEvent(_arg1:String, _arg2:String="0"){
            super(_arg1, true);
            this._qulity = _arg2;
        }
        public function get qulity():String{
            return (this._qulity);
        }

    }
}//package eve 
﻿package eve {
    import flash.events.*;

    public class ControlEvent extends Event {

        public static const SHOW_CTRBAR:String = "show ctrbar";

        private var _info:String;

        public function ControlEvent(_arg1:String, _arg2:String=null, _arg3:Boolean=true, _arg4:Boolean=false){
            super(_arg1, _arg3, _arg4);
            this._info = _arg2;
        }
        override public function clone():Event{
            return (new ControlEvent(type, this.info, bubbles, cancelable));
        }
        override public function toString():String{
            return (formatToString("ControlEvent", "type", "bubbles", "cancelable", "eventPhase"));
        }
        public function get info():String{
            return (this._info);
        }

    }
}//package eve 
﻿package eve {
    import flash.events.*;

    public class EventSet extends Event {

        public static const SET_SIZE:String = "set_size";
        public static const SET_AUTOCHANGE:String = "set_autoChange";
        public static const SET_SKIP:String = "set_skip";
        public static const SKIP_MOVIE_HEAD:String = "skip_movie_head";
        public static const SHOW_AUTOQUALITY_FACE:String = "show_autoQuality_face";
        public static const SHOW_SKIPMOVIE_FACE:String = "show_skipMovie_face";
        public static const SET_CHANGED:String = "set_changed";
        public static const SET_STAGE_VIDEO:String = "set_stageVideo";
        public static const SHOW_STAGE_VIDEO:String = "show_stageVideo";
        public static const SHOW_FACE:String = "show face";
        public static const SHOW_SET_OPTION:String = "show set option";

        private var _info:String;

        public function EventSet(_arg1:String, _arg2:String=null){
            super(_arg1, true);
            this._info = _arg2;
        }
        public function get info():String{
            return (this._info);
        }

    }
}//package eve 
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
﻿package eve {
    import flash.events.*;

    public class VolumeEvent extends Event {

        public static const VOLUME_CHANGE:String = "volume change";
        public static const VOLUME_MUTE:String = "volume mute";
        public static const VOLUME_UNMUTE:String = "volume unmute";
        public static const VOLEME_TIPS:String = "volume tips";

        private var _volume:String;

        public function VolumeEvent(_arg1:String, _arg2:String){
            super(_arg1, true);
            this._volume = _arg2;
        }
        public function get volume():String{
            return (this._volume);
        }

    }
}//package eve 
﻿package eve {
    import flash.events.*;

    public class EventFilter extends Event {

        public static const FILTER_MINGLIANG:String = "filter_mingLiang";
        public static const FILTER_ROUHUO:String = "filter_rouHuo";
        public static const FILTER_XIANYAN:String = "filter_xianYan";
        public static const FILTER_FUGU:String = "filter_fugu";
        public static const FILTER_BIAOZHUN:String = "filter_biaoZhun";

        private var _info:String;

        public function EventFilter(_arg1:String, _arg2:String=null){
            super(_arg1, true);
            this._info = _arg2;
        }
        public function get info():String{
            return (this._info);
        }

    }
}//package eve 
﻿package eve {
    import flash.events.*;

    public class PlayEvent extends Event {

        public static const PLAY:String = "Play";
        public static const PAUSE:String = "Pause";
        public static const RESUME:String = "Resume";
        public static const STOP:String = "Stop";
        public static const BUFFER_START:String = "BufferStart";
        public static const BUFFER_END:String = "BufferEnd";
        public static const REPLAY:String = "Replay";
        public static const PLAY_START:String = "PlayStart";
        public static const PLAY_4_STAGE:String = "PlayForStage";
        public static const PAUSE_4_STAGE:String = "PauseForStage";
        public static const SEEK:String = "Seek";
        public static const PROGRESS:String = "Progress";
        public static const PLAY_NEW_URL:String = "PlayNewUrl";
        public static const SEEK_INVALIDTIME:String = "SeekInvalidTime";
        public static const INIT_STAGE_VIDEO:String = "InitStageVideo";
        public static const INSTALL:String = "Install";
        public static const INVALID:String = "Invalid";
        public static const OPEN_WINDOW:String = "OpenWindow";

        private var _manMade:Boolean = false;
        private var _info:String = "";

        public function PlayEvent(_arg1:String, _arg2:Boolean=false, _arg3:String=""){
            super(_arg1, true);
            this._manMade = _arg2;
            this._info = _arg3;
        }
        public function get manMade():Boolean{
            return (this._manMade);
        }
        public function get info():String{
            return (this._info);
        }

    }
}//package eve 
﻿package {
    import flash.display.*;

    public dynamic class StopButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BtnShare extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class CheckboxItem extends MovieClip {

        public var name_txt:TextField;
        public var cb_mc:MovieClip;
        public var bg_mc:MovieClip;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetFuGuButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;
    import flash.text.*;

    public dynamic class BtnCaption extends MovieClip {

        public var txt:TextField;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetBiaoZhunButton extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class CommonBorder extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class Volume100 extends MovieClip {

    }
}//package 
﻿package com {
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.ui.*;

    public class MouseControl extends EventDispatcher {

        private var _listener:InteractiveObject;
        private var _timer:Timer;
        private var _timer2:Timer;
        private var _state:Boolean = false;
        private var _lastPosition:Point;

        public function MouseControl(_arg1:InteractiveObject){
            this._lastPosition = new Point();
            super();
            this._listener = _arg1;
            this._listener.addEventListener(MouseEvent.MOUSE_MOVE, this.handleMouseMove);
            this._listener.addEventListener(MouseEvent.ROLL_OUT, this.handleMouseRollOut);
            this._listener.addEventListener(MouseEvent.ROLL_OVER, this.handleMouseRollOver);
            this._timer = new Timer(6000);
            this._timer2 = new Timer(3000);
            this._timer.addEventListener(TimerEvent.TIMER, this.handleTimer);
            this._timer.start();
            this._timer2.addEventListener(TimerEvent.TIMER, this.handleTimer);
            this._timer2.start();
            this._lastPosition.x = this._listener.mouseX;
            this._lastPosition.y = this._listener.mouseY;
        }
        private function handleMouseRollOver(_arg1:MouseEvent):void{
            this._state = true;
            this.dispatchEvent(new Event("MOUSE_SHOWED"));
        }
        private function handleMouseRollOut(_arg1:MouseEvent):void{
            this._state = false;
            this.dispatchEvent(new Event("MOUSE_HIDED"));
            this._timer.stop();
        }
        private function handleMouseMove(_arg1:MouseEvent):void{
            if (this._state == false){
                Mouse.show();
                this._state = true;
                this.dispatchEvent(new Event("MOUSE_SHOWED"));
            } else {
                this.dispatchEvent(new Event("MOUSE_MOVEED"));
            };
            this._timer.reset();
            this._timer.start();
            this._timer2.reset();
            this._timer2.start();
            this._lastPosition.x = this._listener.mouseX;
            this._lastPosition.y = this._listener.mouseY;
        }
        private function handleTimer(_arg1:TimerEvent):void{
            if (_arg1.currentTarget == this._timer){
                if (this._listener.parent.stage.displayState == "fullScreen"){
                    Mouse.hide();
                };
                this._state = false;
                this.dispatchEvent(new Event("MOUSE_HIDED"));
                this._timer.stop();
            } else {
                this.dispatchEvent(new Event("SMALL_PLAY_PROGRESS_BAR"));
                this._timer2.stop();
            };
        }
        public function get Timer2():Timer{
            return (this._timer2);
        }
        public function set fullscreen(_arg1:Boolean):void{
            this._timer.delay = ((_arg1) ? 2000 : 6000);
        }

    }
}//package com 
﻿package com.slice {
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    import com.common.*;

    public class SingleSocket extends EventDispatcher {

        public static const Complete:String = "Complete";
        public static const All_Complete:String = "all_complete";
        public static const SocketError:String = "SocketError";
        public static const SocketSecurityError:String = "SocketSecurityError";

        private static var ID:int = 0;

        private var m_socket:Socket;
        private var m_url:String;
        private var m_host:String;
        private var m_port:uint;
        private var m_block_size:uint;
        private var m_socket_count:uint;
        private var m_query_pos:uint;
        private var m_query_end_pos:uint;
        private var m_next_pos:uint;
        private var m_end_pos:uint;
        private var cache_length:uint = 0;
        private var video_length:uint = 0;
        private var video_total_length:uint = 0;
        private var buffer_cache:ByteArray;
        private var buffer_video:ByteArray;
        private var error_info:String;
        private var parentObj;
        private var m_byte_type:String;
        private var __id:int = 0;

        public function SingleSocket(_arg1, _arg2:String, _arg3:uint, _arg4:uint, _arg5:uint, _arg6:uint, _arg7:uint, _arg8:String):void{
            this.buffer_cache = new ByteArray();
            this.buffer_video = new ByteArray();
            super();
            this.parentObj = _arg1;
            var _local9:Object = StringUtil.getHostPort(_arg2);
            this.m_url = this.replaceDT(_local9.url);
            this.m_host = _local9.host;
            this.m_port = _local9.port;
            this.m_block_size = _arg3;
            this.m_socket_count = _arg4;
            this.m_next_pos = _arg5;
            this.m_end_pos = _arg6;
            this.video_total_length = _arg7;
            this.m_byte_type = _arg8;
            ID++;
            this.__id = ID;
        }
        public function getCompletePos():Object{
            return ({
                start_pos:this.m_query_pos,
                end_pos:this.m_query_end_pos
            });
        }
        public function getErrorInfo():String{
            return (this.error_info);
        }
        public function get bytesLoaded():uint{
            return (this.video_length);
        }
        public function get bytesTotal():uint{
            return (this.video_total_length);
        }
        public function setByteType(_arg1:String):void{
            this.m_byte_type = _arg1;
        }
        public function setQueryUrl(_arg1:String):void{
            var _local2:Object = StringUtil.getHostPort(_arg1);
            this.m_url = _local2.url;
            this.m_host = _local2.host;
            this.m_port = _local2.port;
        }
        public function setQueryRange(_arg1:uint, _arg2:uint, _arg3:uint):void{
            this.m_next_pos = _arg1;
            this.m_end_pos = _arg2;
            this.video_total_length = _arg3;
        }
        public function clear():void{
            this.m_query_pos = 0;
            this.m_next_pos = 0;
            this.m_end_pos = 0;
            this.cache_length = 0;
            this.video_length = 0;
            this.video_total_length = 0;
            this.buffer_video.clear();
            this.buffer_cache.clear();
            this.clearSocket();
        }
        public function clearSocket():void{
            if (this.m_socket){
                this.m_socket.removeEventListener(Event.CONNECT, this.connectSuccess);
                this.m_socket.removeEventListener(ProgressEvent.SOCKET_DATA, this.receiveSocketData);
                this.m_socket.removeEventListener(Event.CLOSE, this.connectClose);
                this.m_socket.removeEventListener(IOErrorEvent.IO_ERROR, this.connectIOError);
                this.m_socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.connctSecurityError);
                if (this.m_socket.connected){
                    this.m_socket.close();
                };
                this.m_socket = null;
            };
        }
        public function connectSocket():void{
            this.initSocket();
            this.m_socket.connect(this.m_host, this.m_port);
        }
        private function replaceDT(_arg1:String):String{
            var _local3:String;
            var _local4:String;
            var _local5:String;
            if (!_arg1){
                return (null);
            };
            var _local2:int = _arg1.indexOf("dt=");
            if (_local2 >= 0){
                _local3 = _arg1.substr(0, _local2);
                _local4 = _arg1.substr((_local2 + 5));
                _local5 = ((_local3 + "dt=17") + _local4);
                return (_local5);
            };
            return (_arg1);
        }
        private function initSocket():void{
            if (!this.m_socket){
                this.m_socket = new Socket();
                this.m_socket.timeout = 5000;
                this.m_socket.addEventListener(Event.CONNECT, this.connectSuccess);
                this.m_socket.addEventListener(ProgressEvent.SOCKET_DATA, this.receiveSocketData);
                this.m_socket.addEventListener(Event.CLOSE, this.connectClose);
                this.m_socket.addEventListener(IOErrorEvent.IO_ERROR, this.connectIOError);
                this.m_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.connctSecurityError);
            };
        }
        private function connectSuccess(_arg1:Event):void{
            this.sendQuery();
        }
        private function sendQuery():void{
            this.m_query_pos = this.m_next_pos;
            this.m_query_end_pos = ((this.m_query_pos + this.m_block_size) - 1);
            var _local1 = (("GET " + this.m_url) + " HTTP/1.1 \r\n");
            _local1 = (_local1 + (((("Range: bytes=" + this.m_query_pos) + "-") + this.m_query_end_pos) + " \r\n"));
            _local1 = (_local1 + (((("Host: " + this.m_host) + ":") + this.m_port) + " \r\n\r\n"));
            this.m_socket.writeUTFBytes(_local1);
            this.m_socket.flush();
        }
        private function receiveSocketData(_arg1:ProgressEvent):void{
            var _local5:String;
            var _local6:String;
            var _local7:uint;
            var _local8:uint;
            var _local2:uint = this.m_socket.bytesAvailable;
            this.video_length = (this.video_length + _local2);
            this.buffer_cache.clear();
            this.m_socket.readBytes(this.buffer_cache, 0, this.m_socket.bytesAvailable);
            var _local3:String = this.buffer_cache.toString();
            var _local4:int = _local3.indexOf("\r\n\r\n");
            if ((((_local4 > 0)) && (((_local4 + 4) < _local2)))){
                _local5 = _local3.substring(0, _local4);
                _local6 = StringUtil.getResponseHeader(_local5, "HTTP/1.1", " ");
                if (((_local6) && ((parseInt(_local6) >= 300)))){
                    this.error_info = _local6;
                    dispatchEvent(new Event(SocketError));
                    return;
                };
                _local7 = 0;
                if (_local5.indexOf("HTTP/1.1") >= 0){
                    _local7 = (_local4 + 4);
                    JTracer.sendMessage(((((((("SingleSocket -> receiveSocketData, m_byte_type:" + this.m_byte_type) + ", start_pos:") + this.m_query_pos) + ", end_pos:") + this.m_query_end_pos) + ", read_begin:") + _local7));
                };
                _local8 = (_local2 - _local7);
                if (_local8 > 0){
                    this.buffer_video.writeBytes(this.buffer_cache, _local7, _local8);
                    this.cache_length = (this.cache_length + _local8);
                    if (this.cache_length >= (this.m_block_size - _local7)){
                        StreamList.setBytes(this.m_byte_type, this.m_query_pos, this.m_query_end_pos, this.buffer_video);
                        this.buffer_video.clear();
                        this.cache_length = 0;
                        dispatchEvent(new Event(Complete));
                        this.loadNextStream();
                    };
                };
            } else {
                if (_local4 < 0){
                    this.buffer_video.writeBytes(this.buffer_cache, 0, _local2);
                    this.cache_length = (this.cache_length + _local2);
                    if (this.cache_length >= this.m_block_size){
                        StreamList.setBytes(this.m_byte_type, this.m_query_pos, this.m_query_end_pos, this.buffer_video);
                        this.buffer_video.clear();
                        this.cache_length = 0;
                        dispatchEvent(new Event(Complete));
                        this.loadNextStream();
                    };
                };
            };
        }
        private function loadNextStream():void{
            if (((this.m_next_pos + this.m_block_size) - 1) < (this.m_end_pos - ((this.m_socket_count - 1) * this.m_block_size))){
                this.m_next_pos = this.parentObj.query_pos;
                this.sendQuery();
                this.parentObj.query_pos = (this.parentObj.query_pos + this.m_block_size);
            } else {
                dispatchEvent(new Event(All_Complete));
            };
        }
        private function connectClose(_arg1:Event):void{
            if (this.m_next_pos < this.m_end_pos){
                this.clearSocket();
                this.connectSocket();
            };
            this.error_info = ("Connect Close at Socket:" + this.__id);
            dispatchEvent(new Event(SocketError));
        }
        private function connectIOError(_arg1:IOErrorEvent):void{
            this.error_info = ("Connect IOError at Socket:" + this.__id);
            dispatchEvent(new Event(SocketError));
        }
        private function connctSecurityError(_arg1:SecurityErrorEvent):void{
            this.error_info = ((("Connect SecurityError at Socket:" + this.__id) + ", text:") + _arg1.text);
            dispatchEvent(new Event(SocketSecurityError));
        }

    }
}//package com.slice 
﻿package com.slice {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import com.common.*;
    import com.serialization.json.*;
    import flash.external.*;

    public class FeeLoader extends URLLoader {

        private static var _instance:FeeLoader;

        public var feeSuccess:Function;
        public var feeIOError:Function;
        public var feeSecurityError:Function;

        public function FeeLoader(){
            this.addEventListener(Event.COMPLETE, this.onFeeSuccess);
            this.addEventListener(IOErrorEvent.IO_ERROR, this.onFeeIOError);
            this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.onFeeSecurityError);
        }
        public static function getInstance():FeeLoader{
            if (!_instance){
                _instance = new (FeeLoader)();
            };
            return (_instance);
        }

        public function startFee(_arg1:Number):void{
            var _local2:String = Tools.getUserInfo("userid");
            var _local3:String = Tools.getUserInfo("sessionid");
            var _local4:String = Tools.getUserInfo("gcid");
            var _local5:String = Tools.getUserInfo("cid");
            var _local6:String = _arg1.toString();
            _local6 = _local6.substr(0, _local6.indexOf("."));
            var _local7:String = Tools.getUserInfo("filesize");
            var _local8:String = encodeURIComponent(Tools.getUserInfo("name"));
            var _local9:String = ExternalInterface.call("function (){return document.location.href;}");
            var _local10:URLVariables = new URLVariables();
            _local10.href = _local9;
            var _local11:URLRequest = new URLRequest();
            _local11.url = encodeURI(encodeURI(((((((((((((((GlobalVars.instance.url_deduct_flow + "userid/") + _local2) + "/sessionid/") + _local3) + "/gcid/") + _local4) + "/cid/") + _local5) + "/filesize/") + _local7) + "/filename/") + _local8) + "/videotime/") + _local6)));
            _local11.data = _local10;
            _local11.method = URLRequestMethod.POST;
            this.load(_local11);
        }
        private function onFeeSuccess(_arg1:Event):void{
            var _local2:String;
            var _local3:Object;
            if ((((this.feeSuccess is Function)) && (!((this.feeSuccess == null))))){
                _local2 = _arg1.target.data;
                _local3 = JSON.deserialize(_local2);
                this.feeSuccess(_local3);
            };
        }
        private function onFeeIOError(_arg1:IOErrorEvent):void{
            if ((((this.feeIOError is Function)) && (!((this.feeIOError == null))))){
                this.feeIOError();
            };
        }
        private function onFeeSecurityError(_arg1:SecurityErrorEvent):void{
            if ((((this.feeSecurityError is Function)) && (!((this.feeSecurityError == null))))){
                this.feeSecurityError();
            };
        }

    }
}//package com.slice 
﻿package com.slice {
    import com.global.*;
    import flash.utils.*;
    import com.common.*;

    public class StreamList {

        private static const AUDIO_TAG:int = 8;
        private static const VIDEO_TAG:int = 9;
        private static const SCRIPT_TAG:int = 24;

        private static var header:ByteArray = new ByteArray();
        private static var header_list:Dictionary = new Dictionary();
        private static var cur_list:Dictionary = new Dictionary();
        private static var next_list:Dictionary = new Dictionary();

        public static function clearHeader():void{
            var _local1:*;
            var _local2:ByteArray;
            header.clear();
            for (_local1 in header_list) {
                _local2 = (header_list[_local1] as ByteArray);
                _local2.clear();
                _local2 = null;
            };
            header_list = new Dictionary();
        }
        public static function clearCurList():void{
            var _local1:*;
            var _local2:ByteArray;
            for (_local1 in cur_list) {
                _local2 = (cur_list[_local1] as ByteArray);
                _local2.clear();
                _local2 = null;
            };
            cur_list = new Dictionary();
        }
        public static function clearNextList():void{
            var _local1:*;
            var _local2:ByteArray;
            for (_local1 in next_list) {
                _local2 = (next_list[_local1] as ByteArray);
                _local2.clear();
                _local2 = null;
            };
            next_list = new Dictionary();
        }
        public static function replaceList():void{
            var _local1:*;
            var _local2:ByteArray;
            for (_local1 in next_list) {
                _local2 = (clone(next_list[_local1]) as ByteArray);
                cur_list[_local1] = _local2;
            };
            clearNextList();
        }
        public static function getHeader():ByteArray{
            return (header);
        }
        public static function setHeader(_arg1:ByteArray):void{
            header.clear();
            var _local2:uint;
            var _local3:ByteArray = _arg1;
            var _local4:uint = findTagsStart(_local3);
            var _local5:ByteArray = new ByteArray();
            _local5.writeBytes(_local3, _local2, _local4);
            JTracer.sendMessage(("StreamList -> setHeader, header length:" + _local5.length));
            _local2 = (_local2 + _local4);
            var _local6:ByteArray = new ByteArray();
            _local6.writeBytes(_local3, _local2, 11);
            JTracer.sendMessage(("StreamList -> setHeader, metadata tag header length:" + _local6.length));
            _local6.position = 0;
            var _local7:int = _local6.readByte();
            var _local8 = ((_local6.readUnsignedShort() << 8) | _local6.readUnsignedByte());
            JTracer.sendMessage(((("StreamList -> setHeader, tag_type:" + _local7) + ", tag_size:") + _local8));
            _local2 = (_local2 + 11);
            var _local9:ByteArray = new ByteArray();
            _local9.writeBytes(_local3, _local2, _local8);
            JTracer.sendMessage(("StreamList -> setHeader, tag data length:" + _local9.length));
            _local2 = (_local2 + _local8);
            var _local10:ByteArray = new ByteArray();
            _local10.writeBytes(_local3, _local2, 4);
            _local2 = (_local2 + 4);
            var _local11:ByteArray = new ByteArray();
            _local11.writeBytes(_local3, _local2, 11);
            JTracer.sendMessage(("StreamList -> setHeader, video tag header length:" + _local11.length));
            _local11.position = 0;
            var _local12:int = _local11.readByte();
            var _local13 = ((_local11.readUnsignedShort() << 8) | _local11.readUnsignedByte());
            JTracer.sendMessage(((("StreamList -> setHeader, tag_type:" + _local12) + ", tag_size:") + _local13));
            _local2 = (_local2 + 11);
            var _local14:ByteArray = new ByteArray();
            _local14.writeBytes(_local3, _local2, _local13);
            JTracer.sendMessage(("StreamList -> setHeader, tag data length:" + _local14.length));
            _local2 = (_local2 + _local13);
            var _local15:ByteArray = new ByteArray();
            _local15.writeBytes(_local3, _local2, 4);
            _local2 = (_local2 + 4);
            var _local16:ByteArray = new ByteArray();
            _local16.writeBytes(_local3, _local2, 11);
            JTracer.sendMessage(("StreamList -> setHeader, audio tag header length:" + _local16.length));
            _local16.position = 0;
            var _local17:int = _local16.readByte();
            var _local18 = ((_local16.readUnsignedShort() << 8) | _local16.readUnsignedByte());
            JTracer.sendMessage(((("StreamList -> setHeader, tag_type:" + _local17) + ", tag_size:") + _local18));
            _local2 = (_local2 + 11);
            var _local19:ByteArray = new ByteArray();
            _local19.writeBytes(_local3, _local2, _local18);
            JTracer.sendMessage(("StreamList -> setHeader, tag data length:" + _local19.length));
            _local2 = (_local2 + _local18);
            var _local20:ByteArray = new ByteArray();
            _local20.writeBytes(_local3, _local2, 4);
            header.writeBytes(_local5);
            header.writeBytes(_local6);
            header.writeBytes(_local9);
            header.writeBytes(_local10);
            header.writeBytes(_local11);
            header.writeBytes(_local14);
            header.writeBytes(_local15);
            header.writeBytes(_local16);
            header.writeBytes(_local19);
            header.writeBytes(_local20);
            JTracer.sendMessage(("StreamList -> setHeader, total header length:" + header.length));
        }
        public static function setBytes(_arg1:String, _arg2:uint, _arg3:uint, _arg4:ByteArray):void{
            var _local5:ByteArray = new ByteArray();
            _local5.writeBytes(_arg4);
            if (_arg1 == GlobalVars.instance.type_metadata){
                if (_arg2 == 0){
                    setHeader(_local5);
                };
                header_list[((_arg2.toString() + "-") + _arg3.toString())] = _local5;
                return;
            };
            if (_arg1 == GlobalVars.instance.type_curstream){
                cur_list[((_arg2.toString() + "-") + _arg3.toString())] = _local5;
                return;
            };
            next_list[((_arg2.toString() + "-") + _arg3.toString())] = _local5;
        }
        public static function getBytes(_arg1:String, _arg2:Number, _arg3:uint):ByteArray{
            if (_arg1 == GlobalVars.instance.type_metadata){
                return (header_list[((_arg2.toString() + "-") + _arg3.toString())]);
            };
            if (_arg1 == GlobalVars.instance.type_curstream){
                return (cur_list[((_arg2.toString() + "-") + _arg3.toString())]);
            };
            return (next_list[((_arg2.toString() + "-") + _arg3.toString())]);
        }
        public static function findBytes(_arg1:String, _arg2:Number):Object{
            var _local3:*;
            var _local4:Number;
            var _local5:Number;
            var _local6:Dictionary = (((_arg1 == GlobalVars.instance.type_curstream)) ? cur_list : next_list);
            for (_local3 in _local6) {
                _local4 = Number(_local3.substr(0, _local3.indexOf("-")));
                _local5 = Number(_local3.substr((_local3.indexOf("-") + 1)));
                if ((((_local4 <= _arg2)) && ((_arg2 <= _local5)))){
                    return ({
                        start:_local4,
                        end:_local5
                    });
                };
            };
            return ({});
        }
        private static function findTagsStart(_arg1:ByteArray):uint{
            _arg1.position = 0;
            var _local2:String = _arg1.readUTFBytes(3);
            if (_local2 != "FLV"){
                throw (new Error("Not a valid VIDEO FLV file."));
            };
            var _local3:int = _arg1.readByte();
            var _local4:int = _arg1.readByte();
            var _local5 = (_local4 >> 3);
            var _local6 = ((_local4 & 4) >> 2);
            var _local7 = ((_local4 & 2) >> 1);
            var _local8 = (_local4 & 1);
            var _local9:int = _arg1.readUnsignedInt();
            var _local10:uint = (_arg1.position + 4);
            return (_local10);
        }
        private static function clone(_arg1:Object){
            var _local2:ByteArray = new ByteArray();
            _local2.writeObject(_arg1);
            _local2.position = 0;
            return (_local2.readObject());
        }

    }
}//package com.slice 
﻿package com.slice {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    import com.*;
    import flash.media.*;
    import com.common.*;

    public class StreamMetaData extends EventDispatcher {

        public static const KEYFRAME_LOADED:String = "key frame loaded";
        public static const KEYFRAME_ERROR:String = "key frame error";

        private var _endByte:Number = 81920;
        private var _conn:NetConnection;
        private var _stream:NetStream;
        private var _url:String;
        private var _client:Object;
        private var _timeArr:Array;
        private var _byteArr:Array;
        private var _sIntervalTime:Number;
        private var _spliceByteArr:Array;
        private var _spliceTimeArr:Array;
        private var _firstByteEnd:Number;
        private var _isAdd:Boolean;
        private var _totalByte:Number;
        private var _player:Player;
        private var socket_count:uint = 1;
        private var socket_array:Array;
        private var block_size:uint = 81920;
        private var current_pos:uint = 0;
        private var appendTimer:Timer;
        private var gdlUrl:String = "";
        public var query_pos:uint;

        public function StreamMetaData(_arg1:Player){
            this._timeArr = [];
            this._byteArr = [];
            this._spliceByteArr = [];
            this._spliceTimeArr = [];
            this.socket_array = [];
            super();
            this._player = _arg1;
            this._conn = new NetConnection();
            this._conn.connect(null);
            this._client = {};
            this._client.onMetaData = this.metaDataHandler;
            this._stream = new NetStream(this._conn);
            this._stream.client = this._client;
            this._stream.bufferTime = 1;
            this._stream.soundTransform = new SoundTransform(0);
            this._stream.addEventListener(NetStatusEvent.NET_STATUS, this.netstatusEventHandler);
            this._stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorEventHandler);
            this._stream.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorEventHandler);
        }
        public function loadMetaData(_arg1:String, _arg2:Number):void{
            var suffixUrl:* = null;
            var url:* = _arg1;
            var vduration:* = _arg2;
            suffixUrl = ((("&start=0&end=" + this._endByte) + "&flash_meta=0&type=loadmetadata&du=") + vduration);
            this.gdlUrl = (url + suffixUrl);
            if (GlobalVars.instance.isUseSocket){
                JTracer.sendMessage("StreamMetaData -> loadMetaData, connect socket");
                GetVodSocket.instance.connect(url, function (_arg1:String, _arg2:String, _arg3:String, _arg4:int){
                    if (GlobalVars.instance.getVodTime == 0){
                        GlobalVars.instance.getVodTime = _arg4;
                    };
                    if (!_arg1){
                        GlobalVars.instance.isUseHttpSocket = false;
                        _player.vodUrl = null;
                        JTracer.sendMessage(("StreamMetaData -> loadMetaData, get vod url fail, gdl url:" + gdlUrl));
                        _stream.play(gdlUrl);
                    } else {
                        GlobalVars.instance.isUseHttpSocket = checkIsUseHttpSocket(_arg1);
                        JTracer.sendMessage(("StreamMetaData -> loadMetaData, isUseHttpSocket:" + GlobalVars.instance.isUseHttpSocket));
                        if (GlobalVars.instance.isUseHttpSocket){
                            current_pos = 0;
                            query_pos = (socket_count * block_size);
                            _conn = new NetConnection();
                            _conn.connect(null);
                            _client = {};
                            _client.onMetaData = metaDataHandler;
                            _stream = new NetStream(_conn);
                            _stream.client = _client;
                            _stream.bufferTime = 1;
                            _stream.soundTransform = new SoundTransform(0);
                            _stream.addEventListener(NetStatusEvent.NET_STATUS, netstatusEventHandler);
                            _stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorEventHandler);
                            _stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorEventHandler);
                            _stream.play(null);
                            _stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
                            _player.vodUrl = (_arg1 + suffixUrl);
                            JTracer.sendMessage(((((("StreamMetaData -> loadMetaData, use socket, get vod url success, vod url:" + _arg1) + ", start_pos:0, end_pos:") + _endByte) + ", next_pos:") + query_pos));
                            downloadStream(_arg1, 0, _endByte);
                        } else {
                            _player.vodUrl = (_arg1 + suffixUrl);
                            JTracer.sendMessage(("StreamMetaData -> loadMetaData, get vod url success, vod url:" + _player.vodUrl));
                            _stream.play(_player.vodUrl);
                        };
                    };
                });
            } else {
                JTracer.sendMessage(("StreamMetaData -> loadMetaData, gdl url=" + this.gdlUrl));
                this._stream.play(this.gdlUrl);
            };
            this.initialAppendTimer();
        }
        private function initialAppendTimer():void{
            if (this.appendTimer == null){
                this.appendTimer = new Timer(100);
                this.appendTimer.addEventListener(TimerEvent.TIMER, this.handleAppendTimer);
                this.appendTimer.start();
            };
        }
        private function clearAppendTimer():void{
            if (this.appendTimer){
                this.appendTimer.stop();
                this.appendTimer.removeEventListener(TimerEvent.TIMER, this.handleAppendTimer);
                this.appendTimer = null;
            };
        }
        private function handleAppendTimer(_arg1:TimerEvent):void{
            this.block_complete(null);
        }
        private function checkIsUseHttpSocket(_arg1:String):Boolean{
            var _local5:*;
            var _local2:Object = StringUtil.getHostPort(_arg1);
            var _local3:String = _local2.host;
            var _local4:String = GlobalVars.instance.vodAddr;
            if (GlobalVars.instance.isIPLink){
                for (_local5 in GlobalVars.instance.httpSocketMachines) {
                    JTracer.sendMessage((("machines:" + GlobalVars.instance.httpSocketMachines[_local5]) + "\n"));
                    if (_local4.indexOf(GlobalVars.instance.httpSocketMachines[_local5]) > -1){
                        return (true);
                    };
                };
            };
            for (_local5 in GlobalVars.instance.httpSocketMachines) {
                if (_local3.indexOf(GlobalVars.instance.httpSocketMachines[_local5]) > -1){
                    return (true);
                };
            };
            return (false);
        }
        private function clearSocket():void{
            var _local1:uint;
            var _local2:SingleSocket;
            _local1 = 0;
            while (_local1 < this.socket_array.length) {
                _local2 = this.socket_array[_local1];
                _local2.removeEventListener(SingleSocket.All_Complete, this.all_block_complete);
                _local2.removeEventListener(SingleSocket.SocketError, this.block_error);
                _local2.removeEventListener(SingleSocket.SocketSecurityError, this.block_error);
                _local2.clear();
                _local2 = null;
                _local1++;
            };
            this.socket_array = [];
        }
        private function downloadStream(_arg1:String, _arg2:uint, _arg3:uint):void{
            var _local4:uint;
            var _local5:SingleSocket;
            StreamList.clearHeader();
            this.clearSocket();
            if (this.socket_array.length == 0){
                _local4 = 0;
                while (_local4 < this.socket_count) {
                    _local5 = new SingleSocket(this, _arg1, this.block_size, this.socket_count, (_arg2 + (_local4 * this.block_size)), _arg3, (_arg3 - _arg2), GlobalVars.instance.type_metadata);
                    _local5.addEventListener(SingleSocket.All_Complete, this.all_block_complete);
                    _local5.addEventListener(SingleSocket.SocketError, this.block_error);
                    _local5.addEventListener(SingleSocket.SocketSecurityError, this.block_error);
                    _local5.connectSocket();
                    this.socket_array.push(_local5);
                    _local4++;
                };
            } else {
                _local4 = 0;
                while (_local4 < this.socket_count) {
                    _local5 = this.socket_array[_local4];
                    _local5.clear();
                    _local5.setQueryUrl(_arg1);
                    _local5.setQueryRange((_arg2 + (_local4 * this.block_size)), _arg3, (_arg3 - _arg2));
                    _local5.connectSocket();
                    _local4++;
                };
            };
        }
        private function all_block_complete(_arg1:Event):void{
            var _local2:SingleSocket = (_arg1.currentTarget as SingleSocket);
            _local2.clearSocket();
            var _local3:Object = _local2.getCompletePos();
            JTracer.sendMessage(((((("StreamMetaData -> all_block_complete, start_pos:" + _local3.start_pos) + ", end_pos:") + _local3.end_pos) + ", next_pos:") + this.query_pos));
        }
        private function block_complete(_arg1:Event):void{
            if (((!(GlobalVars.instance.isUseHttpSocket)) || (GlobalVars.instance.isHeaderGetted))){
                return;
            };
            var _local2:ByteArray = (StreamList.getBytes(GlobalVars.instance.type_metadata, this.current_pos, ((this.current_pos + this.block_size) - 1)) as ByteArray);
            if (_local2){
                this._stream.appendBytes(_local2);
                this.current_pos = (this.current_pos + this.block_size);
            };
        }
        private function block_error(_arg1:Event):void{
            var _local2:SingleSocket = (_arg1.currentTarget as SingleSocket);
            JTracer.sendMessage(("StreamMetaData -> block_error, error_info:" + _local2.getErrorInfo()));
            if (_arg1.type == "SocketSecurityError"){
                GlobalVars.instance.isUseHttpSocket = false;
                GlobalVars.instance.isHeaderGetted = false;
                GlobalVars.instance.isUseSocket = false;
                if (this._player.vodUrl){
                    JTracer.sendMessage("StreamMetaData -> block_error SecurityError starting play vod url");
                    this._stream.play(this._player.vodUrl);
                } else {
                    JTracer.sendMessage("StreamMetaData -> block_error SecurityError starting play gdl url");
                    this._stream.play(this.gdlUrl);
                };
            };
        }
        public function set totalByte(_arg1:Number):void{
            this._totalByte = _arg1;
        }
        public function set sliceTime(_arg1:Number):void{
            this._sIntervalTime = (((_arg1 < 30)) ? 30 : _arg1);
            JTracer.sendMessage(("StreamMetaData -> sliceTime:" + _arg1));
        }
        public function spliceUpdateArray():void{
            var _local5:*;
            var _local6:Number;
            if (((!((this._timeArr.length == this._byteArr.length))) || ((this._timeArr.length == 0)))){
                JTracer.sendMessage(((("StreamMetaData -> spliceUpdateArray, _timeArr.length != _byteArr.length, can not match! _timeArr.length:" + this._timeArr.length) + ", _byteArr.length:") + this._byteArr.length));
                return;
            };
            this._isAdd = false;
            var _local1:int = (this.getNearValueIndex(this._timeArr, this._sIntervalTime) + 1);
            JTracer.sendMessage(("StreamMetaData -> spliceUpdateArray, 最接近的id:" + _local1));
            var _local2:int = _local1;
            var _local3:int = this._timeArr.length;
            this._spliceByteArr = [];
            this._spliceTimeArr = [];
            this._spliceByteArr.push(this._byteArr[0]);
            this._spliceTimeArr.push(this._timeArr[0]);
            while ((((_local2 < (_local3 - 1))) && ((_local1 > 0)))) {
                this._spliceByteArr.push(this._byteArr[_local2]);
                this._spliceTimeArr.push(this._timeArr[_local2]);
                _local2 = (_local2 + _local1);
            };
            this._spliceByteArr.push(this._byteArr[(_local3 - 1)]);
            this._spliceTimeArr.push(this._timeArr[(_local3 - 1)]);
            if (((!((this._firstByteEnd == 0))) && ((this._spliceByteArr.length > 2)))){
                _local6 = (this.getNearValueIndex(this._byteArr, this._firstByteEnd) + 1);
                _local6 = (((_local6 < 1)) ? 1 : _local6);
                this._spliceByteArr[1] = this._byteArr[_local6];
                this._spliceTimeArr[1] = this._timeArr[_local6];
            };
            var _local4 = "StreamMetaData -> spliceUpdateArray:";
            for (_local5 in this._spliceTimeArr) {
                _local4 = (_local4 + (((((((("\n" + "_spliceTimeArr[") + _local5) + "]:") + this._spliceTimeArr[_local5]) + ",\t_spliceByteArr[") + _local5) + "]:") + this._spliceByteArr[_local5]));
            };
            JTracer.sendMessage(_local4);
        }
        public function set firstByteEnd(_arg1:Number):void{
            JTracer.sendMessage(("StreamMetaData -> firstByteEnd:" + _arg1));
            this._firstByteEnd = _arg1;
        }
        public function getStartTime(_arg1:Number):Number{
            var _local2:int = (this.getNearValueIndex(this._timeArr, _arg1) + 1);
            _local2 = Math.max(0, Math.min((this._timeArr.length - 2), _local2));
            var _local3:Number = this._timeArr[_local2];
            JTracer.sendMessage(((("StreamMetaData -> 获取的开始时间是:" + _arg1) + ", index:") + _local2));
            return (_local3);
        }
        public function getStartByte(_arg1:Number):Number{
            var _local2:int = (this.getNearValueIndex(this._timeArr, _arg1) + 1);
            _local2 = Math.max(0, Math.min((this._timeArr.length - 2), _local2));
            var _local3:Number = this._byteArr[_local2];
            JTracer.sendMessage(((((("StreamMetaData -> 获取的开始字节位置为:" + _local3) + ", 时间是:") + _arg1) + ", index:") + _local2));
            return (_local3);
        }
        public function getEndByte(_arg1:Number):Number{
            var _local2:int = (this.getNearValueIndex(this._timeArr, _arg1) + 2);
            _local2 = Math.max(1, Math.min((this._timeArr.length - 1), _local2));
            var _local3:Number = this._byteArr[_local2];
            JTracer.sendMessage(((((("StreamMetaData -> 获取的结束字节位置为:" + _local3) + ", 时间是:") + _arg1) + ", index:") + _local2));
            return (_local3);
        }
        public function getSpliceEndByte(_arg1:Number):Number{
            var _local2:int = (this.getNearValueIndex(this._spliceTimeArr, _arg1) + 2);
            _local2 = Math.max(1, Math.min((this._spliceTimeArr.length - 1), _local2));
            var _local3:Number = this._spliceByteArr[_local2];
            if (_local2 == (this._spliceTimeArr.length - 1)){
                _local3 = this._totalByte;
            };
            JTracer.sendMessage(((((("StreamMetaData -> 获取的结束字节位置为:" + _local3) + ", 时间是:") + _arg1) + ", index:") + _local2));
            return (_local3);
        }
        private function getNearValueIndex(_arg1:Array, _arg2:Number):int{
            var _local3 = -3;
            var _local4:int;
            var _local5:int = _arg1.length;
            while (_local4 < _local5) {
                if (_arg1[_local4] > _arg2){
                    _local3 = (_local4 - 2);
                    break;
                };
                _local4++;
            };
            return ((((_local3 == -3)) ? (_arg1.length - 1) : _local3));
        }
        public function startByte(_arg1:Number):Number{
            var _local3:uint;
            var _local4:uint;
            var _local5:Boolean;
            var _local6:uint;
            var _local7:uint;
            if (_arg1 < 0){
                _arg1 = 0;
            };
            var _local2:Number = 0;
            if (this._timeArr.length > 1){
                _local3 = 0;
                _local4 = 0;
                _local5 = false;
                _local6 = this._timeArr.length;
                while (_local3 < (_local6 - 1)) {
                    _local7 = (_local3 + 1);
                    if ((((this._timeArr[_local3] <= _arg1)) && ((this._timeArr[_local7] > _arg1)))){
                        _local4 = _local3;
                        _local5 = true;
                        break;
                    };
                    _local3++;
                };
                if (_local4 == 0){
                    _local4 = ((_local5) ? 1 : (this._timeArr.length - 1));
                };
                _local4 = Math.min((this._timeArr.length - 1), Math.max(1, _local4));
                _local2 = this._byteArr[_local4];
            };
            JTracer.sendMessage(((((("StreamMetaData -> 获取的开始字节位置为:" + _local2) + ", 时间是:") + _arg1) + ", index:") + _local4));
            return (_local2);
        }
        public function endByte(_arg1:Number):Number{
            var _local3:int;
            var _local4:uint;
            var _local5:Boolean;
            var _local6:uint;
            var _local7:uint;
            var _local2:Number = 0;
            if (this._timeArr.length > 1){
                _local3 = 0;
                _local4 = 0;
                _local5 = false;
                _local6 = this._timeArr.length;
                while (_local3 < (_local6 - 1)) {
                    _local7 = (_local3 + 1);
                    if ((((this._timeArr[_local3] <= _arg1)) && ((this._timeArr[_local7] > _arg1)))){
                        _local4 = _local3;
                        _local5 = true;
                        break;
                    };
                    _local3++;
                };
                if (_local4 == 0){
                    _local4 = ((_local5) ? 1 : (this._timeArr.length - 1));
                };
                _local4 = Math.min((this._timeArr.length - 1), Math.max(1, _local4));
                _local2 = this._byteArr[_local4];
            };
            JTracer.sendMessage(((((("StreamMetaData -> 获取的结束字节位置为:" + _local2) + ", 时间是:") + _arg1) + ", index:") + _local4));
            return (_local2);
        }
        public function get timeArr():Array{
            return (this._timeArr);
        }
        public function get byteArr():Array{
            return (this._byteArr);
        }
        public function clear():void{
            this._timeArr = [];
            this._byteArr = [];
            this._stream.close();
            this._conn.close();
        }
        private function isHasValue(_arg1:Array, _arg2:Number):Boolean{
            var _local3:*;
            for (_local3 in _arg1) {
                if (_arg1[_local3] == _arg2){
                    return (true);
                };
            };
            return (false);
        }
        private function netstatusEventHandler(_arg1:NetStatusEvent):void{
            if (_arg1.info.code == "NetStream.Play.StreamNotFound"){
                JTracer.sendMessage("StreamMetaData -> NetStream.Play.StreamNotFound");
                dispatchEvent(new Event(StreamMetaData.KEYFRAME_ERROR));
            };
        }
        private function securityErrorEventHandler(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("StreamMetaData -> SecurityErrorEvent");
            dispatchEvent(new Event(StreamMetaData.KEYFRAME_ERROR));
        }
        private function ioErrorEventHandler(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("StreamMetaData -> IOErrorEvent");
            dispatchEvent(new Event(StreamMetaData.KEYFRAME_ERROR));
        }
        private function metaDataHandler(_arg1:Object):void{
            var arr:* = null;
            var j:* = 0;
            var len:* = 0;
            var info:* = _arg1;
            try {
                if (info.keyframes){
                    this._timeArr = String(info.keyframes.times).split(",");
                    this._byteArr = String(info.keyframes.filepositions).split(",");
                } else {
                    if (info.seekpoints){
                        arr = info.seekpoints;
                        this._timeArr = [];
                        this._byteArr = [];
                        len = arr.length;
                        j = 0;
                        while (j < len) {
                            this._timeArr.push(arr[j].time);
                            this._byteArr.push(arr[j].time);
                            j = (j + 1);
                        };
                    };
                };
            } catch(e:Error) {
                _timeArr = new Array();
                _byteArr = new Array();
            };
            this.clearSocket();
            this.clearAppendTimer();
            if (GlobalVars.instance.isUseHttpSocket){
                GlobalVars.instance.isHeaderGetted = true;
            };
            JTracer.sendMessage("StreamMetaData -> metaDataHandler, 获取关键帧数组完毕");
            dispatchEvent(new Event(StreamMetaData.KEYFRAME_LOADED));
        }

    }
}//package com.slice 
﻿package com.slice {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    import com.*;
    import flash.media.*;
    import com.common.*;

    public class SliceStreamBytes {

        private static var id:int = 0;

        private var _sIntervalTime:Number = 600;
        private var _spliceByteArr:Array;
        private var _spliceTimeArr:Array;
        private var _byteArr:Array;
        private var _timeArr:Array;
        private var _nextStream:NetStream;
        private var _nextVideo:Video;
        private var _preIndex:int = 0;
        private var _curIndex:int = 0;
        private var _spliceCheckTimer:Timer;
        private var _player:Player;
        private var _firstByteEnd:Number = 0;
        private var _playCheckTimer:Timer;
        private var _cacheStream:NetStream;
        private var _spliceInit:Boolean = false;
        private var _totalTime:Number = 0;
        private var _totalByte:Number = 0;
        private var cn:NetConnection;
        private var _onerror:String;
        private var _arrError:Array;
        private var _buffer:Boolean = false;
        private var _isReloadNext:Boolean = false;
        private var _isReplaceNext:Boolean = false;
        private var _huanNextStream:NetStream;
        private var _feeLoader:FeeLoader;
        private var _isFirstFee:Boolean = true;
        private var _startTime:Number;
        private var _endTime:Number;
        private var _globalVars:GlobalVars;
        private var _timeInterval:Number;
        private var _remainTimes:Number;
        private var _hasNextStream:Boolean = true;
        private var block_size:uint = 131072;
        private var socket_count:uint = 3;
        private var socket_array:Array;
        private var current_pos:uint;
        private var is_append_header:Boolean;
        private var loading_pos:Number;
        private var loading_time:Number;
        private var isRetry:Boolean;
        private var sliceSize:uint;
        private var sliceStart:uint;
        private var isLostData:Boolean;
        public var query_pos:uint;
        public var __id:int = 0;

        public function SliceStreamBytes(_arg1:Player){
            this._spliceByteArr = [];
            this._spliceTimeArr = [];
            this._byteArr = [];
            this._timeArr = [];
            this._arrError = new Array();
            this.socket_array = [];
            super();
            this._player = _arg1;
            this._globalVars = GlobalVars.instance;
            this._globalVars.preFeeTime = 0;
            this._globalVars.nowFeeTime = 0;
            this._feeLoader = FeeLoader.getInstance();
            this._feeLoader.feeSuccess = this.onFeeSuccess;
            this._feeLoader.feeIOError = this.onFeeIOError;
            this._feeLoader.feeSecurityError = this.onFeeSecurityError;
        }
        public function changeByteType():void{
            var _local1:uint;
            var _local2:SingleSocket;
            _local1 = 0;
            while (_local1 < this.socket_array.length) {
                _local2 = this.socket_array[_local1];
                _local2.setByteType(GlobalVars.instance.type_curstream);
                _local1++;
            };
        }
        public function get bytesLoaded():Number{
            var _local1:uint;
            var _local2:uint;
            var _local3:SingleSocket;
            if (GlobalVars.instance.isUseHttpSocket){
                _local2 = 0;
                while (_local2 < this.socket_array.length) {
                    _local3 = this.socket_array[_local2];
                    _local1 = (_local1 + _local3.bytesLoaded);
                    _local2++;
                };
                return (_local1);
            };
            return (this._nextStream.bytesLoaded);
        }
        public function get bytesTotal():Number{
            var _local1:uint;
            var _local2:uint;
            var _local3:SingleSocket;
            if (GlobalVars.instance.isUseHttpSocket){
                _local2 = 0;
                while (_local2 < this.socket_array.length) {
                    _local3 = this.socket_array[_local2];
                    _local1 = (_local1 + _local3.bytesTotal);
                    _local2++;
                };
                return ((_local1 / this.socket_count));
            };
            return (this._nextStream.bytesTotal);
        }
        public function spliceStartCheckTimer():void{
            this._startTime = getTimer();
            if (this._spliceCheckTimer == null){
                this._spliceCheckTimer = new Timer(100, 0);
                this._spliceCheckTimer.addEventListener(TimerEvent.TIMER, this.spliceCheckTimeHandler);
                JTracer.sendMessage("SliceStreamBytes -> spliceStartCheckTimer addEventListener spliceCheckTimeHandler");
            };
            this._spliceCheckTimer.start();
            JTracer.sendMessage("SliceStreamBytes -> spliceStartCheckTimer started");
        }
        private function spliceCheckTimeHandler(_arg1:TimerEvent):void{
            var _local3:Number;
            var _local4:Number;
            this.block_complete(null);
            this._endTime = getTimer();
            this._timeInterval = (this._endTime - this._startTime);
            this._startTime = this._endTime;
            var _local2:Number = Number(Tools.getUserInfo("vodPermit"));
            if ((((((((_local2 == 6)) || ((_local2 == 8)))) || ((_local2 == 10)))) && (!((Tools.getUserInfo("from") == this._globalVars.fromXLPan))))){
                if (this._player.main_mc.isChangeQuality){
                    this._globalVars.nowFeeTime = 0;
                    this._globalVars.preFeeTime = 0;
                };
                if (((((!(this._player.isPause)) && (!(this._player.isStop)))) && (!(this._player.main_mc.isBuffering)))){
                    this._globalVars.nowFeeTime = (this._globalVars.nowFeeTime + this._timeInterval);
                };
                if ((this._globalVars.nowFeeTime - this._globalVars.preFeeTime) >= this._globalVars.feeInterval){
                    _local3 = this._globalVars.preFeeTime;
                    _local4 = this._globalVars.nowFeeTime;
                    this._globalVars.preFeeTime = this._globalVars.nowFeeTime;
                    this._feeLoader.startFee((_local4 / 1000));
                    JTracer.sendMessage(((("SliceStreamBytes -> startFee, timePre:" + _local3) + ", timeAll:") + _local4));
                };
            };
            this.spliceCheckTime(this._player.time);
        }
        private function onFeeSuccess(_arg1:Object):void{
            if (_arg1){
                this._remainTimes = _arg1.remain;
                switch (_arg1.result){
                    case "0":
                        break;
                    case "1":
                        break;
                    case "2":
                        break;
                    case "3":
                        if (Tools.getUserInfo("from") != this._globalVars.fromXLPan){
                            this._player.main_mc.showInvalidLoginLogo();
                        };
                        break;
                    case "4":
                        break;
                    case "5":
                        if (Tools.getUserInfo("from") != this._globalVars.fromXLPan){
                            this._player.main_mc.tryPlayEnded(this._remainTimes);
                            this._player.main_mc.isNoEnoughBytes = true;
                            if (!this._player.isStop){
                                this._player.main_mc._ctrBar.dispatchPause();
                            };
                            JTracer.sendMessage(((("SliceStreamBytes -> 时长用完导致播放停止, ygcid:" + Tools.getUserInfo("ygcid")) + ", userid:") + Tools.getUserInfo("userid")));
                            Tools.stat(("f=fluxoutstop&gcid=" + Tools.getUserInfo("ygcid")));
                        };
                        break;
                    case "6":
                        break;
                    case "7":
                        break;
                };
            };
        }
        private function onFeeIOError():void{
        }
        private function onFeeSecurityError():void{
        }
        private function spliceCheckTime(_arg1:Number):void{
            var _local4:Number;
            var _local5:Number;
            var _local6:Number;
            var _local7:Number;
            var _local8:Number;
            if ((((_arg1 <= 0)) || ((this._spliceTimeArr.length == 0)))){
                return;
            };
            var _local2:Number = this._spliceTimeArr[(this._curIndex + 1)];
            var _local3:Number = (_local2 - _arg1);
            if ((((((((this._player.bytesLoaded >= this._player.bytesTotal)) && ((this._player.bytesTotal < (this._player.sliceSize - 0xC800))))) && (!(this.isLostData)))) && (!(GlobalVars.instance.isUseHttpSocket)))){
                this.isLostData = true;
                _local4 = (this.getNearValueIndex(this._byteArr, (this._player.sliceStart + this._player.bytesTotal)) + 1);
                _local4 = (((_local4 < 1)) ? 1 : _local4);
                _local5 = this._spliceTimeArr[(this._curIndex + 1)];
                _local6 = this._spliceByteArr[(this._curIndex + 1)];
                _local7 = this._timeArr[_local4];
                _local8 = this._byteArr[_local4];
                this._spliceTimeArr[(this._curIndex + 1)] = _local7;
                this._spliceByteArr[(this._curIndex + 1)] = _local8;
                JTracer.sendMessage(((((((((((("SliceStreamBytes -> spliceCheckTime, lostData, replace pos, \nlastTime:" + _local5) + "\nlastPos:") + _local6) + "\nreplaceTime:") + _local7) + "\nreplacePos:") + _local8) + "\nnearIndex:") + _local4) + "\n_curIndex+1:") + (this._curIndex + 1)));
            };
            if ((((_local3 > 120)) && (!(this._player.isPause)))){
                return;
            };
            if ((this._player.bytesLoaded / this._player.bytesTotal) < 0.95){
                return;
            };
            if (((((!((this._preIndex == (this._curIndex + 1)))) && (!(this._isReloadNext)))) && (this._hasNextStream))){
                this.isRetry = false;
                this.isLostData = false;
                this._isReloadNext = true;
                this.preLoadNextStream();
            };
            if ((((((((((_local3 < 0.5)) && ((_arg1 >= 20)))) && (((this._totalTime - _arg1) >= 0.5)))) && (this._nextStream))) && ((((this._nextStream.time > 0)) || (GlobalVars.instance.isUseHttpSocket))))){
                JTracer.sendMessage(((((("SliceStreamBytes -> replaceNextStream, _spliceTimeArr[" + this._preIndex) + "]:") + this._spliceTimeArr[this._preIndex]) + ", time:") + _arg1));
                this._player.replaceNextStream(this._nextStream, this._nextVideo, this.replaceCompeleteHandler, this._onerror);
            };
        }
        private function preLoadNextStream():void{
            var end:* = NaN;
            var suffixUrl:* = null;
            var gdlUrl:* = null;
            this.is_append_header = false;
            this._onerror = null;
            this._arrError = new Array();
            if (this._curIndex >= (this._spliceByteArr.length - 2)){
                return;
            };
            var metaObject:* = new Object();
            metaObject.onMetaData = this.spliceOnMetaDataHandler;
            this.cn = new NetConnection();
            this.cn.connect(null);
            if (this._nextStream != null){
                this._nextStream.removeEventListener(NetStatusEvent.NET_STATUS, this.nullNetStatusEventHandler);
                this._nextStream.close();
                this._nextStream = null;
            };
            this._nextStream = new NetStream(this.cn);
            this._nextStream.bufferTime = 0.001;
            this._nextStream.client = metaObject;
            this._nextStream.soundTransform = new SoundTransform(0);
            this._nextStream.addEventListener(NetStatusEvent.NET_STATUS, this.nullNetStatusEventHandler);
            this._huanNextStream = this._nextStream;
            id++;
            this.__id = id;
            this._nextVideo = new Video(this._player.width, this._player.height);
            this._nextVideo.smoothing = true;
            this._nextVideo.visible = false;
            this._nextVideo.attachNetStream(this._nextStream);
            this._player.addChild(this._nextVideo);
            this._buffer = true;
            var start:* = (((this._curIndex == -1)) ? ((GlobalVars.instance.isUseHttpSocket) ? StreamList.getHeader().length : 0) : this._spliceByteArr[(this._curIndex + 1)]);
            if (this._player.isPause){
                this._hasNextStream = false;
                end = this._totalByte;
            } else {
                this._hasNextStream = true;
                end = ((this._curIndex)==(this._spliceByteArr.length - 3)) ? this._totalByte : this._spliceByteArr[(this._curIndex + 2)];
            };
            this.sliceStart = start;
            this.sliceSize = (end - start);
            this.loading_pos = this._player.query_pos;
            this.loading_time = (((this._curIndex == -1)) ? 0 : this._spliceTimeArr[(this._curIndex + 1)]);
            suffixUrl = ((((("&start=" + start) + "&end=") + end) + "&type=normal&du=") + this._player.vduration);
            gdlUrl = (this._player.playUrl + suffixUrl);
            if (GlobalVars.instance.isUseSocket){
                JTracer.sendMessage("SliceStreamBytes -> preLoadNextStream, connect socket");
                GetNextVodSocket.instance.connect(this._player.playUrl, function (_arg1:String, _arg2:String, _arg3:String, _arg4:int){
                    GlobalVars.instance.isChangeURL = false;
                    if (!_arg1){
                        _player.vodUrl = null;
                        JTracer.sendMessage(("SliceStreamBytes -> preLoadNextStream, get vod url fail, gdl url:" + gdlUrl));
                        _nextStream.play(gdlUrl);
                    } else {
                        _player.vodUrl = (_arg1 + suffixUrl);
                        if (GlobalVars.instance.isUseHttpSocket){
                            current_pos = loading_pos;
                            query_pos = (loading_pos + (socket_count * block_size));
                            JTracer.sendMessage(((((((("SliceStreamBytes -> use socket, preLoadNextStream, get vod url success, vod url:" + _arg1) + ", start_pos:") + loading_pos) + ", end_pos:") + end) + ", next_pos:") + query_pos));
                            downloadStream(_arg1, loading_pos, end);
                        } else {
                            JTracer.sendMessage(("SliceStreamBytes -> preLoadNextStream, get vod url success, vod url:" + _player.vodUrl));
                            _nextStream.play(_player.vodUrl);
                        };
                    };
                    _preIndex = (_curIndex + 1);
                });
            } else {
                GlobalVars.instance.isChangeURL = false;
                this._nextStream.play(gdlUrl);
                this._preIndex = (this._curIndex + 1);
            };
            JTracer.sendMessage(("SliceStreamBytes -> netstream preLoadNextStream, time=" + this._player.time));
        }
        public function clearSocket():void{
            var _local1:uint;
            var _local2:SingleSocket;
            _local1 = 0;
            while (_local1 < this.socket_array.length) {
                _local2 = this.socket_array[_local1];
                _local2.removeEventListener(SingleSocket.All_Complete, this.all_block_complete);
                _local2.removeEventListener(SingleSocket.SocketError, this.block_error);
                _local2.clear();
                _local2 = null;
                _local1++;
            };
            this.socket_array = [];
        }
        private function downloadStream(_arg1:String, _arg2:uint, _arg3:uint):void{
            var _local4:uint;
            var _local5:SingleSocket;
            StreamList.clearNextList();
            this.clearSocket();
            if (this.socket_array.length == 0){
                _local4 = 0;
                while (_local4 < this.socket_count) {
                    _local5 = new SingleSocket(this, _arg1, this.block_size, this.socket_count, (_arg2 + (_local4 * this.block_size)), _arg3, (_arg3 - _arg2), GlobalVars.instance.type_nextstream);
                    _local5.addEventListener(SingleSocket.All_Complete, this.all_block_complete);
                    _local5.addEventListener(SingleSocket.SocketError, this.block_error);
                    _local5.connectSocket();
                    this.socket_array.push(_local5);
                    _local4++;
                };
            } else {
                _local4 = 0;
                while (_local4 < this.socket_count) {
                    _local5 = this.socket_array[_local4];
                    _local5.clear();
                    _local5.setQueryUrl(_arg1);
                    _local5.setQueryRange((_arg2 + (_local4 * this.block_size)), _arg3, (_arg3 - _arg2));
                    _local5.connectSocket();
                    _local4++;
                };
            };
        }
        private function all_block_complete(_arg1:Event):void{
            var _local2:SingleSocket = (_arg1.currentTarget as SingleSocket);
            _local2.clearSocket();
            var _local3:Object = _local2.getCompletePos();
            this._player.query_pos = this.query_pos;
            JTracer.sendMessage(((((("SliceStreamBytes -> all_block_complete, start_pos:" + _local3.start_pos) + ", end_pos:") + _local3.end_pos) + ", next_pos:") + this.query_pos));
        }
        private function block_complete(_arg1:Event):void{
            if (!GlobalVars.instance.isUseHttpSocket){
                return;
            };
            if (!this._nextStream){
                return;
            };
            if (!this.is_append_header){
                this.is_append_header = true;
                this._nextStream.play(null);
                this._nextStream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
                this._nextStream.appendBytes(StreamList.getHeader());
                this._nextStream.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
                this._nextVideo.attachNetStream(this._nextStream);
            };
            var _local2:ByteArray = (StreamList.getBytes(GlobalVars.instance.type_nextstream, this.current_pos, ((this.current_pos + this.block_size) - 1)) as ByteArray);
            if (_local2){
                this._nextStream.appendBytes(_local2);
                this.current_pos = (this.current_pos + this.block_size);
            };
        }
        private function block_error(_arg1:Event):void{
            var _local2:SingleSocket = (_arg1.currentTarget as SingleSocket);
            JTracer.sendMessage(("SliceStreamBytes -> block_error, error_info:" + _local2.getErrorInfo()));
        }
        private function nullNetStatusEventHandler(_arg1:NetStatusEvent=null):void{
            JTracer.sendMessage(("SliceStreamBytes -> status:" + _arg1.info.code));
            if (_arg1.info.code == "NetStream.Buffer.Full"){
                if (this._nextStream != null){
                    JTracer.sendMessage("SliceStreamBytes -> NetStream.Buffer.Full");
                    this._buffer = false;
                    this.checkStreamPlayStart();
                };
            } else {
                if (_arg1.info.code == "NetStream.Play.Start"){
                    JTracer.sendLoaclMsg("SliceStreamBytes -> NetStream.Play.Start");
                } else {
                    if (_arg1.info.code == "NetStream.Play.StreamNotFound"){
                        JTracer.sendMessage(("SliceStreamBytes -> NetStream.Play.StreamNotFound, 加载字节数:" + this._nextStream.bytesLoaded));
                        this._onerror = "302";
                        this._nextStream.close();
                        this._nextStream = null;
                        this.cn.close();
                        this.cn = null;
                        if (!this.isRetry){
                            this.isRetry = true;
                            this._isReloadNext = true;
                            this.preLoadNextStream();
                        };
                    };
                };
            };
        }
        private function clearPlayCheckTimer():void{
            if (this._playCheckTimer != null){
                this._playCheckTimer.stop();
                this._playCheckTimer.removeEventListener(TimerEvent.TIMER, this.playCheckTimerHandler);
                this._playCheckTimer = null;
            };
        }
        private function checkStreamPlayStart():void{
            this.clearPlayCheckTimer();
            this._playCheckTimer = new Timer(50, 0);
            this._playCheckTimer.addEventListener(TimerEvent.TIMER, this.playCheckTimerHandler);
            this._playCheckTimer.start();
        }
        private function playCheckTimerHandler(_arg1:TimerEvent):void{
            if (this._nextStream){
                JTracer.sendMessage(((((("SliceStreamBytes -> playCheckTimerHandler at Stream:" + this.__id) + " bufferLength:") + this._nextStream.bufferLength) + " bufferTime:") + this._nextStream.bufferTime));
            };
            if (((((this._nextStream) && ((this._nextStream.time > (Number(this._spliceTimeArr[this._preIndex]) + 0.1))))) || ((this._playCheckTimer.currentCount > (20 * 10))))){
                JTracer.sendMessage(((((("SliceStreamBytes -> playCheckTimerHandler, _nextStream.pause, _nextStream.time:" + this._nextStream.time) + ", _spliceTimeArr[") + this._preIndex) + "]:") + this._spliceTimeArr[this._preIndex]));
                this._nextStream.pause();
                this.clearPlayCheckTimer();
            };
        }
        private function spliceOnMetaDataHandler(_arg1:Object):void{
        }
        public function spliceGetEndByte(_arg1:Number):Number{
            if (this._spliceInit == false){
                return (this._totalByte);
            };
            var _local2:int;
            var _local3:Number = 0;
            while (_local2 < (this._spliceByteArr.length - 1)) {
                if ((((this._spliceByteArr[_local2] <= _arg1)) && ((_arg1 < this._spliceByteArr[(_local2 + 1)])))){
                    _local3 = this._spliceByteArr[(_local2 + 1)];
                    JTracer.sendMessage(((("SliceStreamBytes -> spliceGetEndByte, find index:" + _local2) + ", nByteEnd:") + _local3));
                    break;
                };
                _local2++;
            };
            JTracer.sendMessage(((((((("SliceStreamBytes -> spliceGetEndByte, startByte:" + _arg1) + ", nByteEnd:") + _local3) + ", _totalByte:") + this._totalByte) + ", _spliceByteArr[_spliceByteArr.length - 1]:") + this._spliceByteArr[(this._spliceByteArr.length - 1)]));
            if (_local2 == (this._spliceByteArr.length - 2)){
                _local3 = this._totalByte;
            };
            _local3 = ((_local3)==0) ? this._totalByte : _local3;
            _local3 = (((((((_local2 == 1)) && ((this._player.dragTime[1] == 0)))) && ((this._player.dragTime.length == 2)))) ? this._player.getVideoUrlArr[0].totalByte : _local3);
            return (_local3);
        }
        public function spliceGetStartByte(_arg1:Number):Number{
            var _local6:Number;
            var _local2:int;
            var _local3:Number = _arg1;
            var _local4:int;
            var _local5:int = this._spliceTimeArr.length;
            while (_local4 < _local5) {
                _local6 = (this._spliceTimeArr[_local4] - _arg1);
                if ((((_local6 > 0)) && ((_local6 < 5)))){
                    _local3 = this._spliceTimeArr[_local4];
                    break;
                };
                _local4++;
            };
            return (_local3);
        }
        public function spliceCheckStartTime(_arg1:Number):Number{
            var _local6:Number;
            var _local2:int;
            var _local3:Number = _arg1;
            var _local4:int;
            var _local5:int = this._spliceTimeArr.length;
            while (_local4 < _local5) {
                _local6 = (this._spliceTimeArr[_local4] - _arg1);
                if ((((_local6 > 0)) && ((_local6 < 5)))){
                    _local3 = this._spliceTimeArr[_local4];
                    break;
                };
                _local4++;
            };
            return (_local3);
        }
        public function spliceReplaceRightNow(_arg1:Number):void{
            var _local2:Number = (this._spliceTimeArr[(this._curIndex + 1)] - _arg1);
            JTracer.sendMessage((("spliceTimeArr:[" + this._spliceTimeArr.join(",")) + "]"));
            JTracer.sendMessage(((((("dexTime:" + _local2) + " spliceTime:") + this._spliceTimeArr[(this._curIndex + 1)]) + " playTime:") + _arg1));
            if ((((_arg1 <= 0)) || ((this._spliceTimeArr.length == 0)))){
                return;
            };
            if ((((_local2 < 0.5)) && ((_arg1 >= 20)))){
                this._player.replaceNextStream(this._nextStream, this._nextVideo, this.replaceCompeleteHandler, this._onerror);
            };
        }
        public function spliceUpdateArray(_arg1:Array, _arg2:Array):void{
            var _local7:*;
            var _local8:Number;
            this._timeArr = _arg1;
            this._byteArr = _arg2;
            JTracer.sendMessage(((((((("SliceStreamBytes -> spliceUpdateArray, timeArr[" + (_arg1.length - 1)) + "]:") + _arg1[(_arg1.length - 1)]) + ", byteArr[") + (_arg2.length - 1)) + "]:") + _arg2[(_arg2.length - 1)]));
            if (((!((_arg1.length == _arg2.length))) || ((_arg1.length == 0)))){
                JTracer.sendMessage(((("SliceStreamBytes -> spliceUpdateArray, timeArr.length != positionArr.length, can not match! timeArr.length:" + _arg1.length) + ", positionArr.length:") + _arg2.length));
                return;
            };
            var _local3:int = (this.getNearValueIndex(_arg1, this._sIntervalTime) + 1);
            JTracer.sendMessage(("SliceStreamBytes -> spliceUpdateArray, 最接近的id:" + _local3));
            var _local4:int = _local3;
            var _local5:int = _arg1.length;
            this._spliceByteArr = [];
            this._spliceTimeArr = [];
            this._spliceByteArr.push(_arg2[0]);
            this._spliceTimeArr.push(_arg1[0]);
            while ((((_local4 < (_local5 - 1))) && ((_local3 > 0)))) {
                this._spliceByteArr.push(_arg2[_local4]);
                this._spliceTimeArr.push(_arg1[_local4]);
                _local4 = (_local4 + _local3);
            };
            this._spliceByteArr.push(_arg2[(_local5 - 1)]);
            this._spliceTimeArr.push(_arg1[(_local5 - 1)]);
            if (((!((this._firstByteEnd == 0))) && ((this._spliceByteArr.length > 2)))){
                _local8 = (this.getNearValueIndex(_arg2, this._firstByteEnd) + 1);
                _local8 = (((_local8 < 1)) ? 1 : _local8);
                this._spliceByteArr[1] = _arg2[_local8];
                this._spliceTimeArr[1] = _arg1[_local8];
            };
            var _local6 = "SliceStreamBytes -> spliceUpdateArray:";
            for (_local7 in this._spliceTimeArr) {
                _local6 = (_local6 + (((((((("\n" + "_spliceTimeArr[") + _local7) + "]:") + this._spliceTimeArr[_local7]) + ",\t_spliceByteArr[") + _local7) + "]:") + this._spliceByteArr[_local7]));
            };
            JTracer.sendMessage(_local6);
        }
        private function getNearValueIndex(_arg1:Array, _arg2:Number):int{
            var _local3 = -3;
            var _local4:int;
            var _local5:int = _arg1.length;
            while (_local4 < _local5) {
                if (_arg1[_local4] > _arg2){
                    _local3 = (_local4 - 2);
                    break;
                };
                _local4++;
            };
            return ((((_local3 == -3)) ? (_arg1.length - 1) : _local3));
        }
        private function isHasValue(_arg1:Array, _arg2:Number):Boolean{
            var _local3:*;
            for (_local3 in _arg1) {
                if (_arg1[_local3] == _arg2){
                    return (true);
                };
            };
            return (false);
        }
        public function replaceCompeleteHandler():void{
            JTracer.sendMessage("SliceStreamBytes -> replaceCompeleteHandler");
            this._player.sliceStart = this.sliceStart;
            this._player.sliceSize = this.sliceSize;
            this._isReloadNext = false;
            this._isReplaceNext = true;
            if (this._nextStream){
                this._nextStream.removeEventListener(NetStatusEvent.NET_STATUS, this.nullNetStatusEventHandler);
            };
            this._nextStream = null;
            this._nextVideo = null;
            this._curIndex = this._preIndex;
            this.clearPlayCheckTimer();
            if (this.cn){
                this.cn.close();
                this.cn = null;
            };
            this._onerror = null;
            this._buffer = false;
        }
        public function spliceUpdate(_arg1:Number):void{
            var _local2:int;
            var _local3:int = this._spliceTimeArr.length;
            _local2 = 0;
            while (_local2 < _local3) {
                if (this._spliceTimeArr[_local2] > _arg1){
                    this.setCurIndex(_local2, _arg1);
                    break;
                };
                if (_local2 == (this._spliceTimeArr.length - 1)){
                    this.setCurIndex(_local2, _arg1);
                    break;
                };
                _local2++;
            };
        }
        private function setCurIndex(_arg1:int, _arg2:Number):void{
            this._curIndex = (_arg1 - 1);
            this._preIndex = (_arg1 - 1);
            if (this._nextStream){
                this._nextStream.close();
                this._nextStream = null;
            };
            if (this.cn){
                this.cn.close();
                this.cn = null;
            };
            this._onerror = null;
            this._buffer = false;
            this._isReloadNext = false;
            this.clearPlayCheckTimer();
            JTracer.sendMessage(((("SliceStreamBytes -> spliceUpdate after seek! _curIndex:" + this._curIndex) + ", time:") + _arg2));
        }
        public function clear():void{
            JTracer.sendMessage("SliceStreamBytes -> clear");
            this._spliceByteArr = [];
            this._spliceTimeArr = [];
            this._curIndex = 0;
            this._preIndex = 0;
            this._firstByteEnd = 0;
            if (this._nextStream){
                this._nextStream.close();
                this._nextStream = null;
            };
            if (this.cn){
                this.cn.close();
                this.cn = null;
            };
            this.clearPlayCheckTimer();
            this.clearSocket();
            this._onerror = null;
            this._buffer = false;
            this._isReloadNext = false;
            this._isReplaceNext = false;
            if (this._spliceCheckTimer){
                this._spliceCheckTimer.removeEventListener(TimerEvent.TIMER, this.spliceCheckTimeHandler);
                this._spliceCheckTimer.stop();
                this._spliceCheckTimer = null;
            };
        }
        public function get bufferStartTime():Number{
            JTracer.sendMessage(("SliceStreamBytes -> bufferStartTime, _curIndex:" + this._curIndex));
            return (((this._spliceTimeArr[this._curIndex]) || (0)));
        }
        public function get bufferEndTime():Number{
            var _local1:int = ((this._isReloadNext) ? (this._curIndex + 1) : (this._curIndex + 2));
            if ((((((_local1 == 1)) && ((this._spliceTimeArr[1] == 0)))) && ((this._spliceTimeArr.length == 2)))){
                return (this._totalTime);
            };
            return (((this._spliceTimeArr[_local1]) || (this._spliceTimeArr[(this._spliceTimeArr.length - 1)])));
        }
        public function set firstByteEnd(_arg1:Number):void{
            JTracer.sendMessage(("SliceStreamBytes -> firstByteEnd:" + _arg1));
            this._firstByteEnd = _arg1;
        }
        public function set sliceTime(_arg1:Number):void{
            this._sIntervalTime = (((_arg1 < 30)) ? 30 : _arg1);
            this._spliceInit = true;
            JTracer.sendMessage(("SliceStreamBytes -> sliceTime:" + _arg1));
        }
        public function get spliceInit():Boolean{
            return (this._spliceInit);
        }
        public function set totalByte(_arg1:Number):void{
            this._totalByte = _arg1;
        }
        public function set totalTime(_arg1:Number):void{
            this._totalTime = _arg1;
        }
        public function get arrError():Array{
            return (this._arrError);
        }
        public function get buffer():Boolean{
            return (this._buffer);
        }
        public function get nextStream():NetStream{
            return (this._nextStream);
        }
        public function get sliceStartTime():Number{
            return (this._spliceTimeArr[this._curIndex]);
        }
        public function get sliceEndTime():Number{
            if (((!(this._hasNextStream)) && (!(this._isReloadNext)))){
                return (this._totalTime);
            };
            var _local1:int = (this._curIndex + 1);
            if ((((((_local1 == 1)) && ((this._spliceTimeArr[1] == 0)))) && ((this._spliceTimeArr.length == 2)))){
                return (this._totalTime);
            };
            return (((this._spliceTimeArr[_local1]) || (this._spliceTimeArr[(this._spliceTimeArr.length - 1)])));
        }
        public function get sliceEnd2Time():Number{
            if (!this._hasNextStream){
                return (this._totalTime);
            };
            var _local1:int = (this._curIndex + 2);
            if (_local1 >= this._spliceTimeArr.length){
                return (this._totalTime);
            };
            return (this._spliceTimeArr[_local1]);
        }
        public function get nextVideo():Video{
            return (this._nextVideo);
        }
        public function get isReloadNext():Boolean{
            return (this._isReloadNext);
        }
        public function get isReplaceNext():Boolean{
            return (this._isReplaceNext);
        }
        public function set isReplaceNext(_arg1:Boolean):void{
            this._isReplaceNext = _arg1;
        }
        public function get huanNextStream():NetStream{
            return (this._huanNextStream);
        }
        public function set hasNextStream(_arg1:Boolean):void{
            this._hasNextStream = _arg1;
        }
        public function get loadingPos():Number{
            return (this.loading_pos);
        }
        public function get loadingTime():Number{
            return (this.loading_time);
        }

    }
}//package com.slice 
﻿package com.common {

    public class StringUtil {

        public static function getHostPort(_arg1:String):Object{
            var _local2:String = getRealURL(_arg1);
            var _local3:String = _local2.substr(_local2.indexOf("/"));
            var _local4:String = _local2.substr(0, _local2.indexOf("/"));
            var _local5:uint = 80;
            var _local6:Array = _local4.split(":");
            if (_local6.length > 1){
                _local4 = _local6[0];
                _local5 = _local6[1];
            };
            return ({
                url:_local3,
                host:_local4,
                port:_local5
            });
        }
        public static function getResponseHeader(_arg1:String, _arg2:String, _arg3:String):String{
            var _local6:*;
            var _local7:int;
            var _local8:Array;
            if (((!(_arg1)) || ((_arg1 == "")))){
                trace(((((("not found header:" + _arg2) + ", separate:") + _arg3) + ", response:") + _arg1));
                return (null);
            };
            var _local4:int = _arg1.indexOf(_arg2);
            if (_local4 < 0){
                trace(("not found header:" + _arg2));
                return (null);
            };
            var _local5:Array = _arg1.split("\r\n");
            for (_local6 in _local5) {
                _local8 = _local5[_local6].split(_arg3);
                if ((((_local8.length > 1)) && ((trim(_local8[0]) == _arg2)))){
                    if (_arg3 == ":"){
                        _local7 = _local5[_local6].indexOf(":");
                        return (trim(_local5[_local6].substr((_local7 + 1))));
                    };
                    return (trim(_local8[1]));
                };
            };
            return (null);
        }
        public static function trim(_arg1:String):String{
            return (_arg1.replace(/^\s+/, "").replace(/\s+$/, ""));
        }
        public static function getShortenURL(_arg1:String):String{
            if (!_arg1){
                return (null);
            };
            _arg1 = getRealURL(_arg1);
            _arg1 = _arg1.substr(0, _arg1.indexOf("/"));
            return (_arg1);
        }
        private static function getRealURL(_arg1:String):String{
            var _local2:String;
            var _local3:Array;
            if (_arg1.indexOf("://") >= 0){
                _local3 = _arg1.split("://");
                _local2 = _local3[1];
            } else {
                _local2 = _arg1;
            };
            return (_local2);
        }

    }
}//package com.common 
﻿package com.common {
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;

    public class GetVodCodeSocket {

        private static var _instance:GetVodCodeSocket;

        private var socket:Socket;
        private var host:String;
        private var port:uint;
        private var vod:String;
        private var queryPos:Number;
        private var endPos:Number;
        private var responseBytes:ByteArray;
        private var response:String;
        private var completeFun:Function;
        private var origin_url:String;
        private var url:String;
        private var error_code:String;

        public function GetVodCodeSocket(){
            this.socket = new Socket();
            this.socket.timeout = 5000;
            this.socket.addEventListener(Event.CONNECT, this.connectSuccess);
            this.socket.addEventListener(ProgressEvent.SOCKET_DATA, this.receiveSocketData);
            this.socket.addEventListener(Event.CLOSE, this.closeSocketHandler);
            this.socket.addEventListener(IOErrorEvent.IO_ERROR, this.connectIOError);
            this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.connctSecurityError);
        }
        public static function get instance():GetVodCodeSocket{
            if (!_instance){
                _instance = new (GetVodCodeSocket)();
            };
            return (_instance);
        }

        public function connect(_arg1:Object, _arg2:Function):void{
            this.origin_url = _arg1.url;
            this.error_code = _arg1.error_code;
            this.responseBytes = new ByteArray();
            this.response = null;
            this.completeFun = _arg2;
            this.url = this.getRealURL(_arg1.url);
            this.host = this.url.substr(0, this.url.indexOf("/"));
            this.port = 80;
            var _local3:Array = this.host.split(":");
            if (_local3.length > 1){
                this.host = _local3[0];
                this.port = _local3[1];
            };
            this.vod = this.url.substr(this.url.indexOf("/"));
            var _local4:URLVariables = new URLVariables(this.url);
            this.queryPos = _local4["start"];
            this.endPos = _local4["end"];
            JTracer.sendMessage(((((((((("GetVodCodeSocket -> connect, \nhost:" + this.host) + "\nport:") + this.port) + "\nvod:") + this.vod) + "\nqueryPos:") + this.queryPos) + "\nendPos:") + this.endPos));
            this.socket.connect(this.host, this.port);
        }
        private function closeSocket():void{
            if (this.socket.connected){
                this.socket.close();
                JTracer.sendMessage("GetVodCodeSocket -> socket.close()");
            };
        }
        private function connectSuccess(_arg1:Event):void{
            JTracer.sendMessage("GetVodCodeSocket -> Connect Success");
            var _local2 = (("GET " + this.vod) + " \r\n");
            _local2 = (_local2 + (((("Range: bytes=" + this.queryPos) + "-") + this.endPos) + " \r\n"));
            _local2 = (_local2 + (((("Host: " + this.host) + ":") + this.port) + " \r\n\r\n"));
            this.socket.writeUTFBytes(_local2);
            this.socket.flush();
        }
        private function receiveSocketData(_arg1:ProgressEvent):void{
            var _local2:String;
            JTracer.sendMessage("GetVodCodeSocket -> Receive Socket Data");
            if (this.socket.bytesAvailable > 0){
                this.responseBytes.clear();
                this.socket.readBytes(this.responseBytes, 0, this.socket.bytesAvailable);
                this.response = this.responseBytes.toString();
                JTracer.sendMessage(("GetVodCodeSocket -> response:\n" + this.response));
                _local2 = this.getResponseHeader("HTTP/1.1", " ");
                this.completeFun({
                    origin_url:this.origin_url,
                    url_type:"vod",
                    status_code:_local2,
                    error_code:this.error_code
                });
                this.closeSocket();
            };
        }
        private function closeSocketHandler(_arg1:Event):void{
            JTracer.sendMessage("GetVodCodeSocket -> Connect Close");
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            this.completeFun({
                origin_url:this.origin_url,
                url_type:"vod",
                status_code:_local2,
                error_code:this.error_code
            });
            this.closeSocket();
        }
        private function connectIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("GetVodCodeSocket -> Connect IOError");
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            this.completeFun({
                origin_url:this.origin_url,
                url_type:"vod",
                status_code:_local2,
                error_code:this.error_code
            });
            this.closeSocket();
        }
        private function connctSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage(("GetVodCodeSocket -> Connct SecurityError, text:" + _arg1.text));
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            this.completeFun({
                origin_url:this.origin_url,
                url_type:"vod",
                status_code:_local2,
                error_code:this.error_code
            });
            this.closeSocket();
        }
        private function getRealURL(_arg1:String):String{
            var _local2:String;
            var _local3:Array;
            if (_arg1.indexOf("://") >= 0){
                _local3 = _arg1.split("://");
                _local2 = _local3[1];
            } else {
                _local2 = _arg1;
            };
            return (_local2);
        }
        private function getResponseHeader(_arg1:String, _arg2:String):String{
            var _local5:*;
            var _local6:int;
            var _local7:Array;
            if (((!(this.response)) || ((this.response == "")))){
                JTracer.sendMessage(((((("GetVodCodeSocket -> not found header:" + _arg1) + ", separate:") + _arg2) + ", response:") + this.response));
                return (null);
            };
            var _local3:int = this.response.indexOf(_arg1);
            if (_local3 < 0){
                JTracer.sendMessage(("GetVodCodeSocket -> not found header:" + _arg1));
                return (null);
            };
            var _local4:Array = this.response.split("\r\n");
            for (_local5 in _local4) {
                _local7 = _local4[_local5].split(_arg2);
                if ((((_local7.length > 1)) && ((this.trim(_local7[0]) == _arg1)))){
                    if (_arg2 == ":"){
                        _local6 = _local4[_local5].indexOf(":");
                        return (this.trim(_local4[_local5].substr((_local6 + 1))));
                    };
                    return (this.trim(_local7[1]));
                };
            };
            return (null);
        }
        private function trim(_arg1:String):String{
            return (_arg1.replace(/^\s+/, "").replace(/\s+$/, ""));
        }

    }
}//package com.common 
﻿package com.common {

    public class GetVodSocket extends BaseSocket {

        private static var _instance:GetVodSocket;

        public function GetVodSocket():void{
        }
        public static function get instance():GetVodSocket{
            if (!_instance){
                _instance = new (GetVodSocket)();
            };
            return (_instance);
        }

        override public function connect(_arg1:String, _arg2:Function):void{
            super.connect(_arg1, _arg2);
        }

    }
}//package com.common 
﻿package com.common {
    import flash.display.*;
    import flash.geom.*;

    public class BitmapScale9Grid extends Sprite {

        private var source:BitmapData;
        private var scaleGridTop:Number;
        private var scaleGridBottom:Number;
        private var scaleGridLeft:Number;
        private var scaleGridRight:Number;
        private var leftUp:Bitmap;
        private var leftCenter:Bitmap;
        private var leftBottom:Bitmap;
        private var centerUp:Bitmap;
        private var center:Bitmap;
        private var centerBottom:Bitmap;
        private var rightUp:Bitmap;
        private var rightCenter:Bitmap;
        private var rightBottom:Bitmap;
        private var _width:Number;
        private var _height:Number;
        private var minWidth:Number;
        private var minHeight:Number;

        public function BitmapScale9Grid(_arg1:BitmapData, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number){
            this.source = _arg1;
            this.scaleGridTop = _arg2;
            this.scaleGridBottom = _arg3;
            this.scaleGridLeft = _arg4;
            this.scaleGridRight = _arg5;
            this.init();
        }
        private function init():void{
            this._width = this.source.width;
            this._height = this.source.height;
            this.leftUp = this.getBitmap(0, 0, this.scaleGridLeft, this.scaleGridTop);
            this.addChild(this.leftUp);
            this.leftCenter = this.getBitmap(0, this.scaleGridTop, this.scaleGridLeft, (this.scaleGridBottom - this.scaleGridTop));
            this.addChild(this.leftCenter);
            this.leftBottom = this.getBitmap(0, this.scaleGridBottom, this.scaleGridLeft, (this._height - this.scaleGridBottom));
            this.addChild(this.leftBottom);
            this.centerUp = this.getBitmap(this.scaleGridLeft, 0, (this.scaleGridRight - this.scaleGridLeft), this.scaleGridTop);
            this.addChild(this.centerUp);
            this.center = this.getBitmap(this.scaleGridLeft, this.scaleGridTop, (this.scaleGridRight - this.scaleGridLeft), (this.scaleGridBottom - this.scaleGridTop));
            this.addChild(this.center);
            this.centerBottom = this.getBitmap(this.scaleGridLeft, this.scaleGridBottom, (this.scaleGridRight - this.scaleGridLeft), (this._height - this.scaleGridBottom));
            this.addChild(this.centerBottom);
            this.rightUp = this.getBitmap(this.scaleGridRight, 0, (this._width - this.scaleGridRight), this.scaleGridTop);
            this.addChild(this.rightUp);
            this.rightCenter = this.getBitmap(this.scaleGridRight, this.scaleGridTop, (this._width - this.scaleGridRight), (this.scaleGridBottom - this.scaleGridTop));
            this.addChild(this.rightCenter);
            this.rightBottom = this.getBitmap(this.scaleGridRight, this.scaleGridBottom, (this._width - this.scaleGridRight), (this._height - this.scaleGridBottom));
            this.addChild(this.rightBottom);
            this.minWidth = (this.leftUp.width + this.rightBottom.width);
            this.minHeight = (this.leftBottom.height + this.rightBottom.height);
        }
        private function getBitmap(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number):Bitmap{
            var _local5:BitmapData = new BitmapData(_arg3, _arg4);
            _local5.copyPixels(this.source, new Rectangle(_arg1, _arg2, _arg3, _arg4), new Point(0, 0));
            var _local6:Bitmap = new Bitmap(_local5);
            _local6.x = _arg1;
            _local6.y = _arg2;
            return (_local6);
        }
        override public function set width(_arg1:Number):void{
            if (_arg1 < this.minWidth){
                _arg1 = this.minWidth;
            };
            this._width = _arg1;
            this.refurbishSize();
        }
        override public function set height(_arg1:Number):void{
            if (_arg1 < this.minHeight){
                _arg1 = this.minHeight;
            };
            this._height = _arg1;
            this.refurbishSize();
        }
        private function refurbishSize():void{
            this.leftCenter.height = ((this._height - this.leftUp.height) - this.leftBottom.height);
            this.leftBottom.y = (this._height - this.leftBottom.height);
            this.centerUp.width = ((this._width - this.leftUp.width) - this.rightUp.width);
            this.center.width = this.centerUp.width;
            this.center.height = this.leftCenter.height;
            this.centerBottom.width = this.center.width;
            this.centerBottom.y = this.leftBottom.y;
            this.rightUp.x = (this._width - this.rightUp.width);
            this.rightCenter.x = this.rightUp.x;
            this.rightCenter.height = this.center.height;
            this.rightBottom.x = this.rightUp.x;
            this.rightBottom.y = this.leftBottom.y;
        }

    }
}//package com.common 
﻿package com.common {
    import com.global.*;
    import flash.net.*;
    import flash.display.*;
    import flash.geom.*;
    import ctr.tip.*;
    import flash.external.*;

    public class Tools {

        private static var _mainMc:Sprite;
        private static var _snptBmd:BitmapData;

        public static function getDocumentCookieWithKey(_arg1:String):String{
            var _local3:String;
            var _local4:Array;
            var _local5:*;
            var _local6:Array;
            var _local2 = "";
            if (ExternalInterface.available){
                _local3 = ExternalInterface.call("function(){return document.cookie;}");
                if (((((_local3) && (!((_local3 == ""))))) && (!((_local3 == "null"))))){
                    _local4 = _local3.split("; ");
                    for (_local5 in _local4) {
                        _local6 = _local4[_local5].split("=");
                        if (_local6[0] == _arg1){
                            _local2 = _local6[1];
                            return (_local2);
                        };
                    };
                };
            };
            return ("");
        }
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

    public class KKCountReport {

        private static const kkpgv:String = "http://kkpgv.xunlei.com/?u=flv_player_";
        private static const kkpgv2:String = "http://kkpgv2.xunlei.com/?u=";

        public static function sendKankanPgv(_arg1):void{
            var _local2:String = ("_51&rd=" + new Date().getTime().toString());
            var _local3:URLRequest = new URLRequest(((kkpgv + String(_arg1)) + _local2));
        }
        public static function sendKankanPgv2(_arg1):void{
            var _local2:String = ("_51&rd=" + new Date().getTime().toString());
            var _local3:URLRequest = new URLRequest(((kkpgv2 + String(_arg1)) + _local2));
        }

    }
}//package com.common 
﻿package com.common {

    public class GetNextVodSocket extends BaseSocket {

        private static var _instance:GetNextVodSocket;

        public function GetNextVodSocket():void{
        }
        public static function get instance():GetNextVodSocket{
            if (!_instance){
                _instance = new (GetNextVodSocket)();
            };
            return (_instance);
        }

        override public function connect(_arg1:String, _arg2:Function):void{
            super.connect(_arg1, _arg2);
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
                ExternalInterface.call("G_PLAYER_INSTANCE.trace", ((getTime() + "----") + text));
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
        private static function getTime():String{
            var _local1:Date = new Date();
            var _local2:String = _local1.getFullYear().toString();
            var _local3:String = formatZero((_local1.getMonth() + 1));
            var _local4:String = formatZero(_local1.getDate());
            var _local5:String = formatZero(_local1.getHours());
            var _local6:String = formatZero(_local1.getMinutes());
            var _local7:String = formatZero(_local1.getSeconds());
            var _local8:String = _local1.getMilliseconds().toString();
            return (((((((((((((_local2 + "-") + _local3) + "-") + _local4) + " ") + _local5) + ":") + _local6) + ":") + _local7) + " ") + _local8));
        }
        private static function formatZero(_arg1:Number):String{
            if (_arg1 < 10){
                return (("0" + _arg1.toString()));
            };
            return (_arg1.toString());
        }

    }
}//package com.common 
﻿package com.common {
    import flash.net.*;

    public class Cookies {

        private static var cookie:SharedObject;

        private static function init():void{
            if (!cookie){
                cookie = SharedObject.getLocal("svInfo");
            };
        }
        public static function setCookie(_arg1:String, _arg2):void{
            var i:* = 0;
            var id:* = _arg1;
            var value:* = _arg2;
            JTracer.sendMessage(((("Cookies -> setCookie, id=" + id) + ", value=") + value));
            init();
            var boxes:* = ((cookie.data.boxes) || ([]));
            var len:* = boxes.length;
            i = 0;
            while (i < len) {
                if (boxes[i].id == id){
                    boxes[i].value = value;
                    try {
                        cookie.flush();
                    } catch(e:Error) {
                        JTracer.sendMessage("Cookies -> setCookie, SharedObject.flush() error");
                    };
                    return;
                };
                i = (i + 1);
            };
            boxes.push({
                id:id,
                value:value
            });
            cookie.data.boxes = boxes;
            try {
                cookie.flush();
            } catch(e:Error) {
                JTracer.sendMessage("Cookies -> setCookie, SharedObject.flush() error");
            };
        }
        public static function getCookie(_arg1:String){
            var _local3:uint;
            init();
            var _local2:Array = ((cookie.data.boxes) || ([]));
            var _local4:uint = _local2.length;
            _local3 = 0;
            while (_local3 < _local4) {
                if (_local2[_local3].id == _arg1){
                    JTracer.sendMessage(((("Cookies -> getCookie, id=" + _arg1) + ", value=") + _local2[_local3].value));
                    return (_local2[_local3].value);
                };
                _local3++;
            };
            JTracer.sendMessage((("Cookies -> getCookie, id=" + _arg1) + ", value=null"));
            return (null);
        }

    }
}//package com.common 
﻿package com.common {
    import flash.net.*;
    import flash.events.*;
    import flash.external.*;

    public class GetGdlCodeSocket {

        private static var _instance:GetGdlCodeSocket;

        private var socket:Socket;
        private var host:String;
        private var port:Number;
        private var gdlLink:String;
        private var cookie:String;
        private var referer:String;
        private var response:String;
        private var gdl:String;
        private var origin_url:String;
        private var completeFun:Function;
        private var url_type:String;
        private var error_code:String;

        public function GetGdlCodeSocket():void{
            this.socket = new Socket();
            this.socket.timeout = 5000;
            this.socket.addEventListener(Event.CONNECT, this.connectSuccess);
            this.socket.addEventListener(ProgressEvent.SOCKET_DATA, this.receiveSocketData);
            this.socket.addEventListener(Event.CLOSE, this.closeSocketHandler);
            this.socket.addEventListener(IOErrorEvent.IO_ERROR, this.connectIOError);
            this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.connctSecurityError);
        }
        public static function get instance():GetGdlCodeSocket{
            if (!_instance){
                _instance = new (GetGdlCodeSocket)();
            };
            return (_instance);
        }

        public function connect(_arg1:String, _arg2:String, _arg3:Function):void{
            this.gdl = _arg1;
            this.origin_url = _arg1;
            this.error_code = _arg2;
            this.completeFun = _arg3;
            this.url_type = "vod";
            var _local4:String = this.getFormatURL(this.gdl);
            var _local5:String = _local4.substr(0, _local4.indexOf("/"));
            if (((!((_local5.indexOf("gdl") == 0))) && (!((_local5.indexOf("dl") == 0))))){
                JTracer.sendMessage(("GetGdlCodeSocket -> connect, 页面传递vod地址, vod url:" + this.gdl));
                this.completeFun({
                    url:this.gdl,
                    origin_url:this.origin_url,
                    url_type:this.url_type,
                    status_code:"200",
                    error_code:this.error_code
                });
                return;
            };
            this.url_type = "gdl";
            if (_local5.indexOf("dl") == 0){
                this.url_type = "dl";
            };
            JTracer.sendMessage(("GetGdlCodeSocket -> connect, 页面传递gdl地址, gdl url:" + this.gdl));
            var _local6:Object = StringUtil.getHostPort(_local4);
            this.host = _local6.host;
            this.port = _local6.port;
            this.gdlLink = _local4.substr(_local4.indexOf("/"));
            this.cookie = ((ExternalInterface.call("G_PLAYER_INSTANCE.getParamInfo", "oriCookie")) || (""));
            this.referer = ((ExternalInterface.call("G_PLAYER_INSTANCE.getParamInfo", "referer")) || (""));
            JTracer.sendMessage(((((((((("GetGdlCodeSocket -> connect, \nhost:" + this.host) + "\nport:") + this.port) + "\ngdl:") + this.gdlLink) + "\ncookie:") + this.cookie) + "\nreferer:") + this.referer));
            JTracer.sendMessage("GetGdlCodeSocket -> start connect");
            this.response = "";
            this.socket.connect(this.host, this.port);
        }
        private function replaceTS(_arg1:String):String{
            var _local3:String;
            var _local4:String;
            var _local5:String;
            var _local6:String;
            if (!_arg1){
                return (null);
            };
            var _local2:int = _arg1.indexOf("&ts=");
            if (_local2 >= 0){
                _local3 = int((new Date().getTime() / 1000)).toString();
                _local4 = _arg1.substr(0, _local2);
                _local5 = _arg1.substr((_local2 + 14));
                _local6 = (((_local4 + "&ts=") + _local3) + _local5);
                return (_local6);
            };
            return (_arg1);
        }
        private function closeSocket():void{
            if (this.socket.connected){
                this.socket.close();
                JTracer.sendMessage("GetGdlCodeSocket -> socket.close()");
            };
        }
        private function getFormatURL(_arg1:String):String{
            var _local2:String;
            var _local3:Array;
            if (_arg1.indexOf("://") >= 0){
                _local3 = _arg1.split("://");
                _local2 = _local3[1];
            } else {
                _local2 = _arg1;
            };
            return (_local2);
        }
        private function connectSuccess(_arg1:Event):void{
            JTracer.sendMessage("GetGdlCodeSocket -> Connect Success");
            var _local2 = (("GET " + this.gdlLink) + " \r\n");
            _local2 = (_local2 + (("Host: " + this.host) + " \r\n"));
            _local2 = (_local2 + "User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:14.0) Gecko/20100101 Firefox/14.0.1 \r\n");
            _local2 = (_local2 + "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8 \r\n");
            _local2 = (_local2 + "Accept-Language: zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3 \r\n");
            _local2 = (_local2 + "Accept-Encoding: gzip, deflate \r\n");
            _local2 = (_local2 + "Connection: keep-alive \r\n");
            _local2 = (_local2 + (("Referer: " + this.referer) + " \r\n"));
            _local2 = (_local2 + (("Cookie: " + this.cookie) + " \r\n"));
            _local2 = (_local2 + "UA-CPU: x86 \r\n");
            _local2 = (_local2 + "Cache-Control: no-cache \r\n\r\n");
            this.socket.writeUTFBytes(_local2);
            this.socket.flush();
        }
        private function receiveSocketData(_arg1:ProgressEvent):void{
            JTracer.sendMessage("GetGdlCodeSocket -> Receive Socket Data");
            var _local2:String = this.socket.readUTFBytes(this.socket.bytesAvailable);
            this.response = (this.response + _local2);
            var _local3:String = this.getResponseHeader("HTTP/1.1", " ");
            JTracer.sendMessage(((("GetGdlCodeSocket -> response:\n" + this.response) + "\nstatus:") + _local3));
            var _local4:int = this.response.indexOf("\r\n\r\n");
            if (_local4 < 0){
                JTracer.sendMessage("GetGdlCodeSocket -> response header not receive finish");
                this.completeFun({
                    url:null,
                    origin_url:this.origin_url,
                    url_type:this.url_type,
                    status_code:_local3,
                    error_code:this.error_code
                });
                this.closeSocket();
                return;
            };
            var _local5:String = this.getResponseHeader("Location", ":");
            this.completeFun({
                url:_local5,
                origin_url:this.origin_url,
                url_type:this.url_type,
                status_code:_local3,
                error_code:this.error_code
            });
            this.closeSocket();
        }
        private function closeSocketHandler(_arg1:Event):void{
            JTracer.sendMessage("GetGdlCodeSocket -> Connect Close");
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            this.completeFun({
                url:null,
                origin_url:this.origin_url,
                url_type:this.url_type,
                status_code:_local2,
                error_code:this.error_code
            });
            this.closeSocket();
        }
        private function connectIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("GetGdlCodeSocket -> Connect IOError");
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            this.completeFun({
                url:null,
                origin_url:this.origin_url,
                url_type:this.url_type,
                status_code:_local2,
                error_code:this.error_code
            });
            this.closeSocket();
        }
        private function connctSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage(("GetGdlCodeSocket -> Connct SecurityError, text:" + _arg1.text));
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            this.completeFun({
                url:null,
                origin_url:this.origin_url,
                url_type:this.url_type,
                status_code:_local2,
                error_code:this.error_code
            });
            this.closeSocket();
        }
        private function getResponseHeader(_arg1:String, _arg2:String):String{
            var _local5:*;
            var _local6:int;
            var _local7:Array;
            if (((!(this.response)) || ((this.response == "")))){
                JTracer.sendMessage(((((("GetGdlCodeSocket -> not found header:" + _arg1) + ", separate:") + _arg2) + ", response:") + this.response));
                return (null);
            };
            var _local3:int = this.response.indexOf(_arg1);
            if (_local3 < 0){
                JTracer.sendMessage(("GetGdlCodeSocket -> not found header:" + _arg1));
                return (null);
            };
            var _local4:Array = this.response.split("\r\n");
            for (_local5 in _local4) {
                _local7 = _local4[_local5].split(_arg2);
                if ((((_local7.length > 1)) && ((this.trim(_local7[0]) == _arg1)))){
                    if (_arg2 == ":"){
                        _local6 = _local4[_local5].indexOf(":");
                        return (this.trim(_local4[_local5].substr((_local6 + 1))));
                    };
                    return (this.trim(_local7[1]));
                };
            };
            return (null);
        }
        private function trim(_arg1:String):String{
            return (_arg1.replace(/^\s+/, "").replace(/\s+$/, ""));
        }

    }
}//package com.common 
﻿package com.common {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    import flash.external.*;

    public class BaseSocket {

        private var socket:Socket;
        private var host:String;
        private var port:Number;
        private var gdlLink:String;
        private var cookie:String;
        private var referer:String;
        private var response:String;
        private var gdl:String;
        private var completeFun:Function;
        private var utype:String;
        private var startTime:int;

        public function BaseSocket():void{
            this.socket = new Socket();
            this.socket.timeout = 5000;
            this.socket.addEventListener(Event.CONNECT, this.connectSuccess);
            this.socket.addEventListener(ProgressEvent.SOCKET_DATA, this.receiveSocketData);
            this.socket.addEventListener(Event.CLOSE, this.closeSocketHandler);
            this.socket.addEventListener(IOErrorEvent.IO_ERROR, this.connectIOError);
            this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.connctSecurityError);
        }
        public function connect(_arg1:String, _arg2:Function):void{
            this.gdl = _arg1;
            this.completeFun = _arg2;
            this.utype = "vod";
            if (GlobalVars.instance.isVodGetted){
                JTracer.sendMessage(("GetVodSocket -> connect, socket已成功取vod地址, vod url:" + GlobalVars.instance.vodURL));
                this.completeFun(this.replaceTS(GlobalVars.instance.vodURL), this.utype, "200", 0);
                return;
            };
            if (GlobalVars.instance.isIPLink){
                GlobalVars.instance.isVodGetted = true;
                GlobalVars.instance.vodURL = this.gdl;
                JTracer.sendMessage(("GetVodSocket -> connect, 使用ip地址播放, ip_gdl url:" + this.gdl));
                this.completeFun(this.replaceTS(GlobalVars.instance.vodURL), "ip", "200", 0);
                return;
            };
            var _local3:String = this.getFormatURL(this.gdl);
            var _local4:String = _local3.substr(0, _local3.indexOf("/"));
            if (((!((_local4.indexOf("gdl") == 0))) && (!((_local4.indexOf("dl") == 0))))){
                GlobalVars.instance.isVodGetted = true;
                GlobalVars.instance.vodURL = this.gdl;
                JTracer.sendMessage(("GetVodSocket -> connect, 页面传递vod地址, vod url:" + GlobalVars.instance.vodURL));
                this.completeFun(this.replaceTS(GlobalVars.instance.vodURL), this.utype, "200", 0);
                return;
            };
            this.startTime = getTimer();
            this.utype = "gdl";
            if (_local4.indexOf("dl") == 0){
                this.utype = "dl";
            };
            JTracer.sendMessage(("GetVodSocket -> connect, 页面传递gdl地址, gdl url:" + this.gdl));
            var _local5:Object = StringUtil.getHostPort(_local3);
            this.host = _local5.host;
            this.port = _local5.port;
            this.gdlLink = _local3.substr(_local3.indexOf("/"));
            this.cookie = ((ExternalInterface.call("G_PLAYER_INSTANCE.getParamInfo", "oriCookie")) || (("utype=" + this.utype)));
            this.referer = ((ExternalInterface.call("G_PLAYER_INSTANCE.getParamInfo", "referer")) || ("http://vod.xunlei.com"));
            JTracer.sendMessage(((((((((("GetVodSocket -> connect, \nhost:" + this.host) + "\nport:") + this.port) + "\ngdl:") + this.gdlLink) + "\ncookie:") + this.cookie) + "\nreferer:") + this.referer));
            JTracer.sendMessage("GetVodSocket -> start connect");
            GlobalVars.instance.isVodGetted = false;
            this.response = "";
            this.socket.connect(this.host, this.port);
        }
        private function replaceTS(_arg1:String):String{
            var _local3:String;
            var _local4:String;
            var _local5:String;
            var _local6:String;
            if (!_arg1){
                return (null);
            };
            var _local2:int = _arg1.indexOf("&ts=");
            if (_local2 >= 0){
                _local3 = int((new Date().getTime() / 1000)).toString();
                _local4 = _arg1.substr(0, _local2);
                _local5 = _arg1.substr((_local2 + 14));
                _local6 = (((_local4 + "&ts=") + _local3) + _local5);
                return (_local6);
            };
            return (_arg1);
        }
        private function closeSocket():void{
            if (this.socket.connected){
                this.socket.close();
                JTracer.sendMessage("GetVodSocket -> socket.close()");
            };
        }
        private function getFormatURL(_arg1:String):String{
            var _local2:String;
            var _local3:Array;
            if (_arg1.indexOf("://") >= 0){
                _local3 = _arg1.split("://");
                _local2 = _local3[1];
            } else {
                _local2 = _arg1;
            };
            return (_local2);
        }
        private function connectSuccess(_arg1:Event):void{
            JTracer.sendMessage("GetVodSocket -> Connect Success");
            GlobalVars.instance.connectGldTime = (getTimer() - this.startTime);
            var _local2 = (("GET " + this.gdlLink) + " HTTP/1.1 \r\n");
            _local2 = (_local2 + (("Host: " + this.host) + " \r\n"));
            _local2 = (_local2 + "User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:14.0) Gecko/20100101 Firefox/14.0.1 \r\n");
            _local2 = (_local2 + "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8 \r\n");
            _local2 = (_local2 + "Accept-Language: zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3 \r\n");
            _local2 = (_local2 + "Accept-Encoding: gzip, deflate \r\n");
            _local2 = (_local2 + "Connection: keep-alive \r\n");
            _local2 = (_local2 + (("Referer: " + this.referer) + " \r\n"));
            _local2 = (_local2 + (("Cookie: " + this.cookie) + " \r\n"));
            _local2 = (_local2 + "UA-CPU: x86 \r\n");
            _local2 = (_local2 + "Cache-Control: no-cache \r\n\r\n");
            JTracer.sendMessage(("BaseSocket -> connectSuccess: header-->" + _local2));
            this.socket.writeUTFBytes(_local2);
            this.socket.flush();
        }
        private function receiveSocketData(_arg1:ProgressEvent):void{
            JTracer.sendMessage("GetVodSocket -> Receive Socket Data");
            var _local2:String = this.socket.readUTFBytes(this.socket.bytesAvailable);
            this.response = (this.response + _local2);
            var _local3:String = this.getResponseHeader("HTTP/1.1", " ");
            JTracer.sendMessage(((("GetVodSocket -> response:\n" + this.response) + "\nstatus:") + _local3));
            var _local4:int = this.response.indexOf("\r\n\r\n");
            if (_local4 < 0){
                JTracer.sendMessage("GetVodSocket -> response header not receive finish");
                GlobalVars.instance.isVodGetted = false;
                this.completeFun(null, this.utype, _local3, (getTimer() - this.startTime));
                this.closeSocket();
                return;
            };
            var _local5:String = this.getResponseHeader("Location", ":");
            this.closeSocket();
            JTracer.sendMessage(((("GetVodSocket ->receiveSocketData:" + this.host) + " vod?:") + _local5));
            var _local6:String = _local5.substr(7);
            GlobalVars.instance.vodAddr = _local6.substr(0, _local6.indexOf("/"));
            GlobalVars.instance.isVodGetted = ((_local5) ? true : false);
            GlobalVars.instance.vodURL = _local5;
            this.completeFun(this.replaceTS(GlobalVars.instance.vodURL), this.utype, _local3, (getTimer() - this.startTime));
            this.closeSocket();
        }
        private function closeSocketHandler(_arg1:Event):void{
            JTracer.sendMessage("GetVodSocket -> Connect Close");
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            GlobalVars.instance.isVodGetted = false;
            this.completeFun(null, this.utype, _local2, (getTimer() - this.startTime));
            this.closeSocket();
        }
        private function connectIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("GetVodSocket -> Connect IOError");
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            GlobalVars.instance.isVodGetted = false;
            this.completeFun(null, this.utype, _local2, (getTimer() - this.startTime));
            this.closeSocket();
        }
        private function connctSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage(("GetVodSocket -> Connct SecurityError, text:" + _arg1.text));
            var _local2:String = this.getResponseHeader("HTTP/1.1", " ");
            GlobalVars.instance.isVodGetted = false;
            this.completeFun(null, this.utype, _local2, (getTimer() - this.startTime));
            this.closeSocket();
        }
        private function getResponseHeader(_arg1:String, _arg2:String):String{
            var _local5:*;
            var _local6:int;
            var _local7:Array;
            if (((!(this.response)) || ((this.response == "")))){
                JTracer.sendMessage(((((("GetVodSocket -> not found header:" + _arg1) + ", separate:") + _arg2) + ", response:") + this.response));
                return (null);
            };
            var _local3:int = this.response.indexOf(_arg1);
            if (_local3 < 0){
                JTracer.sendMessage(("GetVodSocket -> not found header:" + _arg1));
                return (null);
            };
            var _local4:Array = this.response.split("\r\n");
            for (_local5 in _local4) {
                _local7 = _local4[_local5].split(_arg2);
                if ((((_local7.length > 1)) && ((this.trim(_local7[0]) == _arg1)))){
                    if (_arg2 == ":"){
                        _local6 = _local4[_local5].indexOf(":");
                        return (this.trim(_local4[_local5].substr((_local6 + 1))));
                    };
                    return (this.trim(_local7[1]));
                };
            };
            return (null);
        }
        private function trim(_arg1:String):String{
            return (_arg1.replace(/^\s+/, "").replace(/\s+$/, ""));
        }

    }
}//package com.common 
﻿package com.global {

    public class GlobalVars {

        private static var _instance:GlobalVars;

        private var _videoRealSize:Object;
        private var _videoPlaySize:Object;
        public var movieType:String = "teleplay";
        public var windowMode:String = "browser";
        public var enableShare:Boolean;
        public var loadTime:Object;
        public var getVodTime:int;
        public var connectGldTime:int = 0;
        public var vodAddr:String = "";
        public var statCC:String = "";
        public var preFeeTime:Number;
        public var nowFeeTime:Number;
        public var feeInterval:Number = 300000;
        public var curFileInfo:Object;
        public var isExchangeError:Boolean;
        public var movieFormat:String;
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
        public var isUseXlpanKanimg:Boolean = true;
        public var screenshot_size:String = "96";
        public var url_new_screen_shot = "http://i{n}.xlpan.kanimg.com/pic/";
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
        public var isHideHighSpeedTips:Boolean;
        public var isHasShowHighSpeedTips:Boolean;
        public var platform:String;
        public var isStat:Boolean = true;
        public var hasSubtitle:Boolean;
        public var isUseHttpSocket:Boolean = false;
        public var httpSocketMachines:Array;
        public var isHeaderGetted:Boolean;
        public var type_metadata:String = "type_metadata";
        public var type_curstream:String = "type_curstream";
        public var type_nextstream:String = "type_nextstream";
        public var isUseSocket:Boolean = true;
        public var isIPLink:Boolean = false;
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
        public var url_buy_flow:String = "http://pay.vip.xunlei.com/vod.html?refresh=2";
        public var url_buy_time:String = "http://pay.vip.xunlei.com/vodcard";
        public var url_free_flow:String = "http://act.vip.xunlei.com/vodfree/";
        public var url_deduct_flow:String = "http://i.vod.xunlei.com/flux_deduct/";
        public var url_check_flow:String = "http://i.vod.xunlei.com/flux_query/";
        public var url_check_account:String = "http://i.vod.xunlei.com/check_user_info";
        public var url_screen_shot:String = "http://i.vod.xunlei.com/req_screenshot?jsonp=xxx";
        public var bt_screen_shot:String = "http://i.vod.xunlei.com/req_screenshot?jsonp=xxx";
        public var url_login:String = "http://vod.xunlei.com/home.html#login=logout";
        public var staticsUrl:String = "http://stat.vod.xunlei.com/stat/s.gif?";
        public var url_feedback:String = "http://i.vod.xunlei.com/feedback";
        public var url_iframe:String = "http://i.vod.xunlei.com/req_screensnpt_url";
        public var url_chome:String = "http://vod.xunlei.com/client/chome.html";
        public var url_home:String = "http://vod.xunlei.com/home.html";
        public var url_search_subtitle:String = "http://www.shooter.cn/";
        public var url_subtitle_style:String = "http://i.vod.xunlei.com/subtitle/preference/font";
        public var url_subtitle_content:String = "http://i.vod.xunlei.com/subtitle/content";
        public var url_subtitle_list:String = "http://i.vod.xunlei.com/subtitle/list";
        public var url_subtitle_autoload:String = "http://i.vod.xunlei.com/subtitle/autoload";
        public var url_subtitle_time:String = "http://i.vod.xunlei.com/subtitle/preference/time";
        public var url_subtitle_grade:String = "http://i.vod.xunlei.com/subtitle/grade";
        public var url_subtitle_lastload:String = "http://i.vod.xunlei.com/subtitle/last_load";

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
            this.httpSocketMachines = [];
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

    }
}//package com.global 
﻿package com {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    import com.common.*;
    import com.greensock.*;
    import flash.ui.*;
    import eve.*;
    import flash.text.*;
    import ctr.fullScreen.*;
    import ctr.format.*;
    import ctr.volume.*;
    import ctr.tip.*;
    import flash.external.*;
    import flash.system.*;

    public class CtrBar extends Sprite {

        public var _barBg:DefaultBar;
        public var _barBuff:LoadingBar;
        public var _barPlay:PlayBar;
        public var _barPreDown:PreDownBar;
        public var _barSlider:Scroll;
        public var _btnPause:PauseButton;
        public var _btnPlay:PlayButton;
        public var _btnStop:StopButton;
        public var _btnUnmute:VolumeButton;
        public var _btnMute:VolumeButton;
        public var _btnFullscreen:FullScreenButton;
        private var _btnFilelist:FilelistButton;
        private var _filelistTips:FilelistTips;
        public var _barBorder:Sprite;
        public var _timerBP:Timer;
        public var playWidth:Number;
        public var playHeight:Number;
        public var _btnPlayBig:GoOnButtonLa;
        public var _btnPauseBig:GoOnButtonLa;
        public var playctrlHandler:PlayerCtrl;
        public var _beFullscreen:Boolean = false;
        public var hidden:Boolean;
        private var _ctrBarBg:CtrBarBg;
        private var _beMouseOn:Boolean = false;
        private var _beMouseOnFormat:Boolean = false;
        private var _formatBtn:FormatBtn;
        private var _curFormatBtn:CurrentFormatBtn;
        private var _noticeText:TextField;
        private var _isClickBarSeek:Boolean;
        private var _lastStartIdx:int = -1;
        private var _captionBtn:MovieClip;
        private var _captionBtnTips:MovieClip;
        private var _txtPlayTime:TextField;
        private var _txtDownloadSpeed:TextField;
        private var _mcVolume:McVolume;
        private var _mcTimeTip:McTimeTip;
        private var _mcTimeTipArrow:TimeTipsArrow;
        private var _videoTipID:uint;
        private var _timeOutID:int;
        private var _isFirstShowTips:Boolean = true;
        private var _player:Player;
        public var _barWidth:Number;
        private var _timerHide:Timer;
        private var _stageInfo:Object;
        private var _beAvailable:Boolean = true;
        private var _so:SharedObject;
        private var barBox:Sprite;
        private var _cacheVolume:Number = 0.5;
        private var _errorInfo:String;
        private var _isVolume:Boolean = true;
        private var _btnTips:BtnTip;
        private var _preBarWidth:Number = 0;
        private var spolierPointArr:Array;
        private var _isChangeQuality:Boolean = false;
        private var _volumeTips:VolumeTips;
        private var _tipsTimer:Timer;
        private var volumeTipsTimer:Timer;
        private var _volume100Tips:Volume100Tips;
        private var volumeTimer:Timer;
        private var _seekEnable:Boolean = true;

        public function CtrBar(_arg1=352, _arg2=293, _arg3=0, _arg4=null){
            this.spolierPointArr = [];
            super();
            this.addEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
            this.addEventListener(MouseEvent.MOUSE_OVER, this.handleMouseOver);
            this.addEventListener(MouseEvent.MOUSE_OUT, this.handleMouseOut);
            this.playctrlHandler = _arg4;
            this.playctrlHandler.addEventListener(MouseEvent.ROLL_OUT, this.handleMouseOutPlayer);
            this._stageInfo = {
                WIDTH:_arg1,
                HEIGHT:_arg2
            };
            this.playWidth = _arg1;
            this.playHeight = _arg2;
            y = (_arg2 - 33);
            x = 0;
            this.addCtr();
        }
        public function showCaptionBtn():void{
            var _local1:TextFormat = new TextFormat();
            _local1.font = "宋体";
            if (!this._captionBtn){
                this._captionBtn = new CaptionButton();
                this._captionBtn.txt.defaultTextFormat = _local1;
                this._captionBtn.txt.setTextFormat(_local1);
                this._captionBtn.x = ((this._curFormatBtn.x - 45) - 8);
                this._captionBtn.y = 7;
                this._captionBtn.buttonMode = true;
                this._captionBtn.mouseChildren = false;
                this._captionBtn.addEventListener(MouseEvent.CLICK, this.showCaptionFace);
                this.barBox.addChild(this._captionBtn);
            };
            var _local2:Boolean = Cookies.getCookie("hideCaptionButtonTips");
            if (!_local2){
                if (!this._captionBtnTips){
                    this._captionBtnTips = new CaptionBtnTips();
                    this._captionBtnTips.txt.defaultTextFormat = _local1;
                    this._captionBtnTips.txt.setTextFormat(_local1);
                    this._captionBtnTips.x = (this._captionBtn.x - 19);
                    this._captionBtnTips.y = -59;
                    this._captionBtnTips.close_btn.addEventListener(MouseEvent.CLICK, this.hideCaptionBtnTips);
                    this.barBox.addChild(this._captionBtnTips);
                };
            };
            this.setPosition();
        }
        public function hideCaptionBtn():void{
            if (this._captionBtn){
                this._captionBtn.removeEventListener(MouseEvent.CLICK, this.showCaptionFace);
                this.barBox.removeChild(this._captionBtn);
                this._captionBtn = null;
            };
            if (this._captionBtnTips){
                this._captionBtnTips.close_btn.removeEventListener(MouseEvent.CLICK, this.hideCaptionBtnTips);
                this.barBox.removeChild(this._captionBtnTips);
                this._captionBtnTips = null;
            };
            this.setPosition();
        }
        public function showFilelistTips(_arg1:Number):void{
            var _local2:StyleSheet;
            var _local3:TextFormat;
            if (!this._filelistTips){
                _local2 = new StyleSheet();
                _local2.setStyle("a", {
                    textDecoration:"underline",
                    fontFamily:"宋体"
                });
                _local3 = new TextFormat("宋体");
                this._filelistTips = new FilelistTips();
                this._filelistTips.info_txt.text = (("共" + _arg1) + "个视频，点击可切换");
                this._filelistTips.info_txt.setTextFormat(_local3);
                this._filelistTips.know_txt.styleSheet = _local2;
                this._filelistTips.know_txt.htmlText = " <a href='event:hide'>我知道了</a>";
                this._filelistTips.know_txt.addEventListener(TextEvent.LINK, this.clickFilelistTips);
                this._filelistTips.x = (this._btnFilelist.x - 24);
                this._filelistTips.y = -51;
                this.barBox.addChild(this._filelistTips);
                setTimeout(this.hideFilelistTips, 5000);
            };
        }
        public function showBarNotice(_arg1:String, _arg2:uint=0):void{
            var _local3:TextFormat;
            if (_arg1){
                if (!this._noticeText){
                    _local3 = new TextFormat("宋体", 12, 0x555555);
                    this._noticeText = new TextField();
                    this._noticeText.selectable = false;
                    this._noticeText.text = _arg1;
                    this._noticeText.setTextFormat(_local3);
                    this._noticeText.width = (this._noticeText.textWidth + 4);
                    this._noticeText.height = (this._noticeText.textHeight + 4);
                    this._noticeText.x = ((this._btnUnmute.x - this._noticeText.width) - 10);
                    this._noticeText.y = 9;
                    addChild(this._noticeText);
                };
                this._txtDownloadSpeed.x = ((this._noticeText.x - 50) - 40);
                if (_arg2 > 0){
                    setTimeout(this.showBarNotice, _arg2, null);
                } else {
                    setTimeout(this.showBarNotice, 10, null);
                };
            } else {
                if (this._noticeText){
                    removeChild(this._noticeText);
                    this._noticeText = null;
                };
                this._txtDownloadSpeed.x = ((this._btnUnmute.x - 50) - 40);
            };
        }
        private function showCaptionFace(_arg1:MouseEvent):void{
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "caption"));
            if (this._captionBtnTips){
                this._captionBtnTips.removeEventListener(MouseEvent.CLICK, this.hideCaptionBtnTips);
                this.barBox.removeChild(this._captionBtnTips);
                this._captionBtnTips = null;
            };
        }
        private function hideCaptionBtnTips(_arg1:MouseEvent):void{
            Cookies.setCookie("hideCaptionButtonTips", true);
            if (this._captionBtnTips){
                this._captionBtnTips.removeEventListener(MouseEvent.CLICK, this.hideCaptionBtnTips);
                this.barBox.removeChild(this._captionBtnTips);
                this._captionBtnTips = null;
            };
        }
        private function clickFilelistTips(_arg1:TextEvent):void{
            Cookies.setCookie("isNoticeList", false);
            this.hideFilelistTips();
        }
        private function hideFilelistTips():void{
            if (this._filelistTips){
                this.barBox.removeChild(this._filelistTips);
                this._filelistTips = null;
            };
        }
        private function handleAddedToStage(_arg1:Event):void{
            removeEventListener(Event.ADDED_TO_STAGE, this.handleAddedToStage);
            this._btnPlayBig.y = (stage.stageHeight - 60);
            this._btnPauseBig.y = (stage.stageHeight - 60);
        }
        private function handleMouseOver(_arg1:MouseEvent):void{
            this._beMouseOn = true;
        }
        private function handleMouseOut(_arg1:MouseEvent):void{
            this._beMouseOn = false;
        }
        public function get beMouseOn():Boolean{
            return (this._beMouseOn);
        }
        private function addCtr(){
            this.barBox = new Sprite();
            addChild(this.barBox);
            this.barBox.graphics.beginFill(0x181818, 1);
            this.barBox.graphics.drawRect(0, 0, (Capabilities.screenResolutionY + 1000), 33);
            this._ctrBarBg = new CtrBarBg();
            this._barBg = new DefaultBar();
            this._barBuff = new LoadingBar();
            this._barPlay = new PlayBar();
            this._barPreDown = new PreDownBar();
            this._barSlider = new Scroll();
            this._btnPause = new PauseButton();
            this._btnPlay = new PlayButton();
            this._btnStop = new StopButton();
            this._btnFilelist = new FilelistButton();
            this._mcTimeTip = new McTimeTip();
            this._mcTimeTipArrow = new TimeTipsArrow();
            this._mcVolume = new McVolume(this);
            this._btnFullscreen = new FullScreenButton();
            this._btnTips = new BtnTip();
            this._volumeTips = new VolumeTips();
            this._volume100Tips = new Volume100Tips();
            this._formatBtn = new FormatBtn();
            this._curFormatBtn = new CurrentFormatBtn();
            this._btnUnmute = new VolumeButton();
            this._btnMute = new VolumeButton();
            this._btnMute.buttonMode = true;
            this._btnUnmute.visible = false;
            this._barBg.buttonMode = true;
            this._barBuff.buttonMode = true;
            this._barPlay.buttonMode = true;
            this._barPreDown.buttonMode = true;
            this._btnPause.visible = false;
            this._mcTimeTip.visible = false;
            this._mcTimeTipArrow.visible = false;
            this._btnTips.visible = false;
            this._volumeTips.visible = false;
            this._volume100Tips.visible = false;
            this._barBorder = new Sprite();
            this._barBorder.graphics.beginFill(0, 0);
            this._barBorder.graphics.lineStyle(1, 0xE1E1E1);
            this._barBorder.graphics.drawRect(0, 0, this.playWidth, 32);
            this._so = SharedObject.getLocal("kkV");
            this._mcVolume.buttonMode = true;
            this._cacheVolume = ((this._so.data.v) ? this._so.data.v : 0.5);
            this._txtPlayTime = new TextField();
            this._txtPlayTime.autoSize = TextFormatAlign.LEFT;
            this._txtPlayTime.selectable = false;
            this.setPlayTimeText("00:00/00:00");
            this._txtDownloadSpeed = new TextField();
            this._txtDownloadSpeed.autoSize = TextFormatAlign.RIGHT;
            this._txtDownloadSpeed.selectable = false;
            this.setDownloadSpeedText(0);
            this.barBox.addChild(this._ctrBarBg);
            this.barBox.addChild(this._btnPause);
            this.barBox.addChild(this._btnPlay);
            this.barBox.addChild(this._btnStop);
            this._btnStop.visible = false;
            this.barBox.addChild(this._btnFilelist);
            this.barBox.addChild(this._btnUnmute);
            this.barBox.addChild(this._btnMute);
            this.barBox.addChild(this._btnFullscreen);
            this.barBox.addChild(this._txtPlayTime);
            this.barBox.addChild(this._txtDownloadSpeed);
            this._formatBtn.visible = false;
            this.barBox.addChild(this._barBg);
            this.barBox.addChild(this._barBuff);
            this.barBox.addChild(this._barPreDown);
            this.barBox.addChild(this._barPlay);
            this.barBox.addChild(this._barSlider);
            this.barBox.addChild(this._mcTimeTip);
            this.barBox.addChild(this._mcTimeTipArrow);
            this.barBox.addChild(this._btnTips);
            this.barBox.addChild(this._mcVolume);
            this.barBox.addChild(this._volumeTips);
            this.barBox.addChild(this._volume100Tips);
            this.barBox.addChild(this._formatBtn);
            this.barBox.addChild(this._curFormatBtn);
            this._btnPlayBig = new GoOnButtonLa();
            this._btnPauseBig = new GoOnButtonLa();
            addChild(this._btnPlayBig);
            addChild(this._btnPauseBig);
            this._btnPauseBig.visible = false;
            this._btnPlayBig.visible = false;
            this._btnPlayBig.addEventListener(MouseEvent.CLICK, this.dispatchPlay);
            this._btnPauseBig.addEventListener(MouseEvent.CLICK, this.dispatchPlay);
            this._tipsTimer = new Timer(2000, 1);
            this._tipsTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onTipsTimerComplete);
            this.volumeTipsTimer = new Timer(2000, 1);
            this.volumeTipsTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onVolumeKeyChangeTimer);
            this.faceLifting(this._stageInfo.WIDTH);
            this._barPlay.width = 0;
            this._barBuff.width = 0;
            this._barPreDown.width = 0;
            this._barSlider.x = 0;
            this._barBg.y = -6;
            this._barBuff.y = -6;
            this._barPlay.y = -6;
            this._barPreDown.y = -6;
        }
        public function faceLifting(_arg1){
            var _local4:Number;
            var _local2:Number = ((this._beFullscreen) ? 26 : 0);
            this._stageInfo.CURR_WIDTH = _arg1;
            this._barBorder.width = _arg1;
            this._ctrBarBg.width = _arg1;
            this._ctrBarBg.x = 0;
            this._ctrBarBg.y = 0;
            this._barBg.x = 0;
            this._barBuff.x = 0;
            this._barPlay.x = 0;
            this._barPreDown.x = 0;
            this._barBg.width = _arg1;
            this._btnPlay.y = 0;
            this._btnPause.y = 0;
            this._btnStop.y = 0;
            this._btnFilelist.y = 0;
            this._txtPlayTime.y = 7;
            this._btnPlay.x = 0;
            this._btnPause.x = 0;
            if (GlobalVars.instance.platform == "client"){
                this.showStopButton(true);
            } else {
                this.showStopButton(false);
            };
            this._barSlider.y = -8;
            this._barWidth = this._barBg.width;
            JTracer.sendMessage(("faceLifting._preBarWidth:" + this._preBarWidth));
            if (this._preBarWidth != 0){
                _local4 = (this._barWidth / this._preBarWidth);
                this._barPlay.width = (_local4 * this._barPlay.width);
                this._barBuff.width = (_local4 * this._barBuff.width);
                this._barPreDown.width = (_local4 * this._barPreDown.width);
                this._barSlider.x = ((this._barPlay.width + this._barPlay.x) - 6);
                if (this._barSlider.x < 0){
                    this._barSlider.x = 0;
                };
                JTracer.sendMessage(((((("faceLifting._differ=" + _local4) + ",_barPlay.width=") + this._barPlay.width) + ",_barBuff.width=") + this._barBuff.width));
            };
            this.timerBuffHandler(null);
            this._preBarWidth = this._barWidth;
            this._btnFullscreen.x = (_arg1 - 36);
            this._btnFullscreen.y = 0;
            this._formatBtn.x = ((this._btnFullscreen.x - 55) - 3);
            this._formatBtn.y = 7;
            this._curFormatBtn.x = ((this._btnFullscreen.x - 55) - 3);
            this._curFormatBtn.y = 7;
            this._mcVolume.y = 11;
            this._btnMute.y = 1;
            this._btnUnmute.y = 1;
            this._txtDownloadSpeed.y = 7;
            this._txtDownloadSpeed.width = 50;
            this._volumeTips.y = -36;
            this._volume100Tips.y = -36;
            this.setPosition();
            this._btnPlayBig.x = (50 - 20);
            this._btnPauseBig.x = (50 - 20);
            var _local3:Number = ((stage) ? stage.stageHeight : this.playHeight);
            this._btnPlayBig.y = (_local3 - 120);
            this._btnPauseBig.y = (_local3 - 120);
            if (stage){
                this.parent.addChild(this._btnPlayBig);
                this.parent.addChild(this._btnPauseBig);
            };
        }
        private function setPosition():void{
            var _local1:Number;
            if (this._captionBtn){
                this._captionBtn.x = ((this._curFormatBtn.x - 45) - 8);
                if (this._captionBtnTips){
                    this._captionBtnTips.x = (this._captionBtn.x - 19);
                };
                _local1 = ((this._captionBtn.x - 53) - 18);
            } else {
                _local1 = ((this._curFormatBtn.x - 53) - 18);
            };
            this._mcVolume.x = _local1;
            this._btnMute.x = ((this._mcVolume.x - 17) - 22);
            this._btnUnmute.x = ((this._mcVolume.x - 17) - 22);
            this._txtDownloadSpeed.x = ((this._btnUnmute.x - 50) - 40);
            this._volumeTips.x = ((this._mcVolume.x + ((this._mcVolume.width - this._volumeTips.width) / 2)) - 2);
            this._volume100Tips.x = ((this._mcVolume.x + ((this._mcVolume.width - this._volume100Tips.width) / 2)) - 2);
        }
        private function addEventHandler(){
            this._player.addEventListener(PlayEvent.STOP, this.handlePlayStop);
            this._btnFullscreen.addEventListener(MouseEvent.CLICK, this.fullscreen_CLICK_handler);
            this._btnMute.addEventListener(MouseEvent.MOUSE_OVER, this.volumeBtnEventHandler);
            this._btnMute.addEventListener(MouseEvent.CLICK, this.volumeBtnEventHandler);
            this._btnMute.addEventListener(MouseEvent.MOUSE_OUT, this.volumeBtnEventHandler);
            this._btnPlay.addEventListener(MouseEvent.CLICK, this.dispatchPlay);
            this._btnFilelist.addEventListener(MouseEvent.CLICK, this.showFilelist);
            this._timerBP = new Timer(500, 0);
            this._timerBP.addEventListener("timer", this.timerBuffHandler);
            this._btnPlay.addEventListener(MouseEvent.MOUSE_OVER, this.btnTipsHandler);
            this._btnPause.addEventListener(MouseEvent.MOUSE_OVER, this.btnTipsHandler);
            this._btnStop.addEventListener(MouseEvent.MOUSE_OVER, this.btnTipsHandler);
            this._btnFilelist.addEventListener(MouseEvent.MOUSE_OVER, this.btnTipsHandler);
            this._btnFullscreen.addEventListener(MouseEvent.MOUSE_OVER, this.btnTipsHandler);
            this._btnPlay.addEventListener(MouseEvent.MOUSE_OUT, this.btnTipsHandler);
            this._btnPause.addEventListener(MouseEvent.MOUSE_OUT, this.btnTipsHandler);
            this._btnStop.addEventListener(MouseEvent.MOUSE_OUT, this.btnTipsHandler);
            this._btnFilelist.addEventListener(MouseEvent.MOUSE_OUT, this.btnTipsHandler);
            this._btnFullscreen.addEventListener(MouseEvent.MOUSE_OUT, this.btnTipsHandler);
            this._curFormatBtn.addEventListener("clickCurrentFormat", this.clickCurrentFormatBtn);
        }
        private function clickCurrentFormatBtn(_arg1:Event):void{
            if (!this._formatBtn.visible){
                this._curFormatBtn.isClicked = true;
                this._formatBtn.visible = true;
                this._formatBtn.addEventListener("clickFormat", this.hideFormatSelector);
                this._formatBtn.addEventListener(MouseEvent.ROLL_OVER, this.showFormatSelector);
                this._formatBtn.addEventListener(MouseEvent.ROLL_OUT, this.hideFormatSelector);
            } else {
                this.hideFormatSelector();
            };
        }
        private function showFormatSelector(_arg1:MouseEvent):void{
            this._curFormatBtn.isClicked = true;
            this._beMouseOnFormat = true;
            this._formatBtn.visible = true;
        }
        public function hideFormatSelector(_arg1:Event=null):void{
            this._curFormatBtn.isClicked = false;
            this._beMouseOnFormat = false;
            this._formatBtn.visible = false;
            this._formatBtn.removeEventListener("clickFormat", this.hideFormatSelector);
            this._formatBtn.removeEventListener(MouseEvent.ROLL_OVER, this.showFormatSelector);
            this._formatBtn.removeEventListener(MouseEvent.ROLL_OUT, this.hideFormatSelector);
        }
        public function get beMouseOnFormat():Boolean{
            return (this._beMouseOnFormat);
        }
        private function handlePlayStop(_arg1:PlayEvent):void{
            this._btnPlay.visible = true;
            this._btnPause.visible = false;
            this._barBuff.width = 0;
            this._barPlay.width = 0;
            this._barPreDown.width = 0;
            this._barSlider.x = 0;
        }
        private function fullscreen_CLICK_handler(_arg1){
            if (this._beFullscreen){
                this.playctrlHandler.stage.displayState = StageDisplayState.NORMAL;
            } else {
                this.playctrlHandler.stage.displayState = StageDisplayState.FULL_SCREEN;
                KKCountReport.sendKankanPgv("btnclick_full");
            };
        }
        private function bar_CLICK_handler(_arg1:MouseEvent):void{
            var _local2:Number = ((((_arg1.stageX - this.getStagePosition(_arg1.target).x) - 1) / this._barWidth) * this._player.totalTime);
            this.seekToTime(_local2, _arg1.stageX, "bar");
        }
        private function videoTip_CLICK_handler(_arg1:MouseEvent):void{
            this.hideVideoTips();
            this.seekToTime(this._mcTimeTip.curTime, this._mcTimeTip.curStageX, "preview");
        }
        private function seekToTime(_arg1:Number, _arg2:Number, _arg3:String):void{
            if (this.playctrlHandler.isNoEnoughBytes){
                return;
            };
            var _local4:Boolean = this.playctrlHandler.isValid;
            if (!_local4){
                this.playctrlHandler.checkIsValid();
                return;
            };
            if (!this.playctrlHandler.isPlayStart){
                return;
            };
            if (!this._seekEnable){
                this.playctrlHandler.flv_setNoticeMsg("数据准备中，暂不支持拖动");
                return;
            };
            var _local5:Number = (_arg2 - this.getStagePosition(this._barSlider).x);
            var _local6:Number = (this._barSlider.x + _local5);
            if (_local6 < 8){
                this._barSlider.x = 0;
            } else {
                if (_local6 > (this._barWidth - 16)){
                    this._barSlider.x = (this._barWidth - 16);
                } else {
                    this._barSlider.x = (_local6 - 8);
                };
            };
            this._barPlay.width = ((this._barSlider.x - this._barPlay.x) + 6);
            var _local7:Number = _arg1;
            var _local8:Number = this._player.totalTime;
            if (_local7 <= 0){
                _local7 = 0.1;
            } else {
                if (_local7 >= _local8){
                    _local7 = (_local8 - 0.1);
                };
            };
            if ((((_local7 > 0)) && ((_local7 < _local8)))){
                JTracer.sendMessage(("bar_CLICK_handler.total_time:" + _local8));
                JTracer.sendMessage(("bar_CLICK_handler.seek_time:" + _local7));
                if (_arg3 == "bar"){
                    this.playctrlHandler._bufferTip.clearBreakCount();
                    GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeDrag;
                    JTracer.sendMessage(("CtrBar -> seekToTime, bar, set bufferType:" + GlobalVars.instance.bufferType));
                } else {
                    if (_arg3 == "preview"){
                        this.playctrlHandler._bufferTip.clearBreakCount();
                        GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypePreview;
                        JTracer.sendMessage(("CtrBar -> seekToTime, preview, set bufferType:" + GlobalVars.instance.bufferType));
                    };
                };
                this._isClickBarSeek = true;
                this._player.seek(_local7);
            };
        }
        private function showStopButton(_arg1:Boolean):void{
            if (_arg1){
                this._btnStop.visible = true;
                this._btnStop.x = 38;
                this._btnFilelist.x = 76;
                this._txtPlayTime.x = 116;
            } else {
                this._btnStop.visible = false;
                this._btnStop.x = 38;
                this._btnFilelist.x = 38;
                this._txtPlayTime.x = 78;
            };
        }
        public function set isClickBarSeek(_arg1:Boolean):void{
            this._isClickBarSeek = _arg1;
        }
        public function get isClickBarSeek():Boolean{
            if (GlobalVars.instance.isUseHttpSocket){
                return (false);
            };
            return (this._isClickBarSeek);
        }
        private function bar_MOUSE_OVER_handler(_arg1:MouseEvent):void{
            if (((!(this._barSlider.visible)) || (!(this.playctrlHandler.isPlayStart)))){
                return;
            };
            this._mcTimeTip.visible = true;
            this._mcTimeTipArrow.visible = this._mcTimeTip.visible;
            var _local2:Number = this._player.totalTime;
            var _local3:Number = ((stage.mouseX / this._barWidth) * _local2);
            _local3 = (((_local3 > _local2)) ? _local2 : _local3);
            _local3 = (((_local3 < 0)) ? 0 : _local3);
            var _local4:GlobalVars = GlobalVars.instance;
            var _local5:uint = this._player.getNearIndex(this._player.dragTime, _local3, 0, (this._player.dragTime.length - 2));
            var _local6:uint = ((this.playctrlHandler.snptBmdArray.length * _local4.iframeRow) * _local4.iframeCol);
            this._mcTimeTip.hasSnapShot = (_local5 < _local6);
            if (((!((this._mcTimeTip.scaleType == 1))) && (!(this._mcTimeTip.hasSnapShot)))){
                this.removeEventListener(Event.ENTER_FRAME, this.onVideoTipEnter);
                clearTimeout(this._videoTipID);
                this._mcTimeTip.isScale = false;
                this._mcTimeTip.scaleType = 1;
                this._mcTimeTip.scaleDefault();
                this._mcTimeTip.buttonMode = false;
                this._mcTimeTip.removeEventListener(MouseEvent.CLICK, this.videoTip_CLICK_handler);
                this._mcTimeTipArrow.buttonMode = false;
                this._mcTimeTipArrow.hideBg();
                this._mcTimeTipArrow.removeEventListener(MouseEvent.CLICK, this.videoTip_CLICK_handler);
            };
            this._mcTimeTip.text = this.formatTime(_local3);
            this._mcTimeTip.curMouseX = stage.mouseX;
            this.setTimeTipPos(this._mcTimeTip.curMouseX);
            this.addEventListener(Event.ENTER_FRAME, this.onVideoTipEnter);
            if (this._mcTimeTip.hasSnapShot){
                if (_local5 != this._lastStartIdx){
                    this._lastStartIdx = _local5;
                    this._mcTimeTip.clear();
                    this._mcTimeTip.showLoading(false);
                    this._mcTimeTip.initDisplay();
                    this._mcTimeTip.setDisplayAlpha(1);
                    if (this._isFirstShowTips){
                        clearTimeout(this._timeOutID);
                        this._timeOutID = setTimeout(this.showVideoTips, 200, _local3, stage.mouseX, _arg1.stageX);
                    } else {
                        this.showVideoTips(_local3, stage.mouseX, _arg1.stageX);
                    };
                    clearTimeout(this._videoTipID);
                    this._videoTipID = setTimeout(this.showVideoTipsFromSnap, 3000, _local3, stage.mouseX, _arg1.stageX);
                };
            } else {
                if (_local5 != this._lastStartIdx){
                    this._lastStartIdx = _local5;
                    clearTimeout(this._videoTipID);
                    this._videoTipID = setTimeout(this.showVideoTipsFromTips, 3000, _local3, stage.mouseX, _arg1.stageX);
                };
            };
        }
        private function bar_MOUSE_OUT_handler(_arg1:MouseEvent):void{
        }
        private function handleMouseOutPlayer(_arg1:MouseEvent):void{
            this.hideVideoTips();
        }
        private function showVideoTipsFromSnap(_arg1:Number, _arg2:Number, _arg3:Number):void{
            this._mcTimeTip.hasSnapShot = false;
            this.showVideoTips(_arg1, _arg2, _arg3);
        }
        private function showVideoTipsFromTips(_arg1:Number, _arg2:Number, _arg3:Number):void{
            this._mcTimeTip.clear();
            this._mcTimeTip.showLoading(true);
            this._mcTimeTip.initDisplay();
            this._mcTimeTip.setDisplayAlpha(0);
            this.showVideoTips(_arg1, _arg2, _arg3);
        }
        private function showVideoTips(_arg1:Number, _arg2:Number, _arg3:Number):void{
            var _local6:GlobalVars;
            var _local7:uint;
            var _local8:uint;
            var _local9:Number;
            var _local10:uint;
            var _local11:uint;
            var _local12:Number;
            var _local13:Number;
            var _local14:String;
            this._isFirstShowTips = false;
            var _local4:uint = this._player.getNearIndex(this._player.dragTime, _arg1, 0, (this._player.dragTime.length - 2));
            var _local5:uint = this._player.getNearIndex(this._player.dragTime, (_arg1 + 5), 1, (this._player.dragTime.length - 1));
            if (_local5 <= _local4){
                _local5 = (_local4 + 1);
            };
            if (this._mcTimeTip.hasSnapShot){
                _local6 = GlobalVars.instance;
                _local7 = (_local6.iframeRow * _local6.iframeCol);
                _local8 = Math.floor((_local4 / _local7));
                _local9 = (_local4 - (_local8 * _local7));
                _local10 = (_local9 % _local6.iframeCol);
                _local11 = Math.floor((_local9 / _local6.iframeCol));
                JTracer.sendMessage(((((((((((((((("CtrBar -> showVideoTips, 显示i帧截图, startIdx:" + _local4) + ", endIdx:") + _local5) + ", perPageNum:") + _local7) + ", curPageNum:") + _local8) + ", remainNum:") + _local9) + ", xPos:") + _local10) + ", yPos:") + _local11) + ", url:") + this.playctrlHandler.snptBmdArray[_local8].url));
                this._mcTimeTip.showSnap(Tools.cutScreenShot(this.playctrlHandler.snptBmdArray[_local8].bmd, new Point((_local10 * _local6.iframeWidth), (_local11 * _local6.iframeHeight))));
            } else {
                _local12 = (((_local4 == 0)) ? 0 : this._player.dragPosition[_local4]);
                _local13 = (((((((_local5 == 1)) && ((this._player.dragTime[1] == 0)))) && ((this._player.dragTime.length == 2)))) ? this._player.getVideoUrlArr[0].totalByte : this._player.dragPosition[_local5]);
                _local14 = ((((("&start=" + _local12) + "&end=") + _local13) + "&type=preview&du=") + this._player.vduration);
                JTracer.sendMessage((((((("CtrBar -> showVideoTips, 显示视频预览, startIdx:" + _local4) + ", endIdx:") + _local5) + ", gdl url:") + this._player.playUrl) + _local14));
                this._mcTimeTip.playStream(this._player.playUrl, _local14);
                if (GlobalVars.instance.isStat){
                    Tools.stat(("f=previewVideo&gdl=" + encodeURIComponent(this._player.playUrl)));
                };
            };
            this._mcTimeTip.isScale = true;
            this._mcTimeTip.curTime = _arg1;
            this._mcTimeTip.curMouseX = _arg2;
            this._mcTimeTip.curStageX = _arg3;
            if (this._mcTimeTip.scaleType == 2){
                this._mcTimeTip.scaleNormal(true);
                this._mcTimeTipArrow.showBg();
            } else {
                if (this._mcTimeTip.scaleType == 3){
                    this._mcTimeTip.scaleBig(true);
                    this._mcTimeTipArrow.showBg();
                } else {
                    this._mcTimeTip.scaleType = 2;
                    this._mcTimeTip.scaleNormal();
                    this._mcTimeTipArrow.showBg();
                    if (this._mcTimeTip.hasSnapShot){
                        if (GlobalVars.instance.isStat){
                            Tools.stat(("f=previewSnapShot&gdl=" + encodeURIComponent(this._player.playUrl)));
                        };
                    };
                };
            };
            this._mcTimeTip.buttonMode = true;
            this._mcTimeTip.addEventListener(MouseEvent.CLICK, this.videoTip_CLICK_handler);
            this._mcTimeTipArrow.buttonMode = true;
            this._mcTimeTipArrow.addEventListener(MouseEvent.CLICK, this.videoTip_CLICK_handler);
        }
        private function onVideoTipEnter(_arg1:Event):void{
            this.setTimeTipPos(this._mcTimeTip.curMouseX);
            var _local2:Number = (this._mcTimeTip.x - (this._mcTimeTip.width / 2));
            var _local3:Number = (this._mcTimeTip.x + (this._mcTimeTip.width / 2));
            var _local4:Number = ((stage.stageHeight - 43) - this._mcTimeTip.height);
            var _local5:Number = (stage.stageHeight - 43);
            var _local6:Number = ((stage.stageHeight - 32) - this._barBg.height);
            var _local7:Number = (stage.stageHeight - 32);
            if (!this._mcTimeTip.isScale){
                if ((((stage.mouseY < _local6)) || ((stage.mouseY > _local7)))){
                    this.hideVideoTips();
                };
                return;
            };
            if ((((((((stage.mouseX < _local2)) || ((stage.mouseX > _local3)))) || ((stage.mouseY < _local4)))) || ((stage.mouseY > _local7)))){
                this.hideVideoTips();
            } else {
                if (stage.mouseY <= _local5){
                    if (this._mcTimeTip.scaleType != 3){
                        this._mcTimeTip.scaleType = 3;
                        this._mcTimeTip.scaleBig();
                        this._mcTimeTipArrow.showBg();
                    };
                } else {
                    if (this._mcTimeTip.scaleType != 2){
                        this._mcTimeTip.scaleType = 2;
                        this._mcTimeTip.scaleNormal();
                        this._mcTimeTipArrow.showBg();
                    };
                };
            };
        }
        private function hideVideoTips():void{
            this.removeEventListener(Event.ENTER_FRAME, this.onVideoTipEnter);
            clearTimeout(this._videoTipID);
            clearTimeout(this._timeOutID);
            this._mcTimeTip.visible = false;
            this._mcTimeTip.init();
            this._mcTimeTip.isScale = false;
            this._mcTimeTip.scaleType = 1;
            this._mcTimeTip.buttonMode = false;
            this._mcTimeTip.removeEventListener(MouseEvent.CLICK, this.videoTip_CLICK_handler);
            this._mcTimeTipArrow.visible = false;
            this._mcTimeTipArrow.buttonMode = false;
            this._mcTimeTipArrow.hideBg();
            this._mcTimeTipArrow.removeEventListener(MouseEvent.CLICK, this.videoTip_CLICK_handler);
            this._lastStartIdx = -1;
            this._isFirstShowTips = true;
        }
        private function setTimeTipPos(_arg1:Number):void{
            this._mcTimeTipArrow.x = (_arg1 - 4);
            if (this._mcTimeTipArrow.x < 2){
                this._mcTimeTipArrow.x = 2;
            } else {
                if (this._mcTimeTipArrow.x > ((stage.stageWidth - this._mcTimeTipArrow.width) - 2)){
                    this._mcTimeTipArrow.x = ((stage.stageWidth - this._mcTimeTipArrow.width) - 2);
                };
            };
            this._mcTimeTipArrow.y = -12;
            this._mcTimeTip.x = (this._mcTimeTipArrow.x + 4);
            if (this._mcTimeTip.x < (this._mcTimeTip.width / 2)){
                this._mcTimeTip.x = (this._mcTimeTip.width / 2);
            } else {
                if (this._mcTimeTip.x > (stage.stageWidth - (this._mcTimeTip.width / 2))){
                    this._mcTimeTip.x = (stage.stageWidth - (this._mcTimeTip.width / 2));
                };
            };
            this._mcTimeTip.y = -10;
        }
        private function barSliderRemoveEvent(){
            this._barSlider.enabled = false;
        }
        private function barSliderAddEvent(){
            this._barSlider.enabled = true;
        }
        private function barslider_MOUSE_DOWN_handler(_arg1:MouseEvent):void{
            if (this.playctrlHandler.isNoEnoughBytes){
                return;
            };
            var _local2:Boolean = this.playctrlHandler.isValid;
            if (!_local2){
                this.playctrlHandler.checkIsValid();
                return;
            };
            if (!this.playctrlHandler.isPlayStart){
                return;
            };
            this._timerBP.stop();
            ExternalInterface.call("flv_playerEvent", "onDragSeekStart");
            this._barSlider.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.barslider_MOUSE_MOVE_handler);
            this._barSlider.stage.addEventListener(MouseEvent.MOUSE_UP, this.barslider_MOUSE_UP_handler);
        }
        private function barslider_MOUSE_UP_handler(_arg1:MouseEvent):void{
            if (this.playctrlHandler.isNoEnoughBytes){
                return;
            };
            var _local2:Boolean = this.playctrlHandler.isValid;
            if (!_local2){
                this.playctrlHandler.checkIsValid();
                return;
            };
            if (!this.playctrlHandler.isPlayStart){
                return;
            };
            this._barSlider.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.barslider_MOUSE_MOVE_handler);
            this._barSlider.stage.removeEventListener(MouseEvent.MOUSE_UP, this.barslider_MOUSE_UP_handler);
            this.playctrlHandler._bufferTip.clearBreakCount();
            GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeDrag;
            JTracer.sendMessage(("CtrBar -> barslider_MOUSE_UP_handler, set bufferType:" + GlobalVars.instance.bufferType));
            var _local3:* = this._player.totalTime;
            var _local4:* = (((this._barPlay.width - 6) / this._barWidth) * _local3);
            if (_local4 <= 0){
                this._isClickBarSeek = true;
                this._player.seek(0);
            };
            if (_local4 >= _local3){
                this._isClickBarSeek = true;
                this._player.seek(_local3);
            };
            if ((((_local4 > 0)) && ((_local4 < _local3)))){
                this._isClickBarSeek = true;
                this._player.seek(_local4);
            };
            this._timerBP.start();
            this.setBarPos(_arg1.stageX);
            ExternalInterface.call("flv_playerEvent", "onDragSeekEnd");
        }
        private function barslider_MOUSE_MOVE_handler(_arg1:MouseEvent):void{
            if (this.playctrlHandler.isNoEnoughBytes){
                return;
            };
            var _local2:Boolean = this.playctrlHandler.isValid;
            if (!_local2){
                this.playctrlHandler.checkIsValid();
                return;
            };
            if (!this.playctrlHandler.isPlayStart){
                return;
            };
            this.setBarPos(_arg1.stageX);
        }
        private function setBarPos(_arg1:Number):void{
            var _local4:*;
            var _local5:*;
            var _local2:* = _arg1;
            var _local3:int;
            if ((((_local2 > this._barPlay.x)) && ((_local2 < ((this._barBg.x + this._barBg.width) - 4))))){
                if (_local2 < 8){
                    this._barSlider.x = 0;
                } else {
                    if (_local2 > (this._barWidth - 16)){
                        this._barSlider.x = (this._barWidth - 16);
                    } else {
                        this._barSlider.x = (_local2 - 8);
                    };
                };
                this._barPlay.width = ((this._barSlider.x - this._barPlay.x) + 6);
                _local4 = this._player.totalTime;
                _local5 = (((this._barPlay.width - 6) / this._barWidth) * _local4);
                if ((((_local5 >= 0)) && ((_local5 <= _local4)))){
                    this.setPlayTimeText(((this.formatTime(_local5) + "/") + this._txtPlayTime.text.split("/")[1]));
                };
            };
        }
        private function timerBuffHandler(_arg1):void{
            var _local6:Boolean;
            if (!this._player){
                return;
            };
            this.setDownloadSpeedText(this._player.downloadSpeed);
            if ((((((this._player.time == -1)) || ((this._player.time == 0)))) || ((this._player.fixedTime == 0)))){
                this.setPlayTimeText(((this.formatTime(0) + "/") + this.formatTime(this._player.totalTime)));
                return;
            };
            var _local2:Number = this._player.totalTime;
            var _local3:Number = this._player.time;
            if (_local3 <= 0){
                return;
            };
            if (_local3 > _local2){
                _local3 = _local2;
            };
            var _local4:Number = this._player.downloadProgress;
            var _local5:* = ((this._player.time / _local2) * (this._barWidth - 16));
            if (isNaN(_local5)){
                this._barSlider.x = 0;
            } else {
                this._barSlider.x = _local5;
            };
            trace(("timerBuffHandler._player.time:" + this._player.time));
            trace(("timerBuffHandler._barSlider.x:" + this._barSlider.x));
            this._barPlay.width = ((this._barSlider.x - this._barPlay.x) + 6);
            if (this._barPlay.width > this._barWidth){
                this._barPlay.width = this._barWidth;
            };
            this._barBuff.width = (_local4 * this._barWidth);
            if (this._barBuff.width > this._barWidth){
                this._barBuff.width = this._barWidth;
            };
            if (this._barBuff.width < 0){
                this._barBuff.width = 0;
            };
            this.setPlayTimeText(((this.formatTime(_local3) + "/") + this.formatTime(_local2)));
            if ((((((Math.abs((this._player.totalTime - this._player.time)) < 1)) && ((this._player.time > (this._player.totalTime - 1))))) && (!((this._player.totalTime == 0))))){
                JTracer.sendMessage(((("_player.time > _player.totalTime, and call playerEvent end! _player.time=" + this._player.time) + ", _player.totalTime=") + this._player.totalTime));
                _local6 = this.playctrlHandler.isHasNext;
                JTracer.sendMessage(("CtrBar -> 是否有下一集, isHasNext:" + _local6));
                this.playctrlHandler.isStopNormal = true;
                if (!_local6){
                    this.playctrlHandler.isShowStopFace = true;
                };
                this.dispatchStop();
                ExternalInterface.call("flv_playerEvent", "onEnd");
                if (_local6){
                    this.playctrlHandler.playNext();
                };
            };
        }
        private function setPlayTimeText(_arg1:String){
            if (this.playctrlHandler.isChangeQuality == true){
                return;
            };
            if (_arg1.length == 14){
                _arg1 = ("00:" + _arg1);
            };
            var _local2:Array = _arg1.split("/");
            _arg1 = (((((("<font color='#9f9f9f'>" + _local2[0]) + "</font>") + "<font color='#555555'>") + "/") + _local2[1]) + "</font>");
            this._txtPlayTime.htmlText = _arg1;
            this._txtPlayTime.setTextFormat(new TextFormat("Arial", 12));
        }
        private function setDownloadSpeedText(_arg1:Number):void{
            var _local2:String;
            if (_arg1 == 0){
                this._txtDownloadSpeed.text = "";
            } else {
                _local2 = "";
                if (_arg1 >= 0x0400){
                    _arg1 = (Math.round(((_arg1 / 0x0400) * 10)) / 10);
                    _local2 = (_arg1.toString() + "MB/s");
                } else {
                    _local2 = (_arg1.toString() + "KB/s");
                };
                this._txtDownloadSpeed.text = _local2;
                this._txtDownloadSpeed.setTextFormat(new TextFormat("Arial", 12, 0x555555));
            };
        }
        function mute_CLICK_handler(_arg1){
            if (_arg1.target == this._btnUnmute){
                this._btnUnmute.visible = false;
                this._btnMute.visible = true;
                this._mcVolume.buttonMode = true;
                this.setVolume(this._mcVolume.currentVolume);
            } else {
                this._btnUnmute.visible = true;
                this._btnMute.visible = false;
                this._mcVolume.buttonMode = false;
                this.setVolume(0);
            };
        }
        private function onVolumeKeyChangeTimer(_arg1:TimerEvent):void{
            this._volumeTips.visible = false;
            this._volume100Tips.visible = false;
        }
        function saveV(_arg1){
            this._so.data.v = _arg1;
            this._so.flush();
        }
        public function handleVolumeFromKey(_arg1:Boolean):void{
            if (!this._player.volum){
                this._btnUnmute.visible = false;
                this._btnMute.visible = true;
                this._btnMute.gotoAndStop(1);
                this._isVolume = true;
                this.setVolume(this._mcVolume.currentVolume);
            };
            this.volumeTipsTimer.reset();
            this.volumeTipsTimer.start();
            if (_arg1){
                if (this._mcVolume.currentVolume > 0.999){
                    this._cacheVolume = ((((this._player.volum + 0.5) > 5)) ? 5 : (this._player.volum + 0.5));
                    if (this._volume100Tips.visible){
                        this._volume100Tips.visible = false;
                    };
                    this._volumeTips.visible = true;
                    this._volumeTips.text = (int((Number(this._cacheVolume) * 100)) + "%");
                    this._mcVolume.handleVolumeBar(this._cacheVolume);
                } else {
                    this._cacheVolume = ((((this._mcVolume.currentVolume + (1 / 10)) > 1)) ? 1 : (this._mcVolume.currentVolume + (1 / 10)));
                    if (this._cacheVolume >= 1){
                        if (this._volumeTips.visible){
                            this._volumeTips.visible = false;
                        };
                        this._volume100Tips.visible = true;
                        this._volume100Tips.text = "100%(按↑键继续放大音量)";
                        this._mcVolume.handleVolumeBar(this._cacheVolume);
                    } else {
                        if (this._volume100Tips.visible){
                            this._volume100Tips.visible = false;
                        };
                        this._volumeTips.visible = true;
                        this._volumeTips.text = (int((Number(this._cacheVolume) * 100)) + "%");
                        this._mcVolume.handleVolumeBar(this._cacheVolume);
                    };
                };
            } else {
                if (this._player.volum > 1){
                    this._cacheVolume = ((((this._player.volum - 0.5) < 1)) ? 1 : (this._player.volum - 0.5));
                    if (this._volume100Tips.visible){
                        this._volume100Tips.visible = false;
                    };
                    this._volumeTips.visible = true;
                    this._volumeTips.text = (int((Number(this._cacheVolume) * 100)) + "%");
                    this._mcVolume.handleVolumeBar(this._cacheVolume);
                } else {
                    this._cacheVolume = ((((this._mcVolume.currentVolume - (1 / 10)) < 0)) ? 0 : (this._mcVolume.currentVolume - (1 / 10)));
                    if (this._volume100Tips.visible){
                        this._volume100Tips.visible = false;
                    };
                    this._volumeTips.visible = true;
                    this._volumeTips.text = (int((Number(this._cacheVolume) * 100)) + "%");
                    this._mcVolume.handleVolumeBar(this._cacheVolume);
                };
            };
            if (this._isVolume){
                this._player.volum = this._cacheVolume;
            };
        }
        private function handleVolumeChanged(_arg1:VolumeEvent):void{
            if (Number(_arg1.volume) > 0){
                this._isVolume = true;
                this._btnMute.gotoAndStop(1);
            };
            if (this.volumeTipsTimer){
                this.volumeTipsTimer.reset();
                this.volumeTipsTimer.start();
            };
            this._volumeTips.text = (int((Number(_arg1.volume) * 100)) + "%");
            this._volumeTips.visible = true;
            this._volume100Tips.visible = false;
            this._cacheVolume = this._mcVolume.currentVolume;
            if (this._isVolume){
                this.setVolume(this._cacheVolume);
            };
            if (this._volumeTips.text == "100%"){
                this._volume100Tips.text = "100%(按↑键继续放大音量)";
                this._volume100Tips.visible = true;
                this._tipsTimer.reset();
                this._tipsTimer.start();
            };
        }
        private function onTipsTimerComplete(_arg1:TimerEvent):void{
            this._tipsTimer.reset();
            this._volume100Tips.visible = false;
        }
        private function handleVolumeMouseOut(_arg1:MouseEvent):void{
            this._volumeTips.visible = false;
        }
        private function showFilelist(_arg1:MouseEvent):void{
            this._btnTips.visible = false;
            this.hideFilelistTips();
            dispatchEvent(new EventSet(EventSet.SHOW_FACE, "filelist"));
        }
        public function get cacheVolume():Number{
            return (this._cacheVolume);
        }
        public function get isVolume():Boolean{
            return (this._isVolume);
        }
        public function dispatchPlay(_arg1:Event=null){
            if (this.playctrlHandler.isNoEnoughBytes){
                return;
            };
            if (GlobalVars.instance.isExchangeError){
                return;
            };
            var _local2:Boolean = this.playctrlHandler.isValid;
            if (!_local2){
                this.playctrlHandler.checkIsValid();
                return;
            };
            if (_arg1){
                switch (_arg1.target){
                    case this._btnPlay:
                        KKCountReport.sendKankanPgv("btnclick_play");
                        break;
                    case this._btnPlayBig:
                        KKCountReport.sendKankanPgv("btnclick_play_b");
                        break;
                    case this._btnPauseBig:
                        KKCountReport.sendKankanPgv("btnclick_play_b");
                        break;
                };
            };
            this.setPlayStatus();
            if (this._player.isStop){
                ExternalInterface.call("flv_playerEvent", "onRePlay");
            } else {
                ExternalInterface.call("flv_playerEvent", "onStartPlay");
                this.dispatchEvent(new PlayEvent(PlayEvent.PLAY));
            };
        }
        public function setPlayStatus():void{
            this._btnPause.visible = true;
            this._btnPlayBig.visible = false;
            this._btnPauseBig.visible = false;
            this._btnPlay.visible = false;
        }
        public function dispatchPause(_arg1:Event=null){
            if (_arg1){
                switch (_arg1.target){
                    case this._btnPause:
                        KKCountReport.sendKankanPgv("btnclick_cancel");
                        break;
                };
            };
            dispatchEvent(new PlayEvent(PlayEvent.PAUSE));
            this._btnPauseBig.visible = true;
            this._btnPlay.visible = true;
            this._btnPause.visible = false;
            ExternalInterface.call("flv_playerEvent", "onPause");
        }
        public function dispatchStop(_arg1=null){
            ExternalInterface.call("flv_playerEvent", "onStop");
            if (this._player.streamInPlay){
                if ((((Math.abs((this._player.streamInPlay.time - this._player.totalTime)) < 0.5)) || ((this.playctrlHandler._isError == true)))){
                    this._barSlider.x = 0;
                    this._barPlay.width = ((this._barSlider.x - this._barPlay.x) + 6);
                    this.setPlayTimeText(((this.formatTime(0) + "/") + this.formatTime(this._player.totalTime)));
                };
            };
            this._btnUnmute.visible = false;
            this._btnMute.visible = true;
            this._btnPlay.visible = true;
            this._btnPause.visible = false;
            this._btnPlayBig.visible = false;
            this._btnPauseBig.visible = false;
            this._barBuff.width = 0;
            this._barPreDown.width = 0;
            this._player.fixedTime = 0;
            this.setDownloadSpeedText(0);
            this.dispatchEvent(new PlayEvent(PlayEvent.STOP));
            if (this._isChangeQuality == false){
                this.setPlayTimeText("00:00/00:00");
            };
        }
        private function dispatchStopBtn(_arg1:MouseEvent):void{
            ExternalInterface.call("flv_playerEvent", "onStop");
            this.playctrlHandler.hideNoticeBar();
            this.playctrlHandler._videoMask.showInputFace();
            if ((((this._player.time <= 0)) || ((this._player.fixedTime == 0)))){
                return;
            };
            this._barSlider.x = 0;
            this._barPlay.width = ((this._barSlider.x - this._barPlay.x) + 6);
            this._btnUnmute.visible = false;
            this._btnMute.visible = true;
            this._btnPlay.visible = true;
            this._btnPause.visible = false;
            this._btnPlayBig.visible = false;
            this._btnPauseBig.visible = false;
            this._barBuff.width = 0;
            this._barPreDown.width = 0;
            this._player.fixedTime = 0;
            this.setDownloadSpeedText(0);
            this.playctrlHandler.isStopNormal = true;
            this.playctrlHandler.isShowStopFace = false;
            this.dispatchEvent(new PlayEvent(PlayEvent.STOP, true));
            this.playctrlHandler.hideNoticeBar();
            this.playctrlHandler._videoMask.showInputFace();
            if (this._isChangeQuality == false){
                this.setPlayTimeText("00:00/00:00");
            };
            Tools.stat("b=stopButtonFromClient");
        }
        public function errorInit():void{
            this._barSlider.x = 0;
            this._barPlay.width = 0;
            this.setPlayTimeText(((this.formatTime(0) + "/") + this.formatTime(this._player.totalTime)));
            this._btnUnmute.visible = false;
            this._btnMute.visible = true;
            this._btnPlay.visible = true;
            this._btnPause.visible = false;
            this._btnPauseBig.visible = false;
            this._barBuff.width = 0;
            this._barPreDown.width = 0;
            this._player.fixedTime = 0;
            ExternalInterface.call("flv_playerEvent", "onStop");
            this.setDownloadSpeedText(0);
        }
        private function _MOUSE_MOVE_handler(_arg1):void{
            var e:* = _arg1;
            visible = true;
            if (this._timerHide){
                this._timerHide.stop();
            };
            this._timerHide = new Timer(2000, 1);
            this._timerHide.addEventListener("timer", function (_arg1){
                visible = false;
            });
            this._timerHide.start();
        }
        private function getStagePosition(_arg1:Object){
            var _local2:* = _arg1.x;
            var _local3:* = _arg1.y;
            var _local4:* = _arg1.parent;
            while (_local4) {
                _local2 = (_local2 + _local4.x);
                _local3 = (_local3 + _local4.y);
                _local4 = _local4.parent;
            };
            return ({
                x:_local2,
                y:_local3
            });
        }
        private function formatTime(_arg1:Number){
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
            if (_local2 > 0){
                return ((((((((_local2 < 10)) ? ("0" + _local2) : _local2) + ":") + (((_local3 < 10)) ? ("0" + _local3) : _local3)) + ":") + (((_arg1 < 10)) ? ("0" + _arg1) : _arg1)));
            };
            return ((((((_local3 < 10)) ? ("0" + _local3) : _local3) + ":") + (((_arg1 < 10)) ? ("0" + _arg1) : _arg1)));
        }
        public function set barEnabled(_arg1):void{
            if (_arg1){
                this._btnPause.addEventListener(MouseEvent.CLICK, this.dispatchPause);
                this._btnStop.addEventListener(MouseEvent.CLICK, this.dispatchStopBtn);
                this._btnPlay.addEventListener(MouseEvent.CLICK, this.dispatchPlay);
                this._btnFilelist.addEventListener(MouseEvent.CLICK, this.showFilelist);
                this._barBg.addEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barBuff.addEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barPlay.addEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barPreDown.addEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barBg.addEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barBuff.addEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barPlay.addEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barPreDown.addEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barBg.addEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barBuff.addEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barPlay.addEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barPreDown.addEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barSlider.addEventListener(MouseEvent.MOUSE_DOWN, this.barslider_MOUSE_DOWN_handler);
            } else {
                this._btnPause.removeEventListener(MouseEvent.CLICK, this.dispatchPause);
                this._btnStop.removeEventListener(MouseEvent.CLICK, this.dispatchStopBtn);
                this._btnPlay.removeEventListener(MouseEvent.CLICK, this.dispatchPlay);
                this._btnFilelist.removeEventListener(MouseEvent.CLICK, this.showFilelist);
                this._barBg.removeEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barBuff.removeEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barPlay.removeEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barPreDown.removeEventListener(MouseEvent.CLICK, this.bar_CLICK_handler);
                this._barBg.removeEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barBuff.removeEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barPlay.removeEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barPreDown.removeEventListener(MouseEvent.MOUSE_MOVE, this.bar_MOUSE_OVER_handler);
                this._barBg.removeEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barBuff.removeEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barPlay.removeEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barPreDown.removeEventListener(MouseEvent.MOUSE_OUT, this.bar_MOUSE_OUT_handler);
                this._barSlider.removeEventListener(MouseEvent.MOUSE_DOWN, this.barslider_MOUSE_DOWN_handler);
            };
        }
        public function set available(_arg1){
            this._beAvailable = _arg1;
            this.barEnabled = _arg1;
            if (_arg1){
                this._mcVolume.addEventListener(VolumeEvent.VOLUME_CHANGE, this.handleVolumeChanged);
                this._mcVolume.addEventListener(MouseEvent.ROLL_OUT, this.handleVolumeMouseOut);
                this._timerBP.start();
            } else {
                this._mcVolume.removeEventListener(VolumeEvent.VOLUME_CHANGE, this.handleVolumeChanged);
                this._mcVolume.removeEventListener(MouseEvent.ROLL_OUT, this.handleVolumeMouseOut);
                this._timerBP.stop();
                this._barBuff.width = 0;
                this._barPlay.width = 0;
                this._barPreDown.width = 0;
                this._barSlider.x = 0;
                this.setDownloadSpeedText(0);
                this.setPlayTimeText("00:00/00:00");
            };
        }
        public function set flvPlayer(_arg1){
            this._player = _arg1;
            if (!this._timerBP){
                this.addEventHandler();
            };
        }
        public function set fullscreen(_arg1){
            this.setFullScreen(_arg1);
        }
        public function get available(){
            return (this._beAvailable);
        }
        public function setFullScreen(_arg1){
            var _local2:* = stage.stageHeight;
            var _local3:* = stage.stageWidth;
            this._beFullscreen = _arg1;
            if (_arg1){
                this.playWidth = _local3;
                this.playHeight = _local2;
                y = (_local2 - 33);
                this.faceLifting(_local3);
            } else {
                this.playWidth = stage.stageWidth;
                this.playHeight = stage.stageHeight;
                y = (this.playHeight - 33);
                this.faceLifting(this.playWidth);
            };
        }
        private function on_stage_FULLSCREEN(_arg1:FullScreenEvent):void{
            this.setFullScreen(_arg1.fullScreen);
        }
        public function set showPlayOrPauseButton(_arg1){
            switch (_arg1){
                case "PLAY":
                    this._btnPause.visible = false;
                    this._btnPlay.visible = true;
                    break;
                case "PAUSE":
                    this._btnPauseBig.visible = true;
                    this._btnPause.visible = true;
                    this._btnPlay.visible = false;
                    break;
            };
        }
        public function onStop(){
            this._barSlider.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
            this._player.fixedTime = 0;
            this._barSlider.x = 0;
            this._barPlay.width = 0;
            this.setPlayTimeText(((this.formatTime(0) + "/") + this.formatTime(this._player.totalTime)));
        }
        public function hide(_arg1:Boolean=false){
            Mouse.hide();
            if (_arg1){
                TweenLite.killTweensOf(this.barBox);
                this.barBox.y = 40;
            } else {
                TweenLite.to(this.barBox, 0.3, {y:40});
            };
            this.hidden = true;
        }
        public function show(_arg1:Boolean=false){
            Mouse.show();
            if (_arg1){
                TweenLite.killTweensOf(this.barBox);
                this.barBox.y = 0;
            } else {
                TweenLite.to(this.barBox, 0.3, {y:0});
            };
            this.hidden = false;
        }
        public function getVolume():Number{
            return (this._player.volum);
        }
        public function setVolume(_arg1:Number):void{
            this._player.volum = _arg1;
        }
        public function getBufferProgress():Number{
            return ((this._player.downloadProgress * 100));
        }
        public function getPlayProgress(_arg1:Boolean):Number{
            if (_arg1){
                return (this._player.time);
            };
            return (this._player.playProgress);
        }
        public function getPlayStatus():Number{
            return (this._player.playStatus);
        }
        public function errorInfo():String{
            return (this._errorInfo);
        }
        public function stopTimer():void{
            if (((this._timerBP) && (this._timerBP.running))){
                this._timerBP.stop();
            };
        }
        public function startTimer():void{
            if (this._timerBP){
                this._timerBP.start();
            };
        }
        private function volumeBtnEventHandler(_arg1:MouseEvent):void{
            if (_arg1.type == "click"){
                KKCountReport.sendKankanPgv("btnclick_silent");
            };
            switch (_arg1.type){
                case "mouseOver":
                    this.setVolumeBtn(2);
                    if (this.volumeTimer){
                        this.volumeTimer.stop();
                    };
                    break;
                case "mouseOut":
                    this.setVolumeBtn(1);
                    if (this.volumeTimer){
                        this.volumeTimer.reset();
                    } else {
                        this.volumeTimer = new Timer(120, 1);
                        this.volumeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.showVolumeTimerHandler);
                    };
                    this.volumeTimer.start();
                    break;
                case "click":
                    this.setVolumeBtn(3);
                    break;
            };
        }
        private function showVolumeTimerHandler(_arg1:TimerEvent):void{
        }
        public function setVolumeBtn(_arg1:Number):void{
            if (this._isVolume){
                if (_arg1 == 3){
                    _arg1 = 4;
                    this.setVolume(0);
                    this._mcVolume.handleVolumeBar(0);
                    this._isVolume = false;
                };
                this._btnMute.gotoAndStop(_arg1);
                return;
            };
            if (_arg1 == 3){
                _arg1 = 0;
                this.setVolume(this._cacheVolume);
                this._mcVolume.handleVolumeBar(this._cacheVolume);
                this._isVolume = true;
            };
            this._btnMute.gotoAndStop((_arg1 + 2));
        }
        private function btnTipsHandler(_arg1:MouseEvent):void{
            if (_arg1.type == "mouseOut"){
                this._btnTips.visible = false;
                return;
            };
            switch (_arg1.currentTarget){
                case this._btnPlay:
                    this._btnTips.x = -3;
                    this._btnTips.bgWidth = 44;
                    this._btnTips.text = "播放";
                    break;
                case this._btnPause:
                    this._btnTips.x = -3;
                    this._btnTips.bgWidth = 44;
                    this._btnTips.text = "暂停";
                    break;
                case this._btnStop:
                    this._btnTips.x = (this._btnStop.x - 3);
                    this._btnTips.bgWidth = 44;
                    this._btnTips.text = "停止";
                    break;
                case this._btnFilelist:
                    this._btnTips.x = (this._btnFilelist.x - 3);
                    this._btnTips.bgWidth = 44;
                    this._btnTips.text = "列表";
                    break;
                case this._btnFullscreen:
                    if (stage.displayState == StageDisplayState.NORMAL){
                        this._btnTips.x = (stage.stageWidth - 41);
                        this._btnTips.bgWidth = 44;
                        this._btnTips.text = "全屏";
                    } else {
                        this._btnTips.x = (stage.stageWidth - 67);
                        this._btnTips.bgWidth = 70;
                        this._btnTips.text = "退出全屏";
                    };
                    break;
                default:
                    return;
            };
            this._btnTips.y = -35;
            this._btnTips.visible = true;
        }
        public function set isChangeQuality(_arg1:Boolean):void{
            this._isChangeQuality = _arg1;
        }
        public function showFormatLayer(_arg1:Object):void{
            this._formatBtn.showLayer(_arg1);
            this._curFormatBtn.showLayer(_arg1);
        }
        public function set formatShowBtn(_arg1:String):void{
            this._formatBtn.showBtn = _arg1;
            this._curFormatBtn.showBtn = _arg1;
        }
        public function changeToNextFormat():void{
            this._formatBtn.changeToNextFormat();
        }
        public function set seekEnable(_arg1:Boolean):void{
            this._seekEnable = _arg1;
        }
        public function set enableFileList(_arg1:Boolean):void{
            this._btnFilelist.mouseEnabled = _arg1;
            this._btnFilelist.alpha = ((_arg1) ? 1 : 0.5);
        }

    }
}//package com 
﻿package com.notice {
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.greensock.*;
    import flash.external.*;

    public class NoticeBar extends Sprite {

        private var _noticeText:NoticeText;
        private var _dontNoticeText:NoticeText;
        private var _noticeCloseBtn:SimpleButton;
        private var _noticeBarBg:Sprite;
        private var _isInit:Boolean = false;
        private var _showTimer:Timer;
        private var _countTimer:Timer;
        private var _content:String = "";
        private var _mainMc:PlayerCtrl;

        public function NoticeBar(_arg1:PlayerCtrl){
            this._mainMc = _arg1;
        }
        private function init():void{
            this._noticeBarBg = this.createNoticeBg();
            this._noticeCloseBtn = this.createNoticeCloseBtn();
            this._noticeText = new NoticeText(this);
            this._dontNoticeText = new NoticeText(this);
            addChild(this._noticeBarBg);
            addChild(this._noticeText);
            addChild(this._dontNoticeText);
            addChild(this._noticeCloseBtn);
            this.resizePos();
            this._noticeCloseBtn.addEventListener(MouseEvent.CLICK, this.hideNoticeHandler);
            stage.addEventListener(Event.RESIZE, this.resizeHandler);
            this._isInit = true;
        }
        private function createNoticeBg():Sprite{
            var _local1:Sprite = new Sprite();
            _local1.graphics.beginFill(0x181818, 0.9);
            _local1.graphics.drawRect(0, 0, 35, 35);
            _local1.graphics.endFill();
            return (_local1);
        }
        private function createNoticeCloseBtn():SimpleButton{
            var _local1:SimpleButton = new SimpleButton();
            _local1.upState = (_local1.downState = (_local1.overState = (_local1.hitTestState = this.createNoticeCloseBtnState())));
            return (_local1);
        }
        private function createNoticeCloseBtnState():Shape{
            var _local1:Shape = new Shape();
            _local1.graphics.beginFill(0xFFFFFF, 0);
            _local1.graphics.drawRect(0, 0, 14, 14);
            _local1.graphics.lineStyle(1, 0xFFFFFF);
            _local1.graphics.moveTo(0, 0);
            _local1.graphics.lineTo(14, 14);
            _local1.graphics.moveTo(14, 0);
            _local1.graphics.lineTo(0, 14);
            _local1.graphics.endFill();
            return (_local1);
        }
        private function resizePos():void{
            this._noticeBarBg.width = stage.stageWidth;
            this._noticeCloseBtn.x = ((stage.stageWidth - this._noticeCloseBtn.width) - 12);
            this._noticeCloseBtn.y = 10;
            this._noticeText.x = 8;
            this._noticeText.y = 6;
            this._noticeText.tWidth = (stage.stageWidth - 73);
            this._dontNoticeText.x = ((this._noticeCloseBtn.x - this._dontNoticeText.tWidth) - 20);
            this._dontNoticeText.y = 6;
            if (this._mainMc._ctrBar.hidden){
                this.y = (stage.stageHeight - 35);
            } else {
                this.y = (stage.stageHeight - 70);
            };
        }
        private function hideNoticeHandler(_arg1:MouseEvent):void{
            if (ExternalInterface.available){
                ExternalInterface.call("G_PLAYER_INSTANCE.closeNoticeCallback");
            };
            this.hideNoticeBar();
        }
        private function resizeHandler(_arg1:Event):void{
            this.resizePos();
        }
        private function timeOutHandler(_arg1:TimerEvent):void{
            this.visible = false;
            this._showTimer.stop();
        }
        private function countDownHandler(_arg1:TimerEvent):void{
            this.setCountTime((this._countTimer.repeatCount - this._countTimer.currentCount));
        }
        private function setCountTime(_arg1:Number):void{
            if (_arg1 < 0){
                if (this._content){
                    this._noticeText.content = this._content;
                };
                return;
            };
            this._noticeText.content = ((("正在试播中(" + this.digits(_arg1)) + "), ") + this._content);
        }
        private function digits(_arg1:Number):String{
            var _local2:Number = Math.floor((_arg1 / 60));
            var _local3:Number = Math.floor((_arg1 % 60));
            var _local4:String = ((this.zero(_local2) + ":") + this.zero(_local3));
            return (_local4);
        }
        private function zero(_arg1:Number):String{
            if (_arg1 < 10){
                return (("0" + _arg1));
            };
            return (("" + _arg1));
        }
        private function timerStart(_arg1:int):void{
            if (this._showTimer){
                this._showTimer.reset();
                this._showTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.timeOutHandler);
                this._showTimer = null;
            };
            this._showTimer = new Timer(1000, _arg1);
            this._showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.timeOutHandler);
        }
        public function setContent(_arg1:String, _arg2:Boolean=false, _arg3:int=15, _arg4:int=1, _arg5:String=null, _arg6:int=0, _arg7:int=0):void{
            this._content = _arg1;
            if (this._isInit == false){
                this.init();
            };
            this._noticeText.content = _arg1;
            this._noticeText.callBackFun = _arg5;
            this._noticeText.setCallBackFunLocation(_arg6, _arg7);
            this._dontNoticeText.content = "";
            this.timerStart((((_arg3 <= 0)) ? 15 : _arg3));
            if (_arg2 == false){
                this._showTimer.start();
            };
            this.visible = true;
            if ((((_arg4 < 1)) || ((_arg4 > 8)))){
                _arg4 = 1;
            };
            this.resizePos();
        }
        public function setRightContent(_arg1:String):void{
            this._dontNoticeText.content = _arg1;
            this.resizePos();
        }
        public function setCountDown(_arg1:Number):void{
            if (this._countTimer){
                this._countTimer.stop();
                this._countTimer.removeEventListener(TimerEvent.TIMER, this.countDownHandler);
                this._countTimer = null;
            };
            if (_arg1 > 0){
                this._countTimer = new Timer(1000, _arg1);
                this._countTimer.addEventListener(TimerEvent.TIMER, this.countDownHandler);
                this._countTimer.start();
            };
            this.setCountTime(_arg1);
            this.resizePos();
        }
        public function hideNoticeBar():void{
            this.visible = false;
            if (this._showTimer){
                this._showTimer.stop();
            };
            if (this._countTimer){
                this._countTimer.stop();
            };
        }
        public function showCloseBtn(_arg1:Boolean):void{
            this._noticeCloseBtn.visible = _arg1;
        }
        public function hide(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.y = (stage.stageHeight - 35);
            } else {
                TweenLite.to(this, 0.3, {y:(stage.stageHeight - 35)});
            };
        }
        public function show(_arg1:Boolean=false):void{
            if (_arg1){
                TweenLite.killTweensOf(this);
                this.y = (stage.stageHeight - 70);
            } else {
                TweenLite.to(this, 0.3, {y:(stage.stageHeight - 70)});
            };
        }

    }
}//package com.notice 
﻿package com.notice {
    import com.global.*;
    import flash.events.*;
    import flash.display.*;
    import com.common.*;
    import eve.*;
    import flash.text.*;
    import flash.external.*;

    public class NoticeText extends Sprite {

        private var _text:TextField;
        private var _style:StyleSheet;
        private var _callBackFun:String;
        private var _start:int;
        private var _length:int;
        private var _noticeBar:NoticeBar;

        public function NoticeText(_arg1:NoticeBar){
            this._noticeBar = _arg1;
            this.init();
        }
        private function init():void{
            if (this._text == null){
                this._text = new TextField();
                this._text.selectable = false;
                this._text.height = 23;
                this._text.addEventListener(TextEvent.LINK, this.linkEventHandler);
                this._text.addEventListener(MouseEvent.CLICK, this.mouseClickHandler);
                addChild(this._text);
                this.initStyle();
            };
        }
        public function set content(_arg1:String):void{
            this._text.styleSheet = this._style;
            this._text.htmlText = (("<span class=\"style\">" + _arg1) + "</span>");
        }
        public function set callBackFun(_arg1:String):void{
            this._callBackFun = _arg1;
        }
        public function setCallBackFunLocation(_arg1:int, _arg2:int):void{
            this._start = _arg1;
            this._length = _arg2;
        }
        private function initStyle():void{
            this._style = new StyleSheet();
            this._style.setStyle(".style", {
                color:"#ffffff",
                fontSize:"15",
                textAlign:"left",
                fontFamily:"微软雅黑"
            });
            this._style.setStyle("a", {
                color:"#097BB3",
                fontSize:"15",
                textDecoration:"underline",
                fontFamily:"微软雅黑"
            });
            this._style.setStyle(".redStyle", {
                color:"#ff0000",
                fontSize:"15",
                textDecoration:"underline",
                fontFamily:"微软雅黑"
            });
        }
        public function set tWidth(_arg1:Number):void{
            this._text.width = _arg1;
        }
        public function get tWidth():Number{
            return (this._text.textWidth);
        }
        private function checkMousePosition(_arg1:int):Boolean{
            if ((((_arg1 >= this._start)) && ((_arg1 <= (this._start + this._length))))){
                return (true);
            };
            return (false);
        }
        private function mouseClickHandler(_arg1:MouseEvent):void{
            var _local2:int = this._text.getCharIndexAtPoint(mouseX, mouseY);
            if (this.checkMousePosition(_local2) == false){
                return;
            };
            if (this._callBackFun != null){
                ExternalInterface.call(this._callBackFun);
            };
        }
        private function linkEventHandler(_arg1:TextEvent):void{
            var _local2:String = Tools.getReferfrom();
            var _local3:String = GlobalVars.instance.paypos_tips_time;
            switch (_arg1.text){
                case "pause":
                    dispatchEvent(new PlayEvent(PlayEvent.PAUSE_4_STAGE));
                    dispatchEvent(new SetQulityEvent(SetQulityEvent.PAUSE_FOR_QUALITY_TIP));
                    break;
                case "changeLowerQulity":
                    dispatchEvent(new SetQulityEvent(SetQulityEvent.LOWER_QULITY));
                    break;
                case "showAutoQualityFace":
                    dispatchEvent(new EventSet(EventSet.SHOW_AUTOQUALITY_FACE));
                    break;
                case "showSkipMovieFace":
                    dispatchEvent(new EventSet(EventSet.SHOW_SKIPMOVIE_FACE));
                    break;
                case "showStageVideo":
                    dispatchEvent(new EventSet(EventSet.SHOW_STAGE_VIDEO));
                    break;
                case "replay":
                    dispatchEvent(new PlayEvent(PlayEvent.REPLAY));
                    break;
                case "dontNotice":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.DontNoticeBytes));
                    break;
                case "buyVIP13":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                        refer:_local2,
                        paypos:_local3,
                        hasBytes:true
                    }));
                    break;
                case "buyVIP13FluxOut":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                        refer:_local2,
                        paypos:_local3,
                        hasBytes:false
                    }));
                    break;
                case "buyVIP11":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.BuyVIP, {
                        refer:_local2,
                        paypos:_local3,
                        hasBytes:false
                    }));
                    break;
                case "getBytes":
                    dispatchEvent(new TryPlayEvent(TryPlayEvent.GetBytes));
                    break;
                case "showCaptionFace":
                    this._noticeBar.hideNoticeBar();
                    dispatchEvent(new EventSet(EventSet.SHOW_FACE, "captionFromTips"));
                    Tools.stat("b=showSubtitleList");
                    break;
                case "hideNoCaptionTips":
                    Cookies.setCookie("hideNoCaptionTips", true);
                    this._noticeBar.hideNoticeBar();
                    break;
                case "hideAutoCaptionTips":
                    Cookies.setCookie("hideAutoCaptionTips", true);
                    this._noticeBar.hideNoticeBar();
                    break;
                case "backToLiuChang":
                    Tools.setFormatCallBack("p", true);
                    if (GlobalVars.instance.isStat){
                        Tools.stat("b=changeToLowerFormat");
                    };
                    break;
                case "backToGaoQing":
                    Tools.setFormatCallBack("g", true);
                    if (GlobalVars.instance.isStat){
                        Tools.stat("b=changeToLowerFormat");
                    };
                    break;
                case "goToGaoQing":
                    Tools.setFormatCallBack("g", true);
                    if (GlobalVars.instance.isStat){
                        Tools.stat("b=changeToHigherFormat");
                    };
                    break;
                case "goToChaoQing":
                    Tools.setFormatCallBack("c", true);
                    if (GlobalVars.instance.isStat){
                        Tools.stat("b=changeToHigherFormat");
                    };
                    break;
                case "hideLowSpeedTips":
                    GlobalVars.instance.isHideLowSpeedTips = true;
                    Cookies.setCookie("hideLowSpeedTips", true);
                    Tools.stat("b=hideLowSpeedTips");
                    this._noticeBar.hideNoticeBar();
                    break;
                case "hideHighSpeedTips":
                    GlobalVars.instance.isHideHighSpeedTips = true;
                    Cookies.setCookie("hideHighSpeedTips", true);
                    Tools.stat("b=hideHighSpeedTips");
                    this._noticeBar.hideNoticeBar();
                    break;
            };
        }

    }
}//package com.notice 
﻿package com.notice {
    import com.global.*;
    import flash.net.*;
    import flash.display.*;
    import flash.utils.*;
    import com.*;
    import com.common.*;
    import eve.*;
    import flash.external.*;

    public class bufferTip extends Sprite {

        private var _countShow:Number = 0;
        private var _countBreak:Number = 0;
        private var _qulityCurr:int = 0;
        private var _qulityTotal:Array;
        private var _isHasQulity:Boolean = false;
        private var _player:Player;
        private var _isRegisted:Boolean;

        public function bufferTip(_arg1:Player){
            this._qulityTotal = [];
            super();
            this._player = _arg1;
        }
        public function changeQulityHandler():void{
            if (this._qulityCurr < 1){
                return;
            };
            while (this._qulityTotal[(this._qulityCurr - 1)] != 1) {
                this._qulityCurr = (this._qulityCurr - 1);
                if (this._qulityCurr == -1){
                    this._isHasQulity = false;
                    return;
                };
            };
            switch ((this._qulityCurr - 1)){
                case 0:
                    ExternalInterface.call("flv_playerEvent", "onNomalClick");
                    dispatchEvent(new SetQulityEvent(SetQulityEvent.CHANGE_QUILTY));
                    break;
                case 1:
                    ExternalInterface.call("flv_playerEvent", "onStandardClick");
                    dispatchEvent(new SetQulityEvent(SetQulityEvent.CHANGE_QUILTY));
                    break;
            };
            this._qulityCurr = (this._qulityCurr - 1);
            if ((((this._qulityCurr == 0)) || ((this._qulityCurr == -1)))){
                this._isHasQulity = false;
            };
        }
        public function addBreakCount(_arg1:Number):void{
            var _local2:int;
            var _local3:GlobalVars;
            var _local4:String;
            var _local5:String;
            var _local6:int;
            if (this._countBreak == 0){
                this._countBreak = 1;
                _local3 = GlobalVars.instance;
                switch (_local3.bufferType){
                    case _local3.bufferTypeCustom:
                        _local2 = -2;
                        if (!this._isRegisted){
                            this._isRegisted = true;
                            sendToURL(new URLRequest(((("http://i.vod.xunlei.com/cdn/req_regist?userid=" + Tools.getUserInfo("userid")) + "&d=") + new Date().time)));
                        };
                        if (_local3.curLowSpeedTipsTime > _local3.startLowSpeedTipsTime){
                            _local3.showLowSpeedTimeArray.push(getTimer());
                            JTracer.sendMessage(("bufferTip -> custom buffer tips, time:" + getTimer()));
                        };
                        if (((((!(GlobalVars.instance.isReplaceURL)) && (this._player.nextIsDL()))) && (!(GlobalVars.instance.isUseHttpSocket)))){
                            GlobalVars.instance.isReplaceURL = true;
                            _local5 = this._player.getNextUrl();
                            if (_local5){
                                this._player.playUrl = _local5;
                                GlobalVars.instance.isVodGetted = false;
                            };
                            JTracer.sendMessage(("addBreakCount -> get next play url:" + this._player.playUrl));
                        };
                        if (((!(GlobalVars.instance.isChangeURL)) && (!((this._player.lastUrl == this._player.playUrl))))){
                            GlobalVars.instance.isChangeURL = true;
                            this._player.lastUrl = this._player.playUrl;
                            _local2 = -3;
                        };
                        break;
                    case _local3.bufferTypeFirstBuffer:
                        if (((!(GlobalVars.instance.isChangeURL)) && (!((this._player.lastUrl == this._player.playUrl))))){
                            GlobalVars.instance.isChangeURL = true;
                            this._player.lastUrl = this._player.playUrl;
                        };
                        _local2 = -3;
                        break;
                    case _local3.bufferTypeChangeFormat:
                        _local2 = -4;
                        break;
                    case _local3.bufferTypeDrag:
                        _local2 = -5;
                        break;
                    case _local3.bufferTypeKeyPress:
                        _local2 = -6;
                        break;
                    case _local3.bufferTypePreview:
                        _local2 = -7;
                        break;
                    case _local3.bufferTypeError:
                        _local2 = -8;
                        break;
                    default:
                        _local2 = -2;
                };
                _local4 = GlobalVars.instance.statCC;
                if ((((_local2 == -2)) || ((_local2 == -3)))){
                    _local6 = this._player.getCurLink();
                    Tools.stat((((((((((((((((("f=buffer&gcid=" + Tools.getUserInfo("gcid")) + "&gdl=") + encodeURIComponent(StringUtil.getShortenURL(this._player.originGdlUrl))) + "&vod=") + encodeURIComponent(StringUtil.getShortenURL(this._player.vodUrl))) + "&t=") + _arg1) + "&e=") + _local2) + "&link=") + _local6) + "&linknum=") + GlobalVars.instance.linkNum) + "&format=") + GlobalVars.instance.movieFormat) + _local4));
                    JTracer.sendMessage((((((((((((((("bufferTip -> addBreakCount, f=buffer&gcid=" + Tools.getUserInfo("gcid")) + "&gdl=") + encodeURIComponent(this._player.originGdlUrl)) + "&vod=") + encodeURIComponent(this._player.vodUrl)) + "&t=") + _arg1) + "&e=") + _local2) + "&link=") + _local6) + "&linknum=") + GlobalVars.instance.linkNum) + _local4));
                } else {
                    Tools.stat((((((((((((("f=buffer&gcid=" + Tools.getUserInfo("gcid")) + "&gdl=") + encodeURIComponent(StringUtil.getShortenURL(this._player.originGdlUrl))) + "&vod=") + encodeURIComponent(StringUtil.getShortenURL(this._player.vodUrl))) + "&t=") + _arg1) + "&e=") + _local2) + "&format=") + GlobalVars.instance.movieFormat) + _local4));
                    JTracer.sendMessage((((((((((("bufferTip -> addBreakCount, f=buffer&gcid=" + Tools.getUserInfo("gcid")) + "&gdl=") + encodeURIComponent(this._player.originGdlUrl)) + "&vod=") + encodeURIComponent(this._player.vodUrl)) + "&t=") + _arg1) + "&e=") + _local2) + _local4));
                };
            };
        }
        public function clearBreakCount():void{
            this._countBreak = 0;
            JTracer.sendMessage("bufferTip -> clearBreakCount");
        }
        public function setQulityType(_arg1:String, _arg2:int):void{
            var _local3 = (_arg1 + "");
            this._qulityTotal.push(((_local3.charAt(0)) || (0)));
            this._qulityTotal.push(((_local3.charAt(1)) || (0)));
            this._qulityTotal.push(((_local3.charAt(2)) || (0)));
            this._qulityCurr = _arg2;
            if (this._qulityCurr == 0){
                this._isHasQulity = false;
                return;
            };
            var _local4:Number = 0;
            while (_local4 < this._qulityCurr) {
                if (this._qulityTotal[_local4] == 1){
                    this._isHasQulity = true;
                };
                _local4++;
            };
        }
        public function autioChangeQuality():void{
            this._qulityCurr++;
        }

    }
}//package com.notice 
﻿package com.serialization.json {

    public class JSON {

        public static function deserialize(_arg1:String){
            var at:* = NaN;
            var ch:* = null;
            var _isDigit:* = null;
            var _isHexDigit:* = null;
            var _white:* = null;
            var _string:* = null;
            var _next:* = null;
            var _array:* = null;
            var _object:* = null;
            var _number:* = null;
            var _word:* = null;
            var _value:* = null;
            var _error:* = null;
            var source:* = _arg1;
            source = new String(source);
            at = 0;
            ch = " ";
            _isDigit = function (_arg1:String){
                return (((("0" <= _arg1)) && ((_arg1 <= "9"))));
            };
            _isHexDigit = function (_arg1:String){
                return (((((_isDigit(_arg1)) || (((("A" <= _arg1)) && ((_arg1 <= "F")))))) || (((("a" <= _arg1)) && ((_arg1 <= "f"))))));
            };
            _error = function (_arg1:String):void{
                throw (new Error(_arg1, (at - 1)));
            };
            _next = function (){
                ch = source.charAt(at);
                at = (at + 1);
                return (ch);
            };
            _white = function ():void{
                while (ch) {
                    if (ch <= " "){
                        _next();
                    } else {
                        if (ch == "/"){
                            switch (_next()){
                                case "/":
                                    do  {
                                    } while (((((_next()) && (!((ch == "\n"))))) && (!((ch == "\r")))));
                                    break;
                                case "*":
                                    _next();
                                    while (true) {
                                        if (ch){
                                            if (ch == "*"){
                                                if (_next() == "/"){
                                                    _next();
                                                    break;
                                                };
                                            } else {
                                                _next();
                                            };
                                        } else {
                                            _error("Unterminated Comment");
                                        };
                                    };
                                    break;
                                default:
                                    _error("Syntax Error");
                            };
                        } else {
                            break;
                        };
                    };
                };
            };
            _string = function (){
                var _local3:*;
                var _local4:*;
                var _local1:* = "";
                var _local2:* = "";
                var _local5:Boolean;
                if (ch == "\""){
                    while (_next()) {
                        if (ch == "\""){
                            _next();
                            return (_local2);
                        };
                        if (ch == "\\"){
                            switch (_next()){
                                case "b":
                                    _local2 = (_local2 + "\b");
                                    break;
                                case "f":
                                    _local2 = (_local2 + "\f");
                                    break;
                                case "n":
                                    _local2 = (_local2 + "\n");
                                    break;
                                case "r":
                                    _local2 = (_local2 + "\r");
                                    break;
                                case "t":
                                    _local2 = (_local2 + "\t");
                                    break;
                                case "u":
                                    _local4 = 0;
                                    _local1 = 0;
                                    while (_local1 < 4) {
                                        _local3 = parseInt(_next(), 16);
                                        if (!isFinite(_local3)){
                                            _local5 = true;
                                            break;
                                        };
                                        _local4 = ((_local4 * 16) + _local3);
                                        _local1 = (_local1 + 1);
                                    };
                                    if (_local5){
                                        _local5 = false;
                                        break;
                                    };
                                    _local2 = (_local2 + String.fromCharCode(_local4));
                                    break;
                                default:
                                    _local2 = (_local2 + ch);
                            };
                        } else {
                            _local2 = (_local2 + ch);
                        };
                    };
                };
                _error("Bad String");
                return (null);
            };
            _array = function (){
                var _local1:Array = [];
                if (ch == "["){
                    _next();
                    _white();
                    if (ch == "]"){
                        _next();
                        return (_local1);
                    };
                    while (ch) {
                        _local1.push(_value());
                        _white();
                        if (ch == "]"){
                            _next();
                            return (_local1);
                        };
                        if (ch != ","){
                            break;
                        };
                        _next();
                        _white();
                        if (ch == "]"){
                            _next();
                            return (_local1);
                        };
                    };
                };
                _error("Bad Array");
                return (null);
            };
            _object = function (){
                var _local1:* = {};
                var _local2:* = {};
                if (ch == "{"){
                    _next();
                    _white();
                    if (ch == "}"){
                        _next();
                        return (_local2);
                    };
                    while (ch) {
                        _local1 = _string();
                        _white();
                        if (ch != ":"){
                            break;
                        };
                        _next();
                        _local2[_local1] = _value();
                        _white();
                        if (ch == "}"){
                            _next();
                            return (_local2);
                        };
                        if (ch != ","){
                            break;
                        };
                        _next();
                        _white();
                        if (ch == "}"){
                            _next();
                            return (_local2);
                        };
                    };
                };
                _error("Bad Object");
            };
            _number = function (){
                var _local3:*;
                var _local4:*;
                var _local7:int;
                var _local1:* = "";
                var _local2:* = "";
                var _local5 = "";
                var _local6 = "";
                if (ch == "-"){
                    _local1 = "-";
                    _local6 = _local1;
                    _next();
                };
                if (ch == "0"){
                    _next();
                    if ((((ch == "x")) || ((ch == "X")))){
                        _next();
                        while (_isHexDigit(ch)) {
                            _local5 = (_local5 + ch);
                            _next();
                        };
                        if (_local5 == ""){
                            _error("mal formed Hexadecimal");
                        } else {
                            return (Number(((_local6 + "0x") + _local5)));
                        };
                    } else {
                        _local1 = (_local1 + "0");
                    };
                };
                while (_isDigit(ch)) {
                    _local1 = (_local1 + ch);
                    _next();
                };
                if (ch == "."){
                    _local1 = (_local1 + ".");
                    while (((((_next()) && ((ch >= "0")))) && ((ch <= "9")))) {
                        _local1 = (_local1 + ch);
                    };
                };
                _local3 = (1 * _local1);
                if (!isFinite(_local3)){
                    _error("Bad Number");
                } else {
                    if ((((ch == "e")) || ((ch == "E")))){
                        _next();
                        _local7 = ((ch)=="-") ? -1 : 1;
                        if ((((ch == "+")) || ((ch == "-")))){
                            _next();
                        };
                        if (_isDigit(ch)){
                            _local2 = (_local2 + ch);
                        } else {
                            _error("Bad Exponent");
                        };
                        while (((((_next()) && ((ch >= "0")))) && ((ch <= "9")))) {
                            _local2 = (_local2 + ch);
                        };
                        _local4 = (_local7 * _local2);
                        if (!isFinite(_local3)){
                            _error("Bad Exponent");
                        } else {
                            _local3 = (_local3 * Math.pow(10, _local4));
                        };
                    };
                    return (_local3);
                };
                return (NaN);
            };
            _word = function (){
                switch (ch){
                    case "t":
                        if ((((((_next() == "r")) && ((_next() == "u")))) && ((_next() == "e")))){
                            _next();
                            return (true);
                        };
                        break;
                    case "f":
                        if ((((((((_next() == "a")) && ((_next() == "l")))) && ((_next() == "s")))) && ((_next() == "e")))){
                            _next();
                            return (false);
                        };
                        break;
                    case "n":
                        if ((((((_next() == "u")) && ((_next() == "l")))) && ((_next() == "l")))){
                            _next();
                            return (null);
                        };
                        break;
                };
                _error("Syntax Error");
                return (null);
            };
            _value = function (){
                _white();
                switch (ch){
                    case "{":
                        return (_object());
                    case "[":
                        return (_array());
                    case "\"":
                        return (_string());
                    case "-":
                        return (_number());
                    default:
                        return ((((((ch >= "0")) && ((ch <= "9")))) ? _number() : _word()));
                };
            };
            return (_value());
        }
        public static function serialize(_arg1):String{
            var _local2:String;
            var _local3:Number;
            var _local4:Number;
            var _local6:*;
            var _local7:String;
            var _local8:Number;
            var _local5 = "";
            switch (typeof(_arg1)){
                case "object":
                    if (_arg1){
                        if ((_arg1 is Array)){
                            _local4 = _arg1.length;
                            _local3 = 0;
                            while (_local3 < _local4) {
                                _local6 = serialize(_arg1[_local3]);
                                if (_local5){
                                    _local5 = (_local5 + ",");
                                };
                                _local5 = (_local5 + _local6);
                                _local3++;
                            };
                            return ((("[" + _local5) + "]"));
                        };
                        if (typeof(_arg1.toString) != "undefined"){
                            for (_local7 in _arg1) {
                                _local6 = _arg1[_local7];
                                if (((!((typeof(_local6) == "undefined"))) && (!((typeof(_local6) == "function"))))){
                                    _local6 = serialize(_local6);
                                    if (_local5){
                                        _local5 = (_local5 + ",");
                                    };
                                    _local5 = (_local5 + ((serialize(_local7) + ":") + _local6));
                                };
                            };
                            return ((("{" + _local5) + "}"));
                        };
                    };
                    return ("null");
                case "number":
                    return (((isFinite(_arg1)) ? String(_arg1) : "null"));
                case "string":
                    _local4 = _arg1.length;
                    _local5 = "\"";
                    _local3 = 0;
                    while (_local3 < _local4) {
                        _local2 = _arg1.charAt(_local3);
                        if (_local2 >= " "){
                            if ((((_local2 == "\\")) || ((_local2 == "\"")))){
                                _local5 = (_local5 + "\\");
                            };
                            _local5 = (_local5 + _local2);
                        } else {
                            switch (_local2){
                                case "\b":
                                    _local5 = (_local5 + "\\b");
                                    break;
                                case "\f":
                                    _local5 = (_local5 + "\\f");
                                    break;
                                case "\n":
                                    _local5 = (_local5 + "\\n");
                                    break;
                                case "\r":
                                    _local5 = (_local5 + "\\r");
                                    break;
                                case "\t":
                                    _local5 = (_local5 + "\\t");
                                    break;
                                default:
                                    _local8 = _local2.charCodeAt();
                                    _local5 = (_local5 + (("\\u00" + Math.floor((_local8 / 16)).toString(16)) + (_local8 % 16).toString(16)));
                            };
                        };
                        _local3 = (_local3 + 1);
                    };
                    return ((_local5 + "\""));
                case "boolean":
                    return (String(_arg1));
                default:
                    return ("null");
            };
        }

    }
}//package com.serialization.json 
﻿package com {
    import com.global.*;
    import flash.net.*;
    import flash.events.*;
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.media.*;
    import com.common.*;
    import com.slice.*;
    import eve.*;
    import com.serialization.json.*;
    import ctr.statuMenu.*;
    import flash.external.*;
    import flash.system.*;

    public class Player extends Sprite {

        public static const SET_QUALITY:String = "set quality";
        public static const AUTO_PLAY:String = "auto play";
        public static const INIT_PAUSE:String = "init pause";

        public var streamInPlay:NetStream;
        public var isStop:Boolean = false;
        public var isStartPause:Boolean = true;
        public var swf_width:Number;
        public var swf_height:Number;
        public var isPause:Boolean;
        public var nomarl_width:int;
        public var nomarl_height:int;
        public var nomarl_x:int;
        public var nomarl_y:int;
        public var v_w:uint;
        public var v_h:uint;
        public var customClient:Object;
        public var dragTime:Array;
        public var dragPosition:Array;
        public var startTimer:Number;
        private var bufferStart:Number = 0;
        private var bufferStartTime:Number = 0;
        public var bufferEndTime:Number = 0;
        public var fixedTime:Number = -1;
        public var fixedByte:Number = 0;
        public var main_mc:PlayerCtrl;
        public var downLoadTimer:Timer;
        public var myTimer:Timer;
        private var _totalTime:int;
        private var _sliceStream:SliceStreamBytes;
        private var _streamMetaData:StreamMetaData;
        private var _streamStartByte:Number = 0;
        private var _streamEndByte:Number = 0;
        private var _streamStartTime:Number = 0;
        private var _avarageSpeedArray:Array;
        private var _totalSpeedArray:Array;
        private var _isSubmitSpeed:Boolean;
        private var _isResetStart:Boolean;
        private var _isInvalidTime:Boolean;
        private var _urlType:String = "normal";
        private var _timePlayed:Number = 0;
        private var _curTimePlayed:Number = 120;
        private var _timeDownload:Number = 0;
        private var _gdlUrl:String;
        private var _originGdlUrl:String;
        private var _suffixUrl:String;
        private var _vodUrl:String;
        private var _playUrl:String;
        private var _lastUrl:String;
        private var __old__currentSeq:int;
        private var _currentPlayID:String;
        private var __old__statLoader:URLLoader;
        private var _highSpeedSpeedArray:Array;
        private var _isStartHighSpeedTimer:Boolean;
        private var socket_count:uint = 3;
        private var socket_array:Array;
        private var block_size:uint = 131072;
        private var current_pos:uint;
        private var is_append_header:Boolean;
        private var is_seek_finish:Boolean = true;
        private var appendTimer:Timer;
        private var isSpliceUpdate:Boolean;
        private var playTimeHeadIndex:Number;
        public var query_pos:uint;
        public var is_invalid_time:Boolean = true;
        public var sliceSize:uint;
        public var sliceStart:uint;
        private var _retryLastTimeStat:String = "";
        public var playEnd:Boolean = false;
        private var _currVolum:Number = 0;
        private var videoUrlArr:Array;
        private var myConnection:NetConnection;
        private var classicVideo:Video;
        private var mySpeed:Number = 0;
        private var _status:Number = -1;
        private var _currentQuality:int;
        private var _errorInfo:String;
        private var preBufferLoaded:uint = 0;
        private var _bufferTime:Number = 10;
        private var _isInBuffer:Boolean = false;
        private var _progressCacheTime:Number = 0;
        private var _seekTime:Number = 0;
        private var _currentQuityType:Number = 0;
        private var _currentQulityStr:String = null;
        private var _isChangeQuality:Boolean = false;
        private var _js_seekPos:Number = -1;
        private var _isLoadedNextStream:Boolean = true;

        public function Player(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:PlayerCtrl){
            this.dragTime = [];
            this.dragPosition = [];
            this._avarageSpeedArray = [];
            this._totalSpeedArray = [];
            this._highSpeedSpeedArray = [];
            this.socket_array = [];
            this.videoUrlArr = [];
            super();
            this.main_mc = _arg4;
            this.swf_width = _arg1;
            this.swf_height = _arg2;
            this.addPlayEventHandler();
            this.fnOnProgress();
            this.mouseEnabled = false;
            this.mouseChildren = false;
            this.playEnd = false;
            this._sliceStream = new SliceStreamBytes(this);
            this._streamMetaData = new StreamMetaData(this);
            this._streamMetaData.addEventListener(StreamMetaData.KEYFRAME_ERROR, this.streamMetaDataHandler);
            this._streamMetaData.addEventListener(StreamMetaData.KEYFRAME_LOADED, this.streamMetaDataHandler);
        }
        public function get retryLastTimeStat():String{
            var _local1:* = this._retryLastTimeStat;
            if (_local1 != ""){
                this._retryLastTimeStat = "";
            };
            return (_local1);
        }
        public function set retryLastTimeStat(_arg1:String):void{
            this._retryLastTimeStat = _arg1;
        }
        private function streamMetaDataHandler(_arg1:Event):void{
            var _local2:Number;
            if (_arg1.type == StreamMetaData.KEYFRAME_ERROR){
                this._errorInfo = "301";
                JTracer.sendMessage(("Player -> onErrorInfo, code:" + this._errorInfo));
                this.main_mc.showPlayError(this._errorInfo);
                Tools.stat((((("f=playerror&e=" + this._errorInfo) + "&gcid=") + Tools.getUserInfo("ygcid")) + this.retryLastTimeStat));
                ExternalInterface.call("flv_playerEvent", "onErrorInfo", this._errorInfo);
            } else {
                if (_arg1.type == StreamMetaData.KEYFRAME_LOADED){
                    _local2 = Math.round(((this.videoUrlArr[0].sliceTime * this.videoUrlArr[0].totalByte) / this.videoUrlArr[0].totalTime));
                    this._streamMetaData.firstByteEnd = _local2;
                    this._streamMetaData.totalByte = this.totalByte;
                    this._streamMetaData.sliceTime = this.videoUrlArr[0].sliceTime;
                    this._streamMetaData.spliceUpdateArray();
                    this._streamStartByte = this._streamMetaData.getStartByte(this.videoUrlArr[0].start);
                    this._streamStartTime = this._streamMetaData.getStartTime(this.videoUrlArr[0].start);
                    this._streamEndByte = this._streamMetaData.getSpliceEndByte(this.videoUrlArr[0].start);
                    this.connectStream();
                };
            };
        }
        private function fnOnEnterFrame():void{
            var _local1:SharedObject;
            var _local2:Number;
            if (this.streamInPlay){
                if (!this.main_mc._ctrBar.isVolume){
                    this.volum = 0;
                    return;
                };
                _local1 = SharedObject.getLocal("kkV");
                _local2 = ((_local1.data.v) ? _local1.data.v : this.main_mc._ctrBar.cacheVolume);
                this.volum = _local2;
            };
        }
        private function fnOnProgress():void{
            this.myTimer = new Timer(1000, 0);
            this.myTimer.addEventListener("timer", function ():void{
                ExternalInterface.call("flv_playerEvent", "onProgress");
            });
        }
        public function setPlayUrl(_arg1:Array):void{
            var _local2:Array;
            this.startTimer = getTimer();
            this.is_seek_finish = true;
            this._streamStartByte = 0;
            this._streamStartTime = 0;
            this._isSubmitSpeed = false;
            this._isResetStart = false;
            if (this._isChangeQuality){
                this._urlType = "changeformat";
            } else {
                this._urlType = "normal";
                this._totalSpeedArray = [];
                this._avarageSpeedArray = [];
                this._timePlayed = 0;
                this.__old__currentSeq = 1;
                this._currentPlayID = "";
            };
            this.videoUrlArr = _arg1;
            this.playUrl = this.getNextUrl();
            this.lastUrl = this.playUrl;
            GlobalVars.instance.isVodGetted = false;
            _local2 = this.playUrl.match(/^http:\/\/\d+\.\d+\.\d+\.\d+/);
            if (_local2){
                GlobalVars.instance.vodAddr = _local2[0].substr(7);
                JTracer.sendMessage(("host:" + GlobalVars.instance.vodAddr));
                GlobalVars.instance.isIPLink = true;
            };
            GlobalVars.instance.statCC = this.playUrl.match(/&cc=[^&]+/)[0];
            JTracer.sendMessage(("Player -> setPlayUrl, get next play url:" + this.playUrl));
            var _local3:int = this.videoUrlArr[0].autoplay;
            if (_local3 == 0){
                dispatchEvent(new Event(INIT_PAUSE));
                this.isStop = false;
                this.isPause = false;
                this.isStartPause = true;
            } else {
                if (_local3 == 1){
                    dispatchEvent(new Event(AUTO_PLAY));
                    this.isStop = false;
                    this.isPause = false;
                    this.isStartPause = false;
                    this.play();
                } else {
                    if (_local3 == 2){
                    } else {
                        if (_local3 == 4){
                        };
                    };
                };
            };
            this.main_mc._ctrBar.formatShowBtn = ((_arg1[0].format) || ("p"));
            dispatchEvent(new ControlEvent(ControlEvent.SHOW_CTRBAR, "show"));
        }
        private function initialConnection():void{
            if (this.myConnection){
                this.myConnection.close();
                this.myConnection = null;
            };
            this.myConnection = new NetConnection();
            this.myConnection.connect(null);
        }
        private function initialStream():void{
            if (this.customClient){
                this.customClient = null;
            };
            this.customClient = new Object();
            this.customClient.onMetaData = this.metaDataHandler(this);
            if (this.streamInPlay){
                this.streamInPlay.close();
                this.streamInPlay.removeEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
                this.streamInPlay = null;
            };
            this.streamInPlay = new NetStream(this.myConnection);
            this.streamInPlay.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
            this.streamInPlay.client = this.customClient;
            this.streamInPlay.bufferTime = this._bufferTime;
            this.streamInPlay.soundTransform = new SoundTransform(0);
        }
        private function initialVideo():void{
            if (this.classicVideo){
                removeChild(this.classicVideo);
                this.classicVideo.clear();
                this.classicVideo = null;
            };
            this.classicVideo = new Video();
            this.classicVideo.visible = true;
            this.classicVideo.smoothing = true;
            this.classicVideo.width = this.width;
            this.classicVideo.height = this.height;
            dispatchEvent(new PlayEvent(PlayEvent.INIT_STAGE_VIDEO));
        }
        private function initialDownLoadTimer():void{
            if (this.downLoadTimer == null){
                this.downLoadTimer = new Timer(1000);
                this.downLoadTimer.addEventListener(TimerEvent.TIMER, this.handleDoanLoadTimer);
                this.downLoadTimer.start();
            };
        }
        private function initialAppendTimer():void{
            if (this.appendTimer == null){
                this.appendTimer = new Timer(100);
                this.appendTimer.addEventListener(TimerEvent.TIMER, this.handleAppendTimer);
                this.appendTimer.start();
            };
        }
        private function addPlayEventHandler():void{
            this.addEventListener(PlayEvent.PLAY, this.playEventHandler);
            this.addEventListener(PlayEvent.STOP, this.playEventHandler);
            this.addEventListener(PlayEvent.PAUSE, this.playEventHandler);
            this.addEventListener(PlayEvent.REPLAY, this.playEventHandler);
        }
        public function playEventHandler(_arg1:PlayEvent):void{
            switch (_arg1.type){
                case "Pause":
                    this.pause();
                    break;
                case "Play":
                    this.play();
                    break;
                case "Stop":
                    this.stop();
                    break;
                case "Replay":
                    this.replay();
                    break;
                case "PlayStart":
                    this.playStart();
                    break;
            };
        }
        public function pause():void{
            JTracer.sendMessage("Player -> pause");
            if (this.myTimer){
                this.myTimer.start();
            };
            this._status = 1;
            if (this.streamInPlay){
                this.streamInPlay.pause();
            };
            this.isStop = false;
            this.isPause = true;
            this.isStartPause = false;
            ExternalInterface.call("flv_playerEvent", "onPlayStatusChanged");
        }
        public function play():void{
            if (((!(this.videoUrlArr)) || ((this.videoUrlArr.length == 0)))){
                return;
            };
            JTracer.sendMessage("Player -> play");
            if (this.myTimer){
                this.myTimer.start();
            };
            this._status = 0;
            ExternalInterface.call("flv_playerEvent", "onPlayStatusChanged");
            this.initialDownLoadTimer();
            this.initialAppendTimer();
            if (((((((this.streamInPlay) && ((this.streamInPlay.time > 0)))) && ((this.isStop == false)))) || ((this.isPause == true)))){
                if (this.streamInPlay){
                    this.streamInPlay.resume();
                };
                ExternalInterface.call("flv_playerEvent", "onplaying");
                JTracer.sendMessage("Player -> onplaying");
            } else {
                dispatchEvent(new PlayEvent(PlayEvent.PLAY_NEW_URL));
                if (this.videoUrlArr[0].start > 0){
                    JTracer.sendMessage("Player -> play, netstream, loadMetaData");
                    if (this._streamMetaData){
                        this._streamMetaData.loadMetaData(this.playUrl, this.vduration);
                    };
                } else {
                    JTracer.sendMessage("Player -> play, connectStream");
                    this.connectStream();
                };
            };
            this.isStop = false;
            this.isPause = false;
            this.isStartPause = false;
            this.main_mc.isStopNormal = false;
        }
        private function replay():void{
            if (((!(this.videoUrlArr)) || ((this.videoUrlArr.length == 0)))){
                return;
            };
            JTracer.sendMessage("Player -> replay");
            if (this.myTimer){
                this.myTimer.start();
            };
            this._status = 3;
            ExternalInterface.call("flv_playerEvent", "onPlayStatusChanged");
            this.initialDownLoadTimer();
            this.initialAppendTimer();
            if (((this.main_mc._ctrBar._timerBP) && ((this.main_mc._ctrBar._timerBP.running == false)))){
                this.main_mc._ctrBar._timerBP.start();
            };
            this.videoUrlArr[0].start = 0;
            this._isResetStart = true;
            this._streamStartByte = 0;
            this.connectStream();
            this.isStop = false;
            this.isPause = false;
            this.isStartPause = false;
            this.main_mc.isStopNormal = false;
        }
        public function stop():void{
            JTracer.sendMessage("Player -> stop");
            this._status = 2;
            if (this.myTimer){
                this.myTimer.stop();
            };
            if (this.streamInPlay){
                this.streamInPlay.seek(0);
                this.streamInPlay.close();
            };
            if (this.classicVideo){
                this.classicVideo.clear();
                if (contains(this.classicVideo)){
                    removeChild(this.classicVideo);
                };
                this.classicVideo = null;
            };
            this.closeNetConnection();
            this.clearSocket();
            this.visible = false;
            if (((this.main_mc._ctrBar._timerBP) && (this.main_mc._ctrBar._timerBP.running))){
                this.main_mc._ctrBar._timerBP.stop();
            };
            this.isStop = true;
            this.isStartPause = false;
            this.bufferStart = 0;
            this.bufferStartTime = 0;
            this.fixedByte = 0;
            this._streamStartByte = 0;
            this._streamEndByte = 0;
            this._progressCacheTime = 0;
            if (this._streamMetaData){
                this._streamMetaData.clear();
            };
            if (this._sliceStream){
                this._sliceStream.clear();
            };
            if (((this.videoUrlArr) && ((this.videoUrlArr.length > 0)))){
                this.videoUrlArr[0].start = 0;
                this._isResetStart = true;
            };
            ExternalInterface.call("flv_playerEvent", "onPlayStatusChanged");
        }
        public function stopError():void{
            JTracer.sendMessage("Player -> stopError");
            this._status = 2;
            if (this.myTimer){
                this.myTimer.stop();
            };
            if (this.streamInPlay){
                this.streamInPlay.seek(0);
                this.streamInPlay.close();
            };
            if (this.classicVideo){
                this.classicVideo.clear();
                if (contains(this.classicVideo)){
                    removeChild(this.classicVideo);
                };
                this.classicVideo = null;
            };
            this.closeNetConnection();
            this.clearSocket();
            this.visible = false;
            if (((this.main_mc._ctrBar._timerBP) && (this.main_mc._ctrBar._timerBP.running))){
                this.main_mc._ctrBar._timerBP.stop();
            };
            this.isStop = true;
            this.isStartPause = false;
            this.bufferStart = 0;
            this.bufferStartTime = 0;
            this.fixedByte = 0;
            this._streamStartByte = 0;
            this._streamEndByte = 0;
            this._progressCacheTime = 0;
            if (this._streamMetaData){
                this._streamMetaData.clear();
            };
            if (this._sliceStream){
                this._sliceStream.clear();
            };
            ExternalInterface.call("flv_playerEvent", "onPlayStatusChanged");
        }
        public function get volum():Number{
            return (this._currVolum);
        }
        public function set volum(_arg1:Number):void{
            this._currVolum = _arg1;
            if (this.streamInPlay){
                this.streamInPlay.soundTransform = new SoundTransform(this._currVolum);
            };
        }
        public function get totalByte():Number{
            var _local1:Number = 0;
            var _local2:Array = [];
            if (((((this.dragPosition) && ((this.dragPosition.length > 0)))) && ((this.dragPosition[(this.dragPosition.length - 1)] > 0)))){
                _local2.push(this.dragPosition[(this.dragPosition.length - 1)]);
            };
            if (((((this.videoUrlArr) && ((this.videoUrlArr.length > 0)))) && ((this.videoUrlArr[0].totalByte > 0)))){
                _local2.push(this.videoUrlArr[0].totalByte);
            };
            if (_local2.length > 0){
                _local2 = _local2.sort(Array.NUMERIC);
                _local1 = _local2[(_local2.length - 1)];
            };
            return (_local1);
        }
        public function get vduration():Number{
            return ((((this.totalTime <= 0)) ? this.videoUrlArr[0].totalTime : this.totalTime));
        }
        public function get totalTime():Number{
            return (this._totalTime);
        }
        public function get time():Number{
            if (!this.streamInPlay){
                return (-1);
            };
            if (GlobalVars.instance.isUseHttpSocket){
                return ((this.streamInPlay.time + this.bufferStart));
            };
            if (this._progressCacheTime != 0){
                return (this._progressCacheTime);
            };
            return (this.streamInPlay.time);
        }
        public function get playStatus():Number{
            return (this._status);
        }
        public function get playProgress():Number{
            return (Math.floor(((this.time * 100) / this.totalTime)));
        }
        public function get downloadProgress():Number{
            if (((((this._sliceStream) && (this._sliceStream.nextStream))) && (this._sliceStream.isReloadNext))){
                this.bufferEndTime = (this._sliceStream.sliceEndTime + ((this._sliceStream.bytesLoaded * (this._sliceStream.sliceEnd2Time - this._sliceStream.sliceEndTime)) / this._sliceStream.bytesTotal));
            } else {
                if (this._sliceStream){
                    if (((this._sliceStream.isReplaceNext) && (GlobalVars.instance.isUseHttpSocket))){
                        this.bufferEndTime = (this.bufferStartTime + ((this._sliceStream.bytesLoaded * (this._sliceStream.sliceEndTime - this.bufferStartTime)) / this._sliceStream.bytesTotal));
                    } else {
                        this.bufferEndTime = (this.bufferStartTime + ((this.bytesLoaded * (this._sliceStream.sliceEndTime - this.bufferStartTime)) / this.bytesTotal));
                    };
                };
            };
            return ((this.bufferEndTime / this.totalTime));
        }
        public function get downloadSpeed():Number{
            return (Math.round(this.mySpeed));
        }
        public function get timePlayed():Number{
            return (this._timePlayed);
        }
        private function __old__statPlayTime():void{
            var _local7:URLRequest;
            var _local1:String = Tools.getUserInfo("userid");
            var _local2:String = Tools.getUserInfo("ygcid");
            var _local3:String = this.totalTime.toString();
            var _local4:String = (this._timePlayed / 1000).toString();
            var _local5:int = this.__old__currentSeq;
            var _local6:String = Tools.getUserInfo("from");
            if (this.__old__currentSeq > 1){
                _local7 = new URLRequest(((((((((((((("http://act.vod.xunlei.com/act/report_play_info?id=" + this._currentPlayID) + "&userid=") + _local1) + "&gcid=") + _local2) + "&du=") + _local3) + "&long=") + _local4) + "&seq=") + _local5) + "&from=") + _local6));
            } else {
                _local7 = new URLRequest(((((((((((("http://act.vod.xunlei.com/act/report_play_info?userid=" + _local1) + "&gcid=") + _local2) + "&du=") + _local3) + "&long=") + _local4) + "&seq=") + _local5) + "&from=") + _local6));
            };
            if (!this.__old__statLoader){
                this.__old__statLoader = new URLLoader();
                this.__old__statLoader.addEventListener(Event.COMPLETE, this.__old__onStatLoaded);
                this.__old__statLoader.addEventListener(IOErrorEvent.IO_ERROR, this.__old__onStatIOError);
                this.__old__statLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.__old__onStatSecurityError);
            };
            this.__old__statLoader.load(_local7);
            this.__old__currentSeq = (this.__old__currentSeq + 1);
        }
        private function __old__onStatLoaded(_arg1:Event):void{
            var _local2:String = String(_arg1.target.data);
            JTracer.sendMessage(("Player -> __old__onStatLoaded, 上报后的返回值:" + _local2));
            var _local3:Object = ((JSON.deserialize(_local2)) || ({}));
            if (((((_local3) && (_local3.resp))) && ((String(_local3.resp.ret) == "0")))){
                this._currentPlayID = _local3.resp.id;
            };
        }
        private function __old__onStatIOError(_arg1:IOErrorEvent):void{
            JTracer.sendMessage("Player -> __old__onStatIOError");
        }
        private function __old__onStatSecurityError(_arg1:SecurityErrorEvent):void{
            JTracer.sendMessage("Player -> __old__onStatSecurityError");
        }
        public function get bytesLoaded():Number{
            var _local1:uint;
            var _local2:uint;
            var _local3:SingleSocket;
            if (GlobalVars.instance.isUseHttpSocket){
                _local2 = 0;
                while (_local2 < this.socket_array.length) {
                    _local3 = this.socket_array[_local2];
                    _local1 = (_local1 + _local3.bytesLoaded);
                    _local2++;
                };
                return (_local1);
            };
            return (this.streamInPlay.bytesLoaded);
        }
        public function get bytesTotal():Number{
            var _local1:uint;
            var _local2:uint;
            var _local3:SingleSocket;
            if (GlobalVars.instance.isUseHttpSocket){
                _local2 = 0;
                while (_local2 < this.socket_array.length) {
                    _local3 = this.socket_array[_local2];
                    _local1 = (_local1 + _local3.bytesTotal);
                    _local2++;
                };
                return ((_local1 / this.socket_count));
            };
            return (this.streamInPlay.bytesTotal);
        }
        private function handleDoanLoadTimer(_arg1:TimerEvent):void{
            var _local6:Number;
            var _local7:*;
            var _local8:uint;
            var _local9:Number;
            var _local10:Number;
            var _local11:*;
            var _local12:Number;
            this._timeDownload++;
            if (this._timeDownload > ((5 * 60) * 60)){
                this._timeDownload = 0;
                this.main_mc.isValid = false;
            };
            this.main_mc.setSystemTime();
            var _local2:Number = 0;
            var _local3:Number = 0;
            if (this.streamInPlay){
                if (((((this._sliceStream.nextStream) && ((this._sliceStream.bytesLoaded > 0)))) || (((this._sliceStream.isReplaceNext) && (GlobalVars.instance.isUseHttpSocket))))){
                    _local2 = this._sliceStream.bytesLoaded;
                    _local3 = this._sliceStream.bytesTotal;
                    if (this._isLoadedNextStream){
                        this.preBufferLoaded = 0;
                        this._isLoadedNextStream = false;
                    };
                    this.mySpeed = ((this._sliceStream.bytesLoaded - this.preBufferLoaded) / 0x0400);
                    if (this.mySpeed <= 0){
                        this.mySpeed = 0;
                    };
                    this.preBufferLoaded = this._sliceStream.bytesLoaded;
                } else {
                    _local2 = this.bytesLoaded;
                    _local3 = this.bytesTotal;
                    this._isLoadedNextStream = true;
                    this.mySpeed = ((this.bytesLoaded - this.preBufferLoaded) / 0x0400);
                    if (this.mySpeed <= 0){
                        this.mySpeed = 0;
                    };
                    this.preBufferLoaded = this.bytesLoaded;
                };
            } else {
                this.mySpeed = 0;
            };
            this._totalSpeedArray.push(this.mySpeed);
            var _local4 = 20;
            if (this._avarageSpeedArray.length < _local4){
                this._avarageSpeedArray.push(this.mySpeed);
            } else {
                if (!this._isSubmitSpeed){
                    this._isSubmitSpeed = true;
                    _local6 = 0;
                    for (_local7 in this._avarageSpeedArray) {
                        _local6 = (_local6 + this._avarageSpeedArray[_local7]);
                    };
                    _local8 = (_local4 - this.getZeroSpeedNum(this._avarageSpeedArray));
                    if (_local8 > 0){
                        _local9 = (_local6 / _local8);
                        JTracer.sendMessage(("平均速度:" + _local9));
                        Tools.stat(((((((("f=playspeed&gcid=" + Tools.getUserInfo("ygcid")) + "&s=") + _local9) + "&vod=") + encodeURIComponent(this.vodUrl)) + "&format=") + GlobalVars.instance.movieFormat));
                    };
                };
            };
            var _local5:GlobalVars = GlobalVars.instance;
            if (!_local5.isHasShowLowSpeedTips){
                _local5.curLowSpeedTipsTime++;
                if (_local5.showLowSpeedTimeArray.length >= _local5.showBufferMax){
                    if ((_local5.showLowSpeedTimeArray[2] - _local5.showLowSpeedTimeArray[0]) <= (_local5.showLowSpeedTipsInterval * 1000)){
                        _local5.isHasShowLowSpeedTips = true;
                        _local5.showLowSpeedTimeArray.splice(0, 3);
                        this.main_mc.showLowSpeedTips();
                        JTracer.sendMessage("Player -> showLowSpeedTips");
                    } else {
                        _local5.showLowSpeedTimeArray.splice(0, 1);
                    };
                };
            };
            if (((!(_local5.isHasShowHighSpeedTips)) && (this.main_mc.isHasHigherFormat))){
                if (this._highSpeedSpeedArray.length >= _local5.showHighSpeedTipsAverageSpeedInterval){
                    this._highSpeedSpeedArray.shift();
                };
                this._highSpeedSpeedArray.push(this.mySpeed);
                if (this._highSpeedSpeedArray.length >= _local5.showHighSpeedTipsAverageSpeedInterval){
                    _local10 = 0;
                    for (_local11 in this._highSpeedSpeedArray) {
                        _local10 = (_local10 + this._highSpeedSpeedArray[_local11]);
                    };
                    _local12 = (_local10 / _local5.showHighSpeedTipsAverageSpeedInterval);
                    if (this._isStartHighSpeedTimer){
                        _local5.curHighSpeedTipsTime++;
                        if (_local5.curHighSpeedTipsTime >= _local5.showHighSpeedTipsInterval){
                            if ((((_local5.movieFormat == "p")) && ((_local12 >= _local5.showGaoQingTipsSpeed)))){
                                _local5.curHighSpeedTipsTime = 0;
                                this.main_mc.showHighSpeedTips("g", _local12);
                            } else {
                                if ((((_local5.movieFormat == "g")) && ((_local12 >= _local5.showChaoQingTipsSpeed)))){
                                    _local5.curHighSpeedTipsTime = 0;
                                    this.main_mc.showHighSpeedTips("c", _local12);
                                };
                            };
                        };
                    };
                    if (!this._isStartHighSpeedTimer){
                        if ((((_local5.movieFormat == "p")) && ((_local12 >= _local5.showGaoQingTipsSpeed)))){
                            _local5.isHasShowHighSpeedTips = true;
                            this._isStartHighSpeedTimer = true;
                            this.main_mc.showHighSpeedTips("g", _local12);
                            JTracer.sendMessage("Player -> showHighSpeedTips, higher format:g");
                        } else {
                            if ((((_local5.movieFormat == "g")) && ((_local12 >= _local5.showChaoQingTipsSpeed)))){
                                _local5.isHasShowHighSpeedTips = true;
                                this._isStartHighSpeedTimer = true;
                                this.main_mc.showHighSpeedTips("c", _local12);
                                JTracer.sendMessage("Player -> showHighSpeedTips, higher format:c");
                            };
                        };
                    };
                };
            };
        }
        private function getZeroSpeedNum(_arg1:Array):uint{
            var _local3:*;
            var _local2:uint;
            for (_local3 in _arg1) {
                if (_arg1[_local3] <= 0){
                    _local2++;
                };
            };
            return (_local2);
        }
        public function get currentQuality():int{
            return (this._currentQuality);
        }
        public function get currentQulityStr():String{
            return (this._currentQulityStr);
        }
        public function get currentQualityType():Number{
            return (this._currentQuityType);
        }
        public function getNearIndex(_arg1:Array, _arg2:Number, _arg3:Number, _arg4:Number):int{
            var _local8:int;
            var _local5:int;
            var _local6:int;
            var _local7:Boolean;
            while (_local5 < (_arg1.length - 1)) {
                _local8 = (_local5 + 1);
                if ((((_arg1[_local5] <= _arg2)) && ((_arg1[_local8] > _arg2)))){
                    _local6 = _local5;
                    _local7 = true;
                    break;
                };
                _local5++;
            };
            if (_local6 == 0){
                _local6 = ((_local7) ? _arg3 : _arg4);
            };
            _local6 = Math.max(_arg3, Math.min(_local6, _arg4));
            return (_local6);
        }
        public function set hasNextStream(_arg1:Boolean):void{
            if (this._sliceStream){
                this._sliceStream.hasNextStream = true;
            };
        }
        public function seek(_arg1:Number, _arg2:Boolean=false):void{
            var _local3:ByteArray;
            var _local4:Object;
            var _local5:ByteArray;
            var _local6:Boolean;
            var _local7:Video;
            this._seekTime = (((((_arg1 >= this.totalTime)) && ((this.totalTime > 0)))) ? (this.totalTime - 0.001) : _arg1);
            this._isInBuffer = this.isInBuffer(this._seekTime);
            JTracer.sendMessage(((((("Player -> seek, time:" + this._seekTime) + ", _isInBuffer:") + this._isInBuffer) + ", isKey:") + _arg2));
            if (!this._isInBuffer){
                this.hasNextStream = true;
            };
            dispatchEvent(new PlayEvent(PlayEvent.SEEK));
            if (this.dragTime.length > 1){
                this.playTimeHeadIndex = this.getNearIndex(this.dragTime, this._seekTime, 0, (this.dragTime.length - 2));
                if (((!(_arg2)) && (this._isInBuffer))){
                    _local6 = this.isSeekOnNextStream(this._seekTime);
                    JTracer.sendMessage(("Player -> seek, is seek to next stream:" + _local6));
                    if (_local6){
                        if (this._sliceStream.huanNextStream != null){
                            if (GlobalVars.instance.isUseHttpSocket){
                                StreamList.clearCurList();
                                this._sliceStream.changeByteType();
                                StreamList.replaceList();
                                this.fixedTime = this.dragTime[this.playTimeHeadIndex];
                                this.fixedByte = (((this.playTimeHeadIndex == 0)) ? StreamList.getHeader().length : this.dragPosition[this.playTimeHeadIndex]);
                                this.bufferStart = this._seekTime;
                                this.bufferStartTime = this._sliceStream.loadingTime;
                                this.isSpliceUpdate = false;
                                JTracer.sendMessage(((((((("Player -> seek, use socket, nextStream is not null, replace next stream, bufferStart:" + this.bufferStart) + ", playTimeHeadIndex:") + this.playTimeHeadIndex) + ", fixedTime:") + this.fixedTime) + ", fixedByte:") + this.fixedByte));
                                this.is_seek_finish = false;
                                this.seekInBuffer();
                                this._sliceStream.replaceCompeleteHandler();
                            } else {
                                JTracer.sendMessage("Player -> seek, nextStream is not null, replace next stream.");
                                this.bufferStartTime = this._sliceStream.loadingTime;
                                this.isSpliceUpdate = false;
                                this.streamInPlay.close();
                                this.streamInPlay = null;
                                this.streamInPlay = this._sliceStream.huanNextStream;
                                this.streamInPlay.bufferTime = this._bufferTime;
                                this.streamInPlay.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
                                this.streamInPlay.seek(this._seekTime);
                                _local7 = this._sliceStream.nextVideo;
                                _local7.width = this.classicVideo.width;
                                _local7.height = this.classicVideo.height;
                                _local7.visible = true;
                                addChild(_local7);
                                this.classicVideo.visible = false;
                                this.classicVideo.clear();
                                this.classicVideo = null;
                                this.classicVideo = _local7;
                                this.classicVideo.visible = true;
                                this._sliceStream.replaceCompeleteHandler();
                            };
                        } else {
                            this.seekOutBuffer();
                        };
                    } else {
                        if (GlobalVars.instance.isUseHttpSocket){
                            this.fixedTime = this.dragTime[this.playTimeHeadIndex];
                            this.fixedByte = (((this.playTimeHeadIndex == 0)) ? StreamList.getHeader().length : this.dragPosition[this.playTimeHeadIndex]);
                            this.bufferStart = this._seekTime;
                            this.isSpliceUpdate = true;
                            JTracer.sendMessage(((((((("Player -> seek, use socket, bufferStart:" + this.bufferStart) + ", playTimeHeadIndex:") + this.playTimeHeadIndex) + ", fixedTime:") + this.fixedTime) + ", fixedByte:") + this.fixedByte));
                            this.is_seek_finish = false;
                            this.seekInBuffer();
                        } else {
                            this.isSpliceUpdate = false;
                            this.streamInPlay.seek(this._seekTime);
                        };
                    };
                    this.streamInPlay.resume();
                    this.isPause = false;
                    this.main_mc._ctrBar._btnPauseBig.visible = false;
                    dispatchEvent(new PlayEvent(PlayEvent.BUFFER_START));
                } else {
                    this.seekOutBuffer();
                };
            } else {
                this.isSpliceUpdate = false;
                this.streamInPlay.seek(this._seekTime);
            };
        }
        private function playStream():void{
            var start_pos:* = NaN;
            var end_pos:* = NaN;
            if (GlobalVars.instance.isUseHttpSocket){
                JTracer.sendMessage("Player -> playStream, use socket, connect socket");
                start_pos = this.fixedByte;
                if (start_pos == 0){
                    start_pos = StreamList.getHeader().length;
                };
                end_pos = ((isNaN(this._sliceStream.spliceGetEndByte(start_pos))) ? this.totalByte : this._sliceStream.spliceGetEndByte(start_pos));
                this.current_pos = start_pos;
                this.query_pos = (start_pos + (this.socket_count * this.block_size));
                GetVodSocket.instance.connect(this.playUrl, function (_arg1:String, _arg2:String, _arg3:String, _arg4:int){
                    if (!_arg1){
                        _vodUrl = null;
                        JTracer.sendMessage("Player -> playStream, use socket, get vod url fail.");
                    } else {
                        _vodUrl = (replaceVideoUrl(_arg1) + _suffixUrl);
                        JTracer.sendMessage(((((((("Player -> playStream, use socket, get vod url success, vod url:" + _arg1) + ", start_pos:") + start_pos) + ", end_pos:") + end_pos) + ", next_pos:") + query_pos));
                        if (streamInPlay){
                            streamInPlay.close();
                            streamInPlay.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
                            streamInPlay = null;
                        };
                        streamInPlay = new NetStream(myConnection);
                        streamInPlay.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
                        streamInPlay.client = customClient;
                        streamInPlay.bufferTime = _bufferTime;
                        downloadStream(_arg1, start_pos, end_pos);
                    };
                    dispatchEvent(new PlayEvent(PlayEvent.BUFFER_START));
                });
            } else {
                if (GlobalVars.instance.isUseSocket){
                    JTracer.sendMessage("Player -> playStream, connect socket");
                    GetVodSocket.instance.connect(this.playUrl, function (_arg1:String, _arg2:String, _arg3:String, _arg4:int){
                        GlobalVars.instance.isChangeURL = false;
                        if (!_arg1){
                            _vodUrl = null;
                            JTracer.sendMessage(("Player -> playStream, get vod url fail, gdl url:" + _gdlUrl));
                            streamInPlay.play(_gdlUrl);
                        } else {
                            _vodUrl = (replaceVideoUrl(_arg1) + _suffixUrl);
                            JTracer.sendMessage(("Player -> playStream, get vod url success, vod url:" + _vodUrl));
                            streamInPlay.play(_vodUrl);
                        };
                        dispatchEvent(new PlayEvent(PlayEvent.BUFFER_START));
                    });
                } else {
                    GlobalVars.instance.isChangeURL = false;
                    this.streamInPlay.play(this._gdlUrl);
                    JTracer.sendMessage(("Player -> playStream, gdl url=" + this._gdlUrl));
                    dispatchEvent(new PlayEvent(PlayEvent.BUFFER_START));
                };
            };
        }
        private function netStatusHandler(_arg1:NetStatusEvent):void{
            var codeUrl:* = null;
            var nextUrl:* = null;
            var seek_time:* = NaN;
            var playTimeHeadIndex:* = 0;
            var event:* = _arg1;
            this._isInvalidTime = false;
            JTracer.sendMessage(("Player -> netStatusHandler, " + event.info.code));
            switch (event.info.code){
                case "NetStream.Buffer.Empty":
                    JTracer.sendMessage(((((("Player -> netStatusHandler, NetStream.Buffer.Empty, streamInPlay.time:" + this.streamInPlay.time) + ", streamInPlay.bufferLenght:") + this.streamInPlay.bufferLength) + ", streamInPlay.bufferTime:") + this.streamInPlay.bufferTime));
                    if (GlobalVars.instance.isUseHttpSocket){
                        seek_time = (((((this.time >= this.totalTime)) && ((this.totalTime > 0)))) ? (this.totalTime - 0.001) : this.time);
                        playTimeHeadIndex = this.getNearIndex(this.dragTime, seek_time, 0, (this.dragTime.length - 2));
                        this.fixedTime = this.dragTime[playTimeHeadIndex];
                        this.fixedByte = (((playTimeHeadIndex == 0)) ? StreamList.getHeader().length : this.dragPosition[playTimeHeadIndex]);
                        this.bufferStart = seek_time;
                        JTracer.sendMessage(((((((("Player -> netStatusHandler, NetStream.Buffer.Empty, bufferStart:" + this.bufferStart) + ", playTimeHeadIndex:") + playTimeHeadIndex) + ", fixedTime:") + this.fixedTime) + ", fixedByte:") + this.fixedByte));
                        this.is_seek_finish = false;
                        this.seekInBuffer();
                    };
                    dispatchEvent(new PlayEvent(PlayEvent.BUFFER_START));
                    break;
                case "NetStream.Play.Start":
                    this.streamInPlay.pause();
                    if (((this.main_mc._ctrBar._timerBP) && ((this.main_mc._ctrBar._timerBP.running == false)))){
                        this.main_mc._ctrBar._timerBP.reset();
                        this.main_mc._ctrBar._timerBP.start();
                    };
                    break;
                case "NetStream.Play.Stop":
                    this.checkIsNormalStop();
                    break;
                case "NetStream.Buffer.Full":
                    JTracer.sendMessage(((((((((("Player -> netStatusHandler, NetStream.Buffer.Full, streamInPlay.time:" + this.streamInPlay.time) + ", bufferStartTime:") + this.bufferStartTime) + ", _progressCacheTime:") + this._progressCacheTime) + ", streamInPlay.bufferLenght:") + this.streamInPlay.bufferLength) + ", streamInPlay.bufferTime:") + this.streamInPlay.bufferTime));
                    this.visible = true;
                    this.fnOnEnterFrame();
                    dispatchEvent(new PlayEvent(PlayEvent.PLAY_START));
                    this._progressCacheTime = 0;
                    this.fixedTime = -1;
                    this.main_mc._ctrBar._btnPause.visible = true;
                    this.main_mc._ctrBar._btnPlay.visible = false;
                    break;
                case "NetStream.Play.StreamNotFound":
                    codeUrl = ((this._vodUrl) ? this._vodUrl : this._gdlUrl);
                    GetGdlCodeSocket.instance.connect(codeUrl, "302", this.onVodGetted);
                    nextUrl = this.getNextUrl();
                    if (nextUrl){
                        this.playUrl = nextUrl;
                        GlobalVars.instance.isVodGetted = false;
                        GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeFirstBuffer;
                        GlobalVars.instance.isChangeURL = false;
                        JTracer.sendMessage(((("netStatusHandler -> has next, get next play url:" + this.playUrl) + "\n,bufferType:") + GlobalVars.instance.bufferType));
                        this.main_mc._bufferTip.clearBreakCount();
                        if (GlobalVars.instance.isFirstBuffer302){
                            JTracer.sendMessage("netStatusHandler -> is first buffer 302");
                            this.play();
                        } else {
                            JTracer.sendMessage("netStatusHandler -> is not first buffer 302");
                            this.main_mc.flv_seek(this.time);
                        };
                        return;
                    };
                    JTracer.sendMessage(("netStatusHandler -> no next, get next play url:" + this.playUrl));
                    ExternalInterface.call("flv_playerEvent", "onErrorInfo", this._errorInfo);
                    this.main_mc.showPlayError(this._errorInfo);
                    break;
                case "NetStream.Seek.InvalidTime":
                    if (this.is_invalid_time){
                        this.is_invalid_time = false;
                        try {
                            JTracer.sendMessage(((((((((((("NetStream.Seek.InvalidTime:totalTime=" + this.totalTime) + ", startPosition=") + this.dragTime[0]) + ", lastPostion=") + this.dragTime[(this.dragTime.length - 1)]) + ", details=") + event.info.details) + ", bufferEndTime=") + this.bufferEndTime) + ", bufferLength=") + this.streamInPlay.bufferLength));
                            this._isInvalidTime = true;
                            this.main_mc._bufferTip.clearBreakCount();
                            GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeError;
                            JTracer.sendMessage(("Player -> netStatusHandler, NetStream.Seek.InvalidTime, set bufferType:" + GlobalVars.instance.bufferType));
                            this.seek(this._seekTime, true);
                        } catch(e:Error) {
                            _errorInfo = "202";
                            JTracer.sendMessage(("Player -> onErrorInfo, code:" + _errorInfo));
                            Tools.stat((((("f=playerror&e=" + _errorInfo) + "&gcid=") + Tools.getUserInfo("ygcid")) + this.retryLastTimeStat));
                            ExternalInterface.call("flv_playerEvent", "onErrorInfo", _errorInfo);
                        };
                    };
                    break;
                case "NetStream.Play.Failed":
                    this._errorInfo = "203";
                    JTracer.sendMessage(("Player -> onErrorInfo, code:" + this._errorInfo));
                    this.main_mc.showPlayError(this._errorInfo);
                    Tools.stat((((("f=playerror&e=" + this._errorInfo) + "&gcid=") + Tools.getUserInfo("ygcid")) + this.retryLastTimeStat));
                    ExternalInterface.call("flv_playerEvent", "onErrorInfo", this._errorInfo);
                    break;
            };
        }
        private function seekInBuffer():void{
            var _local3:ByteArray;
            var _local1:Object = StreamList.findBytes(GlobalVars.instance.type_curstream, this.fixedByte);
            var _local2:ByteArray = (StreamList.getBytes(GlobalVars.instance.type_curstream, _local1.start, ((_local1.start + this.block_size) - 1)) as ByteArray);
            if (_local2){
                _local2.position = 0;
                _local3 = new ByteArray();
                _local3.writeBytes(_local2, (this.fixedByte - _local1.start), (_local2.length - (this.fixedByte - _local1.start)));
                JTracer.sendMessage(((((((("Player -> seekInBuffer, found block, pos_obj.start:" + _local1.start) + ", pos_obj.end:") + _local1.end) + ", fixedByte:") + this.fixedByte) + ", cur_bytes.length:") + _local3.length));
                if (this.streamInPlay){
                    this.streamInPlay.close();
                    this.streamInPlay.removeEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
                    this.streamInPlay = null;
                };
                this.streamInPlay = new NetStream(this.myConnection);
                this.streamInPlay.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
                this.streamInPlay.client = this.customClient;
                this.streamInPlay.bufferTime = this._bufferTime;
                this.streamInPlay.play(null);
                this.streamInPlay.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
                this.streamInPlay.appendBytes(StreamList.getHeader());
                this.streamInPlay.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
                this.streamInPlay.appendBytes(_local3);
                this.classicVideo.attachNetStream(this.streamInPlay);
                this.current_pos = (_local1.start + this.block_size);
                this.is_seek_finish = true;
            } else {
                JTracer.sendMessage(((((("Player -> seekInBuffer, not found block, pos_obj.start:" + _local1.start) + ", pos_obj.end:") + _local1.end) + ", fixedByte:") + this.fixedByte));
                this._seekTime = this.time;
                this.playTimeHeadIndex = this.getNearIndex(this.dragTime, this._seekTime, 0, (this.dragTime.length - 2));
                this.seekOutBuffer();
            };
        }
        private function seekOutBuffer():void{
            var _local1:String;
            this.fixedTime = this.dragTime[this.playTimeHeadIndex];
            this.fixedByte = (((this.playTimeHeadIndex == 0)) ? 0 : this.dragPosition[this.playTimeHeadIndex]);
            _local1 = ((isNaN(this._sliceStream.spliceGetEndByte(this.fixedByte))) ? "" : String(("&end=" + this._sliceStream.spliceGetEndByte(this.fixedByte))));
            this.sliceStart = this.fixedByte;
            this.sliceSize = (this.getFixedByteEnd(_local1) - this.fixedByte);
            this.bufferStart = this._seekTime;
            this.bufferStartTime = this._seekTime;
            this._progressCacheTime = this._seekTime;
            this.isSpliceUpdate = false;
            JTracer.sendMessage(((((((("Player -> seekOutBuffer, bufferStartTime:" + this.bufferStartTime) + ", playTimeHeadIndex:") + this.playTimeHeadIndex) + ", fixedTime:") + this.fixedTime) + ", fixedByte:") + this.fixedByte));
            this._suffixUrl = ((((("start=" + this.fixedByte) + _local1) + "&id=sotester&client=FLASH%20WIN%2010,0,45,2&version=4.1.60") + "&type=normal&du=") + this.vduration);
            this._gdlUrl = (this.replaceVideoUrl(this.playUrl) + this._suffixUrl);
            JTracer.sendMessage((("Player -> seekOutBuffer, start=" + this.fixedByte) + _local1));
            this.isPause = false;
            this.main_mc._ctrBar._btnPause.visible = true;
            this.main_mc._ctrBar._btnPlay.visible = false;
            this.main_mc._ctrBar._btnPauseBig.visible = false;
            JTracer.sendMessage("Player -> seekOutBuffer, start spliceUpdate");
            this._sliceStream.spliceUpdate(this.fixedTime);
            this.playStream();
        }
        public function getCurLink():int{
            var _local1:*;
            for (_local1 in GlobalVars.instance.allURLList) {
                if (GlobalVars.instance.allURLList[_local1].url == this.lastUrl){
                    return (GlobalVars.instance.allURLList[_local1].link);
                };
            };
            return (1);
        }
        public function nextIsDL():Boolean{
            var _local1:*;
            var _local2:String;
            var _local3:Boolean;
            for (_local1 in GlobalVars.instance.allURLList) {
                if ((((GlobalVars.instance.allURLList[_local1].url == this.lastUrl)) && ((_local1 < (GlobalVars.instance.allURLList.length - 1))))){
                    _local2 = GlobalVars.instance.allURLList[(_local1 + 1)].url;
                    _local3 = this.isDL(_local2);
                    return (_local3);
                };
            };
            return (false);
        }
        public function isDL(_arg1:String):Boolean{
            var _local2:String = this.getFormatURL(_arg1);
            if (_local2.indexOf("dl") == 0){
                return (true);
            };
            return (false);
        }
        private function getFormatURL(_arg1:String):String{
            var _local2:String;
            var _local3:Array;
            if (_arg1.indexOf("://") >= 0){
                _local3 = _arg1.split("://");
                _local2 = _local3[1];
            } else {
                _local2 = _arg1;
            };
            return (_local2);
        }
        private function onVodGetted(_arg1:Object):void{
            if (!_arg1.url){
                if ((((_arg1.url_type == "gdl")) || ((_arg1.url_type == "dl")))){
                    this.onCodeGetted(_arg1);
                    return;
                };
            };
            GetVodCodeSocket.instance.connect(_arg1, this.onCodeGetted);
        }
        private function onCodeGetted(_arg1:Object):void{
            var _local2:String = this.getRealURL(_arg1.origin_url);
            var _local3:String = ("http://" + _local2.substr(0, _local2.indexOf("/")));
            var _local4:String = _arg1.status_code;
            var _local5:String = _arg1.url_type;
            var _local6:String = _arg1.error_code;
            JTracer.sendMessage(((("onCodeGetted code:" + _local4) + " retryLastTimeStat:") + this._retryLastTimeStat));
            if ((((_local4 == "403")) && (!((this._retryLastTimeStat == ""))))){
                this.main_mc._videoMask.showErrorNotice(VideoMask.noPrivilege);
                this.playEnd = true;
            };
            JTracer.sendMessage(((((("Player -> onErrorInfo, code:" + _local6) + ", utype:") + _local5) + ", status:") + _local4));
            Tools.stat((((((((((("f=playerror&e=" + _local6) + "&gcid=") + Tools.getUserInfo("ygcid")) + "&utype=") + _local5) + "&status=") + _local4) + "&host=") + _local3) + this.retryLastTimeStat));
        }
        private function getRealURL(_arg1:String):String{
            var _local2:String;
            var _local3:Array;
            if (_arg1.indexOf("://") >= 0){
                _local3 = _arg1.split("://");
                _local2 = _local3[1];
            } else {
                _local2 = _arg1;
            };
            return (_local2);
        }
        public function connectStream():void{
            if (this.streamInPlay){
                this.streamInPlay.close();
                this.streamInPlay = null;
            };
            var start:* = ((this.videoUrlArr[0].start) || (0));
            this._currentQuality = this.videoUrlArr[0].quality;
            this._currentQulityStr = this.videoUrlArr[0].qualitystr;
            this._currentQuityType = ((this.videoUrlArr[0].qualitytype) || (0));
            dispatchEvent(new SetQulityEvent(SetQulityEvent.INIT_QULITY));
            this.initialConnection();
            this.initialStream();
            this.initialVideo();
            this.classicVideo.attachNetStream(this.streamInPlay);
            addChildAt(this.classicVideo, 0);
            JTracer.sendMessage("Player -> setPlayUrl, initClassicVideo");
            this.bufferStart = start;
            this.bufferStartTime = start;
            this._progressCacheTime = start;
            this.isSpliceUpdate = false;
            this.sliceStart = Number(this.getFirstStartByte());
            this.sliceSize = (this.getFixedByteEnd(this.getFirstEndByte()) - Number(this.getFirstStartByte()));
            this._suffixUrl = ((((((("start=" + this.getFirstStartByte()) + this.getFirstEndByte()) + "&id=sotester&client=FLASH%20WIN%2010,0,45,2&version=4.1.60") + "&type=") + this._urlType) + "&du=") + this.vduration);
            this._gdlUrl = (this.replaceVideoUrl(this.playUrl) + this._suffixUrl);
            JTracer.sendMessage(((("Player -> connectStream, url=" + this.playUrl) + "&") + this._suffixUrl));
            if (GlobalVars.instance.isUseSocket){
                JTracer.sendMessage("Player -> connectStream, connect socket");
                GetVodSocket.instance.connect(this.playUrl, function (_arg1:String, _arg2:String, _arg3:String, _arg4:int){
                    var _local5:Number;
                    var _local6:Number;
                    var _local7:uint;
                    if (GlobalVars.instance.getVodTime == 0){
                        GlobalVars.instance.getVodTime = _arg4;
                    };
                    if (!_arg1){
                        GlobalVars.instance.isUseHttpSocket = false;
                        _vodUrl = null;
                        JTracer.sendMessage(("Player -> connectStream, get vod url fail, gdl url:" + _gdlUrl));
                        streamInPlay.play(_gdlUrl);
                    } else {
                        _vodUrl = (replaceVideoUrl(_arg1) + _suffixUrl);
                        GlobalVars.instance.isUseHttpSocket = checkIsUseHttpSocket(_arg1);
                        if (GlobalVars.instance.isUseHttpSocket){
                            if (GlobalVars.instance.isHeaderGetted){
                                if (Number(videoUrlArr[0].start) == 0){
                                    _local5 = StreamList.getHeader().length;
                                } else {
                                    _local7 = getNearIndex(_streamMetaData.timeArr, Number(videoUrlArr[0].start), 0, (_streamMetaData.timeArr.length - 2));
                                    _local5 = _streamMetaData.byteArr[_local7];
                                };
                                _local6 = (((getFirstEndByte().substr(5) == "")) ? totalByte : Number(getFirstEndByte().substr(5)));
                                current_pos = _local5;
                                query_pos = (_local5 + (socket_count * block_size));
                                JTracer.sendMessage(((((((("Player -> connectStream, use socket, get vod url success, vod url:" + _arg1) + ", start_pos:") + _local5) + ", end_pos:") + _local6) + ", next_pos:") + query_pos));
                                downloadStream(_arg1, _local5, _local6);
                            } else {
                                _streamMetaData.loadMetaData(playUrl, vduration);
                            };
                        } else {
                            JTracer.sendMessage(("Player -> connectStream, get vod url success, vod url:" + _vodUrl));
                            streamInPlay.play(_vodUrl);
                        };
                    };
                    if (isChangeQuality == false){
                        JTracer.sendMessage("Player -> dispatch playevent.bufferStart.");
                        dispatchEvent(new PlayEvent(PlayEvent.BUFFER_START));
                    };
                });
            } else {
                this.streamInPlay.play(this._gdlUrl);
                if (this.isChangeQuality == false){
                    JTracer.sendMessage("Player -> dispatch playevent.bufferStart.");
                    dispatchEvent(new PlayEvent(PlayEvent.BUFFER_START));
                };
            };
            this._urlType = "normal";
            ExternalInterface.call("flv_playerEvent", "onopen");
            dispatchEvent(new sizeEvent(sizeEvent.CHANGETITLE, this.videoUrlArr[0].title));
            dispatchEvent(new Event(SET_QUALITY));
        }
        private function checkIsUseHttpSocket(_arg1:String):Boolean{
            var _local5:*;
            var _local2:Object = StringUtil.getHostPort(_arg1);
            var _local3:String = _local2.host;
            var _local4:String = GlobalVars.instance.vodAddr;
            if (GlobalVars.instance.isIPLink){
                for (_local5 in GlobalVars.instance.httpSocketMachines) {
                    JTracer.sendMessage((("machines:" + GlobalVars.instance.httpSocketMachines[_local5]) + "\n"));
                    if (_local4.indexOf(GlobalVars.instance.httpSocketMachines[_local5]) > -1){
                        return (true);
                    };
                };
            };
            for (_local5 in GlobalVars.instance.httpSocketMachines) {
                JTracer.sendMessage((("machines:" + GlobalVars.instance.httpSocketMachines[_local5]) + "\n"));
                if (_local3.indexOf(GlobalVars.instance.httpSocketMachines[_local5]) > -1){
                    return (true);
                };
            };
            return (false);
        }
        private function clearSocket():void{
            var _local1:uint;
            var _local2:SingleSocket;
            _local1 = 0;
            while (_local1 < this.socket_array.length) {
                _local2 = this.socket_array[_local1];
                _local2.removeEventListener(SingleSocket.All_Complete, this.all_block_complete);
                _local2.removeEventListener(SingleSocket.SocketError, this.block_error);
                _local2.clear();
                _local2 = null;
                _local1++;
            };
            this.socket_array = [];
        }
        private function downloadStream(_arg1:String, _arg2:uint, _arg3:uint):void{
            var _local4:uint;
            var _local5:SingleSocket;
            if (((this.main_mc._ctrBar._timerBP) && ((this.main_mc._ctrBar._timerBP.running == false)))){
                this.main_mc._ctrBar._timerBP.reset();
                this.main_mc._ctrBar._timerBP.start();
            };
            StreamList.clearCurList();
            StreamList.clearNextList();
            this._sliceStream.clearSocket();
            this._sliceStream.isReplaceNext = false;
            this.is_append_header = false;
            this.is_seek_finish = true;
            this.clearSocket();
            if (this.socket_array.length == 0){
                _local4 = 0;
                while (_local4 < this.socket_count) {
                    _local5 = new SingleSocket(this, _arg1, this.block_size, this.socket_count, (_arg2 + (_local4 * this.block_size)), _arg3, (_arg3 - _arg2), GlobalVars.instance.type_curstream);
                    _local5.addEventListener(SingleSocket.All_Complete, this.all_block_complete);
                    _local5.addEventListener(SingleSocket.SocketError, this.block_error);
                    _local5.connectSocket();
                    this.socket_array.push(_local5);
                    _local4++;
                };
            } else {
                _local4 = 0;
                while (_local4 < this.socket_count) {
                    _local5 = this.socket_array[_local4];
                    _local5.clear();
                    _local5.setQueryUrl(_arg1);
                    _local5.setQueryRange((_arg2 + (_local4 * this.block_size)), _arg3, (_arg3 - _arg2));
                    _local5.connectSocket();
                    _local4++;
                };
            };
        }
        private function handleAppendTimer(_arg1:TimerEvent):void{
            this.block_complete(null);
        }
        private function all_block_complete(_arg1:Event):void{
            var _local2:SingleSocket = (_arg1.currentTarget as SingleSocket);
            _local2.clearSocket();
            var _local3:Object = _local2.getCompletePos();
            JTracer.sendMessage(((((("Player -> all_block_complete, start_pos:" + _local3.start_pos) + ", end_pos:") + _local3.end_pos) + ", next_pos:") + this.query_pos));
        }
        private function block_complete(_arg1:Event):void{
            if (((((((!(GlobalVars.instance.isUseHttpSocket)) || (!(this.is_seek_finish)))) || (!(GlobalVars.instance.isHeaderGetted)))) || (!(this.streamInPlay)))){
                return;
            };
            if (!this.is_append_header){
                this.is_append_header = true;
                this.streamInPlay.play(null);
                this.streamInPlay.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
                this.streamInPlay.appendBytes(StreamList.getHeader());
                this.streamInPlay.appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
                this.classicVideo.attachNetStream(this.streamInPlay);
            };
            var _local2:ByteArray = (StreamList.getBytes(GlobalVars.instance.type_curstream, this.current_pos, ((this.current_pos + this.block_size) - 1)) as ByteArray);
            if (_local2){
                this.streamInPlay.appendBytes(_local2);
                this.current_pos = (this.current_pos + this.block_size);
            };
        }
        private function block_error(_arg1:Event):void{
            var _local2:SingleSocket = (_arg1.currentTarget as SingleSocket);
            JTracer.sendMessage(("Player -> block_error, error_info:" + _local2.getErrorInfo()));
        }
        private function metaDataHandler(_arg1:Player):Function{
            var playObj:* = _arg1;
            var fun:* = function (_arg1:Object):void{
                var arr:* = null;
                var j:* = 0;
                var len:* = 0;
                var infoObject:* = _arg1;
                v_w = ((isNaN(infoObject.width)) ? swf_width : infoObject.width);
                v_h = ((isNaN(infoObject.height)) ? swf_height : infoObject.height);
                var real_width:* = 0;
                var real_height:* = 0;
                JTracer.sendMessage(((("Player -> metaDataHandler, video.width:" + v_w) + ", video.height:") + v_h));
                GlobalVars.instance.videoRealSize = {
                    width:v_w,
                    height:v_h
                };
                if ((v_w / v_h) > (swf_width / swf_height)){
                    real_width = swf_width;
                    real_height = ((real_width * v_h) / v_w);
                } else {
                    real_height = swf_height;
                    real_width = ((real_height * v_w) / v_h);
                };
                nomarl_width = v_w;
                nomarl_height = v_h;
                main_mc.resizePlayerSize();
                nomarl_x = x;
                nomarl_y = y;
                _totalTime = infoObject.duration;
                JTracer.sendMessage(((((("Player -> metaDataHandler, bufferStartTime:" + bufferStartTime) + ", bytesTotal:") + streamInPlay.bytesTotal) + ", duration:") + infoObject.duration));
                try {
                    if (infoObject.keyframes){
                        dragTime = String(infoObject.keyframes.times).split(",");
                        dragPosition = String(infoObject.keyframes.filepositions).split(",");
                    } else {
                        if (infoObject.seekpoints){
                            arr = infoObject.seekpoints;
                            dragTime = [];
                            dragPosition = [];
                            len = arr.length;
                            j = 0;
                            while (j < len) {
                                dragTime.push(arr[j].time);
                                dragPosition.push(arr[j].time);
                                j = (j + 1);
                            };
                        };
                    };
                } catch(e:Error) {
                    dragTime = new Array();
                    dragPosition = new Array();
                };
                seekBeforePlay();
                playObj._sliceStream.totalByte = playObj.totalByte;
                playObj._sliceStream.totalTime = playObj.totalTime;
                if (((_sliceStream.spliceInit) && (!(isSpliceUpdate)))){
                    isSpliceUpdate = true;
                    playObj._sliceStream.spliceUpdateArray(dragTime, dragPosition);
                    JTracer.sendMessage("Player -> metaDataHandler, start spliceUpdate");
                    playObj._sliceStream.spliceUpdate(playObj.time);
                    playObj._sliceStream.spliceStartCheckTimer();
                };
            };
            return (fun);
        }
        private function isInBuffer(_arg1:Number):Boolean{
            var _local2:Number = 0;
            var _local3:Number = 0;
            if (this._sliceStream.spliceInit == true){
                _local2 = Math.max(this._sliceStream.bufferStartTime, this.bufferStartTime);
                _local3 = this.bufferEndTime;
                JTracer.sendMessage(((((((("Player -> isInBuffer, _sliceStream.bufferStartTime:" + this._sliceStream.bufferStartTime) + ", bufferStartTime:") + this.bufferStartTime) + ", _sliceStream.bufferEndTime:") + this._sliceStream.bufferEndTime) + ", bufferEndTime:") + this.bufferEndTime));
                JTracer.sendMessage(((((((("Player -> isInBuffer, streamInPlay.bytesLoaded:" + this.bytesLoaded) + ", streamInPlay.bytesTotal:") + this.bytesTotal) + ", _sliceStream.sliceEndTime:") + this._sliceStream.sliceEndTime) + ", time:") + this.time));
            } else {
                _local2 = this.bufferStartTime;
                _local3 = this.bufferEndTime;
                JTracer.sendMessage(((("Player -> isInBuffer, bufferStartTime:" + this.bufferStartTime) + ", bufferEndTime:") + this.bufferEndTime));
            };
            var _local4:Boolean = (((_local2 <= _arg1)) && ((_arg1 <= _local3)));
            JTracer.sendMessage(((((((("Player -> isInBuffer, start:" + _local2) + ", end:") + _local3) + ", time:") + _arg1) + " isIn:") + _local4));
            return (_local4);
        }
        private function isSeekOnNextStream(_arg1:Number):Boolean{
            var _local2:Boolean;
            if ((((_arg1 <= this._sliceStream.bufferEndTime)) && ((_arg1 >= this.bufferEndTime)))){
                _local2 = true;
            };
            if ((((_arg1 <= this.bufferEndTime)) && ((_arg1 >= this._sliceStream.bufferEndTime)))){
                _local2 = true;
            };
            JTracer.sendMessage(((((("_sliceStream.bufferEndTime:" + this._sliceStream.bufferEndTime) + ",bufferEndTime:") + this.bufferEndTime) + ",seconds:") + _arg1));
            return (_local2);
        }
        public function get errorInfo():String{
            return (this._errorInfo);
        }
        public function clearUp():void{
            if (this.streamInPlay){
                this.streamInPlay.close();
                this.streamInPlay = null;
            };
        }
        public function set bufferTime(_arg1:Number):void{
            this._bufferTime = _arg1;
        }
        public function get bufferTime():Number{
            return (this._bufferTime);
        }
        public function get isBuffer():Boolean{
            return (this._isInBuffer);
        }
        public function set isBuffer(_arg1:Boolean):void{
            this._isInBuffer = _arg1;
        }
        private function numToStrByDecimal(_arg1:Number):String{
            var _local2:Array = _arg1.toString().split(".");
            if (_local2.length == 1){
                return (((_local2[0] + ".") + "00"));
            };
            if (_local2[1].length >= 2){
                return (_arg1.toString());
            };
            if (_local2[1].length == 1){
                return ((((_local2[0] + ".") + _local2[1]) + "0"));
            };
            return ("error");
        }
        public function get onSeekTime():Number{
            return (this._seekTime);
        }
        public function resizePlayerSize(_arg1:Number, _arg2:Number):void{
            this.swf_width = _arg1;
            this.swf_height = _arg2;
        }
        private function seekBeforePlay():void{
            var _local1:Number;
            if (this._js_seekPos == -1){
                return;
            };
            _local1 = this._js_seekPos;
            this._js_seekPos = -1;
            this.seek(_local1);
        }
        public function setSeekPos(_arg1:Number):void{
            if (this.time > 0){
                this._js_seekPos = -1;
                this.seek(_arg1);
            } else {
                if (_arg1 >= 0){
                    this._js_seekPos = _arg1;
                };
            };
        }
        public function get streamBufferTime():Number{
            var _local2:Number;
            var _local3:int;
            var _local4:uint;
            var _local5:int;
            var _local1:Number = 0;
            if (((this.streamInPlay) && ((this.dragPosition.length > 0)))){
                _local2 = ((this.streamInPlay.bytesLoaded + this.fixedByte) - this.dragPosition[0]);
                _local3 = 0;
                _local4 = 0;
                while (_local3 < this.dragTime.length) {
                    _local5 = (_local3 + 1);
                    if ((((this.dragPosition[_local3] <= _local2)) && ((this.dragPosition[_local5] > _local2)))){
                        _local4 = _local3;
                        break;
                    };
                    _local3++;
                };
                _local1 = (this.dragTime[_local4] - this.time);
                JTracer.sendLoaclMsg(((("loadbyte:" + _local2) + ",loadbyteindex:") + _local4));
            };
            return (_local1);
        }
        private function checkIsNormalStop():void{
            var _local1:String;
            JTracer.sendMessage("Player -> checkIsNormalStop");
            if (((((this.totalTime - this.time) < 25)) && (((this.totalTime - this.time) > 0)))){
                JTracer.sendMessage(((((((("this is stop normal! this.totalTime - this.time:" + (this.totalTime - this.time).toString()) + ", this.time:") + this.time) + ", streamBytesLoaded:") + this.streamInPlay.bytesLoaded) + ", streamBytesTotal:") + this.streamInPlay.bytesTotal));
                _local1 = ((this._vodUrl) ? this._vodUrl : this._gdlUrl);
                GetGdlCodeSocket.instance.connect(_local1, "204", this.onVodGetted);
                ExternalInterface.call("flv_playerEvent", "onErrorInfo", this._errorInfo);
            } else {
                JTracer.sendMessage("abstract stop sliceStram.spliceReplaceRightNow");
                this._sliceStream.spliceReplaceRightNow(this.time);
            };
        }
        public function set isChangeQuality(_arg1:Boolean):void{
            this._isChangeQuality = _arg1;
        }
        public function get isChangeQuality():Boolean{
            return (this._isChangeQuality);
        }
        public function get nsCurrentFps():Number{
            var _local1:Number = 0;
            if (this.streamInPlay != null){
                _local1 = this.streamInPlay.currentFPS;
            };
            return (_local1);
        }
        private function replaceVideoUrl(_arg1:String):String{
            var _local2 = "?";
            var _local3:int = _arg1.indexOf("?");
            if (_local3 != -1){
                _local2 = "&";
            };
            return ((_arg1 + _local2));
        }
        private function playStart():void{
            JTracer.sendMessage(((("Player -> PlayStart, time:" + this.time) + ", _progressCacheTime:") + this._progressCacheTime));
            if (this._sliceStream.spliceInit == false){
                return;
            };
            if (!this.isInBuffer(this.time)){
                this._sliceStream.spliceUpdateArray(this.dragTime, this.dragPosition);
                this._sliceStream.spliceUpdate(this.time);
            };
            this._sliceStream.spliceStartCheckTimer();
        }
        public function replaceNextStream(_arg1:NetStream, _arg2:Video, _arg3:Function, _arg4:String=null):void{
            if ((((_arg1 == null)) || ((_arg2 == null)))){
                if (_arg4){
                    this._errorInfo = _arg4;
                    JTracer.sendMessage(("Player -> onErrorInfo, code:" + this._errorInfo));
                    this.main_mc.showPlayError(this._errorInfo);
                    Tools.stat((((("f=playerror&e=" + this._errorInfo) + "&gcid=") + Tools.getUserInfo("ygcid")) + this.retryLastTimeStat));
                    ExternalInterface.call("flv_playerEvent", "onErrorInfo", this._errorInfo);
                };
                return;
            };
            var _local5:Number = this.time;
            if (GlobalVars.instance.isUseHttpSocket){
                StreamList.clearCurList();
                this._sliceStream.changeByteType();
                StreamList.replaceList();
                this.fixedTime = this._sliceStream.loadingTime;
                this.fixedByte = this._sliceStream.loadingPos;
                this.bufferStartTime = this._sliceStream.loadingTime;
                JTracer.sendMessage(((((("Player -> replaceNextStream, bufferStart:" + this.bufferStart) + ", fixedTime:") + this.fixedTime) + ", fixedByte:") + this.fixedByte));
            } else {
                _arg2.width = this.classicVideo.width;
                _arg2.height = this.classicVideo.height;
                _arg2.visible = true;
                addChild(_arg2);
                JTracer.sendMessage(((("Player -> replaceNextStream front, streamInPlay.time:" + this.streamInPlay.time) + ", nextStream.time:") + _arg1.time));
                this.streamInPlay.close();
                this.streamInPlay = null;
                this.streamInPlay = _arg1;
                this.streamInPlay.addEventListener(NetStatusEvent.NET_STATUS, this.netStatusHandler);
                this.streamInPlay.resume();
                this.fnOnEnterFrame();
                this.classicVideo.visible = false;
                this.classicVideo.clear();
                this.classicVideo = null;
                this.classicVideo = _arg2;
                this.classicVideo.visible = true;
            };
            if (this._sliceStream.buffer){
                JTracer.sendMessage(("Player -> replaceNextStream, _sliceStream.buffer:true, streamInPlay.bufferLenght:" + this.streamInPlay.bufferLength));
                this._progressCacheTime = _local5;
            };
            (_arg3 as Function)();
            JTracer.sendMessage(((((((("Player -> replaceNextStream end, streamInPlay.time:" + this.streamInPlay.time) + ", nextStream.time:") + _arg1.time) + ", streamInPlay.bufferLenght:") + this.streamInPlay.bufferLength) + ", streamInPlay.bufferTime:") + this.streamInPlay.bufferTime));
            if ((((_local5 == 0)) && ((this.streamInPlay.bufferLength > this.streamInPlay.bufferTime)))){
                this.main_mc._bufferTip.clearBreakCount();
                GlobalVars.instance.bufferType = GlobalVars.instance.bufferTypeError;
                JTracer.sendMessage(("Player -> replaceNextStream, set bufferType:" + GlobalVars.instance.bufferType));
                this.seek(_local5, true);
                this._errorInfo = "205";
                JTracer.sendMessage(("Player -> onErrorInfo, code:" + this._errorInfo));
                Tools.stat((((("f=playerror&e=" + this._errorInfo) + "&gcid=") + Tools.getUserInfo("ygcid")) + this.retryLastTimeStat));
                ExternalInterface.call("flv_playerEvent", "onErrorInfo", this._errorInfo);
            };
        }
        private function getFixedByteEnd(_arg1:String):Number{
            if (!_arg1){
                return (0);
            };
            return (Number(_arg1.substr(5)));
        }
        public function getFirstEndByte():String{
            var _local1:Number = 0;
            var _local2 = "";
            var _local3:Number = 0;
            if (((((this.videoUrlArr[0].totalTime) && (this.videoUrlArr[0].totalByte))) && (this.videoUrlArr[0].sliceTime))){
                _local3 = Math.round(((this.videoUrlArr[0].sliceTime * this.videoUrlArr[0].totalByte) / this.videoUrlArr[0].totalTime));
                if (this.videoUrlArr[0].start > 0){
                    _local1 = Math.min(this._streamEndByte, this.videoUrlArr[0].totalByte);
                    _local2 = ("&end=" + _local1);
                    JTracer.sendMessage(((((("Player -> getFirstEndByte, byte end1:" + _local1) + ", _streamStartByte:") + this._streamStartByte) + ", _streamEndByte:") + this._streamEndByte));
                } else {
                    _local1 = Math.min(_local3, this.videoUrlArr[0].totalByte);
                    _local2 = ("&end=" + _local1);
                    JTracer.sendMessage(((((("Player -> getFirstEndByte, byte end2:" + _local1) + ", _streamStartByte:") + this._streamStartByte) + ", endByte:") + _local3));
                };
                this._sliceStream.firstByteEnd = _local3;
                this._sliceStream.sliceTime = this.videoUrlArr[0].sliceTime;
                JTracer.sendMessage(((((((("影片的分段时间sliceTime:" + this.videoUrlArr[0].sliceTime) + ", 总字节totalByte:") + this.videoUrlArr[0].totalByte) + ", 总时长totalTime:") + this.videoUrlArr[0].totalTime) + ", firstByteEnd:") + _local3));
            };
            return (_local2);
        }
        public function getFirstStartTime():Number{
            return (this._streamStartTime);
        }
        public function getFirstStartByte():String{
            return (this._streamStartByte.toString());
        }
        override public function set width(_arg1:Number):void{
            this.swf_width = _arg1;
            if (this.classicVideo != null){
                this.classicVideo.width = _arg1;
            };
        }
        override public function get width():Number{
            return (this.swf_width);
        }
        override public function set height(_arg1:Number):void{
            this.swf_height = _arg1;
            if (this.classicVideo != null){
                this.classicVideo.height = _arg1;
            };
        }
        override public function get height():Number{
            return (this.swf_height);
        }
        public function get lastUrl():String{
            return (this._lastUrl);
        }
        public function set lastUrl(_arg1:String):void{
            this._lastUrl = _arg1;
        }
        public function get playUrl():String{
            return (this._playUrl);
        }
        public function set playUrl(_arg1:String):void{
            this._playUrl = _arg1;
        }
        public function getNextUrl():String{
            var _local1:Object;
            if (GlobalVars.instance.vodURLList.length > 0){
                _local1 = GlobalVars.instance.vodURLList.shift();
                return (_local1.url);
            };
            return (null);
        }
        public function get vodUrl():String{
            return (this._vodUrl);
        }
        public function set vodUrl(_arg1:String):void{
            this._vodUrl = _arg1;
        }
        public function get gdlUrl():String{
            return (this._gdlUrl);
        }
        public function get originGdlUrl():String{
            return (this._originGdlUrl);
        }
        public function set originGdlUrl(_arg1:String):void{
            this._originGdlUrl = _arg1;
        }
        public function closeNetConnection():void{
            if (this.myConnection){
                this.myConnection.close();
            };
        }
        public function get downloadBytes():Number{
            var _local2:*;
            var _local1:Number = 0;
            for (_local2 in this._totalSpeedArray) {
                _local1 = (_local1 + this._totalSpeedArray[_local2]);
            };
            return ((_local1 * 0x0400));
        }
        public function get isResetStart():Boolean{
            return (this._isResetStart);
        }
        public function get isInvalidTime():Boolean{
            return (this._isInvalidTime);
        }
        public function get getVideoUrlArr():Array{
            return (this.videoUrlArr);
        }
        public function set startPosition(_arg1:Number):void{
            this.videoUrlArr[0].start = _arg1;
        }

    }
}//package com 
﻿package com.greensock {
    import flash.events.*;
    import flash.display.*;
    import flash.utils.*;
    import com.greensock.core.*;

    public class TweenLite extends TweenCore {

        public static const version:Number = 11.62;

        public static var plugins:Object = {};
        public static var fastEaseLookup:Dictionary = new Dictionary(false);
        public static var onPluginEvent:Function;
        public static var killDelayedCallsTo:Function = TweenLite.killTweensOf;
        public static var defaultEase:Function = TweenLite.easeOut;
        public static var overwriteManager:Object;
        public static var rootFrame:Number;
        public static var rootTimeline:SimpleTimeline;
        public static var rootFramesTimeline:SimpleTimeline;
        public static var masterList:Dictionary = new Dictionary(false);
        private static var _shape:Shape = new Shape();
        protected static var _reservedProps:Object = {
            ease:1,
            delay:1,
            overwrite:1,
            onComplete:1,
            onCompleteParams:1,
            useFrames:1,
            runBackwards:1,
            startAt:1,
            onUpdate:1,
            onUpdateParams:1,
            onStart:1,
            onStartParams:1,
            onInit:1,
            onInitParams:1,
            onReverseComplete:1,
            onReverseCompleteParams:1,
            onRepeat:1,
            onRepeatParams:1,
            proxiedEase:1,
            easeParams:1,
            yoyo:1,
            onCompleteListener:1,
            onUpdateListener:1,
            onStartListener:1,
            onReverseCompleteListener:1,
            onRepeatListener:1,
            orientToBezier:1,
            timeScale:1,
            immediateRender:1,
            repeat:1,
            repeatDelay:1,
            timeline:1,
            data:1,
            paused:1
        };

        public var target:Object;
        public var propTweenLookup:Object;
        public var ratio:Number = 0;
        public var cachedPT1:PropTween;
        protected var _ease:Function;
        protected var _overwrite:int;
        protected var _overwrittenProps:Object;
        protected var _hasPlugins:Boolean;
        protected var _notifyPluginsOfEnabled:Boolean;

        public function TweenLite(_arg1:Object, _arg2:Number, _arg3:Object){
            var _local5:TweenLite;
            super(_arg2, _arg3);
            if (_arg1 == null){
                throw (new Error("Cannot tween a null object."));
            };
            this.target = _arg1;
            if ((((this.target is TweenCore)) && (this.vars.timeScale))){
                this.cachedTimeScale = 1;
            };
            this.propTweenLookup = {};
            this._ease = defaultEase;
            this._overwrite = ((((!((Number(_arg3.overwrite) > -1))) || (((!(overwriteManager.enabled)) && ((_arg3.overwrite > 1)))))) ? overwriteManager.mode : int(_arg3.overwrite));
            var _local4:Array = masterList[_arg1];
            if (!_local4){
                masterList[_arg1] = [this];
            } else {
                if (this._overwrite == 1){
                    for each (_local5 in _local4) {
                        if (!_local5.gc){
                            _local5.setEnabled(false, false);
                        };
                    };
                    masterList[_arg1] = [this];
                } else {
                    _local4[_local4.length] = this;
                };
            };
            if (((this.active) || (this.vars.immediateRender))){
                this.renderTime(0, false, true);
            };
        }
        public static function initClass():void{
            rootFrame = 0;
            rootTimeline = new SimpleTimeline(null);
            rootFramesTimeline = new SimpleTimeline(null);
            rootTimeline.cachedStartTime = (getTimer() * 0.001);
            rootFramesTimeline.cachedStartTime = rootFrame;
            rootTimeline.autoRemoveChildren = true;
            rootFramesTimeline.autoRemoveChildren = true;
            _shape.addEventListener(Event.ENTER_FRAME, updateAll, false, 0, true);
            if (overwriteManager == null){
                overwriteManager = {
                    mode:1,
                    enabled:false
                };
            };
        }
        public static function to(_arg1:Object, _arg2:Number, _arg3:Object):TweenLite{
            return (new TweenLite(_arg1, _arg2, _arg3));
        }
        public static function from(_arg1:Object, _arg2:Number, _arg3:Object):TweenLite{
            _arg3.runBackwards = true;
            if (!("immediateRender" in _arg3)){
                _arg3.immediateRender = true;
            };
            return (new TweenLite(_arg1, _arg2, _arg3));
        }
        public static function delayedCall(_arg1:Number, _arg2:Function, _arg3:Array=null, _arg4:Boolean=false):TweenLite{
            return (new TweenLite(_arg2, 0, {
                delay:_arg1,
                onComplete:_arg2,
                onCompleteParams:_arg3,
                immediateRender:false,
                useFrames:_arg4,
                overwrite:0
            }));
        }
        protected static function updateAll(_arg1:Event=null):void{
            var _local2:Dictionary;
            var _local3:Object;
            var _local4:Array;
            var _local5:int;
            rootTimeline.renderTime((((getTimer() * 0.001) - rootTimeline.cachedStartTime) * rootTimeline.cachedTimeScale), false, false);
            rootFrame = (rootFrame + 1);
            rootFramesTimeline.renderTime(((rootFrame - rootFramesTimeline.cachedStartTime) * rootFramesTimeline.cachedTimeScale), false, false);
            if (!(rootFrame % 60)){
                _local2 = masterList;
                for (_local3 in _local2) {
                    _local4 = _local2[_local3];
                    _local5 = _local4.length;
                    while (--_local5 > -1) {
                        if (TweenLite(_local4[_local5]).gc){
                            _local4.splice(_local5, 1);
                        };
                    };
                    if (_local4.length == 0){
                        delete _local2[_local3];
                    };
                };
            };
        }
        public static function killTweensOf(_arg1:Object, _arg2:Boolean=false, _arg3:Object=null):void{
            var _local4:Array;
            var _local5:int;
            var _local6:TweenLite;
            if ((_arg1 in masterList)){
                _local4 = masterList[_arg1];
                _local5 = _local4.length;
                while (--_local5 > -1) {
                    _local6 = _local4[_local5];
                    if (!_local6.gc){
                        if (_arg2){
                            _local6.complete(false, false);
                        };
                        if (_arg3 != null){
                            _local6.killVars(_arg3);
                        };
                        if ((((_arg3 == null)) || ((((_local6.cachedPT1 == null)) && (_local6.initted))))){
                            _local6.setEnabled(false, false);
                        };
                    };
                };
                if (_arg3 == null){
                    delete masterList[_arg1];
                };
            };
        }
        protected static function easeOut(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number):Number{
            _arg1 = (1 - (_arg1 / _arg4));
            return ((1 - (_arg1 * _arg1)));
        }

        protected function init():void{
            var _local1:String;
            var _local2:int;
            var _local3:*;
            var _local4:Boolean;
            var _local5:Array;
            var _local6:PropTween;
            if (this.vars.onInit){
                this.vars.onInit.apply(null, this.vars.onInitParams);
            };
            if (typeof(this.vars.ease) == "function"){
                this._ease = this.vars.ease;
            };
            if (this.vars.easeParams){
                this.vars.proxiedEase = this._ease;
                this._ease = this.easeProxy;
            };
            this.cachedPT1 = null;
            this.propTweenLookup = {};
            for (_local1 in this.vars) {
                if ((((_local1 in _reservedProps)) && (!((((_local1 == "timeScale")) && ((this.target is TweenCore))))))){
                } else {
                    if ((((_local1 in plugins)) && ((_local3 = new ((plugins[_local1] as Class))()).onInitTween(this.target, this.vars[_local1], this)))){
                        this.cachedPT1 = new PropTween(_local3, "changeFactor", 0, 1, ((_local3.overwriteProps.length)==1) ? _local3.overwriteProps[0] : "_MULTIPLE_", true, this.cachedPT1);
                        if (this.cachedPT1.name == "_MULTIPLE_"){
                            _local2 = _local3.overwriteProps.length;
                            while (--_local2 > -1) {
                                this.propTweenLookup[_local3.overwriteProps[_local2]] = this.cachedPT1;
                            };
                        } else {
                            this.propTweenLookup[this.cachedPT1.name] = this.cachedPT1;
                        };
                        if (_local3.priority){
                            this.cachedPT1.priority = _local3.priority;
                            _local4 = true;
                        };
                        if (((_local3.onDisable) || (_local3.onEnable))){
                            this._notifyPluginsOfEnabled = true;
                        };
                        this._hasPlugins = true;
                    } else {
                        this.cachedPT1 = new PropTween(this.target, _local1, Number(this.target[_local1]), ((typeof(this.vars[_local1]))=="number") ? (Number(this.vars[_local1]) - this.target[_local1]) : Number(this.vars[_local1]), _local1, false, this.cachedPT1);
                        this.propTweenLookup[_local1] = this.cachedPT1;
                    };
                };
            };
            if (_local4){
                onPluginEvent("onInitAllProps", this);
            };
            if (this.vars.runBackwards){
                _local6 = this.cachedPT1;
                while (_local6) {
                    _local6.start = (_local6.start + _local6.change);
                    _local6.change = -(_local6.change);
                    _local6 = _local6.nextNode;
                };
            };
            _hasUpdate = Boolean(!((this.vars.onUpdate == null)));
            if (this._overwrittenProps){
                this.killVars(this._overwrittenProps);
                if (this.cachedPT1 == null){
                    this.setEnabled(false, false);
                };
            };
            if ((((((((this._overwrite > 1)) && (this.cachedPT1))) && ((_local5 = masterList[this.target])))) && ((_local5.length > 1)))){
                if (overwriteManager.manageOverwrites(this, this.propTweenLookup, _local5, this._overwrite)){
                    this.init();
                };
            };
            this.initted = true;
        }
        override public function renderTime(_arg1:Number, _arg2:Boolean=false, _arg3:Boolean=false):void{
            var _local4:Boolean;
            var _local5:Number = this.cachedTime;
            if (_arg1 >= this.cachedDuration){
                this.cachedTotalTime = (this.cachedTime = this.cachedDuration);
                this.ratio = 1;
                _local4 = true;
                if (this.cachedDuration == 0){
                    if ((((((_arg1 == 0)) || ((_rawPrevTime < 0)))) && (!((_rawPrevTime == _arg1))))){
                        _arg3 = true;
                    };
                    _rawPrevTime = _arg1;
                };
            } else {
                if (_arg1 <= 0){
                    this.cachedTotalTime = (this.cachedTime = (this.ratio = 0));
                    if (_arg1 < 0){
                        this.active = false;
                        if (this.cachedDuration == 0){
                            if (_rawPrevTime >= 0){
                                _arg3 = true;
                                _local4 = true;
                            };
                            _rawPrevTime = _arg1;
                        };
                    };
                    if (((this.cachedReversed) && (!((_local5 == 0))))){
                        _local4 = true;
                    };
                } else {
                    this.cachedTotalTime = (this.cachedTime = _arg1);
                    this.ratio = this._ease(_arg1, 0, 1, this.cachedDuration);
                };
            };
            if ((((this.cachedTime == _local5)) && (!(_arg3)))){
                return;
            };
            if (!this.initted){
                this.init();
                if (((!(_local4)) && (this.cachedTime))){
                    this.ratio = this._ease(this.cachedTime, 0, 1, this.cachedDuration);
                };
            };
            if (((!(this.active)) && (!(this.cachedPaused)))){
                this.active = true;
            };
            if ((((((((_local5 == 0)) && (this.vars.onStart))) && (((!((this.cachedTime == 0))) || ((this.cachedDuration == 0)))))) && (!(_arg2)))){
                this.vars.onStart.apply(null, this.vars.onStartParams);
            };
            var _local6:PropTween = this.cachedPT1;
            while (_local6) {
                _local6.target[_local6.property] = (_local6.start + (this.ratio * _local6.change));
                _local6 = _local6.nextNode;
            };
            if (((_hasUpdate) && (!(_arg2)))){
                this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
            };
            if (((_local4) && (!(this.gc)))){
                if (((this._hasPlugins) && (this.cachedPT1))){
                    onPluginEvent("onComplete", this);
                };
                complete(true, _arg2);
            };
        }
        public function killVars(_arg1:Object, _arg2:Boolean=true):Boolean{
            var _local3:String;
            var _local4:PropTween;
            var _local5:Boolean;
            if (this._overwrittenProps == null){
                this._overwrittenProps = {};
            };
            for (_local3 in _arg1) {
                if ((_local3 in this.propTweenLookup)){
                    _local4 = this.propTweenLookup[_local3];
                    if (((_local4.isPlugin) && ((_local4.name == "_MULTIPLE_")))){
                        _local4.target.killProps(_arg1);
                        if (_local4.target.overwriteProps.length == 0){
                            _local4.name = "";
                        };
                        if (((!((_local3 == _local4.target.propName))) || ((_local4.name == "")))){
                            delete this.propTweenLookup[_local3];
                        };
                    };
                    if (_local4.name != "_MULTIPLE_"){
                        if (_local4.nextNode){
                            _local4.nextNode.prevNode = _local4.prevNode;
                        };
                        if (_local4.prevNode){
                            _local4.prevNode.nextNode = _local4.nextNode;
                        } else {
                            if (this.cachedPT1 == _local4){
                                this.cachedPT1 = _local4.nextNode;
                            };
                        };
                        if (((_local4.isPlugin) && (_local4.target.onDisable))){
                            _local4.target.onDisable();
                            if (_local4.target.activeDisable){
                                _local5 = true;
                            };
                        };
                        delete this.propTweenLookup[_local3];
                    };
                };
                if (((_arg2) && (!((_arg1 == this._overwrittenProps))))){
                    this._overwrittenProps[_local3] = 1;
                };
            };
            return (_local5);
        }
        override public function invalidate():void{
            if (((this._notifyPluginsOfEnabled) && (this.cachedPT1))){
                onPluginEvent("onDisable", this);
            };
            this.cachedPT1 = null;
            this._overwrittenProps = null;
            _hasUpdate = (this.initted = (this.active = (this._notifyPluginsOfEnabled = false)));
            this.propTweenLookup = {};
        }
        override public function setEnabled(_arg1:Boolean, _arg2:Boolean=false):Boolean{
            var _local3:Array;
            if (_arg1){
                _local3 = TweenLite.masterList[this.target];
                if (!_local3){
                    TweenLite.masterList[this.target] = [this];
                } else {
                    _local3[_local3.length] = this;
                };
            };
            super.setEnabled(_arg1, _arg2);
            if (((this._notifyPluginsOfEnabled) && (this.cachedPT1))){
                return (onPluginEvent(((_arg1) ? "onEnable" : "onDisable"), this));
            };
            return (false);
        }
        protected function easeProxy(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number):Number{
            return (this.vars.proxiedEase.apply(null, arguments.concat(this.vars.easeParams)));
        }

    }
}//package com.greensock 
﻿package com.greensock.core {
    import com.greensock.*;

    public class TweenCore {

        public static const version:Number = 1.64;

        protected static var _classInitted:Boolean;

        protected var _delay:Number;
        protected var _hasUpdate:Boolean;
        protected var _rawPrevTime:Number = -1;
        public var vars:Object;
        public var active:Boolean;
        public var gc:Boolean;
        public var initted:Boolean;
        public var timeline:SimpleTimeline;
        public var cachedStartTime:Number;
        public var cachedTime:Number;
        public var cachedTotalTime:Number;
        public var cachedDuration:Number;
        public var cachedTotalDuration:Number;
        public var cachedTimeScale:Number;
        public var cachedPauseTime:Number;
        public var cachedReversed:Boolean;
        public var nextNode:TweenCore;
        public var prevNode:TweenCore;
        public var cachedOrphan:Boolean;
        public var cacheIsDirty:Boolean;
        public var cachedPaused:Boolean;
        public var data;

        public function TweenCore(_arg1:Number=0, _arg2:Object=null){
            this.vars = ((_arg2)!=null) ? _arg2 : {};
            if (this.vars.isGSVars){
                this.vars = this.vars.vars;
            };
            this.cachedDuration = (this.cachedTotalDuration = _arg1);
            this._delay = ((this.vars.delay) ? Number(this.vars.delay) : 0);
            this.cachedTimeScale = ((this.vars.timeScale) ? Number(this.vars.timeScale) : 1);
            this.active = Boolean((((((_arg1 == 0)) && ((this._delay == 0)))) && (!((this.vars.immediateRender == false)))));
            this.cachedTotalTime = (this.cachedTime = 0);
            this.data = this.vars.data;
            if (!_classInitted){
                if (isNaN(TweenLite.rootFrame)){
                    TweenLite.initClass();
                    _classInitted = true;
                } else {
                    return;
                };
            };
            var _local3:SimpleTimeline = (((this.vars.timeline is SimpleTimeline)) ? this.vars.timeline : ((this.vars.useFrames) ? TweenLite.rootFramesTimeline : TweenLite.rootTimeline));
            _local3.insert(this, _local3.cachedTotalTime);
            if (this.vars.reversed){
                this.cachedReversed = true;
            };
            if (this.vars.paused){
                this.paused = true;
            };
        }
        public function play():void{
            this.reversed = false;
            this.paused = false;
        }
        public function pause():void{
            this.paused = true;
        }
        public function resume():void{
            this.paused = false;
        }
        public function restart(_arg1:Boolean=false, _arg2:Boolean=true):void{
            this.reversed = false;
            this.paused = false;
            this.setTotalTime(((_arg1) ? -(this._delay) : 0), _arg2);
        }
        public function reverse(_arg1:Boolean=true):void{
            this.reversed = true;
            if (_arg1){
                this.paused = false;
            } else {
                if (this.gc){
                    this.setEnabled(true, false);
                };
            };
        }
        public function renderTime(_arg1:Number, _arg2:Boolean=false, _arg3:Boolean=false):void{
        }
        public function complete(_arg1:Boolean=false, _arg2:Boolean=false):void{
            if (!_arg1){
                this.renderTime(this.totalDuration, _arg2, false);
                return;
            };
            if (this.timeline.autoRemoveChildren){
                this.setEnabled(false, false);
            } else {
                this.active = false;
            };
            if (!_arg2){
                if (((((this.vars.onComplete) && ((this.cachedTotalTime >= this.cachedTotalDuration)))) && (!(this.cachedReversed)))){
                    this.vars.onComplete.apply(null, this.vars.onCompleteParams);
                } else {
                    if (((((this.cachedReversed) && ((this.cachedTotalTime == 0)))) && (this.vars.onReverseComplete))){
                        this.vars.onReverseComplete.apply(null, this.vars.onReverseCompleteParams);
                    };
                };
            };
        }
        public function invalidate():void{
        }
        public function setEnabled(_arg1:Boolean, _arg2:Boolean=false):Boolean{
            this.gc = !(_arg1);
            if (_arg1){
                this.active = Boolean(((((!(this.cachedPaused)) && ((this.cachedTotalTime > 0)))) && ((this.cachedTotalTime < this.cachedTotalDuration))));
                if (((!(_arg2)) && (this.cachedOrphan))){
                    this.timeline.insert(this, (this.cachedStartTime - this._delay));
                };
            } else {
                this.active = false;
                if (((!(_arg2)) && (!(this.cachedOrphan)))){
                    this.timeline.remove(this, true);
                };
            };
            return (false);
        }
        public function kill():void{
            this.setEnabled(false, false);
        }
        protected function setDirtyCache(_arg1:Boolean=true):void{
            var _local2:TweenCore = ((_arg1) ? this : this.timeline);
            while (_local2) {
                _local2.cacheIsDirty = true;
                _local2 = _local2.timeline;
            };
        }
        protected function setTotalTime(_arg1:Number, _arg2:Boolean=false):void{
            var _local3:Number;
            var _local4:Number;
            if (this.timeline){
                _local3 = ((this.cachedPaused) ? this.cachedPauseTime : this.timeline.cachedTotalTime);
                if (this.cachedReversed){
                    _local4 = ((this.cacheIsDirty) ? this.totalDuration : this.cachedTotalDuration);
                    this.cachedStartTime = (_local3 - ((_local4 - _arg1) / this.cachedTimeScale));
                } else {
                    this.cachedStartTime = (_local3 - (_arg1 / this.cachedTimeScale));
                };
                if (!this.timeline.cacheIsDirty){
                    this.setDirtyCache(false);
                };
                if (this.cachedTotalTime != _arg1){
                    this.renderTime(_arg1, _arg2, false);
                };
            };
        }
        public function get delay():Number{
            return (this._delay);
        }
        public function set delay(_arg1:Number):void{
            this.startTime = (this.startTime + (_arg1 - this._delay));
            this._delay = _arg1;
        }
        public function get duration():Number{
            return (this.cachedDuration);
        }
        public function set duration(_arg1:Number):void{
            var _local2:Number = (_arg1 / this.cachedDuration);
            this.cachedDuration = (this.cachedTotalDuration = _arg1);
            if (((((this.active) && (!(this.cachedPaused)))) && (!((_arg1 == 0))))){
                this.setTotalTime((this.cachedTotalTime * _local2), true);
            };
            this.setDirtyCache(false);
        }
        public function get totalDuration():Number{
            return (this.cachedTotalDuration);
        }
        public function set totalDuration(_arg1:Number):void{
            this.duration = _arg1;
        }
        public function get currentTime():Number{
            return (this.cachedTime);
        }
        public function set currentTime(_arg1:Number):void{
            this.setTotalTime(_arg1, false);
        }
        public function get totalTime():Number{
            return (this.cachedTotalTime);
        }
        public function set totalTime(_arg1:Number):void{
            this.setTotalTime(_arg1, false);
        }
        public function get startTime():Number{
            return (this.cachedStartTime);
        }
        public function set startTime(_arg1:Number):void{
            if (((!((this.timeline == null))) && (((!((_arg1 == this.cachedStartTime))) || (this.gc))))){
                this.timeline.insert(this, (_arg1 - this._delay));
            } else {
                this.cachedStartTime = _arg1;
            };
        }
        public function get reversed():Boolean{
            return (this.cachedReversed);
        }
        public function set reversed(_arg1:Boolean):void{
            if (_arg1 != this.cachedReversed){
                this.cachedReversed = _arg1;
                this.setTotalTime(this.cachedTotalTime, true);
            };
        }
        public function get paused():Boolean{
            return (this.cachedPaused);
        }
        public function set paused(_arg1:Boolean):void{
            if (((!((_arg1 == this.cachedPaused))) && (this.timeline))){
                if (_arg1){
                    this.cachedPauseTime = this.timeline.rawTime;
                } else {
                    this.cachedStartTime = (this.cachedStartTime + (this.timeline.rawTime - this.cachedPauseTime));
                    this.cachedPauseTime = NaN;
                    this.setDirtyCache(false);
                };
                this.cachedPaused = _arg1;
                this.active = Boolean(((((!(this.cachedPaused)) && ((this.cachedTotalTime > 0)))) && ((this.cachedTotalTime < this.cachedTotalDuration))));
            };
            if (((!(_arg1)) && (this.gc))){
                this.setTotalTime(this.cachedTotalTime, false);
                this.setEnabled(true, false);
            };
        }

    }
}//package com.greensock.core 
﻿package com.greensock.core {

    public class SimpleTimeline extends TweenCore {

        protected var _firstChild:TweenCore;
        protected var _lastChild:TweenCore;
        public var autoRemoveChildren:Boolean;

        public function SimpleTimeline(_arg1:Object=null){
            super(0, _arg1);
        }
        public function insert(_arg1:TweenCore, _arg2=0):TweenCore{
            if (((!(_arg1.cachedOrphan)) && (_arg1.timeline))){
                _arg1.timeline.remove(_arg1, true);
            };
            _arg1.timeline = this;
            _arg1.cachedStartTime = (Number(_arg2) + _arg1.delay);
            if (_arg1.gc){
                _arg1.setEnabled(true, true);
            };
            if (_arg1.cachedPaused){
                _arg1.cachedPauseTime = (_arg1.cachedStartTime + ((this.rawTime - _arg1.cachedStartTime) / _arg1.cachedTimeScale));
            };
            if (this._lastChild){
                this._lastChild.nextNode = _arg1;
            } else {
                this._firstChild = _arg1;
            };
            _arg1.prevNode = this._lastChild;
            this._lastChild = _arg1;
            _arg1.nextNode = null;
            _arg1.cachedOrphan = false;
            return (_arg1);
        }
        public function remove(_arg1:TweenCore, _arg2:Boolean=false):void{
            if (_arg1.cachedOrphan){
                return;
            };
            if (!_arg2){
                _arg1.setEnabled(false, true);
            };
            if (_arg1.nextNode){
                _arg1.nextNode.prevNode = _arg1.prevNode;
            } else {
                if (this._lastChild == _arg1){
                    this._lastChild = _arg1.prevNode;
                };
            };
            if (_arg1.prevNode){
                _arg1.prevNode.nextNode = _arg1.nextNode;
            } else {
                if (this._firstChild == _arg1){
                    this._firstChild = _arg1.nextNode;
                };
            };
            _arg1.cachedOrphan = true;
        }
        override public function renderTime(_arg1:Number, _arg2:Boolean=false, _arg3:Boolean=false):void{
            var _local5:Number;
            var _local6:TweenCore;
            var _local4:TweenCore = this._firstChild;
            this.cachedTotalTime = _arg1;
            this.cachedTime = _arg1;
            while (_local4) {
                _local6 = _local4.nextNode;
                if (((_local4.active) || ((((((_arg1 >= _local4.cachedStartTime)) && (!(_local4.cachedPaused)))) && (!(_local4.gc)))))){
                    if (!_local4.cachedReversed){
                        _local4.renderTime(((_arg1 - _local4.cachedStartTime) * _local4.cachedTimeScale), _arg2, false);
                    } else {
                        _local5 = ((_local4.cacheIsDirty) ? _local4.totalDuration : _local4.cachedTotalDuration);
                        _local4.renderTime((_local5 - ((_arg1 - _local4.cachedStartTime) * _local4.cachedTimeScale)), _arg2, false);
                    };
                };
                _local4 = _local6;
            };
        }
        public function get rawTime():Number{
            return (this.cachedTotalTime);
        }

    }
}//package com.greensock.core 
﻿package com.greensock.core {

    public final class PropTween {

        public var target:Object;
        public var property:String;
        public var start:Number;
        public var change:Number;
        public var name:String;
        public var priority:int;
        public var isPlugin:Boolean;
        public var nextNode:PropTween;
        public var prevNode:PropTween;

        public function PropTween(_arg1:Object, _arg2:String, _arg3:Number, _arg4:Number, _arg5:String, _arg6:Boolean, _arg7:PropTween=null, _arg8:int=0){
            this.target = _arg1;
            this.property = _arg2;
            this.start = _arg3;
            this.change = _arg4;
            this.name = _arg5;
            this.isPlugin = _arg6;
            if (_arg7){
                _arg7.prevNode = this;
                this.nextNode = _arg7;
            };
            this.priority = _arg8;
        }
    }
}//package com.greensock.core 
﻿package {
    import flash.display.*;

    public dynamic class TimeTipsLoading extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class LogoEnd extends MovieClip {

        public var share_btn:MovieClip;
        public var replay_btn:MovieClip;

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class PageNavBtn extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class CloseBtn extends SimpleButton {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class CtrBarFullScreenBtn extends MovieClip {

    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class BtnTipsBg extends BitmapData {

        public function BtnTipsBg(_arg1:int=44, _arg2:int=32){
            super(_arg1, _arg2);
        }
    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class TimeTipsBorder extends BitmapData {

        public function TimeTipsBorder(_arg1:int=47, _arg2:int=25){
            super(_arg1, _arg2);
        }
    }
}//package 
﻿package {
    import flash.display.*;

    public dynamic class SetCancleButton extends SimpleButton {

    }
}//package
