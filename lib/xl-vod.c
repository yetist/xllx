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
	//logic:
	//if url is not in list
	//	add url to list
	//get info from list about the url
	//convrt, or process, then get the video stream url for this url.
	
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
