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
#include "xl-json.h"
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

static char* vod_get_bt_index(XLVod *vod, const char* bt_hash);

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

char* vod_list_all_videos(XLVod *vod)
{
	char url[512];
	XLHttp *req;
	XLErrorCode err;
	char *list;

	snprintf(url, sizeof(url) ,"http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=all&order=create&t=%ld", get_current_timestamp());
	req = xl_client_open_url(vod->client, url, HTTP_GET, NULL, NULL, &err);
	if (xl_http_get_status(req) != 200)
	{
		goto failed;
	}
	char *response = xl_http_get_body(req);
	list = s_strdup(response);
	xl_http_free(req);
	return list;
failed:
	xl_http_free(req);
	return NULL;
}

int xl_vod_has_video(XLVod *vod, const char* url)
{
	char* list = vod_list_all_videos(vod);
	if (list == NULL)
		return 0;
	if(json_parse_has_url(list, url) == 0)
	{
		printf("has the video\n");
		s_free(list);
		return 1;
	}
	s_free(list);
	return 0;
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
	char *name = json_parse_get_name(response);
	return name;
}

int xl_vod_add_video(XLVod *vod, const char* url, char *name1)
{
	char *name;
	if (name1 != NULL)
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
	if (json_parse_get_return_code(response) == 0)
	{
		xl_http_free(req);
		return 1;
	}
	xl_http_free(req);
	return 0;
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
	char *vtype = NULL;
	XLCookies *cookies = xl_client_get_cookies(client);

	memset(get_url, '\0', sizeof(get_url));

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

	if (strncmp(url, "magnet", 6) == 0)
	{
		vtype = "loadmetadata";
	}
	else
	{
		vtype="normal";
	}

	if (strncmp(url, "bt://", 5) == 0)
	{
		char* bt_index = vod_get_bt_index(vod, url);
		if (bt_index != NULL)
		{
			snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s/%s&video_name=%s&from=vlist&platform=0&vip=1&userid=%s&sessionid=%s&cache=%ld", en_url, bt_index, en_name, userid, sessionid, get_current_timestamp());
			s_free(bt_index);
		}
	}
	else
	{
		snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s&video_name=%s&from=vlist&platform=0&vip=1&userid=%s&sessionid=%s&cache=%ld", en_url, en_name, userid, sessionid, get_current_timestamp());
	}
	s_free(name);
	s_free(en_url);
	s_free(en_name);
	char *download_refer = "http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01";

	XLHttp *req;
	XLErrorCode err;
	if(strlen(get_url))
	{
		//req = xl_client_open_url(client, get_url, HTTP_GET, NULL, download_refer, &err);
		req = xl_client_open_url(client, get_url, HTTP_GET, NULL, download_refer, &err);
		char *response =  xl_http_get_body(req);
		printf("get response %s\n",  xl_http_get_body(req));

		//return	get_download_url_from_response(response, type, vtype);
		return json_parse_get_download_url(response, type);
	}
		
	return NULL;
}

VideoStatus xl_vod_get_video_status(XLVod *vod, const char* url)
{
	//TODO: 完成视频状态检测，以保证后续播放能正常工作。
	char *list;

	list = vod_list_all_videos(vod);
	//get_url_hash(list, url);
	
	/*
	 * url is: http://i.vod.xunlei.com/req_progress_query?&t=1376470919270
	 * post is {"req":{"url_hash_list":["10582384012816867477"],"platform":0}}
	 * or: {"req":{"url_hash_list":["7561787828864183224","6536430402090067275","13448276460108685446","10653796262410566949","9918101846291549545","7330933771486410590"],"platform":0}}
	 * return is {"resp": {"progress_info_list": [{"progress": "5_10000", "url_hash": "10582384012816867477"}], "userid": "288543553", "ret": 0}}
	 * or: {"resp": {"progress_info_list": [{"progress": "5_10000", "url_hash": "7561787828864183224"}, {"progress": "5_10000", "url_hash": "6536430402090067275"}, {"progress": "5_10000", "url_hash": "13448276460108685446"}, {"progress": "5_10000", "url_hash": "10653796262410566949"}, {"progress": "5_10000", "url_hash": "9918101846291549545"}, {"progress": "5_10000", "url_hash": "7330933771486410590"}], "userid": "288543553", "ret": 0}}
	 *
	 */
	s_free(list);
	return VIDEO_READY;
}

int check_file_existed(const char *filename)
{
	struct stat st;
	return (stat(filename, &st )==0 && S_ISREG(st.st_mode));
}

char* vod_upload_bt_file(XLVod *vod, const char *path)
{
	size_t file_size;
	char url[1024];
	XLErrorCode err;
	XLHttp *http;
	char* body;
	char* bthash;

	if (!vod || !path)
		return NULL;

	if(!check_file_existed(path))
		return NULL;

	get_file_size(path, &file_size);
	if(file_size >= MAX_BUFF_LEN)
		return NULL;

	snprintf(url, sizeof(url), "http://dynamic.vod.lixian.xunlei.com/interface/upload_bt?from=vlist&t=%ld", get_current_timestamp());
	http = xl_client_upload_file(vod->client, url, "Filedata", path, &err);
	if (http == NULL){
		goto failed;
	}
	if (xl_http_get_status(http) != 200)
	{
		err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	body = xl_http_get_body(http);
	bthash = json_parse_bt_hash(body);
	if (bthash == NULL)
		goto failed;
	xl_http_free(http);
	return bthash;
failed:
	xl_http_free(http);
	return NULL;
}

static char* vod_get_bt_index(XLVod *vod, const char* bt_hash)
{
	int i;
	char *index = NULL;
	char *body;
	char url[1024];
	XLHttp *http;
	XLErrorCode err;

	snprintf(url, sizeof(url), "http://i.vod.xunlei.com/req_subBT/info_hash/%s/req_num/30/req_offset/0", bt_hash+5);
	http = xl_client_open_url(vod->client, url, HTTP_GET, NULL, NULL, &err);
	if (http == NULL){
		goto failed;
	}
	if (xl_http_get_status(http) != 200)
	{
		err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	body = xl_http_get_body(http);
	i = json_parse_bt_index(body);
	if (i == -1)
		goto failed;
	xl_http_free(http);
	s_asprintf(&index, "%d", i);
	return index;
failed:
	xl_http_free(http);
	return NULL;
}

int xl_vod_add_bt_video(XLVod *vod, const char *path)
{
	char *bt_hash;
	char *bt_index;
	bt_hash = vod_upload_bt_file(vod, path);
	if (bt_hash == NULL)
		return -1;

	bt_index = vod_get_bt_index(vod, bt_hash);
	if (bt_index == NULL)
		return -1;
	printf("bt_hash=%s, bt_index=%s\n", bt_hash, bt_index);
//	int ret = xl_vod_add_video(vod, bthash, NULL);
	char *media_url;
	media_url = xl_vod_get_video_url(vod, bt_hash, VIDEO_480P);
	//xl_vod_get_video_url(vod, bthash, VIDEO_480P);
	s_free(bt_hash);
	s_free(bt_index);
	s_free(media_url);
	printf("ret=%s\n", media_url);
	return 0;
}
