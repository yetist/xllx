/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-vod.c: This file is part of ____
 *
 * Copyright (C) 2013 yetist <xiaotian.wu@i-soft.com.cn>
 *
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 * */
/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-vod.c: This file is part of ____
 *
 * Copyright (C) 2013 yetist <xiaotian.wu@i-soft.com.cn>
 *
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 * */

#include "xl-vod.h"

#include <json.h>
#include <string.h>

#include "xllx.h"
#include "xl-cookies.h"
#include "xl-client.h"
#include "xl-http.h"
#include "xl-url.h"
#include "xl-utils.h"
#include "smemory.h"
#include "logger.h"
#include "md5.h"

#define DEFAULT_REFERER "http://i.vod.xunlei.com/proxy.html?v2.82"

struct _XLVod
{
	XLClient *client;
};

XLVod* xl_vod_new(XLClient *client)
{
	if (!client)
	{
		return NULL;
	}
	XLVod *vod = s_malloc0(sizeof(*vod));
	vod->client = client;
	return vod;
}

void xl_vod_free(XLVod *vod)
{
	if (!vod)
		return ;

	xl_client_free(vod->client);
	s_free(vod);
}

int xl_vod_has_video(XLVod *vod, const char* url)
{
	return 0;
}

#if 0
void xl_vod_get_userinfo()
{
	//Refer: http://vod.xunlei.com/list.html?userid=288543553
	//http://i.vod.xunlei.com/get_user_info?jsonp=jQuery182008909468542787469_1376055673399&userid=288543553&from=vodLogin&t=1376055674585&_=1376055674597
	//jQuery182008909468542787469_1376055673399({"vtime": 0, "level": 1, "timestamp": 1376055678975, "userid": 288543553, "flux": 0, "expire": "20140808", "payayear": 1, "last_expire": "20140808", "type": 0})
}

void check_user_info()
{
	//Refer: http://i.vod.xunlei.com/proxy.html?v2.82
	//http://i.vod.xunlei.com/check_user_info?userid=288543553&sessionid=F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&ip=0&from=vodlist&t=1376055674628
	//{"userid": 288543553, "expire": "20140808", "payayear": 1, "result": 0, "vip_level": 1, "flux_remain": 0}
}

history_play_list(void)
{
	//Refer: http://i.vod.xunlei.com/proxy.html?v2.82
	//http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=all&order=create&t=1376055675715
	//返回信息
	{"resp": {
		"history_play_list":
				 [
				 {
					"ip": "222.128.181.139",
					"gcid": "A74C828D94C8E419D0238C168780C97C30AD6F15",
					"url_hash": "7330933771486410590",
					"res_list": null,
					"from": "vlist",
					"vod_info": null,
					"cid": "DECE9E4F67AA199E3D7135757AD686AF35228F9D",
					"url": "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=",
					"file_name": "%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv",
					"userid": "288543553",
					"ordertime": 1376044486,
					"file_info": null,
					"datafrom": "req_history_play_list",
					"platform": 0,
					"src_url": "thunder%3A//QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D",
					"file_size": 1261414195,
					"duration": 6013120,
					"playtime": "2013-08-09 19:33:14",
					"playflag": 4,
					"createtime": "2013-08-09 18:34:46"
				 },
				 {
					 "ip": "222.128.181.139",
					 "gcid": null,
					 "url_hash": "7651461091677318816",
					 "res_list": null,
					 "from": "vlist",
					 "vod_info": null,
					 "cid": null,
					 "url": "thunder0X1.02728097026C8P-8720.0000000.000000QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
					 "file_name": "%E4%B8%AD%E5%9B%BD%E5%90%88%E4%BC%99%E4%BA%BABD.rmvb",
					 "userid": "288543553",
					 "ordertime": 1376040983,
					 "file_info": null,
					 "datafrom": "req_history_play_list",
					 "platform": 0,
					 "src_url": "thunder0X1.02728097026C8P-8720.0000000.000000QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU%20MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
					 "file_size": null,
					 "duration": 0,
					 "playtime": "2013-08-09 17:36:23",
					 "playflag": 0,
					 "createtime": "2013-08-09 17:36:23"
				 }
				 ],
		"max_num": 1500,
		"userid": "288543553",
		"ret": 0,
		"end_t": null,
		"record_num": 2,
		"start_t": null,
		"type": "all"}
	}
}

check_ip_info()
{
	// Refer: http://vod.xunlei.com/list.html?userid=288543553
	// http://i.vod.xunlei.com/check_ip_info?jsonp=jQuery182008909468542787469_1376055673400&userid=288543553&from=vodlist&_=1376055675836
	// jQuery182008909468542787469_1376055673400({"userid": "288543553", "result": 1})
}

query_progress()
{
	// Refer: http://i.vod.xunlei.com/proxy.html?v2.82
	// http://i.vod.xunlei.com/req_progress_query?&t=1376055678407
	// POST: {"req":{"url_hash_list":["7330933771486410590","7651461091677318816"],"platform":0}}

	//返回内容
	{"resp": {"progress_info_list": [{"progress": "5_10000", "url_hash": "7330933771486410590"}, {"progress": "5_10000", "url_hash": "7651461091677318816"}], "userid": "288543553", "ret": 0}}
}

query_cdn_info()
{
	//Refer: http://vod.xunlei.com/list.html?userid=288543553
	//http://i.vod.xunlei.com/cdn/req_query_cdn_info?jsonp=jQuery182008909468542787469_1376055673400&userid=288543553&t=1376055678516&_=1376055678523
	//返回内容
	//jQuery182008909468542787469_1376055673400({"resp": {"cdn_info": [], "net_type": 1, "userid": "288543553", "error_msg": "test cdn again", "ret": 2}})
}

cdn_test_hosts()
{
	//Refer: http://vod.xunlei.com/list.html?userid=288543553
	//http://i.vod.xunlei.com/cdn/req_cdn_test_hosts?jsonp=jQuery182008909468542787469_1376055673400&t=1376055680813&_=1376055680817
	jQuery182008909468542787469_1376055673400({"resp": {"test_hosts": [["c10", "http://c2434.sandai.net:8808/cdn_speed.jpg"], ["c11", "http://c1738.sandai.net:8808/cdn_speed.jpg"], ["c12", "http://c2530.sandai.net:8808/cdn_speed.jpg"], ["c13", "http://c05027.sandai.net:8808/cdn_speed.jpg"], ["c4", "http://c1061.sandai.net:8808/cdn_speed.jpg"], ["c5", "http://c1102.sandai.net:8808/cdn_speed.jpg"], ["c6", "http://c2146.sandai.net:8808/cdn_speed.jpg"], ["c7", "http://c1557.sandai.net:8808/cdn_speed.jpg"], ["c8", "http://c21a50.sandai.net:8808/cdn_speed.jpg"], ["c9", "http://c2256.sandai.net:8808/cdn_speed.jpg"], ["c18", "http://c20e005.sandai.net:8808/cdn_speed.jpg"], ["c19", "http://c05b030.sandai.net:8808/cdn_speed.jpg"]], "net_type": 1, "ret": 0}})

}

req_report_cdn_info()
{
	//Refer: http://vod.xunlei.com/list.html?userid=288543553
	//http://i.vod.xunlei.com/cdn/req_report_cdn_info?jsonp=jQuery182008909468542787469_1376055673400&userid=288543553&scns=c10_c11_c12_c13_c4_c5_c6_c7_c8_c9_c18_c19&speeds=2480_1550_1090_932_362_607_758_1112_2759_2029_575_-1&t=1376055707068&_=1376055707081
	jQuery182008909468542787469_1376055673400({"resp": {"userid": "288543553", "ret": 0}})

}

history_play_list()
{
	//Refer: http://i.vod.xunlei.com/proxy.html?v2.82
	//http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=yikan&order=create&t=1376056099662
	{"resp": {"history_play_list": [], "max_num": 1500, "userid": "288543553", "ret": 0, "end_t": null, "record_num": 0, "start_t": null, "type": "yikan"}}
}

req_history_play_list()
{
	//Refer: http://i.vod.xunlei.com/proxy.html?v2.82
	// http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=all&order=create&t=1376057158154
	{
		"resp": 
		{
			"history_play_list": 
				[
				{
					"ip": "222.128.181.139",
						"gcid": "A74C828D94C8E419D0238C168780C97C30AD6F15",
						"url_hash": "7330933771486410590",
						"res_list": null,
						"from": "vlist",
						"gcidlist": [
						{
							"gcid": "887BD0D7E72F7EAFE19F787507F2AA1D19B5BD6D",
							"specid": "LH"
						},
						{
							"gcid": "DCF593C8DC3AF6DB85BA4C2BE2E446BB609C11C2",
							"specid": "L"
						},
						{
							"gcid": "1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267",
							"specid": "M"
						},
						{
							"gcid": "1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267",
							"specid": "H"
						}
					],
						"vod_info": null,
						"cid": "DECE9E4F67AA199E3D7135757AD686AF35228F9D",
						"file_name": "%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv",
						"userid": "288543553",
						"ordertime": 1376044486,
						"file_info": null,
						"datafrom": "req_history_play_list",
						"platform": 0,
						"src_url": "thunder%3A//QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D",
						"file_size": 1261414195,
						"duration": 6013120,
						"playtime": "2013-08-09 19:33:14",
						"playflag": 4,
						"createtime": "2013-08-09 18:34:46"
				},
				{
					"ip": "222.128.181.139",
					"gcid": null,
					"url_hash": "7651461091677318816",
					"res_list": null,
					"from": "vlist",
					"gcidlist": [],
					"vod_info": null,
					"cid": null,
					"file_name": "%E4%B8%AD%E5%9B%BD%E5%90%88%E4%BC%99%E4%BA%BABD.rmvb",
					"userid": "288543553",
					"ordertime": 1376040983,
					"file_info": null,
					"datafrom": "req_history_play_list",
					"platform": 0,
					"src_url": "thunder0X1.02728097026C8P-8720.0000000.000000QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU%20MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
					"file_size": null,
					"duration": 0,
					"playtime": "2013-08-09 17:36:23",
					"playflag": 0,
					"createtime": "2013-08-09 17:36:23"
				}
			],
				"max_num": 1500,
				"userid": "288543553",
				"ret": 0,
				"end_t": null,
				"record_num": 2,
				"start_t": null,
				"type": "all"
		}
	}
}

req_progress_query()
{
	//Refer: http://i.vod.xunlei.com/proxy.html?v2.82
	//http://i.vod.xunlei.com/req_progress_query?&t=1376057159987
	//POST: {"req":{"url_hash_list":["7330933771486410590","7651461091677318816"],"platform":0}}
	{"resp": {"progress_info_list": [{"progress": "5_10000", "url_hash": "7330933771486410590"}, {"progress": "5_10000", "url_hash": "7651461091677318816"}], "userid": "288543553", "ret": 0}}

}

//以上完成列表功能

/* 点击播放 */
get_user_info()
{
	//Refer: http://vod.xunlei.com/iplay.html?uvs=288543553_0_F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&from=vlist&url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&filesize=1261414195&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filename=%255B%25E9%2598%25B3%25E5%2585%2589%25E7%2594%25B5%25E5%25BD%25B1www.ygdy8.com%255D.%25E5%258F%25B6%25E9%2597%25AE%25EF%25BC%259A%25E7%25BB%2588%25E6%259E%2581%25E4%25B8%2580%25E6%2588%2598.BD.720p.%25E5%259B%25BD%25E7%25B2%25A4%25E5%258F%258C%25E8%25AF%25AD%25E4%25B8%25AD%25E5%25AD%2597.mkv&list=all&p=1&isVodVip=1

	//http://i.vod.xunlei.com/get_user_info?jsonp=jQuery18202834776476852303_1376059367752&userid=288543553&from=vodLogin&t=1376059367999&_=1376059368009
	jQuery18202834776476852303_1376059367752({"vtime": 0, "level": 1, "timestamp": 1376059371812, "userid": 288543553, "flux": 0, "expire": "20140808", "payayear": 1, "last_expire": "20140808", "type": 0})
}

check_ip_info()
{
	//Refer: http://vod.xunlei.com/iplay.html?uvs=288543553_0_F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&from=vlist&url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&filesize=1261414195&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filename=%255B%25E9%2598%25B3%25E5%2585%2589%25E7%2594%25B5%25E5%25BD%25B1www.ygdy8.com%255D.%25E5%258F%25B6%25E9%2597%25AE%25EF%25BC%259A%25E7%25BB%2588%25E6%259E%2581%25E4%25B8%2580%25E6%2588%2598.BD.720p.%25E5%259B%25BD%25E7%25B2%25A4%25E5%258F%258C%25E8%25AF%25AD%25E4%25B8%25AD%25E5%25AD%2597.mkv&list=all&p=1&isVodVip=1
	//http://i.vod.xunlei.com/check_ip_info?jsonp=jQuery18202834776476852303_1376059367753&userid=288543553&from=vodplay&_=1376059369349
	jQuery18202834776476852303_1376059367753({"userid": "288543553", "result": 1})
}


req_get_method()
{
	//Refer: http://vod.xunlei.com/iplay.html?uvs=288543553_0_F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&from=vlist&url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&filesize=1261414195&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filename=%255B%25E9%2598%25B3%25E5%2585%2589%25E7%2594%25B5%25E5%25BD%25B1www.ygdy8.com%255D.%25E5%258F%25B6%25E9%2597%25AE%25EF%25BC%259A%25E7%25BB%2588%25E6%259E%2581%25E4%25B8%2580%25E6%2588%2598.BD.720p.%25E5%259B%25BD%25E7%25B2%25A4%25E5%258F%258C%25E8%25AF%25AD%25E4%25B8%25AD%25E5%25AD%2597.mkv&list=all&p=1&isVodVip=1
	//URL: http://i.vod.xunlei.com/req_get_method_vod?url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&video_name=%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv&platform=0&userid=288543553&vip=1&sessionid=F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filesize=1261414195&cache=1376059370234&from=vlist&jsonp=XL_CLOUD_FX_INSTANCEqueryBack
	//XL_CLOUD_FX_INSTANCEqueryBack(
	{
		"resp": {
			"status": 0,
				"url_hash": "7330933771486410590",
				"trans_wait": 0,
				"userid": "288543553",
				"ret": 0,
				"vodinfo_list": [
				{
					"vod_urls": [ "http://dl.c18.lixian.vip.xunlei.com/download?dt=16&g=DCF593C8DC3AF6DB85BA4C2BE2E446BB609C11C2&t=2&ui=288543553&s=470460652&v_type=-1&scn=c16&it=1376077373&cc=8391333648267586370&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76" ],
					"spec_id": 225536,
					"vod_url": "http://gdl.lixian.vip.xunlei.com/download?dt=16&g=DCF593C8DC3AF6DB85BA4C2BE2E446BB609C11C2&t=2&ui=288543553&s=470460652&v_type=-1&scn=c16&it=1376077373&cc=8391333648267586370&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76",
					"has_subtitle": 1
				},
				{
					"vod_urls": [
						"http://dl.c18.lixian.vip.xunlei.com/download?dt=16&g=1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267&t=2&ui=288543553&s=1219016512&v_type=-1&scn=c16&it=1376077373&cc=17244924584470496675&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76",
						"http://dl.c19.lixian.vip.xunlei.com/download?dt=16&g=1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267&t=2&ui=288543553&s=1219016512&v_type=-1&scn=c16&it=1376077373&cc=17244924584470496675&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76"
						],
					"spec_id": 282880,
					"vod_url": "http://gdl.lixian.vip.xunlei.com/download?dt=16&g=1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267&t=2&ui=288543553&s=1219016512&v_type=-1&scn=c16&it=1376077373&cc=17244924584470496675&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76",
					"has_subtitle": 2
				},
				{
					"vod_urls": [
						"http://dl.c18.lixian.vip.xunlei.com/download?dt=16&g=1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267&t=2&ui=288543553&s=1219016512&v_type=-1&scn=c9&it=1376077373&cc=17244924584470496675&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76",
						"http://dl.c19.lixian.vip.xunlei.com/download?dt=16&g=1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267&t=2&ui=288543553&s=1219016512&v_type=-1&scn=c9&it=1376077373&cc=17244924584470496675&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76"
						],
					"spec_id": 356608,
					"vod_url": "http://gdl.lixian.vip.xunlei.com/download?dt=16&g=1458F15EBB10DBBDCFC9D75C7B5CC573A1FA7267&t=2&ui=288543553&s=1219016512&v_type=-1&scn=c9&it=1376077373&cc=17244924584470496675&p=0&n=0DEA5F38650BFD8CE72503456B5F0F72779FCFC7B297402B63DEDBFDF80BF7B3E926184F6A749FBE885728213256F8E3882998E292C04F3730C198454D539FB7A454392C3E41D5E1B81C530D41C0156E76",
					"has_subtitle": 2
				}
			],
				"duration": 6013181000,
				"vod_permit": {
					"msg": "OK",
					"ret": 0
				},
				"src_info": {
					"file_name": "[\u9633\u5149\u7535\u5f71www.ygdy8.com].\u53f6\u95ee\uff1a\u7ec8\u6781\u4e00\u6218.BD.720p.\u56fd\u7ca4\u53cc\u8bed\u4e2d\u5b57.mkv",
					"gcid": "A74C828D94C8E419D0238C168780C97C30AD6F15",
					"file_size": "1261414195",
					"cid": "DECE9E4F67AA199E3D7135757AD686AF35228F9D"
				}

		}
	}
	)
}

req_last_play_pos()
{
	//Refer: http://vod.xunlei.com/iplay.html?uvs=288543553_0_F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&from=vlist&url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&filesize=1261414195&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filename=%255B%25E9%2598%25B3%25E5%2585%2589%25E7%2594%25B5%25E5%25BD%25B1www.ygdy8.com%255D.%25E5%258F%25B6%25E9%2597%25AE%25EF%25BC%259A%25E7%25BB%2588%25E6%259E%2581%25E4%25B8%2580%25E6%2588%2598.BD.720p.%25E5%259B%25BD%25E7%25B2%25A4%25E5%258F%258C%25E8%25AF%25AD%25E4%25B8%25AD%25E5%25AD%2597.mkv&list=all&p=1&isVodVip=1
	//URL: http://i.vod.xunlei.com/req_last_play_pos?userid=288543553&query_list=7330933771486410590_0&t=1376059371514&jsonp=XL_CLOUD_FX_INSTANCEqueryLastPosBack
	//Body: XL_CLOUD_FX_INSTANCEqueryLastPosBack({"resp": {"res_list": [{"is_bt_play": 0, "url_hash": "7330933771486410590", "last_play_pos": 925}], "userid": "288543553", "ret": 0}})
}

cross_domain()
{
	//Refer: http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01
	//URL: http://i.vod.xunlei.com/crossdomain.xml
	<?xml version="1.0"?> 
		<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
		<cross-domain-policy> 
		    <allow-access-from domain="*"/> 
			    <allow-http-request-headers-from domain="*" headers="*"/> 
				</cross-domain-policy> 
}

void get_meta_data()
{
	//Refer: http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01
	//URL: http://119.188.129.126/download?dt=16&g=DCF593C8DC3AF6DB85BA4C2BE2E446BB609C11C2&t=2&ui=288543553&s=470460652&v_type=-1&scn=c16&it=1376078092&p=0&cc=5966695784691550772&n=0CD329057FAEC39EE7DE48744FC09BBC8083480AFF033B2A3757F0E2FFA4E4B9E7D764775ECD97ABAD81783F34ECE82A6D0EB692D1417F0400&start=0&end=81920&flash_meta=0&type=loadmetadata&du=6013
	//内容为视频部分。
}


void downloadn(void)
{
	//Refer: http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01
	//URL: http://vod17.c18.lixian.vip.xunlei.com/download?dt=16&g=DCF593C8DC3AF6DB85BA4C2BE2E446BB609C11C2&t=2&ui=288543553&s=470460652&v_type=-1&scn=c16&it=1376078889&cc=16545132729795102816&p=0&n=09C2055CFB3D8889E70D5921F5697A7777B795A32CA1352E63F68199663D82B6E90E422BF442EABB887F7245AC608DE68801C2860CF63A3230E9C221D365EAB2A47C6348A077A0E4B8340969DFF6606B76&ts=1376061607&start=55913294&end=103178505&type=normal&du=6013
}
#endif

static void create_get_name_post_data(const char *url, char *buf, int buflen)
{
	struct json_object *new_obj;
	struct json_object *new_array;
	struct json_object *urls_obj;
	char *pname_argument;
	new_obj = json_object_new_object();
	json_object_object_add(new_obj, "id", json_object_new_int(0));
	if (url)
	{
		char *en_url = xl_url_quote((char *)url);
		json_object_object_add(new_obj, "url", json_object_new_string(en_url));
		s_free(en_url);
	}
	new_array = json_object_new_array();
	json_object_array_add(new_array, new_obj);
	urls_obj = json_object_new_object();
	json_object_object_add(urls_obj, "urls", new_array);

	printf("to_string()=%s\n", json_object_to_json_string(urls_obj));
	pname_argument = (char *)json_object_to_json_string(urls_obj);
	snprintf(buf, buflen, "%s", pname_argument);
	json_object_put(urls_obj);
}
static void create_add_yun_post_data(const char *url, char *name, char *buf, int buflen)
{
	struct json_object *new_obj;
	struct json_object *new_array;
	struct json_object *urls_obj;
	char *pname_argument;
	new_obj = json_object_new_object();
	json_object_object_add(new_obj, "id", json_object_new_int(0));
	if (url)
	{
		char *en_url = xl_url_quote((char *)url);
		json_object_object_add(new_obj, "url", json_object_new_string(en_url));
		s_free(en_url);
		char *en_name = xl_url_quote(name);
		json_object_object_add(new_obj, "name", json_object_new_string(en_name));
		s_free(en_name);
	}
	new_array = json_object_new_array();
	json_object_array_add(new_array, new_obj);
	urls_obj = json_object_new_object();
	json_object_object_add(urls_obj, "urls", new_array);

	printf("to_string()=%s\n", json_object_to_json_string(urls_obj));
	pname_argument = (char *)json_object_to_json_string(urls_obj);
	snprintf(buf, buflen,"%s", pname_argument);
	json_object_put(urls_obj);
}

void xl_get_name_from_response(char *response, char *buf, int buflen)
{
	struct json_object *resp;
	struct json_object *resp_obj;
	struct json_object *res_array;
	struct json_object *obj;
	char *name = NULL;

	resp = json_tokener_parse(response);

	int rest = (int)json_object_object_get(resp, "ret");
	if (rest == 0)
	{
		resp_obj = json_object_object_get(resp, "resp"); 
		if (resp_obj)
		{
			res_array = json_object_object_get(resp_obj, "res"); 
			if (res_array)
			{
				obj = json_object_array_get_idx(res_array, 0);
				if (obj)
				{
					struct json_object *n = json_object_object_get(obj, "name"); 

					//char *url = (char *)json_object_object_get(obj, "url"); 
					if (n)
					{
						name = strdup(json_object_get_string(n));
						printf("name : %s\n", name);
					}
				}
			}
		}
	}
	if (name)
	{
		snprintf(buf, buflen, "%s", name);
		s_free(name);
	}
}

int xl_get_ret_from_response(char *response)
{
	struct json_object *resp;
	struct json_object *resp_obj;
	resp = json_tokener_parse(response);
	resp_obj = json_object_object_get(resp, "resp"); 
	if (resp_obj)
	{
		printf ("resp_obj: %s\n", json_object_to_json_string(resp_obj));
		int rest = (int)json_object_object_get(resp, "ret");
		if (rest == 0)
			xl_log(LOG_NOTICE, "Add yun tasks successfully\n");
			return 0;
	}

	return 1;
}

int from_url_get_name(XLVod *vod, const char* url, char *buf, int buflen)
{
	XLClient *client = vod -> client;
	char *userid;
	char *sessionid;

	XLHttp *req;
	XLErrorCode err;
	XLCookies *cookies = xl_client_get_cookies(client);

	userid = xl_cookies_get_userid(cookies);
	if (userid != NULL)
	{
		printf("\nuserid=%s\n", userid);
	}

	sessionid = xl_cookies_get_sessionid(cookies);
	if (sessionid != NULL)
	{
		printf("\nsessionid=%s\n", sessionid);
	}
	memset(buf, '\0', buflen);
	create_get_name_post_data(url, buf, buflen);

	char post_url[256];
	memset(post_url, '\0', 256);
	snprintf(post_url, sizeof(post_url), "http://i.vod.xunlei.com/req_video_name?from=vlist&platform=0");
	//XLHttp *xl_client_open_url(XLClient *client, const char *url, HttpMethod method, const char* post_data, const char* refer, XLErrorCode *err);
	req = xl_client_open_url(client, post_url, HTTP_POST, buf, DEFAULT_REFERER, &err);

	char *response = xl_http_get_response(req);
	memset(buf, '\0', buflen);
	xl_get_name_from_response(response, buf, buflen);
	return 0;
}

int xl_vod_add_video(XLVod *vod, const char* url)
{
	XLClient *client = vod -> client;

	XLHttp *req;
	XLErrorCode err;
//	url = "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=";
	char *userid;
	char *sessionid;
	char buf[256];

	XLCookies *cookies = xl_client_get_cookies(client);

	userid = xl_cookies_get_userid(cookies);
	if (userid != NULL)
	{
		printf("\nuserid=%s\n", userid);
	}

	sessionid = xl_cookies_get_sessionid(cookies);
	if (sessionid != NULL)
	{
		printf("\nsessionid=%s\n", sessionid);
	}
	memset(buf, '\0', 256);
	create_get_name_post_data(url, buf, 256);

	char post_url[256];
	memset(post_url, '\0', 256);
	snprintf(post_url, sizeof(post_url), "http://i.vod.xunlei.com/req_video_name?from=vlist&platform=0");
	req = xl_client_open_url(client, post_url, HTTP_POST, buf, DEFAULT_REFERER, &err);

	char *response = xl_http_get_response(req);
	char name[256];
	memset(name, '\0', 256);
	xl_get_name_from_response(response, name, 256);
	if (strcmp(name, "\"\"") == 0)
	{
		xl_log(LOG_NOTICE, "Add yun tasks failed\n");
		xl_http_free(req);
		return 0;
	}
	xl_http_free(req);
	

	memset(buf, '\0', 256);
	create_add_yun_post_data(url, name, buf, 256);
	char p_url[256];
	snprintf(p_url, sizeof(p_url), "http://i.vod.xunlei.com/req_add_record?from=vlist&platform=0&userid=%s&sessionid=%s", userid, sessionid);
	printf("p_url is %s \n", p_url);

	req = xl_client_open_url(client, p_url, HTTP_POST, buf, DEFAULT_REFERER, &err);
	response = xl_http_get_response(req);
	printf("get response %s\n",  xl_http_get_response(req));
	if (xl_get_ret_from_response(response) == 0)
	{
		xl_http_free(req);
		return 1;
	}
	xl_http_free(req);
	return 0;
}


char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type)
{
	char name[256];
	from_url_get_name(vod, url, name, 256);
	printf("get the name is %s\n", name);
	return 0;
	XLClient *client = vod -> client;
	char get_url[1024];
	char *userid, *sessionid;
	XLCookies *cookies = xl_client_get_cookies(client);

	userid = xl_cookies_get_userid(cookies);
	if (userid != NULL)
	{
		printf("\nuserid=%s\n", userid);
	}
	sessionid = xl_cookies_get_sessionid(cookies);
	if (sessionid != NULL)
	{
		printf("\nsessionid=%s\n", sessionid);
	}

	char *en_url = xl_url_quote((char *)url);
	char *en_name = xl_url_quote((char *)name);

	snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s&video_name=%s&from=vlist&platform=0&userid=%s&sessionid=%s&cache=%ld", en_url, en_name, userid, sessionid, get_current_timestamp());
	char *download_refer = "http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01";

	XLHttp *req;
	XLErrorCode err;
	req = xl_client_open_url(client, get_url, HTTP_GET, NULL, download_refer, &err);
	printf("get response %s\n",  xl_http_get_response(req));

//failed:
//	xl_http_free(req);
	//char *get_url ="http://i.vod.xunlei.com/req_get_method_vod?url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&video_name=%22%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv%22&platform=0&userid=288543553&vip=1&sessionid=F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filesize=1261414195&cache=1375959475212&from=vlist&jsonp=XL_CLOUD_FX_INSTANCEqueryBack";

}
