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
	char *bthash= NULL;
	struct json_object *jsobj;
	struct json_object *jo_ret;
	struct json_object *jo_infohash;

	if (!json_str)
		return NULL;

	jsobj = json_tokener_parse(json_str);
	if( is_error(jsobj) || !jsobj)
	{
		printf("got error as expected\n");
		json_object_put(jsobj);
		return NULL;
	}
	jo_ret = json_object_object_get(jsobj, "ret");
	if (jo_ret)
	{
		char *ret = json_object_get_string(jo_ret);
		if (atoi(ret) != 0)
		{
			xl_log(LOG_NOTICE, "get info hash failed\n");
			json_object_put(ret);
			goto failed;
		}
	}
	jo_infohash = json_object_object_get(jsobj, "infohash"); 
	if (jo_infohash)
	{
					s_asprintf(&bthash, "bt://%s", json_object_get_string(jo_infohash));
					json_object_put(jo_infohash);
	}
failed:
	json_object_put(jsobj);
	return bthash;
}
