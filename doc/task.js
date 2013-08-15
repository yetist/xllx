var gTask = (function () {
    var INTERFACE = "http://dynamic.vod.lixian.xunlei.com/interface/";
    var gISERVER = "http://i.vod.xunlei.com/";
    var isTaskValid = false;
    var isTaskSubmiting = false;
    var taskType = "url";
    var from = "vlist";
    var taskCheckTime = 500;
    var timeoutTime = 10000;
    var addRecordsTimer = null;
    var btTaskTips = "点击右侧浏览按钮添加bt种子";
    var urlTaskTips = "多个url请选择回车换行，最多支持100条任务";
    var foldState = false;
    var taskConfig = {
        urlTaskButton: "urlTaskButton",
        btTaskButton: "btTaskButton",
        btUploader: "btUploader",
        submitButton: "submitTask",
        submitButtonEnableStyle: "",
        submitButtonDisableStyle: "p_btn2_gray",
        inputArea: "inputArea",
        btTaskInput: "btTaskInput",
        urlTaskInput: "urlTaskInput",
        urlResultDisplayArea: "urlResultDisplayArea",
        waitingTips: "waitingTips",
        errorTips: "errorTips",
        errorFlag: "errorFlag",
        errorFlagValue: "err_tip",
        onStyle: "tab_cur",
        offStyle: "",
        proxy: null,
        proxyId: "proxy_i",
        proxyName: "proxy_i",
        porxyPath: "http://i.vod.xunlei.com/proxy.html",
        maxUrlNum: 100,
        totalNumPanel: "totalNumPanel"
    };
    var taskTips = {
        userInfoError: "用户帐号信息验证失败，建议重新登录",
        taskQueryinng: "正在查询任务信息...",
        taskSubmiting: "正在提交任务...",
        taskRepeat: "该任务已重复，添加时将被过滤",
        taskContainsError: "全部任务都有错误，无法添加",
        taskNumTooMany: "您添加的任务数超过" + taskConfig.maxUrlNum + "条,无法继续添加",
        paramError: "请求参数有误，请检查后重新添加",
        timeout: "请求超时，请稍后重试",
        svrError: "服务器繁忙，请稍后重试",
        urlInputEmpty: "请输入下载地址",
        urlInputInvalid: "请输入有效下载地址",
        urlInputError: "该视频下载链接有误，添加时将被过滤",
        urlError: "您输入的视频下载地址有误，请检查并重新输入",
        urlNotVideo: "该链接不含视频，添加时将被过滤",
        urlParseError: "该链接解析有误，请检查后重新添加",
        btFileInvalid: "不是有效的BT种子文件，请重新添加",
        btPathInvalid: "BT种子地址无效，请重新添加",
        btNotVideo: "该种子文件不含视频，请检查后重新添加",
        btParseError: "该种子文件解析失败，请稍后再试",
        btUploadTimeout: "BT文件上传超时，请稍候重试",
        btUplaodFail: "BT文件上传失败，请稍候重试",
        btTooLarge: "BT文件大小超过6M，请选择其他BT文件"
    };
    var uploaderConfig = {
        description: "请选择BT种子文件(*.torrent)",
        extension: "*.torrent",
        timeOut: 10,
        url: INTERFACE + "upload_bt?from=" + from,
        label: "",
        limitSize: 6 * 1024 * 1024,
        jsPrefix: "gTask.",
        asPrefix: "gTask_",
        isImmediately: false
    };
    var lastBtTaskReq = btTaskTips,
        lastUrlTaskReqUrls = urlTaskTips;
    var curBatchTaskReqUrls = "",
        lastBatchTaskReqUrls = "",
        curBatchTaskReqResult = [],
        lastBatchTaskReqResult = [];
    var prototype = {
        pageInit: function () {
            var that = this;
            taskConfig.proxy = document.getElementById(taskConfig.proxyId).contentWindow;
            that.genUploadButton(taskConfig.btUploader, "http://vod.xunlei.com/media/fileUploader.swf?t=" + new Date().getTime(), uploaderConfig, "76", "28");
            $("#" + taskConfig.urlTaskButton).unbind().click(function () {
                if (isTaskSubmiting) {
                    return false
                }
                $("#" + taskConfig.btTaskButton).removeClass(taskConfig.onStyle);
                $(this).addClass(taskConfig.onStyle);
                that.showSubmitTips(0);
                taskType = "url";
                var urlResultDisplayArea = $("#" + taskConfig.urlResultDisplayArea);
                that.setSubmitButtonStatus(false);
                $("#" + taskConfig.inputArea).hide();
                $("#" + taskConfig.urlTaskInput).show();
                if (urlResultDisplayArea.find("li").length > 0) {
                    urlResultDisplayArea.show()
                }
                that.updateSubmitButtonStatus();
                that.totalNumPanel("show")
            });
            $("#" + taskConfig.btTaskButton).unbind().click(function () {
                if (taskType == "bt" || isTaskSubmiting) {
                    return false
                }
                taskType = "bt";
                $("#" + taskConfig.urlTaskButton).removeClass(taskConfig.onStyle);
                $("#" + taskConfig.btTaskButton).addClass(taskConfig.onStyle);
                $("#" + taskConfig.btTaskInput).val(lastBtTaskReq);
                $("#" + taskConfig.inputArea).show();
                $("#" + taskConfig.urlTaskInput).hide();
                $("#" + taskConfig.urlResultDisplayArea).hide();
                if (lastBtTaskReq && lastBtTaskReq == btTaskTips) {
                    that.setSubmitButtonStatus(false)
                } else {
                    that.setSubmitButtonStatus(true)
                }
                that.showSubmitTips(0);
                that.totalNumPanel("hide")
            });
            urlTaskCheckTimer = null;
            $("#" + taskConfig.urlTaskInput).focus(function () {
                if ($(this).val() == urlTaskTips) {
                    $(this).val("")
                }
                urlTaskCheckTimer = setInterval(function () {
                    that.queryNames()
                }, taskCheckTime)
            }).blur(function () {
                clearInterval(urlTaskCheckTimer);
                if ($(this).val() == "") {
                    $(this).val(urlTaskTips)
                }
            });
            $("#" + taskConfig.btTaskInput).focus(function () {
                if ($(this).val() == btTaskTips) {
                    $(this).val("")
                }
            }).blur(function () {
                if ($(this).val() == "") {
                    $(this).val(btTaskTips)
                }
            });
            $("#" + taskConfig.submitButton).unbind().click(function () {
                if (!isTaskValid) {
                    return false
                }
                that.showSubmitTips(1, taskTips.taskSubmiting);
                isTaskSubmiting = true;
                if (taskType == "url") {
                    that.submitUrlTask()
                } else {
                    that.submitBtTask()
                }
                return false
            });
            var addUrl = base.$PU("playurl") || "";
            addUrl = base.$PU("addurl") || addUrl;
            if (addUrl) {
                addUrl = base.decode(addUrl);
                var addname = "";
                if (base.$PU("addname")) {
                    addname = base.$PU("addname")
                }
                addname = base.decode(addname);
                var qureyData = {
                    urls: []
                };
                obj = {
                    id: 1,
                    url: base.encode(addUrl),
                    name: base.encode(addname)
                };
                qureyData.urls.push(obj);
                qureyData = JSON.stringify(qureyData);
                that.doAddTask(qureyData, that.doAddTaskDone, that.doAddTaskError)
            }
        },
        queryNames: function () {
            var that = this;
            curBatchTaskReqUrls = "";
            var curBatchTaskReqUrls = $("#" + taskConfig.urlTaskInput).val().trim();
            if (lastUrlTaskReqUrls && lastUrlTaskReqUrls == curBatchTaskReqUrls) {
                return false
            }
            that.showSubmitTips(0);
            lastUrlTaskReqUrls = curBatchTaskReqUrls;
            if (!curBatchTaskReqUrls) {
                $("#" + taskConfig.urlResultDisplayArea).html("").hide();
                that.updateSubmitButtonStatus();
                return false
            }
            var curArrUrls = curBatchTaskReqUrls.split("\n");
            var curReqNum = curArrUrls.length;
            var reqDatas = [];
            var legalDatas = [];
            curBatchTaskReqResult = [];
            var resultHtml = "<ul>";
            var id = 0;
            for (var i = 0; i < curReqNum; i++) {
                var curUrl = curArrUrls[i];
                if ($.trim(curUrl)) {
                    if (id >= taskConfig.maxUrlNum) {
                        that.showSubmitTips(2, taskTips.taskNumTooMany);
                        break
                    }
                    var errorTip = "";
                    var validUrl = that.getValidUrl(curUrl);
                    var sameUrl = that.inLastRequest(curUrl, reqDatas);
                    if (sameUrl) {
                        curBatchTaskReqResult.push({
                            id: id,
                            url: encodeURIComponent(curUrl),
                            name: taskTips.taskRepeat,
                            result: -1
                        })
                    } else {
                        if (validUrl) {
                            var lastItem = that.inLastRequest(encodeURIComponent(validUrl), lastBatchTaskReqResult);
                            if (lastItem) {
                                curBatchTaskReqResult.push({
                                    id: id,
                                    url: lastItem.item.url,
                                    name: lastItem.item.name,
                                    result: lastItem.item.result
                                })
                            } else {
                                legalDatas.push({
                                    id: id,
                                    url: encodeURIComponent(validUrl)
                                })
                            }
                        } else {
                            curBatchTaskReqResult.push({
                                id: id,
                                url: curUrl,
                                name: taskTips.urlInputError,
                                result: 6
                            })
                        }
                    }
                    resultHtml += '<li index="' + id + '"><input type="checkbox"  value="" disabled="true" name="checkitem" class="c_b" ><input disabled="true" name="filename" class="i_p" type="text" value=""></li>';
                    reqDatas.push({
                        id: id,
                        url: curUrl
                    });
                    id++
                }
            }
            resultHtml += "</ul>";
            $("#" + taskConfig.urlResultDisplayArea).html(resultHtml);
            if (legalDatas.length > 0) {
                that.showSubmitTips(1, taskTips.taskQueryinng);
                that.setSubmitButtonStatus(false);
                var url = gISERVER + "req_video_name?from=" + from + "&platform=" + isIpad;
                that.vodPost(url, JSON.stringify({
                    urls: legalDatas
                }), that.queryNamesDone, that.queryNamesError)
            } else {
                that.queryNamesDone({
                    resp: {
                        ret: 0,
                        res: curBatchTaskReqResult,
                        local: 1
                    }
                })
            }
            $("#" + taskConfig.urlResultDisplayArea).scrollTop(100000)
        },
        queryNamesError: function () {
            $("#" + taskConfig.urlResultDisplayArea).html("").hide();
            gTask.setSubmitButtonStatus(false);
            gTask.showSubmitTips(2, taskTips.timeout)
        },
        queryNamesDone: function (resp) {
            var that = gTask;
            that.showSubmitTips(0, "", 1);
            var resultHtml = "";
            var resp = resp.resp;
            if (resp) {
                var ret = resp.ret;
                var res = resp.res;
                if (ret == 0) {
                    if (res.length > 0) {
                        if (!resp.local) {
                            curBatchTaskReqResult = curBatchTaskReqResult.concat(resp.res)
                        }
                        var resultNum = curBatchTaskReqResult.length;
                        for (var i = 0; i < resultNum; i++) {
                            var item = curBatchTaskReqResult[i];
                            var itemLi = $("#" + taskConfig.urlResultDisplayArea + " li[index=" + item.id + "]");
                            var filenameInput = itemLi.find('input[name="filename"]');
                            var checkitem = itemLi.find('input[name="checkitem"]');
                            if (item.result == 0) {
                                var nameExt = base.getNameExt(that.decode(item.name));
                                filenameInput.val(nameExt.name);
                                filenameInput.removeAttr("disabled");
                                filenameInput.attr("ext", nameExt.ext).attr("oriName", nameExt.name);
                                checkitem.attr("checked", "checked");
                                checkitem.removeAttr("disabled")
                            } else {
                                var errorMsg = taskTips.urlInputError;
                                if (item.result == 8) {
                                    errorMsg = taskTips.urlNotVideo
                                } else {
                                    if (item.result == -1) {
                                        errorMsg = taskTips.taskRepeat
                                    }
                                }
                                checkitem.removeAttr("checked");
                                filenameInput.after("<p " + taskConfig.errorFlagValue + '="' + taskConfig.errorFlag + '" class="err_tip1"><span>！</span>' + errorMsg + "</p>")
                            }
                        }
                        $("#" + taskConfig.urlResultDisplayArea).show()
                    } else {
                        if ($("#" + taskConfig.urlResultDisplayArea + " li").length > 0) {
                            $("#" + taskConfig.urlResultDisplayArea).show()
                        }
                    }
                } else {
                    $("#" + taskConfig.urlResultDisplayArea).html("").hide();
                    gTask.showSubmitTips(2, taskTips.svrError)
                }
            }
            var items = $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checkbox");
            var input = items.find("input:text");
            input.bind("keyup", that.verifyNameInput);
            input.bind("blur", that.verifyNameInput);
            that.updateSubmitButtonStatus();
            items = items.find("input:checkbox").unbind("click").bind("click", that.updateSubmitButtonStatus);
            that.totalNumPanel("show")
        },
        doAddTask: function (data, success, error) {
            if (data == undefined || success == undefined) {
                return -1
            }
            base.stat({
                from: "vodlist",
                p: "vodlist",
                f: "tasktype",
                ty: taskType,
                num: (taskType == "url" && $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checked").length > 0) ? $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checked").length : 1
            });
            var that = this;
            var userid = that.getCookie("userid");
            var sessionid = that.getCookie("sessionid");
            var url = gISERVER + "req_add_record?from=" + from + "&platform=" + isIpad + "&userid=" + userid + "&sessionid=" + sessionid;
            that.vodPost(url, data, success, error)
        },
        doAddTaskError: function () {
            gTask.showSubmitTips(2, taskTips.timeout);
            isTaskSubmiting = false
        },
        doAddTaskDone: function (data) {
            isTaskSubmiting = false;
            var that = gTask;
            if (data.resp) {
                var ret = data.resp.ret;
                var _errorMsg = "";
                if (ret == 0) {
                    var _res = data.resp.res;
                    var _len = _res.length;
                    for (var i = 0; i < _len; i++) {
                        if (_res[i].result == 0) {
                            window.parent.location = "http://" + window.parent.location.host + "/list.html";
                            return false
                        } else {
                            if (_res[i].result == 8) {
                                if (taskType == "url") {
                                    _errorMsg = taskTips.urlNotVideo
                                } else {
                                    _errorMsg = taskTips.btNotVideo
                                }
                            } else {
                                if (_res[i].result == 6 || _res[i].result == 2) {
                                    _errorMsg = taskTips.paramError
                                } else {
                                    _errorMsg = taskTips.svrError
                                }
                            }
                        }
                    }
                    if (_len > 1) {
                        _errorMsg = taskTips.taskContainsError
                    }
                    that.showSubmitTips(2, _errorMsg)
                } else {
                    if (ret == 1) {
                        _errorMsg = taskTips.userInfoError;
                        gList.goHomePage("sidExpired")
                    } else {
                        if (ret == 3) {
                            _errorMsg = taskTips.timeout
                        } else {
                            _errorMsg = taskTips.svrError
                        }
                    }
                    that.showSubmitTips(2, _errorMsg)
                }
            } else {
                that.showSubmitTips(2, taskTips.svrError)
            }
        },
        submitUrlTask: function () {
            var that = gTask;
            var error_items = $("li").has("p[class=" + taskConfig.errorFlagValue + "]");
            error_items.remove();
            var items = $("#" + taskConfig.urlResultDisplayArea + " li").has('input:checked="checked"');
            var inputs = items.find("input:text");
            var len = items.length;
            if (len == 0) {
                return
            }
            var error = 0;
            inputs.each(function () {
                var ret = that.verifyNameInput.call(this);
                if (ret != 0) {
                    error = 1
                }
            });
            if (error == 1) {
                return
            }
            var srcData = curBatchTaskReqResult;
            var qureyData = {
                urls: []
            };
            for (var i = 0; i < len; ++i) {
                var num = items.eq(i).attr("index");
                var name = items.eq(i).find("input:text").val();
                name = $.trim(name);
                if (items.eq(i).find("input:text").attr("ext")) {
                    name = name + "." + items.eq(i).find("input:text").attr("ext")
                }
                var _len = srcData.length;
                var obj = null;
                for (var _i = 0; i < _len; _i++) {
                    if (num == srcData[_i].id) {
                        obj = {
                            id: srcData[_i].id,
                            url: srcData[_i].url,
                            name: base.encode(name)
                        };
                        break
                    }
                }
                qureyData.urls.push(obj)
            }
            qureyData = JSON.stringify(qureyData);
            that.setSubmitButtonStatus(false);
            that.doAddTask(qureyData, that.doAddTaskDone, that.doAddTaskError)
        },
        genUploadButton: function (containerId, uploaderPath, config, width, height) {
            if (isIpad || !containerId || !uploaderPath) {
                return false
            }
            var p = [];
            for (var i in config) {
                p.push(i + "=" + config[i])
            }
            var flashvars = p.join("&");
            var width = width || 100;
            var height = height || 40;
            var params = {
                wmode: "transparent",
                allowScriptAccess: "always",
                flashvars: flashvars
            };
            var attributes = {
                id: "uploader",
                name: "uploader"
            };
            if (!isIpad) {
                var swfobjectBack = function () {
                    swfobject.embedSWF(uploaderPath, containerId, width, height, "9.0.0", "libaray/expressInstall.swf", flashvars, params, attributes)
                };
                $.ajax({
                    url: "http://vod.xunlei.com/library/swfobject.js",
                    dataType: "script",
                    cache: true,
                    success: swfobjectBack
                })
            }
        },
        setFilename: function (filename) {
            lastBtTaskReq = filename;
            $("#" + taskConfig.btTaskInput).val(filename);
            this.showSubmitTips(0);
            this.setSubmitButtonStatus(true)
        },
        submitBtTask: function () {
            this.setSubmitButtonStatus(false);
            document.getElementById("uploader").gTask_uploadFile()
        },
        uploadError: function (code, filename) {
            isTaskSubmiting = false;
            var msg = "";
            if (!isTaskValid) {
                return false
            }
            if (code == 6) {
                msg = taskTips.btUploadTimeout
            } else {
                if (code == 5) {
                    msg = taskTips.btTooLarge
                } else {
                    msg = taskTips.btUplaodFail
                }
            }
            this.showSubmitTips(2, msg);
            this.setSubmitButtonStatus(false)
        },
        uploadSuccess: function (result, filename) {
            var that = this;
            var errorMsg = taskTips.svrError;
            if (result) {
                eval("var resp = " + result + ";");
                var ret = resp.ret;
                if (ret == 0 && resp.infohash.length == 40) {
                    qureyData = JSON.stringify({
                        urls: [{
                            id: "1",
                            url: "bt://" + resp.infohash
                        }]
                    });
                    that.doAddTask(qureyData, that.doAddTaskDone, that.doAddTaskError);
                    return false
                } else {
                    if (ret == 2) {
                        errorMsg = taskTips.paramError
                    } else {
                        if (ret == 6) {
                            errorMsg = taskTips.btParseError
                        }
                    }
                }
            } else {
                errorMsg = taskConfig.btUplaodFail
            }
            this.showSubmitTips(2, errorMsg)
        },
        decode: function (str) {
            var r = "";
            try {
                r = decodeURIComponent(decodeURIComponent(str))
            } catch (e) {
                try {
                    r = decodeURIComponent(str)
                } catch (e) {
                    r = str
                }
            }
            return r
        },
        getCookie: function (name) {
            return (document.cookie.match(new RegExp("(^" + name + "| " + name + ")=([^;]*)")) == null) ? "" : RegExp.$2
        },
        resetTaskVal: function () {
            var that = this;
            isTaskValid = true;
            taskType = "url";
            lastBtTaskReq = btTaskTips;
            lastUrlTaskReqUrls = urlTaskTips;
            if (isIpad) {
                $("#" + taskConfig.btTaskButton).hide()
            }
            $("#" + taskConfig.btTaskButton).removeClass(taskConfig.onStyle);
            $("#" + taskConfig.urlTaskButton).addClass(taskConfig.onStyle);
            that.showSubmitTips(0);
            that.setSubmitButtonStatus(false);
            $("#" + taskConfig.btTaskInput).val(btTaskTips);
            $("#" + taskConfig.inputArea).hide();
            $("#" + taskConfig.urlResultDisplayArea).html("").hide();
            $("#" + taskConfig.urlTaskInput).val(urlTaskTips).show();
            that.totalNumPanel("init")
        },
        showSubmitTips: function (type, msg, keepErrorTips) {
            var msg = msg || "";
            if (type == "undefined" || type == null) {
                type = 0
            }
            if (type == 0) {
                $("#" + taskConfig.waitingTips).hide();
                if (!keepErrorTips) {
                    $("#" + taskConfig.errorTips).html("").hide()
                }
            } else {
                if (type == 1) {
                    if (!keepErrorTips) {
                        $("#" + taskConfig.errorTips).html("").hide()
                    }
                    $("#" + taskConfig.waitingTips).html("").html(msg).show()
                } else {
                    if (type == 2) {
                        if (!keepErrorTips) {
                            $("#" + taskConfig.waitingTips).hide()
                        }
                        $("#" + taskConfig.errorTips).html("").html(msg).show()
                    }
                }
            }
        },
        genProxy: function () {
            $("body").append("<iframe id='" + taskConfig.proxyId + "' name='" + taskConfig.proxyName + "' src='" + taskConfig.porxyPath + "' width='0' height='0' style='display:none;'></iframe>");
            taskConfig.proxy = document.getElementById(taskConfig.proxyId).contentWindow
        },
        vodPost: function (url, data, success, error) {
            taskConfig.proxy.$.ajax({
                type: "POST",
                dataType: "json",
                url: url,
                data: data,
                timeout: timeoutTime,
                error: function () {
                    error()
                },
                success: function (resp) {
                    success(resp)
                }
            })
        },
        inLastRequest: function (url, lastReqResult) {
            if (!lastReqResult || typeof (lastReqResult) != "object" || lastReqResult.length < 1) {
                return false
            }
            var len = lastReqResult.length;
            for (var i = 0; i < len; i++) {
                if (lastReqResult[i].url == url) {
                    return {
                        index: i,
                        item: lastReqResult[i]
                    }
                }
            }
            return false
        },
        getValidUrl: function (url) {
            if (!url) {
                return false
            }
            var regString = "xlpan://|thunder://|ftp://|http://|https://|ed2k://|mms://|magnet:|rtsp://|flashget://|qqdl://|bt://|xlpan%3A%2F%2F|thunder%3A%2F%2F|ftp%3A%2F%2F|http%3A%2F%2F|https%3A%2F%2F|ed2k%3A%2F%2F|mms%3A%2F%2F|magnet%3A|rtsp%3A%2F%2F|flashget%3A%2F%2F|qqdl%3A%2F%2F|bt%3A%2F%2F";
            var url = $.trim(url);
            var pattern = new RegExp("(" + regString + ").*", "i");
            if (!url.match(pattern)) {
                return false
            }
            if (url.match(/magnet.*/i)) {
                return url
            }
            var regStringShort = "xlpan|thunder|ftp|http|https|ed2k|mms|magnet|rtsp|flashget|qqdl|bt";
            var pattern0 = new RegExp("(" + regStringShort + ").*[?](" + regStringShort + ").*", "i");
            var result = url.match(pattern0);
            if (!result) {
                var pattern1 = new RegExp("((" + regStringShort + ").*?)((" + regString + ").*)", "i");
                result = url.match(pattern1)
            } else {
                var pattern2 = new RegExp("((" + regStringShort + ").*[?](" + regStringShort + ").*?)((" + regString + ").*)", "i");
                result = url.match(pattern2)
            } if (result && result[1]) {
                return result[1]
            } else {
                return url
            }
        },
        verifyName: function (str) {
            var errorMsg;
            errorMsg = 0;
            var patrn = /^[^`~!@#$%^&*+=|\\:;'"/?<>]{1}[^`~!@#$%^&*+=|\\:;'"\/?<>]{0,}$/;
            if (!patrn.exec(str)) {
                errorMsg = "！检测到非法字符( `~!@#$%^&*+=|\\:;'\"/?<> )"
            }
            if ($.trim(str).length < 1) {
                errorMsg = "请先输入文件名"
            }
            if (str.length > 50) {
                errorMsg = "文件名不能超过50个字符"
            }
            return errorMsg
        },
        updateSubmitButtonStatus: function () {
            var that = gTask;
            var btn = $("#" + taskConfig.submitButton);
            var checkeds = $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checked");
            var errors = $("li").has("p[class=" + taskConfig.errorFlagValue + "]");
            if (checkeds.length > 0 && errors.length == 0) {
                that.setSubmitButtonStatus(true)
            } else {
                that.setSubmitButtonStatus(false)
            }
            that.totalNumPanel("show")
        },
        setSubmitButtonStatus: function (flag) {
            if (flag == false) {
                $("#" + taskConfig.submitButton).addClass(taskConfig.submitButtonDisableStyle);
                isTaskValid = false
            } else {
                $("#" + taskConfig.submitButton).removeClass(taskConfig.submitButtonDisableStyle);
                isTaskValid = true
            }
        },
        verifyNameInput: function () {
            var that = gTask;
            var ret = 0;
            var str = $(this).val();
            if (str != $(this).attr("oriName")) {
                ret = that.verifyName(str)
            }
            var li = $(this).parent();
            if (li.next().find("p").attr("class") == taskConfig.errorFlagValue) {
                li.next().remove()
            }
            if (ret != 0) {
                var html = "<li><p class='" + taskConfig.errorFlagValue + "'>" + ret + "</p></li>";
                li.after(html)
            }
            that.updateSubmitButtonStatus();
            return ret
        },
        totalNumPanel: function (cmd) {
            var totalNumPanel = $("#" + taskConfig.totalNumPanel);
            var totalNumPanelLink = totalNumPanel.find("a");
            var resultDisplayArea = $("#" + taskConfig.urlResultDisplayArea);
            var checkeds;
            var toFold = function () {
                totalNumPanelLink.removeClass("up_arr").addClass("down_arr").text("展开");
                resultDisplayArea.hide();
                foldState = true
            };
            var toUnfold = function () {
                totalNumPanelLink.removeClass("down_arr").addClass("up_arr").text("收起");
                resultDisplayArea.show();
                foldState = false
            };
            var toggle = function () {
                if (foldState) {
                    toUnfold();
                    base.stat({
                        b: "addtask_tounfold",
                        p: "vodlist"
                    })
                } else {
                    toFold();
                    base.stat({
                        b: "addtask_tofold",
                        p: "vodlist"
                    })
                }
            };
            switch (cmd) {
            case "init":
                totalNumPanelLink.unbind("click").bind("click", toggle);
                totalNumPanel.hide();
                if (window.screen.height < 768) {
                    foldState = true
                } else {
                    foldState = false
                }
                break;
            case "show":
                var li = resultDisplayArea.find("li");
                var checkeds = li.has("input:checked");
                var num = checkeds.length;
                if (li.length == 0) {
                    totalNumPanel.hide();
                    return
                }
                if (foldState) {
                    toFold()
                } else {
                    toUnfold()
                }
                totalNumPanel.find("span").text("共" + num + "个视频");
                totalNumPanel.show();
                break;
            case "hide":
                totalNumPanel.hide();
                break
            }
        }
    };
    return prototype
})();
