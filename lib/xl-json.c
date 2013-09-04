/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-json.c: This file is part of ____
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

#include <string.h>
#include <stdlib.h>
#include <json.h>
#include <bits.h>
#include <json_tokener.h>
#include "xl-json.h"
#include "smemory.h"
#include "logger.h"
#include "xl-url.h"

//static int src_url_cmp(const char *orig_url, const char *new_url);

char *json_parse_bt_hash(const char* json_str)
{
	/*
	 * json_str is {"result":"0","ret":"0","infohash":"004F50950256E66F128D528D0773FDEFBC298CCE"}
	 * return "bt://${infohash}"
	 */
	char *bt_hash= NULL;
	struct json_object *jsobj;
	struct json_object *jo_ret;
	struct json_object *jo_infohash;

	if (!json_str)
		return NULL;

	jsobj = json_tokener_parse(json_str);
	if( is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		return NULL;
	}
	jo_ret = json_object_object_get(jsobj, "ret");
	if (jo_ret)
	{
		if (atoi(json_object_get_string(jo_ret)) != 0)
		{
			json_object_put(jo_ret);
			goto failed;
		}
	}
	jo_infohash = json_object_object_get(jsobj, "infohash"); 
	if (jo_infohash)
	{
		s_asprintf(&bt_hash, "bt://%s", json_object_get_string(jo_infohash));
		json_object_put(jo_infohash);
	}
failed:
	json_object_put(jsobj);
	return bt_hash;
}

int json_parse_bt_index(const char* json_str)
{
	/*
	 * json_str is {"resp": {"userid": "111111111", "ret": 0, "subfile_list": [{"index": 0, "url_hash": "10582384012816867477", "name": "aaa58256146@\u7fa4\u9b54\u8272\u821e@(AVopen)\u611b\u7530\u53cb,\u84bc\u4e95,\u7a57\u82b1,\u5c0f\u6fa4\u746a\u5229\u4e9e,\u9ebb\u7f8e,\u9752\u6728~\u4f86\u81eaS1\u7684\u885d\u64ca.rmvb", "cid": null, "gcid": null, "file_size": 0, "duration": 0}], "main_task_url_hash": "9918101846291549545", "info_hash": "004F50950256E66F128D528D0773FDEFBC298CCE", "record_num": 1}}
	 * return "${index}"
	 */
	int index = -1;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_ret;
	struct json_object *jo_subfile_list;
	struct json_object *jo_subfile_list_0;
	struct json_object *jo_index;

	if (!json_str)
		return -1;

	jsobj = json_tokener_parse(json_str);
	if( is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		return -1;
	}
	jo_resp = json_object_object_get(jsobj, "resp");
	if (jo_resp)
	{
		jo_ret = json_object_object_get(jo_resp, "ret");
		if (jo_ret)
		{
			int ret = json_object_get_int(jo_ret);
			if (ret != 0)
			{
				json_object_put(jo_ret);
				goto failed;
			}
			json_object_put(jo_ret);
		}
		jo_subfile_list = json_object_object_get(jo_resp, "subfile_list"); 
		if (jo_subfile_list)
		{
			if (json_object_array_length(jo_subfile_list) >= 1)
			{
				jo_subfile_list_0 = json_object_array_get_idx(jo_subfile_list, 0);
				if (jo_subfile_list_0)
				{
					jo_index = json_object_object_get(jo_subfile_list_0, "index"); 
					if (jo_index)
					{
						index = json_object_get_int(jo_index);
						json_object_put(jo_index);
					}
					json_object_put(jo_subfile_list_0);
				}
			}
			json_object_put(jo_subfile_list);
		}
		json_object_put(jo_resp);
	}
failed:
	json_object_put(jsobj);
	return index;
}

int json_parse_get_return_code(const char* json_str)
{
	/*
	 * json_str is {"resp": {"kkk": "vvv", "ret": 0, "kkkk": ...}}
	 * return "${ret}"
	 */
	int ret = -1;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_ret;

	if (!json_str)
		return -1;

	jsobj = json_tokener_parse(json_str);
	if(is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		return -1;
	}

	jo_resp = json_object_object_get(jsobj, "resp");
	if (jo_resp)
	{
		jo_ret = json_object_object_get(jo_resp, "ret");
		if (jo_ret)
		{
			ret = json_object_get_int(jo_ret);
			json_object_put(jo_ret);
		}
		json_object_put(jo_resp);
	}
	json_object_put(jsobj);
	return ret;
}

#if 0
/**
 * json_parse_has_url:
 * @json_str: 
 * @url: 
 * @url_hash: return url_hash.
 *
 * 
 *
 * Return value: has url return 0; else -1;
 **/
int json_parse_has_url(const char *json_str, const char *url, char **url_hash)
{
	/*
	 *
	 *
	 * {"resp": {
	 *   "history_play_list":
	 *   [
	 *     {
	 *       "ip": "222.128.181.139",
	 *       "gcid": "A74C828D94C8E419D0238C168780C97C30AD6F15",
	 *       "url_hash": "7330933771486410590",
	 *       "res_list": null,
	 *       "from": "vlist",
	 *       "vod_info": null,
	 *       "cid": "DECE9E4F67AA199E3D7135757AD686AF35228F9D",
	 *       "url": "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=",
	 *       "file_name": "%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv",
	 *       "userid": "288543553",
	 *       "ordertime": 1376044486,
	 *       "file_info": null,
	 *       "datafrom": "req_history_play_list",
	 *       "platform": 0,
	 *       "src_url": "thunder%3A//QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D",
	 *       "file_size": 1261414195,
	 *       "duration": 6013120,
	 *       "playtime": "2013-08-09 19:33:14",
	 *       "playflag": 4,
	 *       "createtime": "2013-08-09 18:34:46"
	 *     },
	 *     {
	 *       "ip": "222.128.181.139",
	 *       "gcid": null,
	 *       "url_hash": "7651461091677318816",
	 *       "res_list": null,
	 *       "from": "vlist",
	 *       "vod_info": null,
	 *       "cid": null,
	 *       "url": "thunder0X1.02728097026C8P-8720.0000000.000000QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
	 *       "file_name": "%E4%B8%AD%E5%9B%BD%E5%90%88%E4%BC%99%E4%BA%BABD.rmvb",
	 *       "userid": "288543553",
	 *       "ordertime": 1376040983,
	 *       "file_info": null,
	 *       "datafrom": "req_history_play_list",
	 *       "platform": 0,
	 *       "src_url": "thunder0X1.02728097026C8P-8720.0000000.000000QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU%20MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
	 *       "file_size": null,
	 *       "duration": 0,
	 *       "playtime": "2013-08-09 17:36:23",
	 *       "playflag": 0,
	 *       "createtime": "2013-08-09 17:36:23"
	 *     }
	 *   ],
	 *   "max_num": 1500,
	 *   "userid": "288543553",
	 *   "ret": 0,
	 *   "end_t": null,
	 *   "record_num": 2,
	 *   "start_t": null,
	 *   "type": "all"}
	 * }
	 *
	 */
	int ret = -1;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_history_play_list;
	struct json_object *jo_history_play_list_n;
	struct json_object *jo_src_url;
	struct json_object *jo_url_hash;

	if (!json_str || !url)
	{
		if (url_hash) *url_hash = NULL;
		return -1;
	}

	jsobj = json_tokener_parse(json_str);
	if(is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		if (url_hash) *url_hash = NULL;
		return -1;
	}

	jo_resp = json_object_object_get(jsobj, "resp"); 
	if (jo_resp)
	{
		jo_history_play_list = json_object_object_get(jo_resp, "history_play_list"); 
		if (jo_history_play_list)
		{
			int i;
			for (i = 0; i < json_object_array_length(jo_history_play_list); i++)
			{
				jo_history_play_list_n = json_object_array_get_idx(jo_history_play_list, i);
				if (jo_history_play_list_n)
				{
					jo_src_url = json_object_object_get(jo_history_play_list_n, "src_url"); 
					if (jo_src_url)
					{
						const char *src_url = json_object_get_string(jo_src_url);
						char *new_url = xl_url_unquote(src_url);
						char *orig_url = xl_url_unquote(url);
						if (src_url_cmp(orig_url, new_url) == 0)
						{
							if (url_hash)
							{
								jo_url_hash = json_object_object_get(jo_history_play_list_n, "url_hash"); 
								if (jo_url_hash)
								{
									*url_hash = s_strdup(json_object_get_string(jo_url_hash));
									json_object_put(jo_url_hash);
								}
							}
							ret = 0;
							break;
						}
						s_free(orig_url);
						s_free(new_url);
						json_object_put(jo_src_url);
					}
					json_object_put(jo_history_play_list_n);
				}
			}
			json_object_put(jo_history_play_list);
		}
		json_object_put(jo_resp);
	}
	json_object_put(jsobj);
	return ret;
}
#endif

int json_parse_list_videos(const char *json_str, XLVideos *videos)
{
	/*
	 *
	 *
	 * {"resp": {
	 *   "history_play_list":
	 *   [
	 *     {
	 *       "ip": "222.128.181.139",
	 *       "gcid": "A74C828D94C8E419D0238C168780C97C30AD6F15",
	 *       "url_hash": "7330933771486410590",
	 *       "res_list": null,
	 *       "from": "vlist",
	 *       "vod_info": null,
	 *       "cid": "DECE9E4F67AA199E3D7135757AD686AF35228F9D",
	 *       "url": "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=",
	 *       "file_name": "%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv",
	 *       "userid": "288543553",
	 *       "ordertime": 1376044486,
	 *       "file_info": null,
	 *       "datafrom": "req_history_play_list",
	 *       "platform": 0,
	 *       "src_url": "thunder%3A//QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D",
	 *       "file_size": 1261414195,
	 *       "duration": 6013120,
	 *       "playtime": "2013-08-09 19:33:14",
	 *       "playflag": 4,
	 *       "createtime": "2013-08-09 18:34:46"
	 *     },
	 *     {
	 *       "ip": "222.128.181.139",
	 *       "gcid": null,
	 *       "url_hash": "7651461091677318816",
	 *       "res_list": null,
	 *       "from": "vlist",
	 *       "vod_info": null,
	 *       "cid": null,
	 *       "url": "thunder0X1.02728097026C8P-8720.0000000.000000QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
	 *       "file_name": "%E4%B8%AD%E5%9B%BD%E5%90%88%E4%BC%99%E4%BA%BABD.rmvb",
	 *       "userid": "288543553",
	 *       "ordertime": 1376040983,
	 *       "file_info": null,
	 *       "datafrom": "req_history_play_list",
	 *       "platform": 0,
	 *       "src_url": "thunder0X1.02728097026C8P-8720.0000000.000000QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU%20MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
	 *       "file_size": null,
	 *       "duration": 0,
	 *       "playtime": "2013-08-09 17:36:23",
	 *       "playflag": 0,
	 *       "createtime": "2013-08-09 17:36:23"
	 *     }
	 *   ],
	 *   "max_num": 1500,
	 *   "userid": "288543553",
	 *   "ret": 0,
	 *   "end_t": null,
	 *   "record_num": 2,
	 *   "start_t": null,
	 *   "type": "all"}
	 * }
	 *
	 */
	int ret = -1;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_history_play_list;
	struct json_object *jo_history_play_list_n;

	struct json_object *jo_url_hash;
	//struct json_object *jo_url;
	struct json_object *jo_file_name;
	struct json_object *jo_src_url;
	//struct json_object *jo_file_size;
	//struct json_object *jo_duration;

	if (!json_str || !videos)
	{
		return -1;
	}

	jsobj = json_tokener_parse(json_str);
	if(is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		return -1;
	}

	jo_resp = json_object_object_get(jsobj, "resp"); 
	if (jo_resp)
	{
		jo_history_play_list = json_object_object_get(jo_resp, "history_play_list"); 
		if (jo_history_play_list)
		{
			int i;
			for (i = 0; i < json_object_array_length(jo_history_play_list); i++)
			{
				jo_history_play_list_n = json_object_array_get_idx(jo_history_play_list, i);
				if (jo_history_play_list_n)
				{
					jo_url_hash = json_object_object_get(jo_history_play_list_n, "url_hash"); 
					jo_file_name = json_object_object_get(jo_history_play_list_n, "file_name"); 
					jo_src_url = json_object_object_get(jo_history_play_list_n, "src_url"); 
					//jo_file_size = json_object_object_get(jo_history_play_list_n, "file_size"); 
					//jo_duration = json_object_object_get(jo_history_play_list_n, "duration"); 
					if (jo_url_hash && jo_file_name && jo_src_url)
					{
						char *url_hash;
						char *file_name;
						char *src_url;
						XLVideo *video;

						url_hash = s_strdup(json_object_get_string(jo_url_hash));
						file_name = s_strdup(json_object_get_string(jo_file_name));
						src_url = s_strdup(json_object_get_string(jo_src_url));
						//file_size = json_object_get_int64(jo_file_size);
						//duration = json_object_get_int64(jo_duration);

						video = xl_video_new(url_hash, file_name, src_url);
						xl_videos_append_video(videos, video);

						s_free(url_hash); json_object_put(jo_url_hash);
						//s_free(url); json_object_put(jo_url);
						s_free(file_name); json_object_put(jo_file_name);
						s_free(src_url); json_object_put(jo_src_url);
						//json_object_put(jo_file_size);
						//json_object_put(jo_duration);
						ret++;
					} else {
						if (jo_url_hash) json_object_put(jo_url_hash);
						//if (jo_url) json_object_put(jo_url);
						if (jo_file_name) json_object_put(jo_file_name);
						if (jo_src_url) json_object_put(jo_src_url);
						//if (jo_file_size) json_object_put(jo_file_size);
						//if (jo_duration) json_object_put(jo_duration);
					}
					json_object_put(jo_history_play_list_n);
				}
			}
			json_object_put(jo_history_play_list);
		}
		json_object_put(jo_resp);
	}
	json_object_put(jsobj);
	return ret;
}

#if 0
static int src_url_cmp(const char *orig_url, const char *new_url)
{
	int ret = -1;
	if (!orig_url || !new_url)
		return ret;

	xl_log(LOG_DEBUG, "\norig_url=%s\n new_url=%s\n", orig_url, new_url);
	if ((strncmp(orig_url, "ed2k://", 7) == 0) &&(strncmp(new_url, "ed2k://", 7) == 0))
	{
		char *end;
		char *src = strdup(orig_url);
		char *dst = strdup(new_url);
		char *p1 = src;
		char *p2 = dst;

		p1 = strchr(p1, '|'); p1++;
		p1 = strchr(p1, '|'); p1++;
		p1 = strchr(p1, '|'); p1++;
		p1 = strchr(p1, '|'); p1++;
		end = strchr(p1, '|'); *end = '\0';

		p2 = strchr(p2, '|'); p2++;
		p2 = strchr(p2, '|'); p2++;
		p2 = strchr(p2, '|'); p2++;
		p2 = strchr(p2, '|'); p2++;
		end = strchr(p2, '|'); *end = '\0';

		ret = strncasecmp(p1, p2, strlen(p1));

		free(src);
		free(dst);
	}else if ((strncmp(orig_url, "magnet:", 7) == 0) && (strncmp(new_url, "bt://", 5) == 0)) {
		char *end;
		char *src = strdup(orig_url);
		char *dst = strdup(new_url);
		char *p1 = src;
		char *p2 = dst;

		p1 = strchr(p1, ':'); p1++;
		p1 = strchr(p1, ':'); p1++;
		p1 = strchr(p1, ':'); p1++;
		end = strchr(p1, '&'); *end = '\0';

		p2 = strchr(p2, '/'); p2++;
		p2 = strchr(p2, '/'); p2++;

		ret = strncasecmp(p1, p2, strlen(p1));
		free(src);
		free(dst);
	} else {
		ret = strncasecmp(orig_url, new_url, strlen(orig_url));
	}
	return ret;
}

char *json_parse_get_url_hash(const char* json_str, const char *url)
{
	/*
	 * json_str same as up
	 * return ${url_hash}
	 */
	char *url_hash = NULL;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_history_play_list;
	struct json_object *jo_history_play_list_n;
	struct json_object *jo_src_url;
	struct json_object *jo_url_hash;

	if (!json_str || !url)
		return NULL;

	jsobj = json_tokener_parse(json_str);
	if(is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		return NULL;
	}

	jo_resp = json_object_object_get(jsobj, "resp"); 
	if (jo_resp)
	{
		jo_history_play_list = json_object_object_get(jo_resp, "history_play_list"); 
		if (jo_history_play_list)
		{
			int i;
			for (i = 0; i < json_object_array_length(jo_history_play_list); i++)
			{
				jo_history_play_list_n = json_object_array_get_idx(jo_history_play_list, i);
				if (jo_history_play_list_n)
				{
					jo_src_url = json_object_object_get(jo_history_play_list_n, "src_url"); 
					if (jo_src_url)
					{
						const char *src_url = json_object_get_string(jo_src_url);
						char *uri = xl_url_unquote(src_url);
						if (src_url_cmp(url, uri) == 0)
						{
							jo_url_hash = json_object_object_get(jo_history_play_list_n, "url_hash"); 
							url_hash = s_strdup(json_object_get_string(jo_url_hash));
						}
						s_free(uri);
						json_object_put(jo_src_url);
					}
					json_object_put(jo_history_play_list_n);
				}
			}
			json_object_put(jo_history_play_list);
		}
		json_object_put(jo_resp);
	}
	json_object_put(jsobj);
	return url_hash;
}
#endif

/**
 * json_parse_get_name_and_url:
 * @json_str: 
 * @name: filled with name, should free it.
 * @url: filled with url, should free it.
 *
 * from json return name and url.
 *
 * Return value: error return -1; if name return 1, if url return 2;
 **/
int json_parse_get_name_and_url(const char *json_str, char **name, char **url)
{
	/*
	 * json_str is {"resp": {"res": [{"url": "thunder%3A%2F%2FQUFodHRwOi...12Ylpa", "result": 0, "id": 0, "name": "\u4e2d\u56fd\u5408\u4f19\u4ebaBD.rmvb"}], "ret": 0}}
	 * return resp->res->0->${name}
	 *
	 */
	int found = -1;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_res;
	struct json_object *jo_res_n;
	struct json_object *jo_name;
	struct json_object *jo_url;

	if (!json_str)
	{
		if (name) *name = NULL;
		if (url) *url = NULL;
		return found;
	}

	jsobj = json_tokener_parse(json_str);
	if( is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		if (name) *name = NULL;
		if (url) *url = NULL;
		return found;
	}
	jo_resp = json_object_object_get(jsobj, "resp");
	if (jo_resp)
	{
		jo_res = json_object_object_get(jo_resp, "res"); 
		if (jo_res)
		{
			jo_res_n = json_object_array_get_idx(jo_res, 0);
			if (jo_res_n)
			{
				if (name)
				{
					jo_name = json_object_object_get(jo_res_n, "name"); 
					if (jo_name)
					{
						*name = xl_url_unquote(json_object_get_string(jo_name));
						json_object_put(jo_name);
						found = 1;
					} else {
						*name = NULL;
					}
				}
				if (url)
				{
					jo_url = json_object_object_get(jo_res_n, "url"); 
					if (jo_url)
					{
						*url = strdup(json_object_get_string(jo_url));
						json_object_put(jo_url);
						found = 2;
					} else {
						*url = NULL;
					}
				}
				json_object_put(jo_res_n);
			}
			json_object_put(jo_res);
		}
		json_object_put(jo_resp);
	}
	json_object_put(jsobj);
	return found;
}

char *json_parse_get_download_url(const char *json_str, VideoType type)
{
	/*
	 *
	 * {
     * "resp": {
     *     "status": 0,
     *     "url_hash": "288301201412044132",
     *     "trans_wait": -1,
     *     "userid": "288543553",
     *     "ret": 0,
     *     "src_info": {
     *         "file_name": "梦幻天堂·龙网(killman.net).720p.大话西游之大圣娶亲",
     *         "cid": "",
     *         "file_size": "0",
     *         "gcid": "820EA640D99A37E0AC301CC8BA01E00302622889"
     *     },
     *     "vodinfo_list": [{
     *         "vod_urls": [],
     *         "spec_id": 225536,
     *         "vod_url": "http://124.95.174.190/download?dt=16&g=E8DCDA6F78065905114B0E619B0F334834ADA576&t=2&ui=288543553&s=471222714&v_type=-1&scn=c13&it=1376504026&p=0&cc=9042386459858147283&n=0A4A0F9076D805696CBF854C89DE006574FAC61AD5C01E2EE5774FC5486D86A5BF3550950349E5E5A4740DB14415C6B6E4695A2DE7F06E0000",
     *         "has_subtitle": 0
     *     }, {
     *         "vod_urls": [],
     *         "spec_id": 282880,
     *         "vod_url": "http://124.95.174.190/download?dt=16&g=FFD69470DFE198EC443BB51D054995F74F646A71&t=2&ui=288543553&s=790926882&v_type=-1&scn=c13&it=1376504026&p=0&cc=16893651737588826745&n=0A4A0F9076D805696CBF854C89DE006574FAC61AD5C01E2EE5774FC5486D86A5BF3550950349E5E5A4740DB14415C6B6E4695A2DE7F06E0000",
     *         "has_subtitle": 0
     *     }, {
     *         "vod_urls": [],
     *         "spec_id": 356608,
     *         "vod_url": "http://124.95.174.190/download?dt=16&g=5BB401588FA5978DB9EA90DC205922ADFAF9EFE5&t=2&ui=288543553&s=1273308635&v_type=-1&scn=c13&it=1376504026&p=0&cc=117367614423376147&n=0A4A0F9076D805696CBF854C89DE006574FAC61AD5C01E2EE5774FC5486D86A5BF3550950349E5E5A4740DB14415C6B6E4695A2DE7F06E0000",
     *         "has_subtitle": 0
     *     }],
     *     "duration": 5984172000,
     *     "vod_permit": {
     *         "msg": "OK",
     *         "ret": 0
     *     },
     *     "error_msg": ""
     * }
	 * }
	 */

	int spec_id;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_vodinfo_list;
	struct json_object *jo_vodinfo_list_n;
	struct json_object *jo_spec_id;
	struct json_object *jo_vod_url;
	struct json_object *jo_duration;
	char *vod_url = NULL;
	int64_t duration;
	char *download_url = NULL;

	if (!json_str)
		return download_url;

	jsobj = json_tokener_parse(json_str);
	if( is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		return download_url;
	}
	jo_resp = json_object_object_get(jsobj, "resp");
	if (jo_resp)
	{
		//FIXME: maybe trans_wait -1 is not ready.
		jo_vodinfo_list = json_object_object_get(jo_resp, "vodinfo_list"); 
		if (jo_vodinfo_list)
		{
			int i;
			for (i = 0; i < json_object_array_length(jo_vodinfo_list); i++)
			{
				jo_vodinfo_list_n = json_object_array_get_idx(jo_vodinfo_list, i);
				if (jo_vodinfo_list_n)
				{
					jo_spec_id = json_object_object_get(jo_vodinfo_list_n, "spec_id"); 
					if (jo_spec_id)
					{
						spec_id = json_object_get_int(jo_spec_id);
						json_object_put(jo_spec_id);
					}
					jo_vod_url = json_object_object_get(jo_vodinfo_list_n, "vod_url");
					if (jo_vod_url)
					{
						if (vod_url != NULL)
							s_free(vod_url);
						vod_url = s_strdup(json_object_get_string(jo_vod_url));
						json_object_put(jo_vod_url);
					}
					// use this logic, we sure that will return a valid url if type is not matched.
					if (type == VIDEO_360P && (spec_id == 225536 || spec_id == 226048))
					{
						break;
					} else if (type == VIDEO_480P && (spec_id == 282880 || spec_id == 283392))
					{
						break;
					} else if (type == VIDEO_720P && (spec_id == 356608 || spec_id == 357120))
					{
						break;
					} else if (type == VIDEO_1080P && (spec_id == 356608 || spec_id == 357120))
					{
						break;
					}
					json_object_put(jo_vodinfo_list_n);
				}
			}
			json_object_put(jo_vodinfo_list);
		}
		struct json_object *jo_src_info;
		struct json_object *jo_file_name;

		jo_src_info = json_object_object_get(jo_resp, "src_info"); 
		jo_file_name = json_object_object_get(jo_src_info, "file_name"); 
		xl_log(LOG_NOTICE, "file name:%s\n", json_object_get_string(jo_file_name));
		json_object_put(jo_file_name);
		json_object_put(jo_src_info);

		jo_duration = json_object_object_get(jo_resp, "duration"); 
		if (jo_duration) {
			duration = json_object_get_int64(jo_duration)/1000/1000;
		}
		json_object_put(jo_resp);
	}
	json_object_put(jsobj);
	if (vod_url != NULL)
	{
		char *substr = strstr(vod_url, "s=");
		char num[20];
		int i =0;
		substr += 2;
		while (substr && *substr != '&')
		{
			num[i] = *substr;
			i++;
			substr++;
		}
		num[i] = '\0';
		s_asprintf(&download_url, "%s&start=0&end=%s&flash_meta=0&type=loadmetadata&du=%d", vod_url, num, duration);
		s_free(vod_url);
	}
	return download_url;
}

VideoStatus json_parse_get_video_status(const char *json_str)
{
	 /*
	  * json_str is {"resp": {"progress_info_list": [{"progress": "5_10000", "url_hash": "10582384012816867477"}], "userid": "288543553", "ret": 0}}
	  * return progress to VideoStatus
	  */
	int video_status = 2;
	struct json_object *jsobj;
	struct json_object *jo_resp;
	struct json_object *jo_progress_info_list;
	struct json_object *jo_progress_info_list_n;
	struct json_object *jo_progress;
	char *progress = NULL;

	if (!json_str)
		return VIDEO_DOWNLOAD_FAILED;

	jsobj = json_tokener_parse(json_str);
	if( is_error(jsobj) || !jsobj)
	{
		json_object_put(jsobj);
		return VIDEO_DOWNLOAD_FAILED;
	}
	jo_resp = json_object_object_get(jsobj, "resp");
	if (jo_resp)
	{
		jo_progress_info_list = json_object_object_get(jo_resp, "progress_info_list"); 
		if (jo_progress_info_list)
		{
			if (json_object_array_length(jo_progress_info_list) != 1)
				return VIDEO_DOWNLOAD_FAILED;
			jo_progress_info_list_n = json_object_array_get_idx(jo_progress_info_list, 0);
			if (jo_progress_info_list_n)
			{
				jo_progress = json_object_object_get(jo_progress_info_list_n, "progress");
				if (jo_progress)
				{
					progress = s_strdup(json_object_get_string(jo_progress));
					*(progress+1) = '\0';
					video_status = atoi(progress);
					s_free(progress);
					json_object_put(jo_progress);
				}
				json_object_put(jo_progress_info_list_n);
			}
			json_object_put(jo_progress_info_list);
		}
		json_object_put(jo_resp);
	}
	json_object_put(jsobj);
	return (VideoStatus)video_status;
}
