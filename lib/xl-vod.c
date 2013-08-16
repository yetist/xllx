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


#include <json.h>
#include <string.h>

#include "xl-vod.h"
#include "xl-cookies.h"
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

static char* vod_list_all_videos(XLVod *vod, XLErrorCode *err);
static int vod_get_title_and_url(XLVod *vod, const char* url, char **name, char **real_url);
static char* vod_get_bt_index(XLVod *vod, const char* bt_hash);
static char* vod_upload_bt_file(XLVod *vod, const char *path);
static int xl_vod_has_video(XLVod *vod, const char* url, char** url_hash, XLErrorCode *err);
static int xl_vod_add_video(XLVod *vod, const char* url, XLErrorCode *err);

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

static char* vod_list_all_videos(XLVod *vod, XLErrorCode *err)
{
	char url[1024];
	XLHttp *req;
	char *list;

	snprintf(url, sizeof(url) ,"http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=all&order=create&t=%ld", get_current_timestamp());
	req = xl_client_open_url(vod->client, url, HTTP_GET, NULL, DEFAULT_REFERER, err);
	if (req == NULL){
		goto failed;
	}
	if (xl_http_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
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

static int xl_vod_has_video(XLVod *vod, const char* url, char** url_hash, XLErrorCode *err)
{
	int try = 0;
	char* list = vod_list_all_videos(vod, err);
	while (list == NULL && try < 3){
		list = vod_list_all_videos(vod, err);
		try++;
	}
	if (list == NULL)
	{
		*err = XL_ERROR_HTTP_ERROR;
		return -1;
	}

	if(json_parse_has_url(list, url, url_hash) == 0)
	{
		s_free(list);
		return 0;
	}
	s_free(list);
	return -1;
}

static int vod_get_title_and_url(XLVod *vod, const char* url, char **name, char **real_url)
{
	char post_data[1024];
	char post_url[1024];
	char *body;
	int ret = -1;
	char *en_url;
	XLHttp *req;
	XLErrorCode err;

	if (!url)
		return ret;

	memset(post_data, '\0', sizeof(post_data));
	if (strncmp(url, "magnet:", 7) == 0)
	{
		snprintf(post_data, sizeof(post_data), "{\"urls\":[{\"id\":0, \"url\":\"%s\"}]}", url);
	} else {
		en_url = xl_url_quote(url);
		snprintf(post_data, sizeof(post_data), "{\"urls\":[{\"id\":0, \"url\":\"%s\"}]}", en_url);
		s_free(en_url);
	}

	memset(post_url, '\0', sizeof(post_url));
	snprintf(post_url, sizeof(post_url), "http://i.vod.xunlei.com/req_video_name?from=vlist&platform=0");

	req = xl_client_open_url(vod->client, post_url, HTTP_POST, post_data, DEFAULT_REFERER, &err);
	if (req == NULL){
		goto failed;
	}
	if (xl_http_get_status(req) != 200)
	{
		err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}

	body = xl_http_get_body(req);
	ret = json_parse_get_name_and_url(body, name, real_url);

failed:
	xl_http_free(req);
	return ret;
}

static int xl_vod_add_video(XLVod *vod, const char* url, XLErrorCode *err)
{
	char *name;
	XLHttp *req;
	char *response;
	char *userid;
	char *sessionid;
	char post_data[1024];
	char p_url[256];

	XLCookies *cookies;

	if (url == NULL)
		return -1;
	
	printf("****************add video\n");
	cookies = xl_client_get_cookies(vod->client);
	userid = xl_cookies_get_userid(cookies);
	if (userid == NULL)
		return -1;
	sessionid = xl_cookies_get_sessionid(cookies);
	if (sessionid == NULL)
		goto failed0;
	vod_get_title_and_url(vod, url, &name, NULL);
	if (name == NULL || strcmp(name, "") == 0 )
		goto failed1;

	memset(post_data, '\0', sizeof(post_data));
	char *en_url = xl_url_quote(url);
	char *en_name = xl_url_quote(name);
	snprintf(post_data, sizeof(post_data), "{\"urls\":[{\"id\":0, \"url\":\"%s\", \"name\":\"%s\"}]}", en_url, en_name);
	s_free(en_url);
	s_free(en_name);

	snprintf(p_url, sizeof(p_url), "http://i.vod.xunlei.com/req_add_record?from=vlist&platform=0&userid=%s&sessionid=%s", userid, sessionid);

	req = xl_client_open_url(vod->client, p_url, HTTP_POST, post_data, DEFAULT_REFERER, err);
	if (req == NULL){
		goto failed;
	}
	if (xl_http_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	response = xl_http_get_body(req);
	if (json_parse_get_return_code(response) == 0)
	{
		xl_http_free(req);
		return 0;
	}
failed:
	s_free(name);
	xl_http_free(req);
failed1:
	s_free(sessionid);
failed0:
	s_free(userid);
	return -1;
}

static char *vod_get_video_url(XLVod *vod, const char* url, VideoType type, XLErrorCode *err)
{
	char get_url[1024];
	char *userid, *sessionid, *name;
	char *en_url, *en_name;
	char *download_refer;
	char *body;
	XLCookies *cookies;
	XLHttp *req;
	char *stream_url = NULL;

	if (url == NULL)
		return NULL;

	cookies = xl_client_get_cookies(vod->client);
	userid = xl_cookies_get_userid(cookies);
	if (userid == NULL)
		return NULL;
	sessionid = xl_cookies_get_sessionid(cookies);
	if (sessionid == NULL)
		goto failed0;
	vod_get_title_and_url(vod, url, &name, NULL);
	printf("title is [%s]\n", name);
	if (name == NULL || strcmp(name, "") == 0 )
		goto failed1;

	en_url = xl_url_quote(url);
	en_name = xl_url_quote(name);
	memset(get_url, '\0', sizeof(get_url));
	if (strncmp(url, "bt://", 5) == 0)
	{
		char* bt_index = vod_get_bt_index(vod, url);
		if (bt_index != NULL)
		{
			snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s%%2F%s&video_name=%s&from=vlist&platform=0&vip=1&userid=%s&sessionid=%s&cache=%ld", en_url, bt_index, en_name, userid, sessionid, get_current_timestamp());
			s_free(bt_index);
		} else {
			goto failed2;
		}
	} else {
		snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s&video_name=%s&from=vlist&platform=0&vip=1&userid=%s&sessionid=%s&cache=%ld", en_url, en_name, userid, sessionid, get_current_timestamp());
	}

	download_refer = "http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01";

	req = xl_client_open_url(vod->client, get_url, HTTP_GET, NULL, download_refer, err);
	if (req == NULL){
		goto failed;
	}
	if (xl_http_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	body =  xl_http_get_body(req);
	stream_url = json_parse_get_download_url(body, type);
failed:
	xl_http_free(req);
failed2:
	s_free(name);
	s_free(en_url);
	s_free(en_name);
failed1:
	s_free(sessionid);
failed0:
	s_free(userid);
	return stream_url;
}


char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type, XLErrorCode *err)
{
	VideoStatus video_status;
	char *video_url = NULL;
	char *url_hash;
	if (!url)
		return NULL;

	// BT 文件单独处理。先上传，得到bt_url之后再调用本函数。
	if (re_match("(^file:///|^/).*torrent", url) == 0)
	{
		char *real_url = NULL;
		real_url = vod_upload_bt_file(vod, url);
		if (real_url == NULL)
			return video_url;
		video_url = xl_vod_get_video_url(vod, real_url, type, err);
		s_free(real_url);
		return video_url;
	}

	// 处理普通网址下载了特殊文件(如BT)而非电影，从而导致迅雷返回的src_url不统一的问题。
	if (re_match("(^xlpan://|^thunder://|^ftp://|^http://|^https://|^ed2k://|^mms://|^magnet:|^rtsp://|^Flashget://|^flashget://|^qqdl://|^bt://|^xlpan%3A%2F%2F|^thunder%3A%2F%2F|^ftp%3A%2F%2F|^http%3A%2F%2F|^https%3A%2F%2F|^ed2k%3A%2F%2F|^mms%3A%2F%2F|^magnet%3A|^rtsp%3A%2F%2F|^Flashget%3A%2F%2F|^flashget%3A%2F%2F|^qqdl%3A%2F%2F|^bt%3A%2F%2F).*", url) == 0)
	{
		char *real_url;
		vod_get_title_and_url(vod, url, NULL, &real_url);
		if (re_match("(^xlpan://|^thunder://|^ftp://|^http://|^https://|^ed2k://|^mms://|^magnet:|^rtsp://|^Flashget://|^flashget://|^qqdl://|^bt://|^xlpan%3A%2F%2F|^thunder%3A%2F%2F|^ftp%3A%2F%2F|^http%3A%2F%2F|^https%3A%2F%2F|^ed2k%3A%2F%2F|^mms%3A%2F%2F|^magnet%3A|^rtsp%3A%2F%2F|^Flashget%3A%2F%2F|^flashget%3A%2F%2F|^qqdl%3A%2F%2F|^bt%3A%2F%2F).*", real_url) != 0)
		{
			s_free(real_url);
			goto begin;
		}
		if (strncasecmp(url, real_url, strlen(real_url)) != 0)
		{
			video_url = xl_vod_get_video_url(vod, real_url, type, err);
			s_free(real_url);
			if (video_url == NULL)
				*err = XL_ERROR_VIDEO_NOT_READY;
			return video_url;
		} else {
			s_free(real_url);
			goto begin;
		}
	} else {
		*err = XL_ERROR_VIDEO_URL_NOT_ALLOWED;
		return video_url;
	}
begin:
	// url参数与迅雷使用的src_url一致，开始正式处理
	if (xl_vod_has_video(vod, url, &url_hash, err) != 0)
	{
		if (xl_vod_add_video(vod, url, err) != 0)
		{
			*err = XL_ERROR_VIDEO_ADD_FAILED;
			return video_url;
		}
	}

	if (url_hash != NULL)
	{
		video_status = xl_vod_get_video_status(vod, url, url_hash, err);
	} else {
		video_status = xl_vod_get_video_status(vod, url, NULL, err);
	}
	if (!(video_status == VIDEO_CONVERTED || video_status == VIDEO_READY || video_status == VIDEO_SEED_DOWNLOADED))
	{
		*err = XL_ERROR_VIDEO_NOT_READY;
		xl_log(LOG_NOTICE, "This video is not ready for play[%d], please visit \"http://vod.xunlei.com/list.html#list=all&p=1\" for more info!\n", video_status);
		return video_url;
	}
	video_url = vod_get_video_url(vod, url, type, err);
	if (video_url == NULL)
		*err = XL_ERROR_VIDEO_NOT_READY;
	return video_url;
}

VideoStatus xl_vod_get_video_status(XLVod *vod, const char* url, const char* url_hash, XLErrorCode *err)
{
	/*
	 * url is: http://i.vod.xunlei.com/req_progress_query?&t=1376470919270
	 * post is {"req":{"url_hash_list":["10582384012816867477"],"platform":0}}
	 * or: {"req":{"url_hash_list":["7561787828864183224","6536430402090067275","13448276460108685446","10653796262410566949","9918101846291549545","7330933771486410590"],"platform":0}}
	 * return is {"resp": {"progress_info_list": [{"progress": "5_10000", "url_hash": "10582384012816867477"}], "userid": "288543553", "ret": 0}}
	 * or: {"resp": {"progress_info_list": [{"progress": "5_10000", "url_hash": "7561787828864183224"}, {"progress": "5_10000", "url_hash": "6536430402090067275"}, {"progress": "5_10000", "url_hash": "13448276460108685446"}, {"progress": "5_10000", "url_hash": "10653796262410566949"}, {"progress": "5_10000", "url_hash": "9918101846291549545"}, {"progress": "5_10000", "url_hash": "7330933771486410590"}], "userid": "288543553", "ret": 0}}
	 *
	 */
	VideoStatus status = 2;
	char *body;
	char post_data[1024];
	char post_url[1024];
	XLHttp *http;

	char *uhash;
	if (url_hash == NULL)
	{
		char *list;
		int try = 0;
		list = vod_list_all_videos(vod, err);
		while (list == NULL && try < 3){
			list = vod_list_all_videos(vod, err);
			try++;
		}
		if (list == NULL)
		{
			*err = XL_ERROR_HTTP_ERROR;
			return status;
		}
		json_parse_has_url(list, url, &uhash);
		if (uhash == NULL){
			s_free(list);
			*err = XL_ERROR_HTTP_ERROR;
			return status;
		}
		s_free(list);
	} else {
		uhash = s_strdup(url_hash);
	}
	snprintf(post_data, sizeof(post_data), "{\"req\":{\"url_hash_list\":[\"%s\"],\"platform\":0}}", uhash);
	snprintf(post_url, sizeof(post_url), "http://i.vod.xunlei.com/req_progress_query?&t=%ld", get_current_timestamp());

	http = xl_client_open_url(vod->client, post_url, HTTP_POST, post_data, NULL, err);
	if (http == NULL){
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	if (xl_http_get_status(http) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	body = xl_http_get_body(http);
	status = json_parse_get_video_status(body);
failed:
	s_free(uhash);
	xl_http_free(http);
	return status;
}

static int check_file_existed(const char *filename)
{
	struct stat st;
	return (stat(filename, &st )==0 && S_ISREG(st.st_mode));
}

static char* vod_upload_bt_file(XLVod *vod, const char *path)
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

//int xl_vod_add_bt_video(XLVod *vod, const char *path)
//{
//	char *bt_hash;
//	char *bt_index;
//	bt_hash = vod_upload_bt_file(vod, path);
//	if (bt_hash == NULL)
//		return -1;
//
//	bt_index = vod_get_bt_index(vod, bt_hash);
//	if (bt_index == NULL)
//		return -1;
//	printf("bt_hash=%s, bt_index=%s\n", bt_hash, bt_index);
//	char *media_url;
//	media_url = xl_vod_get_video_url(vod, bt_hash, VIDEO_480P);
//	s_free(bt_hash);
//	s_free(bt_index);
//	printf("ret=%s\n", media_url);
//	s_free(media_url);
//	return 0;
//}
