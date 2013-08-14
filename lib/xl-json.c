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

#include <json.h>
#include "xl-json.h"
#include "smemory.h"
#include "logger.h"

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
	 * json_str is {"resp": {"userid": "288543553", "ret": 0, "subfile_list": [{"index": 0, "url_hash": "10582384012816867477", "name": "aaa58256146@\u7fa4\u9b54\u8272\u821e@(AVopen)\u611b\u7530\u53cb,\u84bc\u4e95,\u7a57\u82b1,\u5c0f\u6fa4\u746a\u5229\u4e9e,\u9ebb\u7f8e,\u9752\u6728~\u4f86\u81eaS1\u7684\u885d\u64ca.rmvb", "cid": null, "gcid": null, "file_size": 0, "duration": 0}], "main_task_url_hash": "9918101846291549545", "info_hash": "004F50950256E66F128D528D0773FDEFBC298CCE", "record_num": 1}}
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
