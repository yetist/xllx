package {
    import flash.events.*;
    import com.serialization.json.*;
    import flash.display.*;
    import flash.net.*;
    import flash.utils.*;
    import flash.text.*;
    import flash.system.*;
    import flash.external.*;
    public class FileUploader extends Sprite {
        public
        var select_btn: movieclip;
        private
        var file: FileReference;
        private
        var filter: FileFilter;
        private
        var url: string;
        private
        var limitSize: number;
        private
        var fileName: string;
        private
        var timer: Timer;
        private
        var isImmediately: boolean = true;
        private
        var style: StyleSheet;
        private
        var jsPrefix: string;
        private
        var asPrefix: string;
        private
        var linkStyle: object;
        private
        var hoverStyle: object;
        public
        function FileUploader(): void {
            if (stage) {
                this.init();
            } else {
                addEventListener(Event.ADDED_TO_STAGE, this.init);
            };
        }
        private
        function init(_arg1: Event = null): void {
            removeEventListener(Event.ADDED_TO_STAGE, this.init);
            Security.allowdomain("*");
            Security.allowinsecuredomain("*");
            stage.align = StageAlign.TOP_LEFT;
            stage.scalemode = StageScaleMode.NO_SCALE;
            this.select_btn.buttonMode = true;
            this.select_btn.mouseChildren = false;
            this.select_btn.addEventListener(MouseEvent.CLICK, this.onClickSelect);
            this.select_btn.addEventListener(MouseEvent.ROLL_OVER, this.onOverSelect);
            this.select_btn.addEventListener(MouseEvent.ROLL_OUT, this.onOutSelect);
            this.style = new StyleSheet();
            var _local2: object = this.loaderInfo.parameters;
            this.setUploadParam(_local2);
            this.registerCallback();
            stage.addEventListener(Event.RESIZE, this.onStageResize);
            this.onStageResize(null);
        }
        private
        function registerCallback(): void {
            if (ExternalInterface.available) {
                ExternalInterface.addCallback((this.asPrefix + "uploadFile"), this.uploadFile);
                ExternalInterface.addCallback((this.asPrefix + "setStyle"), this.setFontStyle);
            };
        }
        private
        function onStageResize(_arg1: Event): void {
            this.select_btn.bg_mc.width = stage.stageWidth;
            this.select_btn.bg_mc.height = stage.stageHeight;
            this.select_btn.label_txt.width = stage.stageWidth;
            this.select_btn.label_txt.height = (this.select_btn.label_txt.textheight + 2);
            this.select_btn.label_txt.y = ((stage.stageHeight - this.select_btn.label_txt.height) / 2);
        }
        private
        function setUploadParam(_arg1: object): void {
            var _local2: string = _arg1.description;
            var _local3: string = _arg1.extension;
            var _local4: uint = ((_arg1.fontSize) ? uint(_arg1.fontSize) : 14);
            var _local5: string = ((_arg1.fontFamily) ? _arg1.fontFamily : "微软雅黑");
            var _local6: string = ((_arg1.fontWeight) ? _arg1.fontWeight : "normal");
            var _local7: string = ((_arg1.fontColor) ? ("#" + _arg1.fontColor.tostring().substr(2)) : "#FFFFFF");
            var _local8: string = ((_arg1.linkDecoration) ? _arg1.linkDecoration : "none");
            var _local9: string = ((_arg1.hoverColor) ? ("#" + _arg1.hoverColor.tostring().substr(2)) : "#FFFFFF");
            var _local10: string = ((_arg1.hoverDecoration) ? _arg1.hoverDecoration : "none");
            this.linkStyle = {
                color: _local7,
                fontSize: _local4,
                fontFamily: _local5,
                fontWeight: _local6,
                textDecoration: _local8
            };
            this.hoverStyle = {
                color: _local9,
                fontSize: _local4,
                fontFamily: _local5,
                fontWeight: _local6,
                textDecoration: _local10
            };
            var _local11: string = ((_arg1.label) || (""));
            var _local12: number = ((number(_arg1.timeOut)) || (30));
            this.url = _arg1.url;
            this.limitSize = _arg1.limitSize;
            this.isImmediately = ((((!(_arg1.isImmediately)) || ((_arg1.isImmediately == "true")))) ? true : false);
            this.jsPrefix = ((_arg1.jsPrefix) || (""));
            this.asPrefix = ((_arg1.asPrefix) || (""));
            this.timer = new Timer((_local12 * 1000), 1);
            this.timer.addEventListener(TimerEvent.TIMER, this.onTimer);
            this.filter = new FileFilter(_local2, _local3);
            this.select_btn.label_txt.text = _local11;
            this.setFontStyle(this.linkStyle, this.hoverStyle);
        }
        private
        function onTimer(_arg1: TimerEvent): void {
            this.destroy();
            ExternalInterface.call((this.jsPrefix + "uploadError"), 6, this.fileName);
        }
        private
        function onClickSelect(_arg1: MouseEvent): void {
            this.setCurrentStyle(this.linkStyle);
            ExternalInterface.call((this.jsPrefix + "browser"));
            this.destroy();
            this.file = new FileReference();
            this.addListeners(this.file);
            this.file.browse([this.filter]);
        }
        private
        function onOverSelect(_arg1: MouseEvent): void {
            this.setCurrentStyle(this.hoverStyle);
        }
        private
        function onOutSelect(_arg1: MouseEvent): void {
            this.setCurrentStyle(this.linkStyle);
        }
        private
        function uploadFile(): void {
            var _local1: date = new date();
            var _local2 = "";
            if (this.url.indexof("?") != -1) {
                _local2 = "&";
            } else {
                _local2 = "?";
            };
            var _local3: URLRequest = new URLRequest((((this.url + _local2) + "t=") + _local1.gettime()));
            try {
                this.file.upload(_local3);
            } catch (e: error) {};
            this.timer.reset();
            this.timer.start();
        }
        private
        function setFontStyle(_arg1: object, _arg2: object): void {
            _arg1 = ((_arg1) || ({}));
            _arg2 = ((_arg2) || ({}));
            this.setCurrentStyle(_arg1);
        }
        private
        function setCurrentStyle(_arg1: object): void {
            this.style.setstyle(".fontStyle", _arg1);
            this.select_btn.label_txt.styleSheet = this.style;
            this.select_btn.label_txt.htmltext = (("" + this.select_btn.label_txt.text) + "");
        }
        private
        function addListeners(_arg1: IEventDispatcher): void {
            _arg1.addEventListener(Event.SELECT, this.onSelectFile);
            _arg1.addEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
            _arg1.addEventListener(ProgressEvent.PROGRESS, this.progressHandler);
            _arg1.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
            _arg1.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.onUploadCompleteHandler);
        }
        private
        function removeListeners(_arg1: IEventDispatcher): void {
            _arg1.removeEventListener(Event.SELECT, this.onSelectFile);
            _arg1.removeEventListener(IOErrorEvent.IO_ERROR, this.ioErrorHandler);
            _arg1.removeEventListener(ProgressEvent.PROGRESS, this.progressHandler);
            _arg1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityErrorHandler);
            _arg1.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.onUploadCompleteHandler);
        }
        private
        function onSelectFile(_arg1: Event): void {
            this.fileName = this.file.name;
            ExternalInterface.call((this.jsPrefix + "setFilename"), this.fileName);
            if (this.file.size > this.limitSize) {
                this.destroy();
                ExternalInterface.call((this.jsPrefix + "uploadError"), 5, this.fileName);
                return;
            };
            if (this.isImmediately) {
                this.uploadFile();
            };
        }
        private
        function onUploadCompleteHandler(_arg1: DataEvent): void {
            var _local2: string = _arg1.data;
            var _local3: object = JSON.deserialize(_local2);
            var _local4: number = _local3.result;
            if (_local4 == -1) {
                return;
            };
            if (this.timer) {
                this.timer.stop();
            };
            ExternalInterface.call((this.jsPrefix + "uploadSuccess"), _local2, this.fileName);
        }
        private
        function ioErrorHandler(_arg1: IOErrorEvent): void {
            ExternalInterface.call((this.jsPrefix + "uploadError"), 3, this.fileName);
        }
        private
        function progressHandler(_arg1: ProgressEvent): void {
            ExternalInterface.call((this.jsPrefix + "uploadProgress"), (_arg1.bytesloaded / _arg1.bytestotal), this.fileName);
        }
        private
        function securityErrorHandler(_arg1: SecurityErrorEvent): void {
            ExternalInterface.call((this.jsPrefix + "uploadError"), 4, this.fileName);
        }
        private
        function destroy(): void {
            if (this.timer) {
                this.timer.stop();
            };
            if (this.file) {
                this.removeListeners(this.file);
                this.file = null;
            };
        }
        private
        function copyObject(_arg1) {
            var _local2: ByteArray = new ByteArray();
            _local2.writeObject(_arg1);
            _local2.position = 0;
            return (_local2.readObject());
        }
    }
} //package

package com.serialization.json {
    public class JSON {
        public static
        function deserialize(_arg1: string) {
            var at: * = nan;
            var ch: * = null;
            var _isDigit: * = null;
            var _isHexDigit: * = null;
            var _white: * = null;
            var _string: * = null;
            var _next: * = null;
            var _array: * = null;
            var _object: * = null;
            var _number: * = null;
            var _word: * = null;
            var _value: * = null;
            var _error: * = null;
            var source: * = _arg1;
            source = new string(source);
            at = 0;
            ch = " ";
            _isDigit = function (_arg1: string) {
                return (((("0" <= _arg1)) && ((_arg1 <= "9"))));
            };
            _isHexDigit = function (_arg1: string) {
                return (((((_isDigit(_arg1)) || (((("A" <= _arg1)) && ((_arg1 <= "F")))))) || (((("a" <= _arg1)) && ((_arg1 <= "f"))))));
            };
            _error = function (_arg1: string): void {
                throw (new error(_arg1, (at - 1)));
            };
            _next = function () {
                ch = source.charat(at);
                at = (at + 1);
                return (ch);
            };
            _white = function (): void {
                while (ch) {
                    if (ch <= " ") {
                        _next();
                    } else {
                        if (ch == "/") {
                            switch (_next()) {
                            case "/":
                                do {} while (((((_next()) && (!((ch == "\n"))))) && (!((ch == "\r")))));
                                break;
                            case "*":
                                _next();
                                while (true) {
                                    if (ch) {
                                        if (ch == "*") {
                                            if (_next() == "/") {
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
            _string = function () {
                var _local3: * ;
                var _local4: * ;
                var _local1: * = "";
                var _local2: * = "";
                var _local5: boolean;
                if (ch == "\"") {
                    while (_next()) {
                        if (ch == "\"") {
                            _next();
                            return (_local2);
                        };
                        if (ch == "\\") {
                            switch (_next()) {
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
                                    _local3 = parseint(_next(), 16);
                                    if (!isfinite(_local3)) {
                                        _local5 = true;
                                        break;
                                    };
                                    _local4 = ((_local4 * 16) + _local3);
                                    _local1 = (_local1 + 1);
                                };
                                if (_local5) {
                                    _local5 = false;
                                    break;
                                };
                                _local2 = (_local2 + string.fromcharcode(_local4));
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
            _array = function () {
                var _local1: array = [];
                if (ch == "[") {
                    _next();
                    _white();
                    if (ch == "]") {
                        _next();
                        return (_local1);
                    };
                    while (ch) {
                        _local1.push(_value());
                        _white();
                        if (ch == "]") {
                            _next();
                            return (_local1);
                        };
                        if (ch != ",") {
                            break;
                        };
                        _next();
                        _white();
                        if (ch == "]") {
                            _next();
                            return (_local1);
                        };
                    };
                };
                _error("Bad Array");
                return (null);
            };
            _object = function () {
                var _local1: * = {};
                var _local2: * = {};
                if (ch == "{") {
                    _next();
                    _white();
                    if (ch == "}") {
                        _next();
                        return (_local2);
                    };
                    while (ch) {
                        _local1 = _string();
                        _white();
                        if (ch != ":") {
                            break;
                        };
                        _next();
                        _local2[_local1] = _value();
                        _white();
                        if (ch == "}") {
                            _next();
                            return (_local2);
                        };
                        if (ch != ",") {
                            break;
                        };
                        _next();
                        _white();
                        if (ch == "}") {
                            _next();
                            return (_local2);
                        };
                    };
                };
                _error("Bad Object");
            };
            _number = function () {
                var _local3: * ;
                var _local4: * ;
                var _local7: int;
                var _local1: * = "";
                var _local2: * = "";
                var _local5 = "";
                var _local6 = "";
                if (ch == "-") {
                    _local1 = "-";
                    _local6 = _local1;
                    _next();
                };
                if (ch == "0") {
                    _next();
                    if ((((ch == "x")) || ((ch == "X")))) {
                        _next();
                        while (_isHexDigit(ch)) {
                            _local5 = (_local5 + ch);
                            _next();
                        };
                        if (_local5 == "") {
                            _error("mal formed Hexadecimal");
                        } else {
                            return (number(((_local6 + "0x") + _local5)));
                        };
                    } else {
                        _local1 = (_local1 + "0");
                    };
                };
                while (_isDigit(ch)) {
                    _local1 = (_local1 + ch);
                    _next();
                };
                if (ch == ".") {
                    _local1 = (_local1 + ".");
                    while (((((_next()) && ((ch >= "0")))) && ((ch <= "9")))) {
                        _local1 = (_local1 + ch);
                    };
                };
                _local3 = (1 * _local1);
                if (!isfinite(_local3)) {
                    _error("Bad Number");
                } else {
                    if ((((ch == "e")) || ((ch == "E")))) {
                        _next();
                        _local7 = ((ch) == "-") ? -1 : 1;
                        if ((((ch == "+")) || ((ch == "-")))) {
                            _next();
                        };
                        if (_isDigit(ch)) {
                            _local2 = (_local2 + ch);
                        } else {
                            _error("Bad Exponent");
                        };
                        while (((((_next()) && ((ch >= "0")))) && ((ch <= "9")))) {
                            _local2 = (_local2 + ch);
                        };
                        _local4 = (_local7 * _local2);
                        if (!isfinite(_local3)) {
                            _error("Bad            Exponent");
                        } else {
                            _local3 = (_local3 * math.pow(10, _local4));
                        };
                    };
                    return (_local3);
                };
                return (nan);
            };
            _word = function () {
                switch (ch) {
                case "t":
                    if ((((((_next() == "r")) && ((_next() == "u")))) && ((_next() == "e")))) {
                        _next();
                        return (true);
                    };
                    break;
                case "f":
                    if ((((((((_next() == "a")) && ((_next() == "l")))) && ((_next() == "s")))) && ((_next() == "e")))) {
                        _next();
                        return (false);
                    };
                    break;
                case "n":
                    if ((((((_next() == "u")) && ((_next() == "l")))) && ((_next() == "l")))) {
                        _next();
                        return (null);
                    };
                    break;
                };
                _error("Syntax Error");
                return (null);
            };
            _value = function () {
                _white();
                switch (ch) {
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
        public static
        function serialize(_arg1): string {
            var _local2: string;
            var _local3: number;
            var _local4: number;
            var _local6: * ;
            var _local7: string;
            var _local8: number;
            var _local5 = "";
            switch (typeof (_arg1)) {
            case "object":
                if (_arg1) {
                    if ((_arg1 is array)) {
                        _local4 = _arg1.length;
                        _local3 = 0;
                        while (_local3 < _local4) {
                            _local6 = serialize(_arg1[_local3]);
                            if (_local5) {
                                _local5 = (_local5 + ",");
                            };
                            _local5 = (_local5 + _local6);
                            _local3++;
                        };
                        return ((("[" + _local5) + "]"));
                    };
                    if (typeof (_arg1.tostring) != "undefined") {
                        for (_local7 in _arg1) {
                            _local6 = _arg1[_local7];
                            if (((!((typeof (_local6) == "undefined"))) && (!((typeof (_local6) == "function"))))) {
                                _local6 = serialize(_local6);
                                if (_local5) {
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
                return (((isfinite(_arg1)) ? string(_arg1) : "null"));
            case "string":
                _local4 = _arg1.length;
                _local5 = "\"";
                _local3 = 0;
                while (_local3 < _local4) {
                    _local2 = _arg1.charat(_local3);
                    if (_local2 >= " ") {
                        if ((((_local2 == "\\")) || ((_local2 == "\"")))) {
                            _local5 = (_local5 + "\\");
                        };
                        _local5 = (_local5 + _local2);
                    } else {
                        switch (_local2) {
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
                            _local8 = _local2.charcodeat();
                            _local5 = (_local5 + (("\\u00" + math.floor((_local8 / 16)).tostring(16)) + (_local8 % 16).tostring(16)));
                        };
                    };
                    _local3 = (_local3 + 1);
                };
                return ((_local5 + "\""));
            case "boolean":
                return (string(_arg1));
            default:
                return ("null");
            };
        }
    }
}
