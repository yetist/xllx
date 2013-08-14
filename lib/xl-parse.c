/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-parse.h: This file is part of ____
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
#include <string.h>
#include "smemory.h"
#include "logger.h"
#include "xl-parse.h"
#include "xl-url.h"

int if_response_has_url(char *response, const char *url)
{
	struct json_object *resp;
	struct json_object *resp_obj;
	struct json_object *res_array;
	struct json_object *obj;

	if(!url)
		return 0;

	resp = json_tokener_parse(response);
	if (!resp)
		return 0;
	if(	is_error(resp)) 
	{
		printf("got error as expected\n");
		return 0;
	}

	xl_log(LOG_NOTICE, "url is %s\n", url);

	resp_obj = json_object_object_get(resp, "resp"); 
	if (resp_obj)
	{
		res_array = json_object_object_get(resp_obj, "history_play_list"); 
		if (res_array)
		{
			int i;
			for (i = 0; i < json_object_array_length(res_array); i++)
			{
				obj = json_object_array_get_idx(res_array, i);
				if (obj)
				{
					struct json_object *n = json_object_object_get(obj, "src_url"); 
					if (n)
					{
						const char *src_url = json_object_get_string(n);
						char *un_url = xl_url_unquote((char *)src_url);
						xl_log(LOG_NOTICE, "un_url is %s\n", un_url);

						if (strcmp(un_url, url) == 0)
						{
							xl_log(LOG_NOTICE, "url is %s\n", url);
							s_free(un_url);
							json_object_put(resp);
							return 1;
						}
						s_free(un_url);
					}
				}
			}
		}
	}
	json_object_put(resp);
	return 0;
}

char *xl_get_name_from_response(char *response)
{
	struct json_object *resp;
	struct json_object *resp_obj;
	struct json_object *res_array;
	struct json_object *obj;
	char *name = NULL;

	printf("here res is %s\n", response);

	resp = json_tokener_parse(response);

	if (!resp)
		return NULL;

	if(	is_error(resp)) 
	{
		printf("got error as expected\n");
		json_object_put(resp);
		return NULL;
	}

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
	json_object_put(resp);
	if (name)
	{
		return name;
	}
	return NULL;
}

int xl_get_ret_from_response(char *response)
{
	if (!response)
		return -1;
	struct json_object *resp;
	struct json_object *resp_obj;
	resp = json_tokener_parse(response);

	if(	is_error(resp)) 
	{
		printf("got error as expected\n");
		json_object_put(resp);
		return -1;
	}
	resp_obj = json_object_object_get(resp, "resp"); 
	if (resp_obj)
	{
		printf ("resp_obj: %s\n", json_object_to_json_string(resp_obj));
		struct json_object *ret_obj = json_object_object_get(resp, "ret");
		if (ret_obj)
		{
			int rest = json_object_get_int(ret_obj);
			if (rest == 0)
			{
				xl_log(LOG_NOTICE, "Add yun tasks successfully\n");
			json_object_put(resp);
				return 0;
			}
		}
	}

	json_object_put(resp);
	return 1;
}

char *get_download_url_from_response(char *response, VideoType type, char *vtype)
{
	struct json_object *resp;
	struct json_object *resp_obj;
	struct json_object *res_array;
	struct json_object *obj;
	struct json_object *duration;
	char *url = NULL;
	char download_url[512];
	int du = 0;

	memset(download_url, '\0', sizeof(download_url));

	resp = json_tokener_parse(response);
	if (!resp)
		return NULL;
	if(	is_error(resp)) 
	{
		printf("got error as expected\n");
		json_object_put(resp);
		return NULL;
	}

	resp_obj = json_object_object_get(resp, "resp"); 
	if (resp_obj)
	{
		res_array = json_object_object_get(resp_obj, "vodinfo_list"); 
		if (res_array)
		{
			int i;
			for (i = 0; i < json_object_array_length(res_array); i++)
			{
				obj = json_object_array_get_idx(res_array, i);
				if (obj)
				{
					
					struct json_object *spec = json_object_object_get(obj, "spec_id"); 
					if (spec)
					{
						int spec_id = json_object_get_int(spec);
						xl_log(LOG_NOTICE, "spec_id is %d\n", spec_id);
						struct json_object *n = json_object_object_get(obj, "vod_url"); 
						if (type == 0 && spec_id == 225536)
						{
							if (n)
							{
								const char *vod_url = json_object_get_string(n);
								url = strdup(vod_url);
								xl_log(LOG_NOTICE, "url is %s\n", url);
								break;
							}
						}
						else if(type == 1 && spec_id == 282880)
						{
							const char *vod_url = json_object_get_string(n);
							url = strdup(vod_url);
							xl_log(LOG_NOTICE, "url is %s\n", url);
							break;
						}
						else if(type == 2 && spec_id == 356608)
						{
							const char *vod_url = json_object_get_string(n);
							url = strdup(vod_url);
							xl_log(LOG_NOTICE, "url is %s\n", url);
							break;
						}
					}
				}
			}
		}
		duration = json_object_object_get(resp_obj, "duration"); 

		if (duration)
			du = json_object_get_int64(duration)/1000/1000;
		xl_log(LOG_NOTICE, "du %d\n", du);
	}
	if (url)
	{
		char *substr = strstr(url, "s=");
		char num[20];
		int i =0;
		for (*(substr+2); *(substr+2 + i) != '&'; i++)
		{
			num[i] = *(substr+2 + i);
		}
		num[i] = '\0';
		xl_log(LOG_NOTICE, "substr is %s, num is %s\n", substr, num);
		//thunder and bt
		//snprintf(download_url, sizeof(download_url), "%s&start=0&end=%s&type=normal&du=%d", url, num, du);

		//megnet
		snprintf(download_url, sizeof(download_url), "%s&start=0&end=%s&flash_meta=0&type=%s&du=%d", url, num,vtype, du);

		xl_log(LOG_NOTICE, "download_url is %s\n", download_url);
		s_free(url);
	}
	else
	{
		xl_log(LOG_NOTICE, "NO this videotype\n");
	}
	
	json_object_put(resp);
	if (strlen(download_url))
		return strdup(download_url);
	else
		return NULL;
}

int xl_get_index_from_response(char *response)
{
	if (!response)
		return -1;
	struct json_object *resp;
	struct json_object *resp_obj;
	resp = json_tokener_parse(response);

	if(	is_error(resp)) 
	{
		printf("got error as expected\n");
		json_object_put(resp);
		return -1;
	}
	resp_obj = json_object_object_get(resp, "resp"); 
	if (resp_obj)
	{
		printf ("resp_obj: %s\n", json_object_to_json_string(resp_obj));
		struct json_object *ret_obj = json_object_object_get(resp_obj, "ret");
		if (ret_obj)
		{
			int rest = json_object_get_int(ret_obj);
			if (rest == 0)
			{
				struct json_object *sub_obj = json_object_object_get(resp_obj, "subfile_list");
				if (sub_obj)
				{
					xl_log(LOG_NOTICE, "%s\n", json_object_to_json_string(sub_obj));
					struct json_object *obj = json_object_array_get_idx(sub_obj, 0);
					if (obj)
					{
						struct json_object *index_obj = json_object_object_get(obj, "index");
						if (index_obj)
						{
							int rest = json_object_get_int(index_obj);
							json_object_put(resp);
							return rest;
						}
					}

				}
			}
		}
	}

	json_object_put(resp);
	return -1;
}

char *xl_get_infohash_from_response(char *response)
{
	if (!response)
		return NULL;
	struct json_object *resp;
	struct json_object *resp_obj;
	resp = json_tokener_parse(response);
	char *hash;

	if( is_error(resp))
	{
		printf("got error as expected\n");
		json_object_put(resp);
		return NULL;
	}
	struct json_object *ret_obj = json_object_object_get(resp, "ret");
	if (ret_obj)
	{
		const char *rest = json_object_get_string(ret_obj);
		if (atoi(rest) != 0)
		{
			xl_log(LOG_NOTICE, "get info hash failed\n");
			json_object_put(resp);
			return NULL;
		}
	}

	resp_obj = json_object_object_get(resp, "infohash");
	if (resp_obj)
	{
		hash = strdup(json_object_get_string(resp_obj));
		printf ("resp_obj: %s\n", json_object_to_json_string(resp_obj));
	}

	json_object_put(resp);

	return hash;
}

