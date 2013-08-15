define("app/list/1.0.0/list", ["./task", "gallery/jquery/1.0.0/jquery", "common/login/1.0.0/login", "common/base/1.0.0/base", "common/loc-store/1.0.0/loc-store", "common/placeholder/1.0.0/placeholder", "gallery/pagination/1.0.0/pagination", "gallery/hashchange/1.0.0/hashchange", "gallery/ace-template/1.0.0/ace-template", "common/top-notice/1.0.0/top-notice"], function (require) {
    var $ = require("gallery/jquery/1.0.0/jquery"),
        jQuery = $,
        Login = require("common/login/1.0.0/login"),
        base = require("common/base/1.0.0/base"),
        locStore = require("common/loc-store/1.0.0/loc-store"),
        gTask = require("./task"),
        pagination = require("gallery/pagination/1.0.0/pagination"),
        hash = require("gallery/hashchange/1.0.0/hashchange"),
        AceTemplate = require("gallery/ace-template/1.0.0/ace-template"),
        topNotice = require("common/top-notice/1.0.0/top-notice");
    (function (a) {
        var b = "http://i.vod.xunlei.com",
            c = "#proxy_i",
            d = a,
            e = 3e4,
            f = 5e3,
            g = {
                init: function () {
                    d = $(c)[0].contentWindow
                },
                send: function (a) {
                    return a.url = encodeURI(a.url), d.$.ajax(a)
                },
                checkUserInfo: function (a) {
                    var c = function (b) {
                        4 == b.result && a("sidExpired"), a("")
                    }, d = function () {
                            a("")
                        }, e = [b, "check_user_info"];
                    e = e.join("/");
                    var f = {
                        userid: base.getCookie("userid"),
                        sessionid: base.getCookie("sessionid"),
                        ip: "0",
                        from: "vodlist",
                        t: (new Date).getTime()
                    }, g = {
                            url: e,
                            dataType: "json",
                            data: f,
                            timeout: 5e3,
                            error: d,
                            success: c
                        }, h = this.send(g);
                    return h
                },
                getUserFlux: function (a, c) {
                    var d = [b, "flux_query", "userid", base.getCookie("userid"), "sessionid", base.getCookie("sessionid")];
                    d = d.join("/");
                    var f = {
                        t: (new Date).getTime()
                    }, g = {
                            url: d,
                            dataType: "json",
                            data: f,
                            processData: !0,
                            timeout: e,
                            error: c,
                            success: a
                        }, h = this.send(g);
                    return h
                },
                getHistoryList: function (a) {
                    var c = this,
                        d = a.typeName,
                        f = a.num,
                        g = a.offset,
                        h = a.success,
                        i = a.fail,
                        j = e;
                    a.timeout && (j = a.timeout);
                    var k = [b, "req_history_play_list", "req_num", f, "req_offset", g];
                    k = k.join("/");
                    var l = {
                        type: d,
                        order: a.order,
                        t: (new Date).getTime()
                    };
                    "" !== a.startDate && (l.start_t = a.startDate), "" !== a.endDate && (l.end_t = a.endDate);
                    var m = {
                        url: k,
                        dataType: "json",
                        data: l,
                        processData: !0,
                        timeout: j,
                        error: i,
                        success: function (b) {
                            b = c.fileDataFormat({
                                typeName: d,
                                data: b,
                                order: a.order
                            }), h(b)
                        }
                    }, n = this.send(m);
                    return n
                },
                getSubBtList: function (a) {
                    var c = this,
                        d = a.typeValue,
                        f = a.num,
                        g = a.offset,
                        h = a.success,
                        i = a.fail,
                        j = [b, "req_subBT", "info_hash", d, "req_num", f, "req_offset", g];
                    j = j.join("/");
                    var k = {
                        url: j,
                        dataType: "json",
                        processData: !0,
                        timeout: e,
                        error: i,
                        success: function (b) {
                            b = c.fileDataFormat({
                                typeName: "BtFolder",
                                data: b,
                                order: a.order,
                                createTime: a.createTime,
                                playTime: a.playTime
                            }), h(b)
                        }
                    }, l = this.send(k);
                    return l
                },
                getLixianList: function (a) {
                    var c = this,
                        d = {
                            offset: 0,
                            num: 30,
                            success: function () {},
                            fail: function () {}
                        }, a = $.extend(d, a),
                        f = [b, "req_lxtask_list"];
                    f = f.join("/");
                    var g = {
                        userid: base.getCookie("userid"),
                        name: base.getCookie("usrname"),
                        newno: base.getCookie("usernewno"),
                        vip: base.getCookie("isvip"),
                        ip: "",
                        sessionid: base.getCookie("sessionid"),
                        from: 0
                    }, h = {
                            user_info: g,
                            offset: a.offset,
                            req_num: a.num,
                            req_type: 2,
                            fileattribute: 1,
                            t: (new Date).getTime()
                        }, i = h;
                    i = JSON.stringify(i);
                    var j = {
                        url: f,
                        type: "POST",
                        dataType: "json",
                        data: i,
                        timeout: e,
                        error: a.fail,
                        success: function (b) {
                            b = c.lixianDataFormat({
                                typeName: "lixian",
                                data: b
                            }), a.success(b)
                        }
                    }, k = this.send(j);
                    return k
                },
                fileDataFormat: function (b) {
                    var c = {
                        typeName: "",
                        data: {},
                        order: "",
                        createTime: "--",
                        playTime: "--"
                    };
                    b = $.extend(c, b);
                    var d = b.typeName,
                        e = b.data,
                        f = b.order;
                    e = e.resp;
                    var g = {
                        type: "Folder",
                        typeName: d,
                        totalNum: e.record_num,
                        limitNum: e.max_num,
                        list: [],
                        ret: 0
                    };
                    if ("all" == d && ("undefined" == typeof g.totalNum || "undefined" == typeof g.limitNum ? gList.setListUsedInfo(-1, 0, 0) : gList.setListUsedInfo(1, g.totalNum, g.limitNum)), 0 != e.ret) return g.ret = e.ret, g;
                    if ("BtFolder" !== d) {
                        for (var h = e.history_play_list, i = [], j = 0; h.length > j; ++j) {
                            var k = h[j],
                                l = {
                                    url_hash: k.url_hash,
                                    src_url: base.decode(k.src_url),
                                    cid: k.cid,
                                    gcid: k.gcid,
                                    file_name: base.decode(k.file_name),
                                    file_size: k.file_size,
                                    duration: k.duration,
                                    from: k.from,
                                    createTime: k.createtime,
                                    playTime: k.playtime,
                                    playFlag: k.playflag,
                                    onefilebt: "Invalid",
                                    clarity: {
                                        srcInfo: k.gcidlist || [],
                                        enable: !1,
                                        liuchang: !1,
                                        gaoqing: !1,
                                        chaoqing: !1
                                    }
                                };
                            l.icoName = this.toIcoName(l.file_name);
                            var m = "File"; - 1 != l.src_url.search(/^bt:\/\//) && (m = "Folder", l.icoName = "bt_f"), l.typeName = d, l.type = m, l.shortName = this.toShortName(l.file_name, 30, 14, 12), l.listShortName = 1024 >= a.screen.width ? this.toShortName(l.file_name, 50, 30, 15) : this.toShortName(l.file_name, 88, 68, 15), l.thumbFileSize = this.toFileSize(l.file_size), l.picState = "None", l.picSrc = "", l.showIndex = j, l.showTime = "create" == f ? this.toDate(l.createTime) : this.toDate(l.playTime), l.progState = "Invalid", l.progScale = "Invalid";
                            var n = l.clarity.srcInfo.length;
                            n && $.each(l.clarity.srcInfo, function (a, b) {
                                if (b && b.specid) {
                                    var c = b.specid;
                                    if ("L" == c || "M" == c || "H" == c) {
                                        var d = {
                                            L: "liuchang",
                                            M: "gaoqing",
                                            H: "chaoqing"
                                        };
                                        l.clarity.enable = !0;
                                        var e = d[c];
                                        l.clarity[e] = !0
                                    }
                                }
                            }), void 0 == l.playFlag && (l.playFlag = "None");
                            var o = {
                                daikan: !1,
                                yikan: !1,
                                quxiaoyincang: !1,
                                yincang: !1,
                                yibo: !1
                            };
                            0 == (1 & l.playFlag) && (o.daikan = !0), 1 == (1 & l.playFlag) && (o.yikan = !0), 0 == (2 & l.playFlag) && (o.quxiaoyincang = !0), 2 == (2 & l.playFlag) && (o.yincang = !0), 4 == (4 & l.playFlag) && (o.yibo = !0), l.playFlag = o, l.duration = this.toPlayDuration(l.duration), i.push(l)
                        }
                        g.list = i
                    } else {
                        for (var h = e.subfile_list, i = [], j = 0; h.length > j; ++j) {
                            var k = h[j],
                                l = {
                                    url_hash: k.url_hash,
                                    gcid: k.gcid,
                                    file_name: base.decode(k.name),
                                    file_size: k.file_size,
                                    index: k.index,
                                    main_url_hash: e.main_task_url_hash,
                                    info_hash: e.info_hash,
                                    duration: k.duration,
                                    onefilebt: "Invalid",
                                    clarity: {
                                        srcInfo: k.gcidlist || [],
                                        enable: !1,
                                        liuchang: !1,
                                        gaoqing: !1,
                                        chaoqing: !1
                                    }
                                };
                            l.type = "File", l.typeName = "BtFile", l.picState = "None", l.picSrc = "", l.shortName = this.toShortName(l.file_name, 30, 14, 12), l.listShortName = 1024 >= a.screen.width ? this.toShortName(l.file_name, 50, 30, 15) : this.toShortName(l.file_name, 88, 68, 15), l.icoName = this.toIcoName(l.file_name), l.thumbFileSize = this.toFileSize(l.file_size), l.createTime = b.createTime, l.playTime = b.playTime, l.showTime = "create" == f ? this.toDate(l.createTime) : this.toDate(l.playTime), l.progState = "Invalid", l.progScale = "Invalid", l.screenshot = "None", l.showIndex = j;
                            var o = {
                                daikan: !1,
                                yikan: !1,
                                quxiaoyincang: !1,
                                yincang: !1
                            };
                            l.playFlag = o, l.thumbFileSize = this.toFileSize(l.file_size), l.duration = this.toPlayDuration(l.duration), i.push(l)
                        }
                        g.list = i
                    }
                    return g
                },
                lixianDataFormat: function (b) {
                    var c = {
                        typeName: "lixian",
                        totalNum: 0,
                        list: [],
                        ret: 0
                    }, d = b.data;
                    if (d.ret && 0 != d.ret) return c.ret = d.ret, c;
                    c.totalNum = d.task_total_cnt;
                    for (var e = d.tasklist, f = [], g = 0; e.length > g; ++g) {
                        var h = e[g],
                            i = {
                                url_hash: h.taskid,
                                src_url: base.decode(h.url),
                                cid: h.cid,
                                gcid: h.gcid,
                                file_name: base.decode(h.taskname),
                                file_size: h.filesize,
                                duration: 0,
                                from: "ipad_lixian",
                                createTime: "--",
                                playTime: "--",
                                playFlag: 0,
                                onefilebt: "Invalid",
                                clarity: {
                                    srcInfo: h.gcidlist || [],
                                    enable: !1,
                                    liuchang: !1,
                                    gaoqing: !1,
                                    chaoqing: !1
                                }
                            };
                        i.icoName = this.toIcoName(i.file_name);
                        var j = "File"; - 1 != i.src_url.search(/^bt:\/\//) && (j = "Folder", i.icoName = "bt_f"), i.typeName = b.typeName, i.type = j, i.shortName = this.toShortName(i.file_name, 30, 14, 12), i.listShortName = 1024 >= a.screen.width ? this.toShortName(i.file_name, 50, 30, 15) : this.toShortName(i.file_name, 88, 68, 15), i.thumbFileSize = this.toFileSize(i.file_size), i.picState = "None", i.picSrc = "", i.showIndex = g, i.showTime = this.toDate(i.createTime), i.progState = "Invalid", i.progScale = "Invalid", void 0 == i.playFlag && (i.playFlag = "None");
                        var k = {
                            daikan: !1,
                            yikan: !1,
                            quxiaoyincang: !1,
                            yincang: !1,
                            yibo: !1
                        };
                        0 == (1 & i.playFlag) && (k.daikan = !0), 1 == (1 & i.playFlag) && (k.yikan = !0), 0 == (2 & i.playFlag) && (k.quxiaoyincang = !0), 2 == (2 & i.playFlag) && (k.yincang = !0), 4 == (4 & i.playFlag) && (k.yibo = !0), i.playFlag = k, i.duration = this.toPlayDuration(i.duration), f.push(i)
                    }
                    return c.list = f, c
                },
                getList: function (a) {
                    var c = {
                        type: "Folder",
                        typeName: "all",
                        num: 18,
                        offset: 0,
                        success: function () {},
                        fail: function () {}
                    };
                    if (a = $.extend(c, a), "File" !== a.type) {
                        var d;
                        return d = "lixian" == a.typeName ? this.getLixianList(a) : "BtFolder" !== a.typeName ? this.getHistoryList(a) : this.getSubBtList(a)
                    }
                },
                deleteList: function (a, c, d, e) {
                    var g = [b, "req_del_list"];
                    g = g.join("/");
                    var h = base.getCookie("sessionid"),
                        i = {
                            flag: 0,
                            sessionid: h,
                            t: (new Date).getTime()
                        };
                    0 != a.length && (i.url_hash = a.join("/")), 0 != c.length && (i.info_hash = c.join("/"));
                    var j = {
                        url: g,
                        dataType: "json",
                        data: i,
                        processData: !0,
                        timeout: f,
                        error: e,
                        success: function (a) {
                            var b = a.resp.ret;
                            d(b)
                        }
                    };
                    this.send(j)
                },
                reqModifyType: function (a, c, d, e) {
                    var g = [b, "req_modify_type"];
                    g = g.join("/");
                    var h = c.join("/"),
                        i = base.getCookie("sessionid"),
                        j = base.getCookie("userid"),
                        k = {
                            type: a,
                            modify_list: h,
                            userid: j,
                            sessionid: i,
                            t: (new Date).getTime()
                        }, l = {
                            url: g,
                            dataType: "json",
                            data: k,
                            processData: !0,
                            timeout: f,
                            error: e,
                            success: function (a) {
                                var b = a.resp.ret;
                                d(b)
                            }
                        };
                    this.send(l)
                },
                getPics: function (a) {
                    var c = {
                        typeName: "BtFile",
                        gcids: [],
                        info_hash: "",
                        indexs: [],
                        success: function () {},
                        fail: function () {}
                    };
                    a = $.extend(c, a);
                    var d = [b, "req_screenshot"];
                    if (d = d.join("/"), "BtFile" !== a.typeName) var e = {
                        req_list: a.gcids.join("/")
                    };
                    else var e = {
                        info_hash: a.info_hash,
                        req_list: a.indexs.join("/")
                    };
                    e.t = (new Date).getTime();
                    var f = {
                        url: d,
                        dataType: "json",
                        data: e,
                        processData: !0,
                        success: function (b) {
                            var c = b.resp.ret;
                            0 === c ? a.success(b.resp.screenshot_list) : a.fail()
                        }
                    };
                    this.send(f)
                },
                doRenameFile: function (a) {
                    var c = a.urlHash,
                        d = a.newName,
                        e = b + "/req_rename?jsonp=?&url_hash=" + c + "&new_name=" + encodeURIComponent(d) + "&t=" + (new Date).getTime(),
                        g = {
                            url: e,
                            dataType: "json",
                            timeout: f,
                            success: function (b) {
                                a.success(a, b.resp)
                            },
                            error: function () {
                                a.error(a)
                            }
                        };
                    this.send(g)
                },
                getProgress: function (a) {
                    var c = {
                        idArr: [],
                        platform: isIpad,
                        success: function () {},
                        fail: function () {}
                    }, a = $.extend(c, a),
                        d = [b, "req_progress_query"];
                    d = d.join("/"), d = d + "?&t=" + (new Date).getTime();
                    var e = {
                        url_hash_list: a.idArr,
                        platform: a.platform
                    }, f = {
                            req: e
                        };
                    f = JSON.stringify(f);
                    var g = {
                        url: d,
                        type: "POST",
                        dataType: "json",
                        data: f,
                        success: function (b) {
                            var c = b.resp.ret;
                            0 === c ? a.success(b.resp.progress_info_list) : a.fail()
                        }
                    };
                    this.send(g)
                },
                getDownloadAddr: function (a) {
                    var c = {
                        gcid: "",
                        filename: "",
                        callback: function () {}
                    }, a = $.extend(c, a),
                        d = a.gcid,
                        e = a.filename,
                        f = a.callback,
                        g = function (a) {
                            f(a)
                        }, h = function () {
                            f({})
                        }, i = [b, "vod_dl_all"];
                    i = i.join("/");
                    var j = {
                        userid: base.getCookie("userid"),
                        gcid: d,
                        filename: base.encode(e),
                        t: (new Date).getTime()
                    }, k = {
                            url: i,
                            dataType: "json",
                            data: j,
                            processData: !0,
                            timeout: 5e3,
                            error: h,
                            success: g
                        }, l = this.send(k);
                    return l
                },
                getXLpanDWAddr: function (a) {
                    var c = {
                        url: "",
                        callback: function () {}
                    }, a = $.extend(c, a),
                        d = a.url,
                        e = a.callback,
                        f = function (a) {
                            a.url ? e(a.url) : e("")
                        }, g = function () {
                            e("")
                        }, h = [b, "vod_dl_xlpan"];
                    h = h.join("/");
                    var i = {
                        userid: base.getCookie("userid"),
                        url: base.encode(d),
                        t: (new Date).getTime()
                    }, j = {
                            url: h,
                            dataType: "json",
                            data: i,
                            processData: !0,
                            timeout: 5e3,
                            error: g,
                            success: f
                        }, k = this.send(j);
                    return k
                },
                toShortName: function (a, b, c, d) {
                    for (var e = 0, f = 0; a.length > e; ++e, ++f) a.charCodeAt(e) > 255 && ++f;
                    if (b >= f) return a;
                    for (var e = 0, f = 0; c > e; ++e, ++f) a.charCodeAt(f) > 255 && ++e;
                    for (var g = a.substr(0, f), e = 0, f = 0; d > e; ++e, ++f) {
                        var h = a.length - f - 1;
                        a.charCodeAt(h) > 255 && ++e
                    }
                    var i = a.substring(a.length - f);
                    return g + " ... " + i
                },
                toIcoName: function (a) {
                    var b = {
                        mkv: "mkv",
                        xv: "xv",
                        bt: "bt",
                        mp4: "mp4",
                        flv: "flv",
                        rm: "rm",
                        mpg: "mpg",
                        mov: "mov",
                        "3gp": "gp3",
                        wmv: "wmv",
                        avi: "avi",
                        f4v: "f4v",
                        ts: "ts",
                        asf: "asf",
                        mpeg: "mpeg",
                        m4v: "m4v",
                        vob: "vob",
                        rmvb: "rmvb"
                    }, c = a.match(/\.\w+$/g);
                    if (void 0 == c || 0 === c.length) return c = "add_i";
                    var c = c[0].substr(1);
                    return c = void 0 !== b[c] ? b[c] : "add_i"
                },
                toFileSize: function (a) {
                    var b = "--";
                    if (void 0 == a || 0 == a) return b;
                    var c = a / 1024;
                    return 1024 > c ? b = parseInt(c) + " K" : (c /= 1024, 1024 > c ? b = parseInt(c) + " M" : (c /= 1024, b = c.toFixed(2) + " G"))
                },
                toPlayDuration: function (a) {
                    var b = "--";
                    return void 0 == a || null == a ? (a = b, void 0) : (a /= 1e3, 0 == a ? a = b : a > 0 && 60 > a ? a = parseInt(a) + " 秒" : (a /= 60, a = 0 == a ? b : a > 600 ? b : parseInt(a) + " 分钟"), a)
                },
                toDate: function (a) {
                    var b = "--",
                        c = b;
                    return c = void 0 == a || null == a ? b : "None" == a ? "--" : a.substr(0, 10)
                },
                createBeforeDate: function (a) {
                    var b, c, d, e;
                    b = new Date, d = e = b.getTime();
                    var f = 864e5;
                    d = e - a * f, c = new Date(d);
                    var g, h, i, j;
                    return g = c.getFullYear(), h = c.getMonth() + 1, 10 > h && (h = "0" + h), i = c.getDate(), 10 > i && (i = "0" + i), j = g + "-" + h + "-" + i
                },
                transRemainTime: function (a) {
                    var b = a;
                    return a >= 0 && (b = a >= 3600 ? parseFloat(a / 3600).toFixed(1).toString() + "小时" : a >= 60 ? parseFloat(Math.floor(a / 60)).toFixed(0).toString() + "分钟" : a + "秒"), b
                },
                transRemainDay: function (a, b, c) {
                    if (!a || !b || !c) return -1;
                    var d = (new Date).getTime(),
                        e = new Date(a, b - 1, c).getTime(),
                        f = 864e5,
                        g = (e - d) / f;
                    return g = Math.ceil(g), 0 > g ? -1 : g
                },
                formatExpireDay: function (a, b, c) {
                    if (!a || !b || !c) return {
                        num: -1
                    };
                    var d = (new Date).getTime(),
                        e = 864e5,
                        f = new Date(a, b - 1, c).getTime(),
                        g = f + 30 * e,
                        h = new Date(g),
                        i = Math.ceil((g - d) / e),
                        j = {
                            num: d > f && i > 0 && 30 >= i ? i : -1,
                            m: h.getMonth() + 1,
                            d: h.getDate()
                        };
                    return j
                }
            };
        a.gData = g
    })(window),
    function (a) {
        var b = "listContent",
            c = "ListDataArea",
            d = null,
            e = {
                init: function () {
                    this.showClientDownlaod(), this.initAddFavorite(), "client" != base.getPlatForm() && (this.dropDownMenuInit(), this.searchBarInit(), this.addScroll())
                },
                add: function (a) {
                    var b = $("#" + c);
                    b.append(a)
                },
                empty: function () {
                    root = $("#listContent"), root.empty(), root.attr("class", "")
                },
                addListFrame: function (a) {
                    var c = $("#" + b);
                    if ("Thumb" === a) {
                        var d = AceTemplate.format("TplThumbFrame");
                        c.addClass("task_list"), c.append(d)
                    } else if ("List" === a) {
                        var d = AceTemplate.format("TplListFrame");
                        c.addClass("file_list"), c.append(d)
                    }
                },
                toListData: function (a, b) {
                    var c = b.list,
                        d = "",
                        e = "";
                    return "Thumb" == a ? e = "TplThumbMode" : "List" == a && (e = "TplListMode"), d = AceTemplate.format(e, c), d = $(d).not("text")
                },
                getElement: function (a) {
                    var b;
                    switch (a) {
                    case "MenuList":
                        b = $("#leftMenu a[name=menuLink]").parent();
                        break;
                    case "ThumbBtn":
                        b = $("#listCtrl a.thum");
                        break;
                    case "ListBtn":
                        b = $("#listCtrl a.list");
                        break;
                    case "HeapManageBtn":
                        b = $("#listCtrl a.manage");
                        break;
                    case "HeapManagePanel":
                        b = $("#heapManagePanel");
                        break;
                    case "ListWrap":
                        b = $("#listWrap");
                        break;
                    case "ListMain":
                        b = $("#listMain");
                        break;
                    case "ListContent":
                        b = $("#listContent");
                        break;
                    case "ListDataArea":
                        b = $("#ListDataArea");
                        break;
                    case "ListCheckBox":
                        b = $("#ListDataArea input:checkbox")
                    }
                    return b
                },
                showViewCtrlBtn: function (a) {
                    var b = this.getElement("ListBtn"),
                        c = this.getElement("ThumbBtn");
                    switch (a) {
                    case "List":
                        b.addClass("list_cur").css("cursor", "default"), c.removeClass("thum_cur").css("cursor", "pointer");
                        break;
                    case "Thumb":
                        b.removeClass("list_cur").css("cursor", "pointer"), c.addClass("thum_cur").css("cursor", "default")
                    }
                },
                showPics: function (a, b) {
                    b = b || "Req";
                    var c = "images/no_img.png";
                    "client" == base.getPlatForm() && (c = "../images/no_img.png");
                    for (var d = 0; a.length > d; d++) {
                        var e = a[d];
                        if ("Success" === e.picState)
                            if ("Req" == b) {
                                var f = e.url_hash;
                                $("#" + f).find("img[name=thumbImg]").attr("src", e.picSrc || c)
                            } else if ("Ping" == b) {
                            var g = e.picSrc || c;
                            g != c && (function () {
                                var a = e,
                                    b = e.url_hash,
                                    c = g,
                                    d = new Image;
                                d.onload = function () {
                                    $("#" + b).find("img[name=thumbImg]").attr("src", c), a.picState = "AllSuccess"
                                }, d.src = c
                            }(), e.picState = "Loding")
                        }
                    }
                },
                showHeapManage: function (a) {
                    var b = this.getElement("ListWrap"),
                        c = this.getElement("HeapManageBtn"),
                        d = this.getElement("HeapManagePanel"),
                        e = this.getElement("ListCheckBox");
                    switch (a) {
                    case "unManaging":
                        b.removeClass("heap_padding"), c.removeClass("invalid").attr("title", "批量管理").text("批量管理").removeClass("red"), d.hide(), e.hide();
                        break;
                    case "Managing":
                        b.addClass("heap_padding"), c.removeClass("invalid").attr("title", "退出管理").text("退出管理").addClass("red"), d.show(), e.attr("checked", !1), e.show();
                        break;
                    case "Invalid":
                        b.removeClass("heap_padding"), c.addClass("invalid").attr("title", "批量管理").text("批量管理").removeClass("red"), d.hide(), e.hide()
                    }
                },
                showBigTip: function (a) {
                    var b = this.getElement("ListMain"),
                        c = this.getElement("ListContent"),
                        d = b,
                        e = b.find("div.loading1"),
                        f = b.find("div.not_find"),
                        g = f.find("[name=content]"),
                        h = a.type || "List",
                        i = a.content || "服务器繁忙，请稍后重试";
                    switch (h) {
                    case "List":
                        e.hide(), f.hide(), d[0].scrollTop = 0, c.show();
                        break;
                    case "Loding":
                        c.hide(), f.hide(), d[0].scrollTop = 0, e.show();
                        break;
                    case "ListNotFind":
                        c.hide(), e.hide(), g.html(i), d[0].scrollTop = 0, f.show();
                        break;
                    case "PleaseTry":
                        c.hide(), e.hide(), g.html(i), d[0].scrollTop = 0, f.show()
                    }
                    var j = g.find("a");
                    j && 0 != j.length && (j.attr("href", "javascript:;"), j.click(function () {
                        return gList.retryLoadList(), !1
                    }))
                },
                showLittleTip: function (a) {
                    defaultOptions = {
                        toState: "show",
                        content: "正在加载",
                        time: 5,
                        showLoading: !1,
                        showMask: !1
                    }, a = $.extend(defaultOptions, a);
                    var b = $("#litteTip"),
                        c = b.find("img"),
                        e = $("#loadingMask");
                    return "hide" == a.toState ? (b.hide(), e.hide(), void 0) : (1 == a.showLoading ? c.show() : c.hide(), 1 == a.showMask ? e.show() : e.hide(), b.find("[name=text]").text(a.content), b.show(), clearTimeout(d), -1 != a.time && (d = setTimeout(function () {
                        b.hide()
                    }, 1e3 * a.time)), void 0)
                },
                showThumbProgress: function (a, b, c) {
                    var d = a.url_hash,
                        e = $("#" + d),
                        f = e.find("[name=state]"),
                        g = f.find("[name=progText]"),
                        h = f.find("[name=progErrorIcon]"),
                        i = e.find("[name=stateBar]"),
                        j = i.find("[name=stateBarContent]"),
                        k = 0,
                        l = {
                            0: "下载等待中",
                            1: "下载中",
                            2: "下载失败",
                            3: "转码等待中",
                            4: "转码中",
                            5: "转码完成",
                            6: "转码失败",
                            7: "完成",
                            8: "种子下载中",
                            9: "种子下载完成",
                            10: "链接不含视频",
                            11: "下载失败"
                        }, m = e.find("a[name=openLink]");
                    if (h.hide(), 5 == b || 7 == b || 9 == b) return f.hide(), i.hide(), m.css("cursor", "pointer").removeClass("nohover"), void 0;
                    if (m.css("cursor", "default").addClass("nohover"), 2 == b || 6 == b || 10 == b || 11 == b) return g.text(l[b]), h.show(), f.show(), i.hide(), void 0;
                    var n = "";
                    0 == b && (k = "0.00"), 3 == b && (k = "50.00"), 1 == b && (k = c / 100 / 2, k = k.toFixed(2)), 4 == b && (k = c / 100 / 2 + 50, k = k.toFixed(2)), 8 == b && (k = 0, k = k.toFixed(2), n = l[b]), n = n ? n : l[b] + "(" + k + "%)", g.text(n), f.show(), j.css("width", k + "%"), i.show()
                },
                showListProgress: function (a, b, c) {
                    var d = a.url_hash,
                        e = $("#" + d);
                    e.find("[name=stateBar]");
                    var g = 0,
                        h = {
                            0: "下载等待中",
                            1: "下载中",
                            2: "下载失败",
                            3: "转码等待中",
                            4: "转码中",
                            5: "转码完成",
                            6: "转码失败",
                            7: "完成",
                            8: "种子下载中",
                            9: "种子下载完成",
                            10: "链接不含视频",
                            11: "下载失败"
                        }, i = {
                            disArea: e.find("[name=progBarArea]"),
                            disBarText: e.find("[name=progBarText]"),
                            disNum: e.find("[name=progBarDisNum]"),
                            num: e.find("[name=progBarNum]"),
                            disText: e.find("[name=progText]")
                        }, j = a.icoName,
                        k = "error",
                        l = j + "_gray",
                        m = e.find("[name=icoArea]"),
                        n = e.find("[name=listPlayBtn]"),
                        o = e.find("a[name=openLink]"),
                        p = "red";
                    return m.removeClass(k), i.disBarText.removeClass(p), 5 == b || 7 == b || 9 == b ? (i.disNum.css("width", "100%"), i.num.text("100%"), i.disText.text(h[b]), i.disArea.hide(), "Folder" == a.type ? i.disBarText.text("--") : i.disBarText.text("100%"), i.disBarText.show(), m.removeClass(l).addClass(j), n.removeClass("disable_btn"), o.css("cursor", "pointer").removeClass("nohover"), void 0) : (m.removeClass(j).addClass(l), n.addClass("disable_btn"), o.css("cursor", "default").addClass("nohover"), 10 == b || 11 == b ? (i.disArea.hide(), m.removeClass(j).removeClass(l).addClass(k), i.disBarText.addClass(p).text(h[b]).show(), void 0) : (i.disArea.show(), i.disText.text(h[b]), i.disBarText.hide(), 2 == b || 6 == b ? (i.disNum.css("width", "0%"), i.num.text("0%"), void 0) : (0 == b && (g = "0.00"), 3 == b && (g = "50.00"), 1 == b && (g = c / 100 / 2, g = g.toFixed(2)), 4 == b && (g = c / 100 / 2 + 50, g = g.toFixed(2)), 8 == b && (g = 0, g = g.toFixed(2)), i.disNum.css("width", g + "%"), i.num.text(g + "%"), void 0)))
                },
                showListMenu: function (a, b) {
                    var d, f, c = {
                            all: ["all", "全部任务", "all", "全部任务"],
                            daikan: ["all", "全部任务", "daikan", "待看任务"],
                            yikan: ["all", "全部任务", "yikan", "已看任务"],
                            yincang: ["all", "全部任务", "yincang", "隐藏任务"],
                            recent: ["recent", "最近播放", "recent", "最近播放"],
                            rweek: ["recent", "最近播放", "rweek", "最近一周"],
                            rmonth: ["recent", "最近播放", "rmonth", "最近一月"],
                            omonth: ["recent", "最近播放", "omonth", "一个月前"],
                            lixian: ["lixian", "离线空间", "lixian", "离线空间"]
                        };
                    switch (a) {
                    case "daikan":
                    case "yikan":
                    case "yincang":
                    case "recent":
                    case "rweek":
                    case "rmonth":
                    case "omonth":
                    case "lixian":
                        d = c[a][3], f = a;
                        break;
                    case "all":
                    default:
                        d = c.all[3], f = "all"
                    }
                    var g = e.getElement("MenuList");
                    g.each(function () {
                        $(this).removeClass("nav_on")
                    }), g.has("a[listName=" + f + "]").addClass("nav_on");
                    var h = $("#menuPath"),
                        i = h.find("[name=secondFolder]"),
                        j = h.find("[name=lastFolder]");
                    "" != b ? (i.find("[name=content]").attr("title", d).text(d), i.find("a").unbind("click").bind("click", function () {
                        gList.selectMenu()
                    }), j.find("[name=content]").text(b), i.show(), j.show()) : (j.find("[name=content]").text(d), i.hide(), j.show());
                    var k = h.find("[name=firstFolder]");
                    if ("all" == a || "recent" == a || "lixian" == a) k.hide();
                    else {
                        var l = c[a][1];
                        k.find("[name=content]").attr("title", l).text(l), k.find("a").unbind("click").bind("click", function () {
                            var b = {
                                list: c[a][0]
                            };
                            gList.selectMenu(b)
                        }), k.show()
                    }
                },
                refreshSelectAll: function () {
                    var a = this.getElement("ListDataArea"),
                        b = a.find("input:checkbox"),
                        c = a.find("input:checked"),
                        d = this.getElement("HeapManagePanel").find("input:checkbox"),
                        e = this.getElement("HeapManagePanel").find("a[name=heapDelete], a[name=heapYinCang], span[name=heapMore]");
                    0 == c.length ? e.addClass("disable") : e.removeClass("disable"), 0 >= b.length || (b.length == c.length ? d.attr("checked", !0) : d.attr("checked", !1))
                },
                popConfirm: function (a) {
                    defaultOptions = {
                        type: "Default",
                        title: "提示",
                        content: "确认操作吗?",
                        callback: function () {}
                    }, a = $.extend(defaultOptions, a);
                    var b = $("#popConfirmLayer"),
                        c = $("#bgMask"),
                        d = b.find("[name=title]"),
                        e = b.find("[name=ico]"),
                        f = b.find("[name=content]"),
                        g = b.find("a[name=confirm]"),
                        h = b.find("a[name=close]");
                    "Delete" == a.type ? e.addClass("del_ico") : e.attr("class", ""), d.text(a.title), f.find("[name=text]").text(a.content), g.unbind("click").bind("click", function () {
                        b.hide(), c.hide(), a.callback()
                    }), h.unbind("click").bind("click", function () {
                        b.hide(), c.hide()
                    }), c.show(), b.show()
                },
                searchBarInit: function () {
                    var a = {
                        uid: base.getCookie("userid"),
                        from: "vodlist",
                        search: "brSearch",
                        callback: function () {
                            var a = $("#listCtrl"),
                                b = parseInt(a.css("right")) + 200;
                            a.css("right", b)
                        }
                    };
                    base.toggleSearchBar(a)
                },
                initAddFavorite: function () {
                    var a = $("#addFavor");
                    return base.checkEnv("iPad") ? (a.parent().hide(), void 0) : (a.unbind("click").bind("click", function () {
                        return base.addFavorite(), base.stat({
                            b: "collectOnTop",
                            p: "vodlist"
                        }), !1
                    }), void 0)
                },
                showClientDownlaod: function () {
                    $("#clientDLBtn").unbind("click").bind("click", function () {
                        var b = "http://down.sandai.net/Vod/XunleiCloudPlayer.exe";
                        return base.stat({
                            b: "lmClientDownload",
                            p: "vodlist",
                            from: "vodlist"
                        }), setTimeout(function () {
                            a.open(b, "_self")
                        }, 100), !1
                    })
                },
                dropDownMenuInit: function () {
                    $("#userSet").mouseenter(function () {
                        var a = $(this).next();
                        a.show().mouseleave(function () {
                            $(this).hide()
                        })
                    })
                },
                loadAppsEntry: function () {
                    if ("client" != base.getPlatForm()) {
                        var c = "page/appsEntry/index.html?v=1.0.0",
                            d = {}, e = $("#appsLayer"),
                            f = /\/\*_version_(\d+)\*\//g,
                            g = /\/\*_style_start_\*\/([\s\S]+)\/\*_style_end_\*\//g,
                            h = /<body>([\s\S]+)<\/body>/g,
                            i = "_apps_link_btn",
                            j = parseInt(e.css("top")),
                            k = parseInt(e.css("right"));
                        base.attachEvent("AppLayerPosEvent", function () {
                            if (arguments[2]) {
                                var a = arguments[2],
                                    b = $("#common_notice_layer").outerHeight(),
                                    c = 1 == a.diry ? b : 0,
                                    e = 1 == a.dirx ? 100 : 0;
                                d.addjustPosition(e, c)
                            }
                        }), d.init = function (a) {
                            var b = e,
                                d = parseInt(a),
                                f = 0,
                                g = $("#appsEntry").next(),
                                h = !0,
                                i = base.getCookie("userid"),
                                j = function () {
                                    var a = {};
                                    a[i] = {
                                        ver: d,
                                        ldate: (new Date).getTime()
                                    }, locStore.storeData({
                                        appsEntryInfo: a
                                    }), j = null
                                };
                            try {
                                f = locStore.getStoredData("appsEntryInfo")[i].ver, "undefined" != typeof f && (h = !1), f = f || 0
                            } catch (k) {}
                            return d > f && (h ? (b.show(), g.hide(), j && j()) : (b.hide(), g.show())), $("#appsEntry").unbind("click").bind("click", function () {
                                b.toggle(), g.hide(), d > f && j && j(), base.stat({
                                    b: "appsEntryBtn",
                                    from: "vodlist"
                                })
                            }), $("#clsEntry").unbind("click").bind("click", function () {
                                b.hide()
                            }), this.addjustPosition()
                        }, d.loadStyles = function (a) {
                            var b;
                            a = a.replace(/url\(/gi, "url(page/appsEntry/");
                            try {
                                b = document.createStyleSheet(), b.cssText = a
                            } catch (c) {
                                b = document.createElement("style"), b.type = "text/css", $("head")[0].appendChild(b), b.textContent = a
                            }
                            return this
                        }, d.parseContents = function (a, b) {
                            var c = /(_ID_APP_)(\d*)/g,
                                a = "string" == typeof a ? $("#" + a) : a;
                            return a[0].innerHTML = b.replace(c, function (a, b, c) {
                                return c ? i + c : i
                            }), this
                        }, d.parseLinks = function () {
                            var e = $("." + i).unbind("click").bind("click", function () {
                                var c = $(this),
                                    d = c.attr("href"),
                                    e = c.attr("target"),
                                    f = c.attr("stat");
                                return base.stat({
                                    b: f,
                                    p: "vodlist",
                                    from: "vodlist"
                                }), "_self" == e ? setTimeout(function () {
                                    a.open(d, e)
                                }, 100) : a.open(d, e), !1
                            });
                            return e.size(), this
                        }, d.addjustPosition = function (a, b) {
                            var c = e;
                            return a = a || 0, b = b || 0, j ? c.css("top", j + b) : (j = c.offset().top) && c.css("top", j + b), k ? c.css("right", k + a) : (k = c.offset().left) && c.css("right", k + a), this
                        }, $.get(c, function (a) {
                            var b = g.exec(a)[1],
                                c = h.exec(a)[1],
                                e = f.exec(a)[1];
                            d.init(e).loadStyles(b).parseContents("appLayerContainer", c).parseLinks()
                        })
                    }
                },
                addScroll: function () {
                    function h() {
                        var a = arguments.callee;
                        document.readyState.match(/complete/gi) ? j() : setTimeout(a, c)
                    }

                    function j() {
                        (d && "4" > d[0].split(" ")[1] || e) && ($("#listWrap").wrap(function () {
                            return '<div id="' + f + '" style="width:100%;"/>'
                        }), require.async(g, function (a) {
                            b = new a.iScroll(f)
                        }))
                    }
                    var b = "",
                        c = 450,
                        d = navigator.userAgent.match(/Android\s[^\;]+/g),
                        e = /HTC_EVO3D_X515m/g.test(navigator.userAgent),
                        f = "scrollWrap",
                        g = "http://vod.xunlei.com/js/gallery/iscroll/1.0.0/iscroll.js";
                    h()
                }
            };
        a.gListUI = e
    }(window),
    function (window) {
        var listState = {
            type: "",
            typeName: "",
            mode: "Thumb",
            heapManage: "Invalid",
            data: {},
            totalNum: 0,
            offset: 0,
            perPageNum: 30,
            limitTotalNum: 9e3,
            listName: "all",
            folderName: "",
            order: "commit",
            startDate: "",
            endDate: "",
            pickupState: !1,
            lastLoadConfig: ""
        }, localLoginObj = {}, listConfig = {
                picMode: "Ping"
            }, queueHide = [],
            lastListAjax, lastGetlistUsedAjax, homePageUrl = "http://vod.xunlei.com",
            vodUserInfo = {
                userid: base.getCookie("userid"),
                usernick: base.decode(base.getCookie("usernick")),
                sessionid: base.getCookie("sessionid"),
                oriType: 0,
                type: 0 != base.getCookie("isvip") ? "vipUser" : "norUser",
                level: base.getCookie("isvip"),
                expire: "",
                fluxState: "init",
                fluxValue: -1,
                fluxDeadline: -1
            }, listUsedInfo = {
                ready: 0,
                useNum: 0,
                limitNum: 0
            }, pageInitTime = base.getInfo("pageInitTime") || 0,
            reqListMoment = 0,
            listDomReadyTime = 0,
            isIE = -1 != navigator.appVersion.indexOf("MSIE") ? !0 : !1,
            isClient = !1;
        if ("client" == base.getPlatForm() && (isClient = !0), isClient) {
            base.setGdCookie("cPrePage", "list", 2592e3), homePageUrl = "http://vod.xunlei.com/client/chome.html?list=clist", window.vodClientDragCallback = function (arr) {
                if (eval("var arr=" + arr + ";"), !(arr && 0 >= arr.length && arr[0])) {
                    var dragNum = arr.length;
                    base.stat({
                        f: "dragFromClient",
                        p: "vodClientList",
                        num: dragNum
                    }), $("#addTask").click();
                    for (var text = "", i = 0; arr.length > i; i++) {
                        var item = arr[i];
                        text += item.url + "\n"
                    }
                    $("#urlTaskInput").val(text).focus()
                }
            }, window.vodClientTabSwitch = function (a) {
                return "focus" == a && base.setGdCookie("cPrePage", "list", 2592e3), !0
            };
            try {
                window.external.setVodClientTab("list")
            } catch (e) {}
        }
        var gList = {
            hash: {
                list: "all",
                p: 1,
                folder: "",
                value: ""
            },
            hashAble: !0,
            LoginIint: function () {
                var a = this;
                pageInitTime && (listDomReadyTime = (new Date).getTime() - pageInitTime);
                var b = function () {
                    return base.isLogin() ? (a.pageInit(), a.genUserInfoPanel(), void 0) : (window.open(homePageUrl, "_self"), !1)
                }, c = function () {
                        return window.open(homePageUrl, "_self"), !1
                    };
                base.attachEvent("logosuccess", function () {
                    b()
                }).attachEvent("logout", function () {
                    if (isClient) {
                        try {
                            window.external.openVodClientWindow("player", "open", homePageUrl);
                            var a = "http://vod.xunlei.com/client/blank.html";
                            window.external.openVodClientWindow("list", "silent", a)
                        } catch (b) {}
                        return !1
                    }
                    c()
                }), localLoginObj = loginObj = Login.init().success(function () {
                    base.fireEvent("logosuccess")
                }).error(function (a, b) {
                    alert(b), $("#login_p").val("")
                }).valid(function (a) {
                    alert(a)
                }).logining(function () {}).autoerror(function () {
                    this.exit()
                }).logout(function () {
                    base.fireEvent("logout")
                }).userinfoloaded(function () {
                    var b = this.getuserinfo();
                    a.transUserInfo(b), a.showAds(), gListUI.loadAppsEntry(b)
                }).auto(), gData.checkUserInfo(function (b) {
                    "sidExpired" == b && a.goHomePage("sidExpired")
                })
            },
            goHomePage: function (a, b) {
                var c = "http://vod.xunlei.com/home.html",
                    d = "";
                if (isClient && (c = "http://vod.xunlei.com/client/chome.html"), ("sidExpired" == a || "logStateError" == a) && (d = c + "?t=" + (new Date).getTime() + "#action=" + a, b && (d = d + "&logErrCode=" + b)), d) {
                    if (isClient) {
                        try {
                            window.external.openVodClientWindow("player", "open", d)
                        } catch (e) {}
                        return
                    }
                    window.open(d, "_self")
                }
            },
            genUserInfoPanel: function () {
                var a = this;
                setTimeout(function () {
                    a.showUserInfo()
                }, 500), $("#funcExit").unbind("click").click(function (a) {
                    localLoginObj.exit(), a.stopPropagation()
                });
                var b = !1;
                $("#moreUserInfo").unbind().click(function (c) {
                    b ? ($("#userInfo1").hide(), b = !1) : ($("#userInfo1").show(), a.getAndShowFlux(), a.getListUsedInfo(), b = !0), c.stopPropagation(), gList.dropMenuQueue("add", function () {
                        b = !1, $("#userInfo1").hide()
                    })
                }), $("#userInfo").unbind().click(function (a) {
                    a.stopPropagation()
                })
            },
            transUserInfo: function (a) {
                var b = vodUserInfo;
                a && (b.oriType = a.oriType, b.type = a.type, b.level = a.level || b.level, b.expire = "------" != a.expire && (a.expire || ""), b.last_expire = "------" != a.last_expire && (a.last_expire || ""), this.getAndShowFlux())
            },
            showAds: function () {
                function g(a, b) {
                    isIpad ? base.showPayTutor() : "undefined" != typeof b ? window.open(a + "?referfrom=" + b) : window.open(a)
                }

                function h(e) {
                    return e.currentTarget !== d[0] ? (b = "http://pay.vip.xunlei.com/vod.html", g(b, a)) : (b = c[1], window.open(b)), !1
                }
                var a, b, c = ["img/topads.jpg", "http://act.vip.xunlei.com/vod_myyr/?from=vodlist"],
                    d = $("#headAds").hide(),
                    e = $("#bottomAds").hide(),
                    f = '<strong>加5元</strong>升级为白金会员，享4大特权                        <a class="five_update" href="javascript:;" title="5元升级" target="_blank">5元升级</a>';
                if (isClient) return !1;
                switch (vodUserInfo.type) {
                case "vodVipUser":
                case "oldVodVipUser":
                    break;
                case "vipUser":
                    b = "http://pay.vip.xunlei.com/upgrade_pay.html", a = "XV_29", e.show().find(".add_five").html(f).find("a").unbind("click").bind("click", function () {
                        return g(b, a), !1
                    }), d.html('<img src="' + c[0] + '" width="300" height="65">').unbind("click").bind("click", function () {
                        b = c[1], window.open(b)
                    });
                    break;
                case "expVipUser":
                case "norUser":
                    a = "XV_29", d.html('<img src="' + c[0] + '" width="300" height="65">').unbind("click").bind("click", h), e.show().find(".add_five > a").unbind("click").bind("click", h);
                    break;
                default:
                }
                return !1
            },
            showUserInfo: function () {
                var a = $('#moreUserInfo span[name="userName"]'),
                    b = $("#moreUserInfo .funcUserVipLevel"),
                    c = $("#userAttr").find("a"),
                    d = $("#userAttr .funcUserVipLevel"),
                    e = $("#flux"),
                    f = $("#topPaylink"),
                    g = $("#tipPayLink");
                a.attr("title", vodUserInfo.usernick).text(vodUserInfo.usernick), b.removeClass("icvip"), d.removeClass("icvip");
                var h = function (a, b, c, d) {
                    var e = a.substr(0, 4),
                        f = a.substr(4, 2),
                        g = a.substr(6, 2),
                        h = gData.formatExpireDay(e, f, g);
                    if (h.num > 0) {
                        var i = ["您的会员已于", f + "." + g, " 到期，", h.m + "." + h.d, " 日后列表任务将会被限制为1000个（剩余", h.num, '天），多出任务将按日期从后往前删除，<a id="topNoticeLink" href="javascript:;">续费会员</a>'].join(""),
                            j = {
                                name: b,
                                priority: 25,
                                content: {
                                    text: i
                                },
                                link: {
                                    display: !1
                                },
                                noPop: {
                                    display: !1
                                }
                            }, k = topNotice.topNoticeInit(j);
                        k.show(function () {
                            var a = $("#topNoticeLink");
                            a.css("color", "#1874CA").unbind("click").click(function () {
                                base.stat({
                                    p: "vodlist",
                                    f: "trailviptips"
                                }), isClient ? base.jumpUrlOnId("http://pay.vip.xunlei.com/vod.html?referfrom=XV_30&refresh=2", "_blank") : base.goPay("XV_30", "vodlist", c, d)
                            })
                        })
                    }
                }, j = "newpay_banner",
                    k = "",
                    l = "开通迅雷白金会员",
                    m = "白金会员不限时长";
                if (c.css("color", "#323232"), "vodVipUser" == vodUserInfo.type || "oldVodVipUser" == vodUserInfo.type) c.text("迅雷白金会员"), l = m = "续费会员", f.text(l).attr("title", l), g.addClass("red").text(m).attr("title", m), j = "repay_banner", "oldVodVipUser" == vodUserInfo.type && (c.text("迅雷会员"), k = "oldPayUrl");
                else if ("vipUser" == vodUserInfo.type) {
                    c.text("迅雷会员"), l = "开通迅雷白金会员", m = "白金会员不限时长", f.text(l).attr("title", l), g.addClass("red").text(m).attr("title", m), j = "newpay_banner";
                    var n = vodUserInfo.last_expire;
                    n && h(n, "vipUser", j, k)
                } else if ("expVipUser" == vodUserInfo.type) {
                    c.text("体验会员"), l = "开通迅雷白金会员", m = "白金会员不限时长", f.text(l).attr("title", l), g.addClass("red").text(m).attr("title", m), j = "newpay_banner";
                    var n = vodUserInfo.last_expire;
                    n && h(n, "expVipUser", j, k);
                    var o = vodUserInfo.expire;
                    if (o && !n) {
                        var p = gData.transRemainDay(o.substr(0, 4), o.substr(4, 2), o.substr(6, 2));
                        if (p >= 0 && 8 >= p) {
                            var q = p + "天后";
                            0 == p && (q = "今天");
                            var r = "您的体验会员将在" + q + "到期，立即<a id='topNoticeLink' href='javascript:;'>成为迅雷白金会员</a>",
                                s = {
                                    name: "expVipTip",
                                    priority: 15,
                                    content: {
                                        text: r
                                    },
                                    link: {
                                        display: !1
                                    },
                                    noPop: {
                                        display: !1
                                    }
                                }, t = topNotice.topNoticeInit(s);
                            t.show();
                            var u = $("#topNoticeLink");
                            u.css("color", "#1874CA").unbind("click").click(function () {
                                base.stat({
                                    p: "vodlist",
                                    f: "trailviptips"
                                }), isClient ? base.jumpUrlOnId("http://pay.vip.xunlei.com/vod.html?referfrom=XV_01&refresh=2", "_blank") : base.goPay("XV_01", "vodlist", j, k)
                            })
                        }
                    }
                } else if ("norUser" == vodUserInfo.type) {
                    c.text("普通用户"), l = "开通迅雷白金会员", m = "白金会员不限时长", f.text(l).attr("title", l), g.addClass("red").text(m).attr("title", m), j = "newpay_banner";
                    var n = vodUserInfo.last_expire;
                    n && h(n, "norUser", j, k)
                } else if ("unknownType" == vodUserInfo.type)
                    if (base.isVip()) {
                        c.text("");
                        var v = "icvip0" + base.getCookie("isvip");
                        d.addClass("icvip").addClass(v), l = "续费会员", m = "续费会员", f.text(l).attr("title", l), g.addClass("red").text(m).attr("title", m), j = "repay_banner"
                    } else {
                        c.text("普通用户"), d.removeClass("icvip"), l = "开通迅雷白金会员", m = "白金会员不限时长", f.text(l).attr("title", l), g.addClass("red").text(m).attr("title", m), j = "newpay_banner";
                        var n = vodUserInfo.last_expire;
                        n && h(n, "norUser", j, k)
                    }
                var w = function (a) {
                    return base.goPay(a, "vodlist", j, k), gList.dropMenuQueue("clear"), !1
                };
                f.unbind("click").click(function () {
                    w("XV_01")
                }), g.unbind("click").click(function () {
                    w("XV_14")
                });
                var x = function (a, b, c, d) {
                    if (!base.checkEnv("iPad")) {
                        var e = gData.transRemainTime(a),
                            f = "<a id='topBuyFluxLink' class='red' href='javascript:;'>1元购买2小时</a>",
                            g = "vipUser" == vodUserInfo.type ? !0 : !1,
                            h = g ? "加5元升白金包月" : "开通白金会员包月",
                            i = "<a id='topNoticePayLink'class='red' href='javascript:;'>" + h + "</a>",
                            j = "您的播放时长剩余" + e + "，您可以选择" + f + "，或者" + i;
                        if ("undefined" != typeof d && d >= 0 && 7 >= d) {
                            var k = 0 == d ? "今天到期" : d + "天后到期";
                            j = "您剩余" + e + "播放时长将于" + k + "，建议您尽快用完，或者" + f + "，购买成功后时长将自动续期半年"
                        }
                        var l = {
                            name: "leftTimeTip",
                            priority: 20,
                            content: {
                                text: j
                            },
                            noPop: {
                                display: !1
                            }
                        }, m = topNotice.topNoticeInit(l);
                        m.show(), $("#topBuyFluxLink").unbind("click").bind("click", function () {
                            var a = "http://pay.vip.xunlei.com/vodcard/?referfrom=XV_32";
                            return isClient ? base.jumpUrlOnId(a, "topBuyFluxLink") : isIpad ? base.showPayTutor() : window.open(a, "topBuyFluxLink"), base.stat({
                                b: "buyFluxLinkAtTopNotice",
                                p: "vodlist"
                            }), !1
                        }), $("#topNoticePayLink").unbind("click").bind("click", function () {
                            return isClient ? base.jumpUrlOnId("http://pay.vip.xunlei.com/vod.html?referfrom=XV_12&refresh=2", "_blank") : isIpad ? base.showPayTutor() : g ? window.open("http://pay.vip.xunlei.com/upgrade_pay.html?referfrom=XV_12", "topNoticePayLink") : base.goPay("XV_12", "vodlist", b, c), !1
                        })
                    }
                };
                if ("vodVipUser" == vodUserInfo.type || "oldVodVipUser" == vodUserInfo.type) e.text("剩余时长：不限时长");
                else if ("fail" == vodUserInfo.fluxState || -1 == vodUserInfo.fluxValue) e.text("剩余时长：暂时无法获取...");
                else if ("init" == vodUserInfo.fluxState) e.text("剩余时长：正在获取...");
                else if ("success" == vodUserInfo.fluxState) {
                    if (0 == vodUserInfo.fluxValue) {
                        var y = gData.transRemainTime(vodUserInfo.fluxValue),
                            z = " <a id='buyFluxLinkInUserInfo' class='red' href='javascript:;'>1元购买两小时</a>";
                        base.checkEnv("iPad") && (z = ""), e.html("剩余时长：" + y + z), $("#buyFluxLinkInUserInfo").unbind("click").bind("click", function () {
                            return window.open("http://pay.vip.xunlei.com/vodcard/?referfrom=XV_33", "buyFluxLinkInUserInfo"), base.stat({
                                b: "buyFluxLinkInTopUserInfo",
                                p: "vodlist"
                            }), !1
                        }), x(vodUserInfo.fluxValue, j, k)
                    }
                    if (vodUserInfo.fluxValue > 0) {
                        var y = gData.transRemainTime(vodUserInfo.fluxValue),
                            A = "",
                            B = -1;
                        if (vodUserInfo.fluxDeadline > 0) {
                            var C = new Date(1e3 * vodUserInfo.fluxDeadline);
                            B = gData.transRemainDay(C.getFullYear(), C.getMonth() + 1, C.getDate()), B >= 0 && 1e3 > B && (A = 0 == B ? "(今天到期)" : "(" + B + "天后到期)")
                        }
                        e.text("剩余时长：" + y + A), x(vodUserInfo.fluxValue, j, k, B)
                    }
                }
            },
            fillTipsContent: function () {
                var a, b = {}, c = /<[0-9]>/g,
                    d = [],
                    e = "",
                    f = 0,
                    g = ' style="color:#EC6001"',
                    h = {
                        vip: {
                            cont: "您的播放时长剩余<1><2>，加<3>白金会员不限时观看，并可享高速、离线特权",
                            link: "加5元升级"
                        },
                        non_vip: {
                            cont: "您的播放时长剩余<1><2>，开通白金会员不限时观看，并可享高速、离线特权",
                            link: "开通白金会员"
                        }
                    };
                if (vodUserInfo.fluxValue > 0)
                    if (f = vodUserInfo.fluxDeadline && 1e3 * vodUserInfo.fluxDeadline <= +new Date ? -1 : 1e3 * vodUserInfo.fluxDeadline, d = [gData.transRemainTime(vodUserInfo.fluxValue)], f > 0) {
                        f = new Date(parseInt(f)), f.getFullYear() % 100;
                        var j = f.getMonth() + 1 + "",
                            k = f.getDate() + "";
                        e = "(<span " + g + ">" + j + "月" + k + "日前有效</span>)", d.push(e)
                    } else d.push("");
                    else 0 == vodUserInfo.fluxValue && (d = ["0分钟", ""]);
                if ("vipUser" == vodUserInfo.type && h.vip) b = h.vip, d.push("<span " + g + ">5元升级</span>"), a = function () {
                    return isClient ? base.jumpUrlOnId("http://pay.vip.xunlei.com/upgrade_pay.html?referfrom=XV_12&refresh=2", "_blank") : isIpad ? base.showPayTutor() : window.open("http://pay.vip.xunlei.com/upgrade_pay.html?referfrom=XV_12"), !1
                };
                else {
                    if ("norUser" != vodUserInfo.type || !h.non_vip) return {};
                    b = h.non_vip
                }
                var l = 0,
                    m = b.cont.replace(c, function () {
                        return d[l++]
                    });
                return {
                    content: m,
                    link: b.link,
                    exec: a
                }
            },
            getAndShowFlux: function () {
                var a = this;
                "vodVipUser" != vodUserInfo.type && "oldVodVipUser" != vodUserInfo.type && (vodUserInfo.fluxState = "init", gData.getUserFlux(function (b) {
                    if (b && 0 == b.result) {
                        vodUserInfo.fluxState = "success";
                        var c = b.remain || 0;
                        vodUserInfo.fluxValue = c, vodUserInfo.fluxDeadline = b.vtime || 0, -1 == b.remain && (vodUserInfo.fluxState = "fail")
                    } else vodUserInfo.fluxState = "fail";
                    a.showUserInfo()
                }, function () {
                    vodUserInfo.fluxState = "fail", a.showUserInfo()
                }), this.showUserInfo())
            },
            setListUsedInfo: function (a, b, c) {
                b = b || 0, c = c || 0, listUsedInfo.ready = a, listUsedInfo.useNum = parseInt(b), listUsedInfo.limitNum = parseInt(c)
            },
            getListUsedInfo: function () {
                var a = this,
                    b = listUsedInfo.ready,
                    c = listUsedInfo.useNum,
                    d = listUsedInfo.limitNum;
                if (1 == b) this.showListUsedInfo(b, c, d);
                else {
                    listUsedInfo.ready = 0, this.showListUsedInfo(0, 0, 0);
                    var e = gData.getHistoryList({
                        typeName: "all",
                        num: 1,
                        offset: 0,
                        order: "create",
                        timeout: 5e3,
                        success: function () {
                            a.showListUsedInfo(listUsedInfo.ready, listUsedInfo.useNum, listUsedInfo.limitNum)
                        },
                        fail: function (b) {
                            return "abort" != b.statusText ? "timeout" == b.statusText ? (listUsedInfo.ready = -1, a.showListUsedInfo(-1), void 0) : void 0 : void 0
                        }
                    });
                    lastGetlistUsedAjax && lastGetlistUsedAjax.abort(), lastGetlistUsedAjax = e
                }
            },
            showListUsedInfo: function (a, b, c) {
                $("#listUsedTip");
                var e = $("#listUsedRate"),
                    f = $("#listUsedText");
                if (1 == a)
                    if (b >= 0 && c >= 0 && c >= b) {
                        var g = (100 * b / c).toFixed(2);
                        e.css("width", g + "%"), f.text(b.toString() + "个/" + c.toString() + "个")
                    } else a = -1;
                0 == a && (e.css("width", "10%"), f.text("正在获取…")), -1 == a && (e.css("width", "10%"), f.text("获取失败"))
            },
            pageAble: !0,
            pageInit: function () {
                var a = this,
                    b = base.getCookie("userid");
                listState.mode = b && 1 !== b % 2 ? "List" : "Thumb";
                var c = base.getCookie("viewMode");
                c && (listState.mode = c);
                var d = 5;
                window.screen.width > 1280 && (d = 6);
                var e = 13;
                isClient && (d = 5, e = 8);
                var f = e,
                    g = 134,
                    h = (g + 2 * e) * d + 40,
                    i = ".task_list li {margin: 0 " + e + "px 5px;}",
                    j = $("#listMain"),
                    k = $("#listWrap");
                try {
                    var l = document.createStyleSheet()
                } catch (m) {
                    var n = document.createElement("style");
                    n.type = "text/css", document.getElementsByTagName("head").item(0).appendChild(n)
                }
                if (isIpad) i = ".task_list li {margin: 0 8px 5px;}", l ? l.cssText = i : n.textContent = i;
                else {
                    var o = j[0].clientWidth;
                    o > h ? (f = parseInt((o - h) / d / 2 + e), j.css("overflow-x", "hidden"), e > f && (f = e)) : (j.css("overflow-x", "auto"), f = e, o = h), i = ".task_list li {margin: 0 " + f + "px 5px;};", l ? l.cssText = i : n.textContent = i, k.css("width", o)
                }
                var p = null;
                $(window).resize(function () {
                    clearTimeout(p), p = setTimeout(function () {
                        1 == listState.pickupState ? $("#mainwrap").removeClass("spread").addClass("pack_up") : $("#mainwrap").removeClass("pack_up").addClass("spread"), k.css("width", ""), o = j[0].clientWidth, o > h ? (j.css("overflow-x", "hidden"), f = parseInt((o - h) / d / 2 + e), e > f && (f = e)) : (j.css("overflow-x", "auto"), f = e, o = h), i = ".task_list li {margin: 0 " + f + "px 5px;}", isIpad && 0 == listState.pickupState && (i = ".task_list li {margin: 0 8px 5px;}"), l ? l.cssText = i : n.textContent = i, isIpad || k.css("width", o)
                    }, 5)
                });
                var q = "http://lixian.xunlei.com";
                if (isIpad && !base.isVip() && (q = "http://lixian.vip.xunlei.com/task.html?fromipad=1"), $("#lixianLink").unbind("click").click(function () {
                    return isClient ? (base.jumpUrlOnId(q, "lixian"), void 0) : (window.open(q, "lixian"), void 0)
                }), this.dropMenuQueue("init"), 0 == this.pageAble) return gListUI.showBigTip({
                    type: "PleaseTry",
                    content: gList.loadDataTips.pageUnable
                }), void 0;
                var r = gListUI.getElement("MenuList");
                r.bind("click", function () {
                    var b = $(this).find("a").attr("listName");
                    if ("lixian" == b && !base.isVip()) {
                        var c = q;
                        return isClient ? (base.jumpUrlOnId(q, "lixian"), void 0) : (window.open(c, "lixian"), void 0)
                    }
                    a.selectMenu({
                        list: b
                    }), base.stat({
                        b: b,
                        p: "vodlist"
                    })
                });
                var s = this.getQueryStringArgs(location.hash),
                    t = {
                        list: s.list,
                        folder: s.folder,
                        value: s.value,
                        p: s.p
                    };
                this.selectMenu(t), this.pickupInit(), this.ctrlBtnInit(), $("#addTask").click(function () {
                    $("#newTask").show(), $("#bgMask").show(), $("#closeNewTask").unbind("click").click(function () {
                        $("#newTask").hide(), $("#bgMask").hide()
                    }), gTask.resetTaskVal(), $("#urlTaskInput").focus()
                }), $.fn.hashchange.src = "http://vod.xunlei.com/js/gallery/hashchange/1.0.0/document-domain.html", $.fn.hashchange.domain = document.domain, $(window).bind("hashchange", function () {
                    var a = gList.hash;
                    if (gList.hashAble) {
                        a.list = base.$PU("list", location.hash), a.folder = base.$PU("folder", location.hash), a.value = base.$PU("value", location.hash), a.p = base.$PU("p", location.hash);
                        var b = {
                            list: a.list,
                            folder: a.folder,
                            value: a.value,
                            p: a.p,
                            NeedChgHash: !1
                        };
                        gList.selectMenu(b)
                    }
                    gList.hashAble = !0
                }), gListUI.init()
            },
            selectMenu: function (a) {
                var b = {
                    list: listState.listName,
                    folder: "",
                    value: "",
                    p: 1,
                    order: "create",
                    createTime: "--",
                    playTime: "--",
                    NeedChgHash: !0
                };
                a = $.extend(b, a), listState.lastLoadConfig = a, listState.listName = a.list;
                var c = a.order,
                    d = h = "";
                a.p || (a.p = 1);
                var e = (a.p - 1) * listState.perPageNum;
                gList.hash = {}, gList.hash.list = a.list, gList.hash.p = a.p;
                var f = function () {
                    if (a.NeedChgHash) {
                        var b = $.param(gList.hash);
                        gList.hashAble = !1, location.hash = b
                    }
                };
                if ("" != a.folder) return a.folder = base.decode(a.folder), listState.folderName = a.folder, gList.hash.folder = base.encode(a.folder), gList.hash.value = a.value, gListUI.showListMenu(a.list, a.folder), ("recent" == a.list || "rweek" == a.list || "rmonth" == a.list || "omonth" == a.list) && (c = "commit"), f(), this.loadList({
                    type: "Folder",
                    typeName: "BtFolder",
                    typeValue: a.value,
                    offset: e,
                    order: c,
                    createTime: a.createTime,
                    playTime: a.playTime,
                    startDate: d,
                    endDate: h
                }), void 0;
                gListUI.showListMenu(a.list, a.folder);
                var g, d, h;
                switch (a.list) {
                case "daikan":
                case "yikan":
                case "yincang":
                    g = a.list, c = "create";
                    break;
                case "recent":
                    g = "yibo", c = "commit", h = gData.createBeforeDate(0);
                    break;
                case "rweek":
                    g = "yibo", c = "commit", d = gData.createBeforeDate(6), h = gData.createBeforeDate(0);
                    break;
                case "rmonth":
                    g = "yibo", c = "commit", d = gData.createBeforeDate(29), h = gData.createBeforeDate(0);
                    break;
                case "omonth":
                    g = "yibo", c = "commit", h = gData.createBeforeDate(29);
                    break;
                case "lixian":
                    g = "lixian";
                    break;
                case "all":
                default:
                    g = "all", c = "create"
                }
                f(), this.loadList({
                    typeName: g,
                    startDate: d,
                    endDate: h,
                    order: c,
                    offset: e
                })
            },
            retryLoadList: function () {
                listState.lastLoadConfig && this.selectMenu(listState.lastLoadConfig)
            },
            pickupInit: function () {
                var a = function (a, b) {
                    var c = listState.pickupState,
                        d = !1;
                    "undefined" == typeof b || b !== !0 && b !== !1 ? (c = !c, d = !0) : c = b, 0 == c ? (a.attr("title", "收起"), listState.pickupState = !1, d && base.stat({
                        b: "left_tounfold",
                        p: "vodlist"
                    })) : (a.attr("title", "展开"), listState.pickupState = !0, d && base.stat({
                        b: "left_tofold",
                        p: "vodlist"
                    }));
                    var e = {
                        pickupState: listState.pickupState
                    };
                    locStore.storeData({
                        pageState: e
                    })
                }, b = $("#pickuparea"),
                    c = $("#pickupbtn"),
                    d = listState.pickupState;
                isIpad || isAndroid ? (d = !0, c.show()) : (b.hover(function () {
                    c.show()
                }, function () {
                    c.hide()
                }), c.hide());
                var e, f = locStore.getStoredData("pageState");
                f && "undefined" != typeof f.pickupState && (f.pickupState === !0 || 0 == f.pickupState) && (e = f.pickupState, d = e), d === !0 && (a(c, d), $(window).resize()), c.unbind("click").bind("click", function () {
                    a($(this)), $(window).resize()
                })
            },
            ctrlBtnInit: function () {
                var a = this;
                gListUI.getElement("ListBtn").live("click", function () {
                    "List" != listState.mode && a.switchMode("List")
                }), gListUI.getElement("ThumbBtn").live("click", function () {
                    "Thumb" != listState.mode && a.switchMode("Thumb")
                })
            },
            switchMode: function (a) {
                base.stat({
                    b: a.toLowerCase() + "_mode",
                    p: "vodlist"
                }), listState.mode = a;
                var b = [];
                "Managing" == listState.heapManage && (b = this.checkboxState("getChecked")), this.listInit(listState.data, a, !0), "Managing" == listState.heapManage && this.checkboxState("setChecked", b), base.setCookie("viewMode", a, 2592e3)
            },
            contentEventInit: function (a, b) {
                var c = this,
                    d = listState.data.list,
                    e = gListUI.getElement("ListDataArea").find("a[name=openLink]");
                if (e.unbind("click"), e.each(function () {
                    var a = $(this).closest("[index]").attr("index"),
                        b = d[a].playFlag.yikan,
                        c = d[a].progState;
                    b === !0 && $(this).addClass("yikan"), (5 == c || 7 == c || "Invalid" == c) && $(this).removeClass("nohover")
                }), "Managing" == b) {
                    var f = gListUI.getElement("ListDataArea").children();
                    "Managing" == listState.heapManage && gListUI.getElement("ListCheckBox").show();
                    var g = gListUI.getElement("HeapManagePanel").find("a[name=daikan], a[name=yikan]");
                    g.parent().show(), ("yikan" == listState.listName || "daikan" == listState.listName) && g.filter("a[name=" + listState.listName + "]").parent().hide(), gListUI.refreshSelectAll();
                    var h = gListUI.getElement("ListCheckBox");
                    h.unbind("click").bind("click", function (a) {
                        a.stopPropagation(), gListUI.refreshSelectAll()
                    }), f.unbind("click").bind("click", function () {
                        var a = $(this).find("input:checkbox"),
                            b = a[0].checked;
                        1 == b ? a.attr("checked", !1) : a.attr("checked", !0), gListUI.refreshSelectAll()
                    }), f.find("a").addClass("nohover")
                } else e.unbind("click").bind("click", function (a) {
                    a.stopPropagation(), gList.dropMenuQueue("clear");
                    var b = $(this).closest("[index]").attr("index");
                    c.openFile(b)
                });
                "List" == a ? this.listEventInit() : "Thumb" == a && this.thumbEventInit()
            },
            setInfoTimer: null,
            listEventInit: function () {
                var b, a = this;
                b = "BtFolder" == listState.typeName || "lixian" == listState.typeName ? !0 : !1;
                var c = listState.data.list,
                    d = gListUI.getElement("ListDataArea").children();
                if (isIpad || d.hover(function () {
                    $(this).css("backgroundColor", "#e9eef4"), $(this).css("cursor", "pointer"), 1 == b && $(this).css("cursor", "default")
                }, function () {
                    $(this).css("backgroundColor", "")
                }), clearTimeout(this.setInfoTimer), this.setInfoTimer = setTimeout(function () {
                    d.find("td:contains(--)").attr("title", "未知")
                }, 500), d.unbind("contextmenu"), "Managing" == listState.heapManage) {
                    var e = d.filter("tr.tr_sel");
                    return e.find("div.edit_area").hide(), e.removeClass("tr_sel"), void 0
                }
                var f = function (d) {
                    var e = d.find("[name=listPlayBtn]"),
                        f = d.find("[name=listDeleteBtn]"),
                        g = d.find("[name=listDownloadBtn]"),
                        h = d.find("[name=listRenameBtn]"),
                        i = d.find("[name=listMoreBtn]");
                    b ? (e.show(), isIpad || g.show()) : (e.show(), f.show(), isIpad || g.show(), h.show(), i.show()), e.unbind("click").bind("click", function () {
                        gList.dropMenuQueue("clear");
                        var b = $(this).closest("[index]").attr("index");
                        a.openFile(b)
                    }), e.each(function () {
                        var a = $(this).closest("[index]").attr("index");
                        "Folder" == c[a].type && $(this).text("打开").attr("title", "打开")
                    }), f.unbind("click").bind("click", function () {
                        gList.dropMenuQueue("clear");
                        var b = $(this).closest("[index]").attr("index");
                        a.deleteFile({
                            cmd: "popConfirm",
                            indexArr: [b]
                        });
                        var c = $.extend({
                            b: "single_delete",
                            p: "vodlist"
                        }, a.getDelParams4Stat(b, {
                            gc: "gcid",
                            state: "progState",
                            vaddr: "src_url"
                        }));
                        base.stat(c)
                    }), g.unbind("click").bind("click", function () {
                        gList.dropMenuQueue("clear");
                        var b = $(this).closest("[index]").attr("index");
                        a.popDownloadLayer(b)
                    }), h.unbind("click").bind("click", function (b) {
                        gList.dropMenuQueue("clear"), $(this).hide();
                        var c = $(this).closest("[index]");
                        a.renameFile(c), i.find("[name=listMore]").hide(), b.stopPropagation(), base.stat({
                            b: "single_rename",
                            p: "vodlist"
                        })
                    }), i.unbind("click").bind("click", function (b) {
                        b.stopPropagation(), $("#rightClickMenu").hide();
                        var d = $(this).find("[name=listMore]");
                        d.toggle(), gList.dropMenuQueue("add", function () {
                            d.hide(), i.find("[name=copyer]").html("")
                        }), a.setCopyLink($(this));
                        var e = $(this).closest("[index]");
                        e.find("input[name='rename']").hide(), e.find("[name=listSaveRenameBtn]").hide(), e.find("[name=listRenameBtn]").show(), e.find("a[name='openLink']").show();
                        var f = $(this).closest("[index]").attr("index"),
                            g = c[f].playFlag,
                            h = $(this).find("[name=yikan], [name=daikan], [name=yincang], [name=quxiaoyincang]");
                        h.parent().show(), h.each(function () {
                            var a = $(this).attr("name");
                            1 == g[a] && $(this).parent().hide()
                        });
                        var j = AceTemplate.format("linkCopyerTpl", {
                            width: 82,
                            height: 22
                        });
                        $(this).find("[name=copyer]").html("").html(j)
                    });
                    var j = d.find("[name=yikan], [name=daikan], [name=yincang], [name=quxiaoyincang]");
                    j.unbind("click").bind("click", function () {
                        var c = $(this).closest("[index]").attr("index"),
                            d = $(this).attr("name");
                        "yincang" == d || "quxiaoyincang" == d ? a.modifyHideState({
                            toType: d,
                            indexArr: [c]
                        }) : ("yikan" == d || "daikan" == d) && a.modifyVisitState({
                            toType: d,
                            indexArr: [c]
                        }), base.stat({
                            b: "single" + d,
                            p: "vodlist"
                        })
                    })
                }, g = function (b) {
                        var d = $(b).find("span[name=clarityArea]"),
                            e = d.find("a"),
                            f = d.find("a[name=liuchang]"),
                            g = d.find("a[name=gaoqing]"),
                            h = d.find("a[name=chaoqing]"),
                            i = "d_sel",
                            j = $(b).closest("[index]").attr("index"),
                            k = c[j].clarity;
                        return g.addClass(i), 0 == k.enable ? (d.hide(), void 0) : (f.removeClass(i), g.removeClass(i), h.removeClass(i), k.liuchang && f.addClass(i), k.gaoqing && g.addClass(i), k.chaoqing && h.addClass(i), e.unbind("click").bind("click", function () {
                            var b = $(this).closest("[index]").attr("index"),
                                d = $(this).attr("name"),
                                e = c[b].clarity;
                            if (1 == e[d]) {
                                var f = {
                                    liuchang: "p",
                                    gaoqing: "g",
                                    chaoqing: "c"
                                }, g = f[d];
                                a.openFile(b, g)
                            }
                            return !1
                        }), void 0)
                    }, h = function () {
                        gList.dropMenuQueue("clear"), d.each(function () {
                            $(this).removeClass("tr_sel"), $(this).find("a[name=stateBar]").hide(), $(this).find("div.edit_area").hide(), $(this).find("span[name=clarityArea]").hide()
                        }), $(this).addClass("tr_sel"), $(this).find("a[name=stateBar]").show(), $(this).find("div.edit_area").show(), $(this).find("span[name=clarityArea]").show(), g(this), f($(this))
                    };
                1 != b && d.bind("contextmenu", function () {
                    return h.apply(this, arguments), a.goRightMenu.apply(this, arguments)
                }), d.unbind("click").bind("click", h)
            },
            renameFile: function (a) {
                var b = !1,
                    d = a.attr("index"),
                    e = a.find("input[name='rename']"),
                    f = listState.data.list[d].file_name,
                    g = base.getNameExt(f),
                    h = g.name,
                    i = g.ext,
                    j = listState.mode,
                    k = a.find("[name='rename_error']"),
                    l = {
                        emptyInput: "请先输入文件名",
                        nameTooLong: "文件名不能超过50个字符",
                        renaming: "正在处理重命名...",
                        containIllegalCharacter: "检测到非法字符"
                    };
                if (e.val(h).show(), e.select(), e.unbind("click").click(function (a) {
                    a.stopPropagation()
                }), "Thumb" == j) a.find("p a").hide(), e.unbind("blur").blur(function () {
                    gListUI.showLittleTip({
                        showMask: !1,
                        toState: "hide"
                    }), k.html("").hide();
                    var c = $.trim(e.val());
                    if (c != h) {
                        if (1 > c.length) e.val(h).hide(), a.find("p a").show();
                        else if (c.length > 50) e.val(h).hide(), a.find("p a").show(), k.html(l.nameTooLong).show().fadeOut(2500);
                        else if (c) {
                            var f = /^[^`~!@#$%^&*+=|\\:;'"\/?<>]{1}[^`~!@#$%^&*+=|\\:;'"\/?<>]{0,}$/i;
                            if (f.exec(c)) {
                                if ("BtFile" != listState.data.list[d].typeName) var g = listState.data.list[d].url_hash;
                                else var g = listState.data.list[d].main_url_hash;
                                gListUI.showLittleTip({
                                    showMask: !0,
                                    content: l.renaming
                                }), option = {
                                    urlHash: g,
                                    item: a,
                                    newName: i ? c + "." + i : c,
                                    success: gList.renameFileSuccess,
                                    error: gList.renameFileError
                                }, gData.doRenameFile(option)
                            } else e.val(h).hide(), a.find("p a").show(), k.html(l.containIllegalCharacter).show().fadeOut(2500)
                        }
                    } else e.hide(), a.find("p a").show()
                });
                else {
                    a.find("[name='openLink']").hide();
                    var m = a.find("[name=listRenameBtn]"),
                        n = a.find("[name=listSaveRenameBtn]");
                    m.hide();
                    var o = function () {
                        gListUI.showLittleTip({
                            toState: "hide"
                        }), k.html("").hide();
                        var f = $.trim(e.val());
                        if (f != h && b)
                            if (a.find("a[name='openLink']").hide(), b = !1, 1 > f.length) e.val(h).hide(), a.find("[name='openLink']").show(), k.html(l.emptyInput).show().fadeOut(2500), n.show(), m.hide();
                            else if (f.length > 50) e.val(h).hide(), a.find("[name='openLink']").show(), k.html(l.nameTooLong).show().fadeOut(2500), n.hide(), m.hide();
                        else {
                            if (f) {
                                var g = /^[^`~!@#$%^&*+=|\\:;'"\/?<>]{1}[^`~!@#$%^&*+=|\\:;'"\/?<>]{0,}$/i;
                                if (g.exec(f)) {
                                    if ("BtFile" != listState.data.list[d].typeName) var j = listState.data.list[d].url_hash;
                                    else var j = listState.data.list[d].main_url_hash;
                                    gListUI.showLittleTip({
                                        showMask: !0,
                                        time: 30,
                                        content: l.renaming
                                    }), option = {
                                        urlHash: j,
                                        item: a,
                                        newName: i ? f + "." + i : f,
                                        success: gList.renameFileSuccess,
                                        error: gList.renameFileError
                                    }, gData.doRenameFile(option)
                                } else e.hide(), a.find("[name='openLink']").show(), k.html(l.containIllegalCharacter + "( `~!@#$%^&*+=|\\:;'\"/?<> )").show().fadeOut(2500), n.hide(), m.hide();
                                return !1
                            }
                            e.hide(), a.find("a[name='openLink']").show(), n.hide(), m.show()
                        } else e.hide(), a.find("a[name='openLink']").show(), n.hide(), m.show()
                    };
                    n.unbind("click").bind("click", function (a) {
                        a.stopPropagation(), b = !0, o()
                    }).show(), $("#loadingMask").unbind().click(function (a) {
                        return a.stopPropagation, !1
                    }), gList.dropMenuQueue("add", o)
                }
                e.unbind("keydown").keydown(function (a) {
                    return 13 == a.keyCode ? ("Thumb" == j ? e.blur() : (b = !0, $(document).click()), !1) : void 0
                })
            },
            renameFileError: function (a) {
                var b = a.item;
                b.find("input[name='rename']").removeAttr("disabled").focus(), "Thumb" == listState.mode && b.find("p a").show(), gListUI.showLittleTip({
                    content: "重命名保存失败，请重试"
                })
            },
            renameFileSuccess: function (a, b) {
                var c = "",
                    d = a.item,
                    e = d.find("input[name='rename']");
                if (0 == b.ret) {
                    e.hide();
                    var f = d.attr("index");
                    listState.data.list[f].file_name = a.newName, listState.data.list[f].shortName = gData.toShortName(a.newName, 30, 14, 12);
                    var g = a.newName;
                    g = 1024 >= window.screen.width ? gData.toShortName(g, 50, 30, 15) : gData.toShortName(g, 88, 68, 15), listState.data.list[f].listShortName = g, d.find("a[name='openLink']").attr("title", a.newName).show(), "Thumb" == listState.mode ? d.find("p a").html("").html(gData.toShortName(a.newName, 30, 14, 12)).show() : (d.find("a[name='openLink']").html("").html(gData.toShortName(a.newName, 88, 68, 15)).show(), d.find("[name=listSaveRenameBtn]").hide(), d.find("[name=listRenameBtn]").show()), c = "重命名成功"
                } else e.removeAttr("disabled").focus(), c = "重命名保存失败，请重试";
                gListUI.showLittleTip({
                    content: c
                })
            },
            thumbEventInit: function () {
                var b, a = this;
                if (b = "BtFolder" == listState.typeName || "lixian" == listState.typeName ? !0 : !1, 1 != b) {
                    var c = gListUI.getElement("ListDataArea").children();
                    if (c.unbind("contextmenu").unbind("hover"), "Managing" != listState.heapManage) {
                        isIpad || c.hover(function () {
                            $(this).find("a[name=deleteIco]").show()
                        }, function () {
                            $(this).find("a[name=deleteIco]").hide()
                        });
                        var d = c.find("a[name=deleteIco]");
                        d.unbind("click").bind("click", function () {
                            var b = $(this).closest("[index]").attr("index");
                            a.deleteFile({
                                cmd: "popConfirm",
                                indexArr: [b]
                            });
                            var c = $.extend({
                                b: "single_delete",
                                p: "vodlist"
                            }, a.getDelParams4Stat(b, {
                                gc: "gcid",
                                state: "progState",
                                vaddr: "src_url"
                            }));
                            base.stat(c)
                        }), c.unbind("contextmenu").bind("contextmenu", function () {
                            return a.goRightMenu.apply(this, arguments)
                        })
                    }
                }
            },
            getDelParams4Stat: function (a, b) {
                var c = listState.data.list[a] || {}, d = {};
                b = b || {};
                for (var e in b) "undefined" != typeof c[b[e]] && (d[e] = c[b[e]]);
                return d
            },
            goRightMenu: function (a) {
                var b = this,
                    c = listState.data.list;
                gList.dropMenuQueue("clear");
                var d = AceTemplate.format("linkCopyerTpl", {
                    width: 87,
                    height: 23
                });
                $("#rightClickMenu").find("[name=copyer]").html("").html(d);
                var e = $("#rightClickMenu").show();
                $(this).find("a").attr("title", "");
                var f = $(this).closest("[index]").attr("index"),
                    g = c[f].playFlag,
                    h = e.find("[name=yikan], [name=daikan], [name=yincang], [name=quxiaoyincang]");
                h.show(), h.each(function () {
                    var a = $(this).attr("name");
                    1 == g[a] && $(this).hide()
                });
                try {
                    var i = a.clientY + $(document).scrollTop() - 1,
                        j = a.clientX - 1;
                    e[0].style.top = i.toString() + "px", e[0].style.left = j.toString() + "px"
                } catch (a) {
                    e.offset({
                        top: a.clientY,
                        left: a.clientX
                    })
                }
                i + e.height() > document.documentElement.scrollTop + document.documentElement.clientHeight && (e[0].style.top = (i - e.height()).toString() + "px"), gList.dropMenuQueue("add", function () {
                    $("#rightClickMenu").find("[name=copyer]").html(""), e.hide();
                    var a = $(b).closest("[index]").attr("index"),
                        d = c[a].file_name;
                    $(b).find("a").attr("title", d)
                }), h.unbind("click").bind("click", function () {
                    var c = $(b).closest("[index]").attr("index"),
                        d = $(this).attr("name");
                    "yincang" == d || "quxiaoyincang" == d ? gList.modifyHideState({
                        toType: d,
                        indexArr: [c]
                    }) : ("yikan" == d || "daikan" == d) && gList.modifyVisitState({
                        toType: d,
                        indexArr: [c]
                    }), gList.dropMenuQueue("clear"), base.stat({
                        b: "single_" + d,
                        p: "vodlist"
                    })
                });
                var k = e.find("[name=delete]");
                k.unbind("click").bind("click", function () {
                    var a = $(b).closest("[index]").attr("index");
                    gList.deleteFile({
                        cmd: "popConfirm",
                        indexArr: [a]
                    });
                    var c = $.extend({
                        b: "single_delete",
                        p: "vodlist"
                    }, gList.getDelParams4Stat(a, {
                        gc: "gcid",
                        state: "progState",
                        vaddr: "src_url"
                    }));
                    base.stat(c)
                });
                var l = e.find("[name=download]");
                isIpad && l.hide(), l.unbind("click").bind("click", function () {
                    var a = $(b).closest("[index]").attr("index");
                    gList.popDownloadLayer(a)
                });
                var m = e.find("[name=rename]");
                return m.unbind("click").bind("click", function (a) {
                    var c = $(b).closest("[index]");
                    gList.renameFile(c), a.stopPropagation(), e.hide(), base.stat({
                        b: "single_rename",
                        p: "vodlist"
                    })
                }), gList.setCopyLink($(this)), !1
            },
            listInit: function (a, b, c) {
                var d = this;
                if (listState.mode = b, 0 == c) {
                    var e = gListUI.toListData(b, a);
                    return gListUI.add(e), "Thumb" == b && this.loadPics(a.list), d.contentEventInit(b, listState.heapManage), this.loadProgress(a.list), this.loadOneFileBt(a.list), void 0
                }
                gListUI.showViewCtrlBtn(b), gListUI.empty(), gListUI.addListFrame(b);
                var e = gListUI.toListData(b, a);
                gListUI.add(e), d.heapManageInit(listState.heapManage);
                var f = $("#showTimeTitle");
                if ("create" == listState.order ? f.text("添加日期") : f.text("播放日期"), 0 != a.list.length && gListUI.showBigTip({
                    type: "List"
                }), "Thumb" == b) {
                    for (var g = [], h = 0; a.list.length > h; h++) {
                        var i = a.list[h];
                        "Yes" == a.list[h].onefilebt ? this.loadPics([i]) : g.push(i)
                    }
                    this.loadPics(g), gListUI.showPics(a.list, listConfig.picMode)
                }
                if (d.contentEventInit(b, listState.heapManage), "List" == b && "Managing" != listState.heapManage) {
                    var j = gListUI.getElement("ListDataArea").children().first();
                    j.click()
                }
                this.loadProgress(a.list), this.autoLoadProgress(), this.loadOneFileBt(a.list), $(window).resize()
            },
            setCopyLink: function (a) {
                var b = a.closest("[index]").attr("index"),
                    c = "";
                listState.data.list && listState.data.list[b] && listState.data.list[b].src_url && (c = listState.data.list[b].src_url), c = this.transSrcUrl(c), window.copyLink = c, window.copyShareLink = function () {
                    return window.copyLink
                }, window.copySuccess = function () {
                    gListUI.showLittleTip({
                        content: "复制成功"
                    }), setTimeout(function () {
                        gList.dropMenuQueue("clear")
                    }, 5), base.stat({
                        b: "single_copylink",
                        p: "vodlist"
                    })
                }
            },
            transSrcUrl: function (a) {
                if (a = a || "", -1 != a.search(/^bt:\/\//)) {
                    var b = a.substring(5, 45);
                    a = "magnet:?xt=urn:btih:" + b
                }
                return a
            },
            paginationInit: function (a, b, c) {
                if (listState.perPageNum >= a) return !1;
                var d = !1;
                $("#pagination").pagination(a, {
                    items_per_page: listState.perPageNum,
                    num_display_entries: 5,
                    current_page: parseInt(listState.offset / listState.perPageNum),
                    num_edge_entries: 3,
                    link_to: "javascript:;",
                    prev_text: "上一页",
                    next_text: "下一页",
                    ellipse_text: "...",
                    prev_show_always: !0,
                    next_show_always: !0,
                    callback: function (a) {
                        if (!d) return d = !0, !1;
                        gList.hash.p = a + 1;
                        var e = $.param(gList.hash);
                        gList.hashAble = !1, location.hash = e, "object" == typeof listState.lastLoadConfig && (listState.lastLoadConfig.p = a + 1), b({
                            num: listState.perPageNum,
                            offset: a * listState.perPageNum,
                            mode: listState.mode,
                            typeName: listState.typeName,
                            typeValue: c.typeValue,
                            order: c.order,
                            startDate: c.startDate,
                            endDate: c.endDate,
                            createTime: c.createTime,
                            playTime: c.playTime
                        })
                    }
                }).show()
            },
            loadDataTips: {
                notfind: {
                    all: "您的列表为空",
                    daikan: "没有找到待看任务或任务已被删除",
                    yikan: "没有找到已看任务或任务已被删除",
                    yincang: "没有找到标记为隐藏的任务或任务已被删除",
                    recent: "没有找到最近播放过的任务或任务已被删除",
                    rweek: "没有找到最近一周播放过的任务或任务已被删除",
                    rmonth: "没有找到最近一月播放过的任务或任务已被删除",
                    omonth: "没有找到一个月以前播放过的任务或任务已被删除",
                    lixian: "您的离线下载空间暂无云端下载完成的视频"
                },
                pageUnable: "加载出现异常，请刷新<a>重试</a>",
                timeout: "获取列表超时，请稍后<a>重试</a>",
                loadlistfail: "获取列表失败，请稍后<a>重试</a>",
                Loding: "正在努力加载列表..."
            },
            loadList: function (a) {
                var b = gList,
                    c = listState.limitTotalNum;
                $("#pagination").hide();
                var d = {
                    type: "Folder",
                    typeName: listState.typeName,
                    typeValue: "none",
                    num: listState.perPageNum,
                    offset: 0,
                    success: function () {},
                    fail: function () {},
                    mode: listState.mode,
                    rebuild: !0,
                    listName: "",
                    folderName: "",
                    startDate: listState.startDate,
                    endDate: listState.endDate,
                    order: listState.order,
                    createTime: "--",
                    playTime: "--"
                };
                if (a = $.extend(d, a), "Invalid" == listState.heapManage && (listState.heapManage = "unManaging"), ("BtFolder" == a.typeName || "lixian" == a.typeName) && (listState.heapManage = "Invalid", b.heapManageInit(listState.heapManage)), a.offset + a.num > c && c >= a.num) {
                    var e = c - a.offset;
                    a.num = e > 0 ? e : a.num
                }
                listState.typeName = a.typeName, listState.order = a.order, listState.startDate = a.startDate, listState.endDate = a.endDate;
                var f = function (c) {
                    var d = (new Date).getTime();
                    if (1 == a.rebuild) {
                        if (0 != c.ret) return gListUI.showBigTip({
                            type: "PleaseTry",
                            content: gList.loadDataTips.loadlistfail
                        }), void 0;
                        if (listState.data = c, 0 == c.list.length) return gListUI.empty(), gListUI.showBigTip({
                            type: "ListNotFind",
                            content: gList.loadDataTips.notfind[listState.listName]
                        }), void 0;
                        listState.offset = a.offset
                    } else {
                        if (0 == c.list.length) return;
                        for (var e = listState.data.list.length, f = 0; c.list.length > f; f++) c.list[f].showIndex += e;
                        listState.data.list = listState.data.list.concat(c.list)
                    }
                    listState.totalNum = c.totalNum;
                    var g = listState.totalNum;
                    if (c.limitNum && (listState.limitTotalNum = c.limitNum), b.paginationInit(g, b.loadList, a), b.listInit(c, a.mode, a.rebuild), a.rebuild) {
                        var h = (new Date).getTime(),
                            i = d - reqListMoment,
                            j = h - d;
                        base.stat({
                            f: "pageLoadTime",
                            listDomReadyTime: listDomReadyTime,
                            reqListTime: i,
                            renderListTime: j,
                            p: "vodlist"
                        })
                    }
                }, g = function (b) {
                        if (b) {
                            if (4 != b.readyState) return b.statusText && "timeout" == b.statusText && 1 == a.rebuild && gListUI.showBigTip({
                                type: "PleaseTry",
                                content: gList.loadDataTips.timeout
                            }), void 0;
                            if ("abort" == b.statusText) return;
                            if ("timeout" == b.statusText) {
                                if (1 == a.rebuild) return gListUI.showBigTip({
                                    type: "PleaseTry",
                                    content: gList.loadDataTips.timeout
                                }), void 0
                            } else if (1 == a.rebuild) return gListUI.showBigTip({
                                type: "PleaseTry",
                                content: gList.loadDataTips.loadlistfail
                            }), void 0
                        }
                    };
                a.success = f, a.fail = g, 1 == a.rebuild && (gListUI.showBigTip({
                    type: "Loding",
                    content: gList.loadDataTips.loading
                }), reqListMoment = (new Date).getTime());
                var h = gData.getList(a);
                1 == a.rebuild && (lastListAjax && lastListAjax.abort(), lastListAjax = h, gList.dropMenuQueue("clear"))
            },
            genPicAddr: function (a) {
                a = a || "";
                var b = "0",
                    c = "",
                    d = "_X96";
                if (0 == a.search(/^[0-9a-zA-Z]/)) {
                    var e = a.charAt(0),
                        f = parseInt(e, 16);
                    f >= 0 && 15 >= f && (f %= 5, b = f.toString())
                }
                var g = "http://i" + b + ".xlpan.kanimg.com/pic/" + a + d + c + ".jpg";
                return g
            },
            loadPics: function (a) {
                for (var b = [], c = [], d = 0; a.length > d; d++) "Success" != a[d].picState && "File" == a[d].type && ("BtFile" == a[d].typeName ? c.push(a[d]) : b.push(a[d]));
                var e = listConfig.picMode;
                if ("Ping" != e) {
                    if ("Req" == e) {
                        if (0 != b.length) {
                            for (var f = [], g = [], d = 0; b.length > d; d++) null == b[d].gcid ? b[d].picState = "Invalid" : (f.push(b[d]), g.push(b[d].gcid));
                            if (0 == g.length) return;
                            var h = function (a) {
                                for (var b = {}, c = 0; a.length > c; c++) {
                                    var d = a[c].gcid,
                                        g = a[c].smallshot_url;
                                    b[d] = g
                                }
                                for (var c = 0; f.length > c; c++) {
                                    var d = f[c].gcid;
                                    void 0 != b[d] && (f[c].picSrc = b[d], f[c].picState = "Success")
                                }
                                gListUI.showPics(f, e)
                            }, i = {
                                    typeName: "File",
                                    gcids: g,
                                    success: h,
                                    fail: function () {}
                                };
                            gData.getPics(i)
                        }
                        if (0 != c.length) {
                            for (var j = c[0].info_hash, k = [], d = 0; c.length > d; d++) k.push(c[d].index);
                            var h = function (a) {
                                for (var b = {}, d = 0; a.length > d; d++) {
                                    var f = a[d].idx,
                                        g = a[d].smallshot_url;
                                    b[f] = g
                                }
                                for (var d = 0; c.length > d; d++) {
                                    var f = c[d].index;
                                    void 0 != b[f] && (c[d].picSrc = b[f], c[d].picState = "Success")
                                }
                                gListUI.showPics(c, e)
                            }, i = {
                                    typeName: "BtFile",
                                    info_hash: j,
                                    indexs: k,
                                    success: h,
                                    fail: function () {}
                                };
                            gData.getPics(i)
                        }
                    }
                } else {
                    if (0 != b.length) {
                        for (var f = [], d = 0; b.length > d; d++) null == b[d].gcid ? b[d].picState = "Invalid" : b[d].gcid && (b[d].picSrc = this.genPicAddr(b[d].gcid), b[d].picState = "Success", f.push(b[d]));
                        if (0 == f.length) return;
                        gListUI.showPics(f, e)
                    }
                    if (0 != c.length) {
                        for (var f = [], d = 0; c.length > d; d++) c[d].gcid && (c[d].picSrc = this.genPicAddr(c[d].gcid), c[d].picState = "Success", f.push(c[d]));
                        if (0 == f.length) return;
                        gListUI.showPics(c, e)
                    }
                }
            },
            loadProgress: function (a, b) {
                var d = listState.mode;
                if (b = b || "", "lixian" != listState.listName) {
                    for (var e = [], f = [], g = 0; a.length > g; g++) "onefilebt" == b && a[g].onefilebt && "Yes" != a[g].onefilebt || 5 != a[g].progState && 7 != a[g].progState && (e.push(a[g]), f.push(a[g].url_hash));
                    if (0 != f.length) {
                        var h = function (a) {
                            for (var b = {}, c = 0; a.length > c; c++) {
                                var f = a[c].url_hash,
                                    g = a[c].progress;
                                b[f] = g
                            }
                            for (var c = 0; e.length > c; c++) {
                                var h = e[c].url_hash;
                                if (void 0 != b[h]) {
                                    var i = b[h],
                                        j = i.split("_");
                                    e[c].progState = j[0], e[c].progScale = j[1]
                                }
                            }
                            for (var c = 0; e.length > c; c++) {
                                var k = e[c];
                                "Thumb" == d ? gListUI.showThumbProgress(k, k.progState, k.progScale) : "List" == d && gListUI.showListProgress(k, k.progState, k.progScale)
                            }
                        };
                        gData.getProgress({
                            idArr: f,
                            success: h
                        })
                    }
                }
            },
            loadOneFileBt: function (a) {
                for (var b = this, c = [], d = 0; a.length > d; d++) "Folder" == a[d].type && "Invalid" == a[d].onefilebt && c.push(a[d]);
                if (0 != c.length)
                    for (var e = 0, f = c.length, g = function () {
                            if (++e, e == f) {
                                var a = listState.data.list;
                                b.loadProgress(a, "onefilebt")
                            }
                        }, d = 0; c.length > d; d++) {
                        var h = c[d],
                            i = h.src_url.substring(5, 45);
                        (function (a) {
                            gData.getList({
                                type: "Folder",
                                typeName: "BtFolder",
                                typeValue: i,
                                num: 2,
                                fail: function () {
                                    g()
                                },
                                success: function (d) {
                                    b.buildOneFileBT(d, c[a].showIndex), g()
                                }
                            })
                        })(d)
                    }
            },
            buildOneFileBT: function (a, b) {
                var c = listState;
                if (1 != a.list.length) return c.data.list[b].onefilebt = "No", void 0;
                var d = c.data.list[b],
                    e = a.list[0];
                e.showIndex = d.showIndex, e.file_name = d.file_name, e.shortName = d.shortName, e.listShortName = d.listShortName, e.showTime = d.showTime, e.src_url = d.src_url, e.icoName = "bt", e.playFlag = d.playFlag, e.onefilebt = "Yes", e.parent_url_hash = d.url_hash;
                var f = gListUI.toListData(c.mode, {
                    list: [e]
                }),
                    g = $("#" + d.url_hash);
                g.after(f), g.remove(), c.data.list[b] = e, this.loadProgress({
                    indexArr: [b]
                }), this.contentEventInit(c.mode, listState.heapManage), "Thumb" == listState.mode && this.loadPics([e])
            },
            progressTimer: null,
            autoLoadProgress: function () {
                var a = this;
                clearTimeout(a.progressTimer), a.progressTimer = setTimeout(function () {
                    var b = listState.data.list;
                    a.loadProgress(b), a.autoLoadProgress()
                }, 25e3)
            },
            popDownloadLayer: function (a, b) {
                var c = listState.data.list[a],
                    d = "";
                b && (d = b);
                var e = $("#downloadLayer"),
                    f = $("#closeDWLayer"),
                    g = $("#bgMask"),
                    h = $("#dwLayerBtn"),
                    i = e.find("input[name=clarity]"),
                    j = {
                        dwBtn: !1,
                        tpl: {
                            name: ["chaoqing", "gaoqing", "liuchang", "yuanshi"],
                            obj: {
                                enable: !1,
                                gcid: "",
                                filename: "",
                                url: ""
                            }
                        },
                        items: {}
                    };
                if (!isIpad) {
                    var k = j.tpl.name,
                        l = j.tpl.obj;
                    for (num in k) {
                        var m = k[num];
                        j.items[m] = {}, $.extend(j.items[m], l)
                    }
                    var n = j.items.yuanshi,
                        o = this.transSrcUrl(c.src_url);
                    o && (n.enable = !0, n.gcid = c.gcid, n.filename = c.file_name, n.url = o), c.gcid && (n.gcid = c.gcid, n.filename = c.file_name), i.attr("checked", !1);
                    var p = function () {
                        var a = j.items;
                        if (d && a[d].enable) {
                            var b = "[value=" + d + "]",
                                c = i.filter(b);
                            return c.attr("checked", !0), c.next("span").addClass("color2"), j.dwBtn = !0, void 0
                        }
                        for (name in a) {
                            var e = a[name].enable,
                                b = "[value=" + name + "]",
                                c = i.filter(b);
                            if (c.next("span").removeClass("color2"), e) {
                                c.attr("checked", !0), c.next("span").addClass("color2"), j.dwBtn = !0;
                                break
                            }
                        }
                    };
                    p(), g.show(), e.show(), f.unbind("click").click(function () {
                        return g.hide(), e.hide(), !1
                    });
                    var q = function () {
                        var a = j.items;
                        for (name in a) {
                            var b = a[name].enable,
                                c = "input[value=" + name + "]",
                                d = e.find(c);
                            d.attr("disabled", !b), b ? d.next("span").addClass("color2") : d.next("span").removeClass("color2")
                        }
                        j.dwBtn ? h.removeClass("p_btn2_gray").addClass("p_btn1") : h.removeClass("p_btn1").addClass("p_btn2_gray")
                    };
                    i.unbind("click").click(function () {
                        j.dwBtn = !0, q()
                    }), h.unbind("click").click(function () {
                        if (0 == j.dwBtn) return !1;
                        var a = i.filter(":checked").attr("value"),
                            b = j.items[a];
                        base.stat({
                            b: "download",
                            dwType: a,
                            p: "vodlist"
                        });
                        var c = b.url.toLowerCase();
                        return "yuanshi" == a && -1 != c.indexOf("xlpan") ? (gData.getXLpanDWAddr({
                            url: b.url,
                            callback: function (a) {
                                a ? base.thunderDown(b.gcid, a, b.filename) : alert("对不起，暂时无法获取该下载链接。")
                            }
                        }), !1) : (base.thunderDown(b.gcid, b.url, b.filename), !1)
                    });
                    var r = function (a) {
                        var b = {
                            liuchang: "SD",
                            gaoqing: "HD",
                            chaoqing: "Full_HD"
                        };
                        for (name in b) {
                            var c = b[name],
                                d = a[c];
                            if (d && "object" == typeof d && d.url) {
                                j.dwBtn = !0;
                                var e = j.items[name];
                                e.enable = !0, e.gcid = d.gcid, e.filename = d.filename, e.url = d.url
                            }
                        }
                        q(), p()
                    };
                    n.gcid && gData.getDownloadAddr({
                        gcid: n.gcid,
                        filename: n.filename,
                        callback: r
                    }), q(), "File" == c.type ? base.stat({
                        b: "singleDownload",
                        p: "vodlist"
                    }) : base.stat({
                        b: "multiDownload",
                        p: "vodlist"
                    })
                }
            },
            deleteFile: function (a) {
                var b = this,
                    c = {
                        cmd: "",
                        indexArr: [],
                        urlHashArr: [],
                        infoHashArr: [],
                        convert: !1
                    };
                if (a = $.extend(c, a), a.convert === !1) {
                    for (var d = listState.data.list, e = 0; a.indexArr.length > e; e++) {
                        var f = a.indexArr[e],
                            g = d[f];
                        if ("Folder" == g.type)
                            if (g.src_url.length > 46) a.urlHashArr.push(g.url_hash);
                            else {
                                var h = g.src_url.substring(5, 45);
                                a.infoHashArr.push(h)
                            } else if ("BtFile" != g.typeName) a.urlHashArr.push(g.url_hash);
                        else if (g.src_url.length > 46) g.parent_url_hash ? a.urlHashArr.push(g.parent_url_hash) : a.urlHashArr.push(g.main_url_hash);
                        else {
                            var h = g.src_url.substring(5, 45);
                            a.infoHashArr.push(h)
                        }
                    }
                    a.convert = !0
                }
                switch (a.cmd) {
                case "popConfirm":
                    if (a.cmd = "serverDelete", "Managing" == listState.heapManage && a.indexArr.length > 1) var i = "您确定要批量删除这些任务吗？",
                    j = "批量删除提示";
                    else var i = "您确定要删除此任务吗？",
                    j = "确认删除任务";
                    gListUI.popConfirm({
                        type: "Delete",
                        title: j,
                        content: i,
                        callback: function () {
                            b.deleteFile(a)
                        }
                    });
                    break;
                case "serverDelete":
                    a.cmd = "clientDelete";
                    var k = function (c) {
                        0 != c ? 1 == c ? (gListUI.showLittleTip({
                            content: "用户帐号信息验证失败,建议重新登录"
                        }), b.goHomePage("sidExpired")) : gListUI.showLittleTip({
                            content: "删除失败，请重试"
                        }) : (gListUI.showLittleTip({
                            content: "删除成功"
                        }), b.deleteFile(a))
                    }, l = function (a) {
                            return a && "timeout" == a.statusText ? (gListUI.showLittleTip({
                                content: "删除失败，请重试"
                            }), void 0) : void 0
                        };
                    if ("Managing" == listState.heapManage && a.indexArr.length > 1) var i = "批量删除中...";
                    else var i = "正在删除任务...";
                    gListUI.showLittleTip({
                        content: i,
                        time: -1,
                        showLoading: !0,
                        showMask: !0
                    }), gData.deleteList(a.urlHashArr, a.infoHashArr, k, l);
                    break;
                case "clientDelete":
                    var m = a.indexArr;
                    this.deleteShowItem(m)
                }
            },
            deleteShowItem: function (a) {
                items = gListUI.getElement("ListDataArea").children();
                for (var c = a.length, d = 0; a.length > d; d++) {
                    var e = a[d];
                    listState.data.list[e] = -1, items.eq(e).remove()
                }
                for (var d = 0; listState.data.list.length > d; d++) {
                    var f = listState.data.list[d]; - 1 === f && (listState.data.list.splice(d, 1), --d)
                }
                for (var d = 0; listState.data.list.length > d; d++) listState.data.list[d].showIndex = d;
                items = gListUI.getElement("ListDataArea").children();
                for (var d = 0; items.length > d; d++) items.eq(d).attr("index", d);
                if (0 != c) {
                    var g = c,
                        h = listState.totalNum,
                        i = listState.limitTotalNum,
                        j = listState.perPageNum,
                        k = listState.offset,
                        l = !1,
                        m = -1;
                    h >= i ? m = i - g : h > k + j ? m = k + j - g : (listState.totalNum = h -= c, h > 0 && h == k && h - j >= 0 ? (m = h - j, g = j, l = !0) : 0 == h && gListUI.showBigTip({
                        type: "ListNotFind",
                        content: gList.loadDataTips.notfind[listState.listName]
                    })), -1 !== m && this.loadList({
                        offset: m,
                        num: g,
                        rebuild: l
                    })
                }
            },
            modifyHideState: function (a) {
                var b = this,
                    c = listState.data.list,
                    d = {
                        toType: "",
                        indexArr: [],
                        idArr: []
                    };
                a = $.extend(d, a);
                for (var g, e = {
                        yincang: "隐藏",
                        quxiaoyincang: "非隐藏"
                    }, f = a.toType, h = 0; a.indexArr.length > h; h++) {
                    var i = a.indexArr[h];
                    g = c[i].playFlag.yincang, g = 1 == g ? "yincang" : "quxiaoyincang", g == f && (a.indexArr.splice(h, 1), --h)
                }
                if (0 == a.indexArr.length) return gListUI.showLittleTip({
                    content: "已经标记为" + e[f]
                }), void 0;
                a.idArr = $.map(a.indexArr, function (a) {
                    return "BtFile" != c[a].typeName ? c[a].url_hash : c[a].main_url_hash
                });
                var j = function (c) {
                    if (1 == c) return gListUI.showLittleTip({
                        content: "用户帐号信息验证失败,建议重新登录"
                    }), b.goHomePage("sidExpired"), void 0;
                    if (0 != c) {
                        if ("yincang" == f)
                            if ("Managing" == listState.heapManage && a.indexArr.length > 1) var d = "批量隐藏失败，请重试";
                            else var d = "隐藏失败,请重试";
                            else if ("Managing" == listState.heapManage && a.indexArr.length > 1) var d = "批量取消隐藏失败，请重试";
                        else var d = "取消隐藏失败,请重试";
                        gListUI.showLittleTip({
                            content: d
                        })
                    } else {
                        if ("yincang" == f)
                            if ("Managing" == listState.heapManage && a.indexArr.length > 1) var d = "批量隐藏成功";
                            else var d = "隐藏成功，已加入隐藏任务列表";
                            else if ("Managing" == listState.heapManage && a.indexArr.length > 1) var d = "批量取消隐藏成功";
                        else var d = "取消隐藏成功";
                        gListUI.showLittleTip({
                            content: d
                        });
                        var e = a.indexArr;
                        b.deleteShowItem(e)
                    }
                }, k = function (b) {
                        if (b && "timeout" == b.statusText) {
                            if ("yincang" == f)
                                if ("Managing" == listState.heapManage && a.indexArr.length > 1) var c = "批量隐藏失败，请重试";
                                else var c = "隐藏失败,请重试";
                                else if ("Managing" == listState.heapManage && a.indexArr.length > 1) var c = "批量取消隐藏失败，请重试";
                            else var c = "取消隐藏失败,请重试";
                            return gListUI.showLittleTip({
                                content: c
                            }), void 0
                        }
                    };
                if ("yincang" == f)
                    if ("Managing" == listState.heapManage && a.indexArr.length > 1) var l = "批量隐藏中...";
                    else var l = "正在隐藏任务...";
                    else if ("Managing" == listState.heapManage && a.indexArr.length > 1) var l = "批量取消隐藏中...";
                else var l = "正在取消隐藏...";
                gListUI.showLittleTip({
                    content: l,
                    time: -1,
                    showLoading: !0,
                    showMask: !0
                }), gData.reqModifyType(f, a.idArr, j, k)
            },
            modifyVisitState: function (a) {
                var b = this,
                    c = listState.data.list,
                    d = {
                        toType: "",
                        indexArr: [],
                        idArr: []
                    };
                a = $.extend(d, a);
                for (var g, e = {
                        yikan: "已看",
                        daikan: "待看"
                    }, f = a.toType, h = 0; a.indexArr.length > h; h++) {
                    var i = a.indexArr[h];
                    g = c[i].playFlag.daikan, g = 1 == g ? "daikan" : "yikan", g == f && (a.indexArr.splice(h, 1), --h)
                }
                if (0 == a.indexArr.length) return gListUI.showLittleTip({
                    content: "已经标记为" + e[f]
                }), void 0;
                a.idArr = $.map(a.indexArr, function (a) {
                    return "BtFile" != c[a].typeName ? c[a].url_hash : c[a].main_url_hash
                });
                var j = function (d) {
                    if (1 == d) return gListUI.showLittleTip({
                        content: "用户帐号信息验证失败,建议重新登录"
                    }), b.goHomePage("sidExpired"), void 0;
                    if (0 != d) {
                        if ("Managing" == listState.heapManage && a.indexArr.length > 1) var g = "批量更改为" + e[f] + "失败，请重试";
                        else var g = "标记失败,请重试";
                        gListUI.showLittleTip({
                            content: g
                        })
                    } else {
                        if ("Managing" == listState.heapManage && a.indexArr.length > 1) var g = "批量更改为" + e[f] + "成功";
                        else var g = "成功标记为" + e[f];
                        gListUI.showLittleTip({
                            content: g
                        });
                        var h = a.indexArr;
                        if ("daikan" != listState.typeName && "yikan" != listState.typeName)
                            for (var i = 0; h.length > i; i++) {
                                var j = c[h[i]],
                                    k = j.url_hash;
                                k = $("#" + k).find("a[name=openLink]"), "yikan" == f ? (j.playFlag.yikan = !0, j.playFlag.daikan = !1, k.addClass("yikan")) : (j.playFlag.yikan = !1, j.playFlag.daikan = !0, k.removeClass("yikan"))
                            } else b.deleteShowItem(h)
                    }
                }, k = function (b) {
                        if (b && "timeout" == b.statusText) {
                            if ("Managing" == listState.heapManage && a.indexArr.length > 1) var c = "批量更改为" + e[f] + "失败,请重试";
                            else var c = "标记失败,请重试";
                            return gListUI.showLittleTip({
                                content: c
                            }), void 0
                        }
                    };
                if ("Managing" == listState.heapManage && a.indexArr.length > 1) var l = "批量更改为" + e[f] + "中...";
                else var l = "正在标记为" + e[f] + "...";
                gListUI.showLittleTip({
                    content: l,
                    time: -1,
                    showLoading: !0,
                    showMask: !0
                }), gData.reqModifyType(f, a.idArr, j, k)
            },
            openFile: function (a) {
                if (!base.isLogin()) return window.open(homePageUrl, "_self"), !1;
                var b = base.getGoIp(),
                    c = base.getCookie("userid") + "_" + vodUserInfo.oriType + "_" + base.getCookie("sessionid"),
                    d = listState.data.list,
                    e = d[a],
                    f = arguments[1];
                if ("File" == e.type) {
                    var g = "Invalid" == e.progState || 5 == e.progState || 7 == e.progState;
                    if (0 == g) return;
                    var h;
                    switch (e.typeName) {
                    case "BtFile":
                        h = {
                            uvs: c,
                            from: "vlist",
                            url: "bt://" + e.info_hash + "/" + e.index,
                            list: listState.listName,
                            folder: base.encode(listState.folderName),
                            p: Math.floor(listState.offset / listState.perPageNum) + 1
                        }, "Yes" == e.onefilebt && (h.folder = base.encode(e.file_name), h.onefilebt = 1);
                        break;
                    default:
                        h = {
                            uvs: c,
                            from: "vlist",
                            url: e.src_url,
                            filesize: e.file_size,
                            gcid: e.gcid,
                            cid: e.cid,
                            filename: base.encode(e.file_name),
                            list: listState.listName,
                            p: Math.floor(listState.offset / listState.perPageNum) + 1
                        }
                    }
                    "vodVipUser" != vodUserInfo.type && "oldVodVipUser" != vodUserInfo.type && 0 == vodUserInfo.fluxValue && (h.tryplay = 1), ("vodVipUser" == vodUserInfo.type || "oldVodVipUser" == vodUserInfo.type) && (h.isVodVip = 1), f && (h.format = f);
                    var i = "vodplay",
                        j = "http://" + b + "/iplay.html?" + base.linkQuery(h);
                    if (isClient && (h.from = "vodClientList", j = "http://vod.xunlei.com/client/cplayer.html?" + base.linkQuery(h), i = "_self"), isIpad && "vodVipUser" != vodUserInfo.type && "oldVodVipUser" != vodUserInfo.type) return base.showPayTutor(), void 0;
                    if (isClient) {
                        try {
                            window.external.openVodClientWindow("player", "open", j)
                        } catch (k) {}
                        return
                    }
                    var l = window.open(j, i);
                    try {
                        l && l.open && !l.closed && l.focus()
                    } catch (k) {}
                } else if ("Folder" == e.type) {
                    if (8 == e.progState || 10 == e.progState || 11 == e.progState) return;
                    var m = e.src_url.substring(5, 45),
                        n = {
                            folder: e.file_name,
                            value: m,
                            order: listState.order,
                            createTime: e.createTime,
                            playTime: "--"
                        };
                    this.selectMenu(n)
                }
            },
            heapManageInit: function (a) {
                if (a != listState.mode) {
                    var b = this,
                        c = gListUI.getElement("ListMain"),
                        d = gListUI.getElement("HeapManageBtn"),
                        e = gListUI.getElement("HeapManagePanel"),
                        f = $("#yinCangBtn");
                    "yincang" == listState.listName ? (f.attr("name", "quxiaoyincang"), f.find("a").text("取消隐藏")) : (f.attr("name", "yincang"), f.find("a").text("隐藏")), e.css("width", c[0].clientWidth);
                    var g = null;
                    if ($(window).resize(function () {
                        clearTimeout(g), g = setTimeout(function () {
                            e.css("width", c[0].clientWidth)
                        }, 25)
                    }), "unManaging" == a) {
                        gListUI.showHeapManage("unManaging"), listState.heapManage = "unManaging", d.unbind("click").bind("click", function () {
                            gList.dropMenuQueue("clear"), "unManaging" == listState.heapManage ? (gListUI.showHeapManage("Managing"), listState.heapManage = "Managing", b.contentEventInit(listState.mode, listState.heapManage)) : "Managing" == listState.heapManage && (gListUI.showHeapManage("unManaging"), listState.heapManage = "unManaging", b.contentEventInit(listState.mode, listState.heapManage)), base.stat({
                                b: "heap_manage",
                                p: "vodlist"
                            }), isIE && $(window).resize()
                        });
                        var h = e.find("input:checkbox");
                        h.attr("checked", !1), h.unbind("click").bind("click", function () {
                            gListUI.getElement("ListCheckBox").attr("checked", this.checked), gListUI.refreshSelectAll()
                        });
                        var i = e.find("a[name=checkAll]");
                        i.unbind("click").bind("click", function () {
                            var a = h[0].checked;
                            1 == a ? h.attr("checked", !1) : h.attr("checked", !0), gListUI.getElement("ListCheckBox").attr("checked", h[0].checked), gListUI.refreshSelectAll()
                        });
                        var j = e.find("span[name=heapDelete]");
                        j.unbind("click").bind("click", function () {
                            var a = gListUI.getElement("ListCheckBox").filter("input:checked");
                            a = a.closest("[index]");
                            var c = [];
                            a.each(function (a) {
                                var a = $(this).attr("index");
                                c.push(a)
                            }), 0 != c.length && (b.deleteFile({
                                cmd: "popConfirm",
                                indexArr: c
                            }), base.stat({
                                b: "heap_delete",
                                p: "vodlist"
                            }))
                        });
                        var k = e.find("span[name=heapMore]");
                        k.unbind("click").bind("click", function (a) {
                            a.stopPropagation();
                            var b = gListUI.getElement("ListCheckBox").filter("input:checked");
                            b = b.closest("[index]");
                            var c = [];
                            if (b.each(function (a) {
                                var a = $(this).attr("index");
                                c.push(a)
                            }), 0 != c.length) {
                                var d = $(this).find("[name=heapMoreList]");
                                d.toggle(), gList.dropMenuQueue("add", function () {
                                    d.hide()
                                })
                            }
                        });
                        var l = e.find("[name=yikan], [name=daikan], [name=yincang], [name=quxiaoyincang]");
                        l.unbind("click").bind("click", function () {
                            var a = gListUI.getElement("ListCheckBox").filter("input:checked");
                            a = a.closest("[index]");
                            var b = [];
                            if (a.each(function (a) {
                                var a = $(this).attr("index");
                                b.push(a)
                            }), 0 != b.length) {
                                var c = $(this).attr("name");
                                "yincang" == c || "quxiaoyincang" == c ? gList.modifyHideState({
                                    toType: c,
                                    indexArr: b
                                }) : ("yikan" == c || "daikan" == c) && gList.modifyVisitState({
                                    toType: c,
                                    indexArr: b
                                }), base.stat({
                                    b: "heap_" + c,
                                    p: "vodlist"
                                })
                            }
                        })
                    } else "Invalid" == a && (d.unbind("click"), gListUI.showHeapManage("Invalid"), listState.heapManage = "Invalid")
                }
            },
            dropMenuQueue: function (a, b) {
                var c = function () {
                    for (var a = 0; queueHide.length > a; ++a) {
                        var b = queueHide[a];
                        b(), queueHide.shift()
                    }
                };
                "init" == a ? $(document).live("click", function () {
                    c()
                }) : "add" == a ? queueHide.push(b) : "clear" == a && c()
            },
            checkboxState: function (a, b) {
                if ("getChecked" == a) {
                    var c = gListUI.getElement("ListDataArea").children().has("input:checked"),
                        d = [];
                    return c.each(function (a) {
                        var a = $(this).attr("index");
                        d.push(a)
                    }), d
                }
                if ("setChecked" == a) {
                    if (0 == b.length) return;
                    for (var e, c = gListUI.getElement("ListCheckBox"), f = 0; b.length > f; f++) e = b[f], c.eq(e).attr("checked", !0);
                    return gListUI.refreshSelectAll(), void 0
                }
            },
            getQueryStringArgs: function (a) {
                for (var b = a.length > 0 ? a.substring(1) : "", c = {}, d = b.split("&"), e = null, f = null, g = null, h = 0; d.length > h; h++) e = d[h].split("="), f = decodeURIComponent(e[0]), g = decodeURIComponent(e[1]), c[f] = g;
                return c
            }
        };
        window.gList = gList
    }(window), $(document).ready(function () {
        var c, a = $("#proxy_i")[0],
            b = 0,
            d = !1,
            e = function () {
                clearTimeout(c), b++, b > 6e3 && (gList.pageAble = !1, gData.init(), gList.LoginIint());
                try {
                    d = a.contentWindow && a.contentWindow.jQuery
                } catch (f) {
                    c = setTimeout(e, 5)
                }
                d ? (gData.init(), gList.LoginIint(), gTask.pageInit()) : c = setTimeout(e, 5)
            };
        e(), topNotice.autoShowInit(), base.stat({
            p: "vodlist",
            f: "pv"
        });
        var f = function () {
            base.checkEnv("IE6") && require.async("gallery/DD_belatedPNG/1.0.0/DD_belatedPNG", function (a) {
                a.fix(".rad, .rad_l, .png")
            });
            var a = "https:" == document.location.protocol ? " https://" : " http://",
                b = document.createElement("script");
            if (b.type = "text/javascript", b.src = a + "hm.baidu.com/h.js?cb40dd55b713d4ff8da1d8e032c83cd4", document.body.appendChild(b), "client" != base.getPlatForm()) {
                var c = document.title;
                try {
                    document.attachEvent("onpropertychange", function () {
                        document.title != c && (document.title = c)
                    })
                } catch (d) {}
            }
        };
        base.loadAction(f)
    }), gSpeedTest = {
        init: function () {
            var a = this,
                b = function (b) {
                    a.startSpeedTest(b, 1, function (b) {
                        a.uploadSpeedInfo(b)
                    })
                };
            this.getSpeedTest(function (c) {
                1 == c && a.getSpeedHosts(b)
            })
        },
        picSpeedTest: function (a, b) {
            var c = a.url,
                d = a.macRoom,
                e = 0,
                f = 0,
                g = !1;
            "function" != typeof b && (b = function () {});
            var h = new Image;
            h = $(h), $(h).bind("load", function () {
                if (1 != g) {
                    g = !0, f = (new Date).getTime();
                    var a = f - e;
                    b({
                        macRoom: d,
                        url: c,
                        time: a
                    })
                }
            }), e = (new Date).getTime();
            var i = c + "?t=" + (new Date).getTime();
            h.attr("src", i), setTimeout(function () {
                0 == g && (g = !0, b({
                    macRoom: d,
                    url: c,
                    time: -1
                }))
            }, 1e4)
        },
        startSpeedTest: function (a, b, c) {
            var d = this,
                e = [],
                f = 0,
                g = {
                    ctrl: function () {},
                    send: function () {}
                };
            g.ctrl = function () {
                var d = a.length;
                if (0 == d && c(e), d >= b) {
                    var f = a.splice(0, b);
                    g.send(f)
                } else {
                    var f = a.splice(0, d);
                    g.send(f)
                }
            }, g.send = function (a) {
                var b = a.length;
                f = b;
                for (var c = 0; b > c; ++c) d.picSpeedTest(a[c], function (a) {
                    e.push(a), --f, 0 == f && g.ctrl()
                })
            }, g.ctrl()
        },
        getSpeedTest: function (a) {
            var b = function (b) {
                var c = b.resp.ret;
                2 == c ? a(1) : a(0)
            }, c = function () {
                    a(0)
                }, d = ["http://i.vod.xunlei.com", "cdn/req_query_cdn_info"];
            d = d.join("/");
            var e = {
                userid: base.getCookie("userid"),
                t: (new Date).getTime()
            }, f = {
                    url: d,
                    dataType: "jsonp",
                    jsonp: "jsonp",
                    data: e,
                    processData: !0,
                    timeout: 7e3,
                    error: c,
                    success: b
                }, g = $.ajax(f);
            return g
        },
        getSpeedHosts: function (a) {
            var b = [{
                macRoom: "t10",
                url: "http://t28a04.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t11",
                url: "http://t02a60.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t12",
                url: "http://t28b56.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t13",
                url: "http://t30a23.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t14",
                url: "http://t28c10.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t15",
                url: "http://t3630.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t16",
                url: "http://t21031.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t17",
                url: "http://t25043.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t18",
                url: "http://t10025.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t3",
                url: "http://t0458.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t5",
                url: "http://t0677.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t6",
                url: "http://t0575.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t7",
                url: "http://t1904.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t8",
                url: "http://t0157.sandai.net:8808/cdn_speed.jpg"
            }, {
                macRoom: "t9",
                url: "http://t2849.sandai.net:8808/cdn_speed.jpg"
            }],
                c = function (b) {
                    if (b && b.resp && 0 == b.resp.ret && b.resp.test_hosts) {
                        for (var c = b.resp.test_hosts, d = [], e = 0; c.length > e; ++e) {
                            var f = c[e],
                                g = {
                                    macRoom: f[0],
                                    url: f[1]
                                };
                            d.push(g)
                        }
                        a(d)
                    }
                }, d = function () {
                    a(b)
                }, e = ["http://i.vod.xunlei.com", "cdn/req_cdn_test_hosts"];
            e = e.join("/");
            var f = {
                t: (new Date).getTime()
            }, g = {
                    url: e,
                    dataType: "jsonp",
                    jsonp: "jsonp",
                    data: f,
                    processData: !0,
                    timeout: 7e3,
                    error: d,
                    success: c
                }, h = $.ajax(g);
            return h
        },
        uploadSpeedInfo: function (a) {
            for (var b = [], c = [], d = 0; a.length > d; ++d) {
                var e = a[d];
                b.push(e.macRoom), c.push(e.time)
            }
            var f = ["http://i.vod.xunlei.com", "cdn/req_report_cdn_info"];
            f = f.join("/");
            var g = {
                userid: base.getCookie("userid"),
                scns: b.join("_"),
                speeds: c.join("_"),
                t: (new Date).getTime()
            }, h = {
                    url: f,
                    dataType: "jsonp",
                    jsonp: "jsonp",
                    data: g,
                    processData: !0,
                    timeout: 7e3,
                    error: function () {},
                    success: function () {}
                }, i = $.ajax(h);
            return i
        }
    };
    var realSpeedTestInit = function () {
        setTimeout(function () {
            gSpeedTest.init()
        }, 3e3)
    };
    base.loadAction(realSpeedTestInit)
}), define("app/list/1.0.0/task", ["gallery/jquery/1.0.0/jquery", "common/base/1.0.0/base", "common/placeholder/1.0.0/placeholder"], function (require) {
    var $ = require("gallery/jquery/1.0.0/jquery"),
        jQuery = $,
        base = require("common/base/1.0.0/base"),
        placeholder = require("common/placeholder/1.0.0/placeholder"),
        INTERFACE = "http://dynamic.vod.lixian.xunlei.com/interface/",
        gISERVER = "http://i.vod.xunlei.com/",
        isTaskValid = !1,
        isTaskSubmiting = !1,
        taskType = "url",
        from = "vlist",
        taskCheckTime = 500,
        timeoutTime = 1e4,
        addRecordsTimer = null,
        btTaskTips = "点击右侧浏览按钮添加bt种子",
        urlTaskTips = "多个url请选择回车换行，最多支持100条任务",
        foldState = !1,
        isClient = !1;
    "client" == base.getPlatForm() && (isClient = !0);
    var taskConfig = {
        urlTaskButton: "urlTaskButton",
        btTaskButton: "btTaskButton",
        btUploader: "btUploader",
        submitButton: "submitTask",
        submitButtonEnableStyle: "",
        submitButtonDisableStyle: "p_btn2_gray",
        inputArea: "inputArea",
        btTaskInput: "btTaskInput",
        urlTaskArea: "urlTaskArea",
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
    }, taskTips = {
            userInfoError: "用户帐号信息验证失败，建议重新登录",
            taskQueryinng: "正在查询任务信息...",
            taskSubmiting: "正在上传到云空间...",
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
        }, uploaderConfig = {
            description: "请选择BT种子文件(*.torrent)",
            extension: "*.torrent",
            timeOut: 30,
            url: INTERFACE + "upload_bt?from=" + from,
            label: "",
            limitSize: 6291456,
            jsPrefix: "gTask.",
            asPrefix: "gTask_",
            isImmediately: !1
        }, lastBtTaskReq = btTaskTips,
        lastUrlTaskReqUrls = urlTaskTips,
        curBatchTaskReqUrls = "",
        lastBatchTaskReqUrls = "",
        curBatchTaskReqResult = [],
        lastBatchTaskReqResult = [],
        urlTaskCheckTimer = null,
        gTask = {}, prototype = {
            pageInit: function () {
                var a = this;
                gTask = this, window.gTask = this, taskConfig.proxy = document.getElementById(taskConfig.proxyId).contentWindow, a.genUploadButton(taskConfig.btUploader, "http://vod.xunlei.com/media/fileUploader.swf?t=" + (new Date).getTime(), uploaderConfig, "76", "28"), $("#" + taskConfig.urlTaskButton).unbind().click(function () {
                    if (isTaskSubmiting) return !1;
                    $("#" + taskConfig.btTaskButton).removeClass(taskConfig.onStyle), $(this).addClass(taskConfig.onStyle), a.showSubmitTips(0), taskType = "url";
                    var b = $("#" + taskConfig.urlResultDisplayArea);
                    a.setSubmitButtonStatus(!1), $("#" + taskConfig.inputArea).hide(), $("#" + taskConfig.urlTaskArea).show(), $("#" + taskConfig.urlTaskInput).focus(), b.find("li").length > 0 && b.show(), a.updateSubmitButtonStatus(), a.totalNumPanel("show")
                }), $("#" + taskConfig.btTaskButton).unbind().click(function () {
                    return "bt" == taskType || isTaskSubmiting ? !1 : (taskType = "bt", $("#" + taskConfig.urlTaskButton).removeClass(taskConfig.onStyle), $("#" + taskConfig.btTaskButton).addClass(taskConfig.onStyle), $("#" + taskConfig.btTaskInput).val(lastBtTaskReq), $("#" + taskConfig.inputArea).show(), $("#" + taskConfig.urlTaskArea).hide(), $("#" + taskConfig.urlResultDisplayArea).hide(), lastBtTaskReq && lastBtTaskReq == btTaskTips ? a.setSubmitButtonStatus(!1) : base.checkEnv("IE") ? a.setSubmitButtonStatus(!0) : (lastBtTaskReq = btTaskTips, $("#" + taskConfig.btTaskInput).val(btTaskTips), a.setSubmitButtonStatus(!1)), a.showSubmitTips(0), a.totalNumPanel("hide"), urlTaskCheckTimer && clearInterval(urlTaskCheckTimer), void 0)
                });
                var b = $("#" + taskConfig.urlTaskInput);
                b.placeholder(), b.focus(function () {
                    urlTaskCheckTimer && clearInterval(urlTaskCheckTimer), urlTaskCheckTimer = setInterval(function () {
                        a.queryNames()
                    }, taskCheckTime)
                }).blur(function () {
                    clearInterval(urlTaskCheckTimer)
                }), $("#" + taskConfig.btTaskInput).focus(function () {
                    $(this).val() == btTaskTips && $(this).val("")
                }).blur(function () {
                    "" == $(this).val() && $(this).val(btTaskTips)
                }), $("#" + taskConfig.submitButton).unbind().click(function () {
                    return isTaskValid ? (a.showSubmitTips(1, taskTips.taskSubmiting), isTaskSubmiting = !0, "url" == taskType ? a.submitUrlTask() : a.submitBtTask(), !1) : !1
                });
                var c = base.$PU("playurl") || "";
                if (c = base.$PU("addurl") || c) {
                    c = base.decode(c);
                    var d = "";
                    base.$PU("addname") && (d = base.$PU("addname")), d = base.decode(d);
                    var e = {
                        urls: []
                    };
                    obj = {
                        id: 1,
                        url: base.encode(c),
                        name: base.encode(d)
                    }, e.urls.push(obj), e = JSON.stringify(e), a.doAddTask(e, a.doAddTaskDone, a.doAddTaskError)
                }
            },
            queryNames: function () {
                var a = this;
                b = "";
                var b = $("#" + taskConfig.urlTaskInput).val().trim();
                if (lastUrlTaskReqUrls && lastUrlTaskReqUrls == b) return !1;
                if (a.showSubmitTips(0), lastUrlTaskReqUrls = b, !b) return $("#" + taskConfig.urlResultDisplayArea).html("").hide(), a.updateSubmitButtonStatus(), !1;
                var c = b.split("\n"),
                    d = c.length,
                    e = [],
                    f = [];
                curBatchTaskReqResult = [];
                for (var g = "<ul>", h = 0, i = 0; d > i; i++) {
                    var j = c[i];
                    if ($.trim(j)) {
                        if (h >= taskConfig.maxUrlNum) {
                            a.showSubmitTips(2, taskTips.taskNumTooMany);
                            break
                        }
                        var l = a.getValidUrl(j),
                            m = a.inLastRequest(j, e);
                        if (m) curBatchTaskReqResult.push({
                            id: h,
                            url: encodeURIComponent(j),
                            name: taskTips.taskRepeat,
                            result: -1
                        });
                        else if (l) {
                            var n = a.inLastRequest(encodeURIComponent(l), lastBatchTaskReqResult);
                            n ? curBatchTaskReqResult.push({
                                id: h,
                                url: n.item.url,
                                name: n.item.name,
                                result: n.item.result
                            }) : f.push({
                                id: h,
                                url: encodeURIComponent(l)
                            })
                        } else curBatchTaskReqResult.push({
                            id: h,
                            url: j,
                            name: taskTips.urlInputError,
                            result: 6
                        });
                        g += '<li index="' + h + '"><input type="checkbox"  value="" disabled="true" name="checkitem" class="c_b" ><input disabled="true" name="filename" class="i_p" type="text" value=""></li>', e.push({
                            id: h,
                            url: j
                        }), h++
                    }
                }
                if (g += "</ul>", $("#" + taskConfig.urlResultDisplayArea).html(g), f.length > 0) {
                    a.showSubmitTips(1, taskTips.taskQueryinng), a.setSubmitButtonStatus(!1);
                    var o = gISERVER + "req_video_name?from=" + from + "&platform=" + isIpad;
                    a.vodPost(o, JSON.stringify({
                        urls: f
                    }), a.queryNamesDone, a.queryNamesError)
                } else a.queryNamesDone({
                    resp: {
                        ret: 0,
                        res: curBatchTaskReqResult,
                        local: 1
                    }
                });
                $("#" + taskConfig.urlResultDisplayArea).scrollTop(1e5)
            },
            queryNamesError: function () {
                $("#" + taskConfig.urlResultDisplayArea).html("").hide(), gTask.setSubmitButtonStatus(!1), gTask.showSubmitTips(2, taskTips.timeout)
            },
            queryNamesDone: function (a) {
                var b = gTask;
                b.showSubmitTips(0, "", 1);
                var a = a.resp;
                if (a) {
                    var d = a.ret,
                        e = a.res;
                    if (0 == d)
                        if (e.length > 0) {
                            a.local || (curBatchTaskReqResult = curBatchTaskReqResult.concat(a.res));
                            for (var f = curBatchTaskReqResult.length, g = 0; f > g; g++) {
                                var h = curBatchTaskReqResult[g],
                                    i = $("#" + taskConfig.urlResultDisplayArea + " li[index=" + h.id + "]"),
                                    j = i.find('input[name="filename"]'),
                                    k = i.find('input[name="checkitem"]');
                                if (0 == h.result) {
                                    var l = base.getNameExt(b.decode(h.name));
                                    j.val(l.name), j.removeAttr("disabled"), j.attr("ext", l.ext).attr("oriName", l.name), k.attr("checked", "checked"), k.removeAttr("disabled")
                                } else {
                                    var m = taskTips.urlInputError;
                                    8 == h.result ? m = taskTips.urlNotVideo : -1 == h.result && (m = taskTips.taskRepeat), k.removeAttr("checked"), j.after("<p " + taskConfig.errorFlagValue + '="' + taskConfig.errorFlag + '" class="err_tip1"><span>！</span>' + m + "</p>")
                                }
                            }
                            $("#" + taskConfig.urlResultDisplayArea).show()
                        } else $("#" + taskConfig.urlResultDisplayArea + " li").length > 0 && $("#" + taskConfig.urlResultDisplayArea).show();
                        else $("#" + taskConfig.urlResultDisplayArea).html("").hide(), gTask.showSubmitTips(2, taskTips.svrError)
                }
                var n = $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checkbox"),
                    o = n.find("input:text");
                o.bind("keyup", b.verifyNameInput), o.bind("blur", b.verifyNameInput), b.updateSubmitButtonStatus(), n = n.find("input:checkbox").unbind("click").bind("click", b.updateSubmitButtonStatus), b.totalNumPanel("show")
            },
            doAddTask: function (a, b, c) {
                if (void 0 == a || void 0 == b) return -1;
                base.stat({
                    from: "vodlist",
                    p: "vodlist",
                    f: "tasktype",
                    ty: taskType,
                    num: "url" == taskType && $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checked").length > 0 ? $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checked").length : 1
                });
                var d = this,
                    e = d.getCookie("userid"),
                    f = d.getCookie("sessionid"),
                    g = gISERVER + "req_add_record?from=" + from + "&platform=" + isIpad + "&userid=" + e + "&sessionid=" + f;
                d.vodPost(g, a, b, c)
            },
            doAddTaskError: function () {
                gTask.showSubmitTips(2, taskTips.timeout), isTaskSubmiting = !1, gTask.setSubmitButtonStatus(!0)
            },
            doAddTaskDone: function (a) {
                isTaskSubmiting = !1;
                var b = gTask;
                if (a.resp) {
                    var c = a.resp.ret,
                        d = "";
                    if (0 == c) {
                        for (var e = a.resp.res, f = e.length, g = 0; f > g; g++) {
                            if (0 == e[g].result) {
                                var h = "http://" + window.parent.location.host + "/list.html";
                                return isClient && (h = "http://" + window.parent.location.host + "/client/clist.html"), window.parent.location = h, !1
                            }
                            d = 8 == e[g].result ? "url" == taskType ? taskTips.urlNotVideo : taskTips.btNotVideo : 6 == e[g].result || 2 == e[g].result ? taskTips.paramError : taskTips.svrError
                        }
                        f > 1 && (d = taskTips.taskContainsError), b.showSubmitTips(2, d)
                    } else 1 == c ? (d = taskTips.userInfoError, gList.goHomePage("sidExpired")) : d = 3 == c ? taskTips.timeout : taskTips.svrError, b.showSubmitTips(2, d)
                } else b.showSubmitTips(2, taskTips.svrError)
            },
            submitUrlTask: function () {
                var a = gTask,
                    b = $("li").has("p[class=" + taskConfig.errorFlagValue + "]");
                b.remove();
                var c = $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checked"),
                    d = c.find("input:text"),
                    e = c.length;
                if (0 != e) {
                    var f = 0;
                    if (d.each(function () {
                        var b = a.verifyNameInput.call(this);
                        0 != b && (f = 1)
                    }), 1 != f) {
                        for (var g = curBatchTaskReqResult, h = {
                                urls: []
                            }, i = 0; e > i; ++i) {
                            var j = c.eq(i).attr("index"),
                                k = c.eq(i).find("input:text").val();
                            k = $.trim(k), c.eq(i).find("input:text").attr("ext") && (k = k + "." + c.eq(i).find("input:text").attr("ext"));
                            for (var l = g.length, m = null, n = 0; l > i; n++)
                                if (j == g[n].id) {
                                    m = {
                                        id: g[n].id,
                                        url: g[n].url,
                                        name: base.encode(k)
                                    };
                                    break
                                }
                            h.urls.push(m)
                        }
                        h = JSON.stringify(h), a.setSubmitButtonStatus(!1), a.doAddTask(h, a.doAddTaskDone, a.doAddTaskError)
                    }
                }
            },
            genUploadButton: function (a, b, c, d, e) {
                if (isIpad || !a || !b) return !1;
                var f = [];
                for (var g in c) f.push(g + "=" + c[g]);
                var h = f.join("&"),
                    d = d || 100,
                    e = e || 40,
                    i = {
                        wmode: "transparent",
                        allowScriptAccess: "always",
                        flashvars: h
                    }, j = {
                        id: "uploader",
                        name: "uploader"
                    };
                if (!isIpad) {
                    var k = function (c) {
                        c.embedSWF(b, a, d, e, "9.0.0", "libaray/expressInstall.swf", h, i, j)
                    };
                    require.async("gallery/swfobject/1.0.0/swfobject", function (a) {
                        k(a)
                    })
                }
            },
            setFilename: function (a) {
                lastBtTaskReq = a, $("#" + taskConfig.btTaskInput).val(a), this.showSubmitTips(0), this.setSubmitButtonStatus(!0)
            },
            submitBtTask: function () {
                this.setSubmitButtonStatus(!1), document.getElementById("uploader").gTask_uploadFile()
            },
            uploadError: function (a) {
                isTaskSubmiting = !1;
                var c = "";
                c = 6 == a ? taskTips.btUploadTimeout : 5 == a ? taskTips.btTooLarge : taskTips.btUplaodFail, this.showSubmitTips(2, c), this.setSubmitButtonStatus(!1)
            },
            uploadSuccess: function (result, filename) {
                var that = this;
                isTaskSubmiting = !1;
                var errorMsg = taskTips.svrError;
                if (result) {
                    eval("var resp = " + result + ";");
                    var ret = resp.ret;
                    if (0 == ret && 40 == resp.infohash.length) return qureyData = JSON.stringify({
                        urls: [{
                            id: "1",
                            url: "bt://" + resp.infohash
                        }]
                    }), that.doAddTask(qureyData, that.doAddTaskDone, that.doAddTaskError), !1;
                    2 == ret ? errorMsg = taskTips.paramError : 6 == ret && (errorMsg = taskTips.btParseError)
                } else errorMsg = taskConfig.btUplaodFail;
                this.showSubmitTips(2, errorMsg)
            },
            decode: function (a) {
                var b = "";
                try {
                    b = decodeURIComponent(decodeURIComponent(a))
                } catch (c) {
                    try {
                        b = decodeURIComponent(a)
                    } catch (c) {
                        b = a
                    }
                }
                return b
            },
            getCookie: function (a) {
                return null == document.cookie.match(new RegExp("(^" + a + "| " + a + ")=([^;]*)")) ? "" : RegExp.$2
            },
            resetTaskVal: function () {
                var a = this;
                isTaskValid = !0, taskType = "url", lastBtTaskReq = btTaskTips, lastUrlTaskReqUrls = urlTaskTips, isIpad && $("#" + taskConfig.btTaskButton).hide(), $("#" + taskConfig.btTaskButton).removeClass(taskConfig.onStyle), $("#" + taskConfig.urlTaskButton).addClass(taskConfig.onStyle), a.showSubmitTips(0), a.setSubmitButtonStatus(!1), $("#" + taskConfig.btTaskInput).val(btTaskTips), $("#" + taskConfig.inputArea).hide(), $("#" + taskConfig.urlResultDisplayArea).html("").hide(), $("#" + taskConfig.urlTaskArea).show();
                var b = $("#" + taskConfig.urlTaskInput);
                "" != b.val() && b.val(""), a.totalNumPanel("init")
            },
            showSubmitTips: function (a, b, c) {
                var b = b || "";
                ("undefined" == a || null == a) && (a = 0), 0 == a ? ($("#" + taskConfig.waitingTips).hide(), c || $("#" + taskConfig.errorTips).html("").hide()) : 1 == a ? (c || $("#" + taskConfig.errorTips).html("").hide(), $("#" + taskConfig.waitingTips).html("").html(b).show()) : 2 == a && (c || $("#" + taskConfig.waitingTips).hide(), $("#" + taskConfig.errorTips).html("").html(b).show())
            },
            genProxy: function () {
                $("body").append("<iframe id='" + taskConfig.proxyId + "' name='" + taskConfig.proxyName + "' src='" + taskConfig.porxyPath + "' width='0' height='0' style='display:none;'></iframe>"), taskConfig.proxy = document.getElementById(taskConfig.proxyId).contentWindow
            },
            vodPost: function (a, b, c, d) {
                return base.isLogin() ? (taskConfig.proxy.$.ajax({
                    type: "POST",
                    dataType: "json",
                    url: a,
                    data: b,
                    timeout: timeoutTime,
                    error: function () {
                        d()
                    },
                    success: function (a) {
                        c(a)
                    }
                }), void 0) : (gList.goHomePage("logStateError", "uidEmpty"), void 0)
            },
            inLastRequest: function (a, b) {
                if (!b || "object" != typeof b || 1 > b.length) return !1;
                for (var c = b.length, d = 0; c > d; d++)
                    if (b[d].url == a) return {
                        index: d,
                        item: b[d]
                    };
                return !1
            },
            getValidUrl: function (a) {
                if (!a) return !1;
                var b = "xlpan://|thunder://|ftp://|http://|https://|ed2k://|mms://|magnet:|rtsp://|flashget://|qqdl://|bt://|xlpan%3A%2F%2F|thunder%3A%2F%2F|ftp%3A%2F%2F|http%3A%2F%2F|https%3A%2F%2F|ed2k%3A%2F%2F|mms%3A%2F%2F|magnet%3A|rtsp%3A%2F%2F|flashget%3A%2F%2F|qqdl%3A%2F%2F|bt%3A%2F%2F",
                    a = $.trim(a);
                if (-1 != a.search(/^www|\nwww/)) return a;
                var c = new RegExp("(" + b + ").*", "i");
                if (!a.match(c)) return !1;
                if (a.match(/magnet.*/i)) return a;
                var d = "xlpan|thunder|ftp|http|https|ed2k|mms|magnet|rtsp|flashget|qqdl|bt",
                    e = new RegExp("(" + d + ").*[?](" + d + ").*", "i"),
                    f = a.match(e);
                if (f) {
                    var h = new RegExp("((" + d + ").*[?](" + d + ").*?)((" + b + ").*)", "i");
                    f = a.match(h)
                } else {
                    var g = new RegExp("((" + d + ").*?)((" + b + ").*)", "i");
                    f = a.match(g)
                }
                return f && f[1] ? f[1] : a
            },
            verifyName: function (a) {
                var b;
                b = 0;
                var c = /^[^`~!@#$%^&*+=|\\:;'"/?<>]{1}[^`~!@#$%^&*+=|\\:;'"\/?<>]{0,}$/;
                return c.exec(a) || (b = "！检测到非法字符( `~!@#$%^&*+=|\\:;'\"/?<> )"), 1 > $.trim(a).length && (b = "请先输入文件名"), a.length > 50 && (b = "文件名不能超过50个字符"), b
            },
            updateSubmitButtonStatus: function () {
                var a = gTask;
                $("#" + taskConfig.submitButton);
                var c = $("#" + taskConfig.urlResultDisplayArea + " li").has("input:checked"),
                    d = $("li").has("p[class=" + taskConfig.errorFlagValue + "]");
                c.length > 0 && 0 == d.length ? a.setSubmitButtonStatus(!0) : a.setSubmitButtonStatus(!1), a.totalNumPanel("show")
            },
            setSubmitButtonStatus: function (a) {
                0 == a ? ($("#" + taskConfig.submitButton).addClass(taskConfig.submitButtonDisableStyle), isTaskValid = !1) : ($("#" + taskConfig.submitButton).removeClass(taskConfig.submitButtonDisableStyle), isTaskValid = !0)
            },
            verifyNameInput: function () {
                var a = gTask,
                    b = 0,
                    c = $(this).val();
                c != $(this).attr("oriName") && (b = a.verifyName(c));
                var d = $(this).parent();
                if (d.next().find("p").attr("class") == taskConfig.errorFlagValue && d.next().remove(), 0 != b) {
                    var e = "<li><p class='" + taskConfig.errorFlagValue + "'>" + b + "</p></li>";
                    d.after(e)
                }
                return a.updateSubmitButtonStatus(), b
            },
            totalNumPanel: function (a) {
                var e, b = $("#" + taskConfig.totalNumPanel),
                    c = b.find("a"),
                    d = $("#" + taskConfig.urlResultDisplayArea),
                    f = function () {
                        c.removeClass("up_arr").addClass("down_arr").text("展开"), d.hide(), foldState = !0
                    }, g = function () {
                        c.removeClass("down_arr").addClass("up_arr").text("收起"), d.show(), foldState = !1
                    }, h = function () {
                        foldState ? (g(), base.stat({
                            b: "addtask_tounfold",
                            p: "vodlist"
                        })) : (f(), base.stat({
                            b: "addtask_tofold",
                            p: "vodlist"
                        }))
                    };
                switch (a) {
                case "init":
                    c.unbind("click").bind("click", h), b.hide(), foldState = 768 > window.screen.height ? !0 : !1;
                    break;
                case "show":
                    var i = d.find("li"),
                        e = i.has("input:checked"),
                        j = e.length;
                    if (0 == i.length) return b.hide(), void 0;
                    foldState ? f() : g(), b.find("span").text("共" + j + "个视频"), b.show();
                    break;
                case "hide":
                    b.hide()
                }
            }
        };
    return prototype
});
