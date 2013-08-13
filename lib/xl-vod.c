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

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#define DEFAULT_REFERER "http://i.vod.xunlei.com/proxy.html?v2.82"
#define MAX_BUFF_LEN 6291456 

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
						char *src_url = json_object_get_string(n);
						char *un_url = xl_url_unquote(src_url);
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

int xl_vod_has_video(XLVod *vod, const char* url)
{
	//http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=all&order=create&t=1376293731064
	char get[512];
	XLClient *client = vod -> client;
	XLHttp *req;
	XLErrorCode err;

	snprintf(get, sizeof(get) ,"http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=all&order=create&t=%ld", get_current_timestamp());
	xl_log(LOG_NOTICE, "get url is %s\n", get);

	req = xl_client_open_url(client, get, HTTP_GET, NULL, DEFAULT_REFERER, &err);

	char *response = xl_http_get_body(req);
	printf("here the response is %s\n", response);
	if(if_response_has_url(response, url))
	{
		printf("has the video\n");
		xl_http_free(req);
		return 1;
	}

	xl_http_free(req);

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

char *from_url_get_name(XLVod *vod, const char* url)
{
	if (!url)
		return NULL;
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
	char parg[512];
	memset(parg, '\0', sizeof(parg));
	//create_get_name_post_data(url, buf, buflen);
	//{ "urls": [ { "id": 0, "url": "thunder%3A%2F%2FQUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU%20MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa" } ] }
	if (url)
	{
		char *en_url = xl_url_quote((char *)url);
		snprintf(parg, sizeof(parg), "{\"urls\":[{\"id\":0, \"url\":\"%s\"}]}", en_url);
		printf("post argument is %s\n ", parg);
		s_free(en_url);
	}

	char post_url[256];
	memset(post_url, '\0', 256);
	snprintf(post_url, sizeof(post_url), "http://i.vod.xunlei.com/req_video_name?from=vlist&platform=0");
	//XLHttp *xl_client_open_url(XLClient *client, const char *url, HttpMethod method, const char* post_data, const char* refer, XLErrorCode *err);
	req = xl_client_open_url(client, post_url, HTTP_POST, parg, DEFAULT_REFERER, &err);

	char *response = xl_http_get_body(req);
	printf("here the response is %s\n", response);
	char *name = xl_get_name_from_response(response);
	return name;
}

int xl_vod_add_video(XLVod *vod, const char* url, char *name1)
{
	char *name;
	if (name1 == NULL)
	{
		name = name1;
	}
	else
	{
		name = from_url_get_name(vod, url);
	}

	//	char *from_url_get_name(XLVod *vod, const char* url)
	XLClient *client = vod -> client;


	XLHttp *req;
	XLErrorCode err;
	char *response;
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


	xl_log(LOG_NOTICE, "name is %s\n", name);
	if (name == NULL || strcmp (name, "") == 0)
	{
		xl_log(LOG_NOTICE, "Add yun tasks failed\n");
		return 0;
	}
	

	memset(buf, '\0', 256);
	//create_add_yun_post_data(url, name, buf, 256);
	if (url)
	{
		char *en_url = xl_url_quote((char *)url);
		char *en_name = xl_url_quote((char *)name);
		snprintf(buf, sizeof(buf), "{\"urls\":[{\"id\":0, \"url\":\"%s\", \"name\":\"%s\"}]}", en_url, en_name);
		s_free(en_url);
		s_free(en_name);
	}
	char p_url[256];
	snprintf(p_url, sizeof(p_url), "http://i.vod.xunlei.com/req_add_record?from=vlist&platform=0&userid=%s&sessionid=%s", userid, sessionid);
	printf("p_url is %s \n", p_url);

	req = xl_client_open_url(client, p_url, HTTP_POST, buf, DEFAULT_REFERER, &err);
	response = xl_http_get_body(req);
	printf("get response %s\n",  xl_http_get_body(req));
	if (xl_get_ret_from_response(response) == 0)
	{
		xl_http_free(req);
		return 1;
	}
	xl_http_free(req);
	return 0;
}

char *get_download_url_from_response(char *response, VideoType type)
{
	struct json_object *resp;
	struct json_object *resp_obj;
	struct json_object *res_array;
	struct json_object *obj;
	struct json_object *duration;
	char *url = NULL;
	char download_url[512];
	int du = 0;

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
			//int i;
			//for (i = 0; i < json_object_array_length(res_array); i++)
			//	{
			obj = json_object_array_get_idx(res_array, type);
			if (obj)
			{
				struct json_object *n = json_object_object_get(obj, "vod_url"); 
				if (n)
				{
					char *vod_url = json_object_get_string(n);
					url = strdup(vod_url);
					xl_log(LOG_NOTICE, "url is %s\n", url);
				}
			}
			//	}
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
		snprintf(download_url, sizeof(download_url), "%s&start=0&end=%s&type=normal&du=%d", url, num, du);
		xl_log(LOG_NOTICE, "download_url is %s\n", download_url);
		s_free(url);
	}
	
	json_object_put(resp);
	return strdup(download_url);
}

char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type)
{
	if (!url)
		return NULL;


	printf("url is :%s\n", url);
	char *name = from_url_get_name(vod, url);

	printf("get the name is %s\n", name);
	if (!xl_vod_has_video(vod, url))
	{
		//add
		xl_vod_add_video(vod, url, name);
	}
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
	s_free(name);
	s_free(en_url);
	s_free(en_name);
	char *download_refer = "http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01";

	XLHttp *req;
	XLErrorCode err;
	req = xl_client_open_url(client, get_url, HTTP_GET, NULL, download_refer, &err);
	char *response =  xl_http_get_body(req);
	printf("get response %s\n",  xl_http_get_body(req));
	return	get_download_url_from_response(response, type);
}

int check_file_existed(char *filename)
{
	struct stat st;
	return (stat( filename, &st )==0 && S_ISREG(st.st_mode));
}

int xl_vod_add_bt_video(XLVod *vod, const char *path)
{
	if (!vod || !path)
	{
		return -1;
	}
		
	if(!check_file_existed(path))
	{
		xl_log(LOG_NOTICE, "File Not Existed %s\n", path);
		return -1;
	}
	xl_log(LOG_NOTICE, "File Existed %s\n", path);

	//Check File Size
	size_t file_size;
	get_file_size(path, &file_size);
	if(file_size >= MAX_BUFF_LEN)
	{
		xl_log(LOG_NOTICE, "File Size is too Big %s\n", path);
		return -1;
	}
	xl_log(LOG_NOTICE, "File Size %d\n", file_size);

	char url[1024];
	XLErrorCode err;
	XLHttp *http;

	snprintf(url, sizeof(url), "http://dynamic.vod.lixian.xunlei.com/interface/upload_bt?from=vlist&t=%ld", get_current_timestamp());
	http = xl_client_upload_file(vod->client, url, "Filedata", path, &err);
	return 0;
}
