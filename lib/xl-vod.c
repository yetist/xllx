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


#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#include <json.h>

#include "xl-vod.h"
#include "xl-http.h"
#include "xl-url.h"
#include "xl-utils.h"
#include "xl-json.h"
#include "xl-videos.h"
#include "smemory.h"
#include "logger.h"
#include "md5.h"


#define DEFAULT_REFERER "http://i.vod.xunlei.com/proxy.html?v2.82"
#define MAX_BUFF_LEN 6291456 
#define UPLOAD_FILE_MAX_SIZE 6291456

struct _XLVod
{
	XLClient *client;
	XLVideos *videos;
};

static char* vod_list_all_videos(XLVod *vod, XLErrorCode *err);
static void  vod_update_list(XLVod *vod);
static int   vod_get_title_and_url(XLVod *vod, const char* url, char **name, char **real_url);
static char* vod_get_bt_index(XLVod *vod, const char* bt_hash);
static char* vod_upload_bt_file(XLVod *vod, const char *path);
static int vod_add_video(XLVod *vod, const char* url, XLErrorCode *err);

XLVod* xl_vod_new(XLClient *client)
{
	if (!client)
	{
		return NULL;
	}
	XLVod *vod = s_malloc0(sizeof(*vod));
	vod->client = client;
	vod->videos = xl_videos_new();
	vod_update_list(vod);
	return vod;
}

void xl_vod_free(XLVod *vod)
{
	if (!vod)
		return ;

	xl_client_free(vod->client);
	xl_videos_free(vod->videos);
	s_free(vod);
}

static char* vod_list_all_videos(XLVod *vod, XLErrorCode *err)
{
	char url[1024];
	XLHttp *http;
	char *list;

	snprintf(url, sizeof(url) ,"http://i.vod.xunlei.com/req_history_play_list/req_num/30/req_offset/0?type=all&order=create&t=%ld", get_current_timestamp());
	http = xl_client_open_url(vod->client, url, HTTP_GET, NULL, DEFAULT_REFERER, err);
	if (http == NULL){
		return NULL;
	}
	if (xl_http_get_status(http) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	const char *response = xl_http_get_body(http);
	list = s_strdup(response);
	xl_http_free(http);
	return list;
failed:
	xl_http_free(http);
	return NULL;
}

static void vod_update_list(XLVod *vod)
{
	XLErrorCode err;
	char* list = vod_list_all_videos(vod, &err);
	if (list == NULL)
	{
		xl_log(LOG_DEBUG, "http error, get video list error\n");
		return;
	}

	if (json_parse_list_videos(list, vod->videos) == -1)
	{
		//xl_log(LOG_DEBUG, "no list video found\n");
		s_free(list);
		return;
	}
	s_free(list);
	return;
}

XLVideos* xl_vod_get_videos(XLVod *vod)
{
	/*
	if (xl_videos_get_count(vod->videos) == 0)
		vod_update_list(vod);
		*/
	return vod->videos;
}

int xl_vod_remove_video(XLVod *vod, const char *url_hash)
{
	char *sessionid;
	char p_url[512];
	XLHttp *req;
	XLVideo* video;
	XLErrorCode err;

	if (url_hash == NULL)
		return -1;

	video = xl_videos_find_video_by_url_hash(vod->videos, url_hash);
	if (video == NULL)
		return 0;
	
	sessionid = xl_client_get_cookie(vod->client, "sessionid");
	if (sessionid == NULL)
		return -1;
	snprintf(p_url, sizeof(p_url), "http://i.vod.xunlei.com/req_del_list?flag=0&sessionid=%s&t=%ld&url_hash=%s", sessionid, get_current_timestamp(), url_hash);
	req = xl_client_open_url(vod->client, p_url, HTTP_GET, NULL, DEFAULT_REFERER, &err);
	if (req == NULL){
		goto failed;
	}
	if (xl_http_get_status(req) != 200)
	{
		err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	const char* response = xl_http_get_body(req);
	if (json_parse_get_return_code(response) == 0)
	{
		s_free(sessionid);
		xl_http_free(req);
		xl_videos_remove (vod->videos, video);
		return 0;
	}
failed:
	xl_http_free(req);
	s_free(sessionid);
	return -1;
}

// 0 for success.
int xl_vod_remove_all_video(XLVod *vod)
{
	int count;
	int i;
	int ret = 0;
	count = xl_videos_get_count(vod->videos);
	if (count == 0)
		return 0;
	for (i = 0; i < count; i++)
	{
		XLVideo *video;
		char *url_hash;
		int ret_code;
		video = xl_videos_get_nth_video(vod->videos, i);
		url_hash = xl_video_get_url_hash(video);
		ret_code = xl_vod_remove_video(vod, url_hash);
		if (ret_code != 0) ret++;
		s_free(url_hash);
	}
	return ret;
}

// 0 for success.
int xl_vod_add_video(XLVod *vod, const char *url, XLErrorCode *err)
{
	int ret = -1;
	int prev_count = 0;
	int current_count = 0;
	XLVideos* videos;

	// BT 文件单独处理。先上传到视频服务器，得到url_hash之后再添加至当前用户列表中。
	if ((re_match(".*torrent", url) == 0) && check_file_existed(url))
	{
		int len;
		size_t fsize;
		char *url_hash = NULL;

		len = get_file_size(url, &fsize);
		if (len != 0 || fsize > UPLOAD_FILE_MAX_SIZE)
		{
			return ret;
		}

		url_hash = vod_upload_bt_file(vod, url);
		if (url_hash == NULL)
		{
			*err = XL_ERROR_VIDEO_ADD_FAILED;
			return -1;
		}
		ret = xl_vod_add_video(vod, url_hash, err);
		s_free(url_hash);
		return ret;
	}

	videos = xl_vod_get_videos(vod);
	prev_count = xl_videos_get_count(videos);

	if (re_match("(^xlpan://|^thunder://|^ftp://|^http://|^https://|^ed2k://|^mms://|^magnet:|^rtsp://|^Flashget://|^flashget://|^qqdl://|^bt://|^xlpan%3A%2F%2F|^thunder%3A%2F%2F|^ftp%3A%2F%2F|^http%3A%2F%2F|^https%3A%2F%2F|^ed2k%3A%2F%2F|^mms%3A%2F%2F|^magnet%3A|^rtsp%3A%2F%2F|^Flashget%3A%2F%2F|^flashget%3A%2F%2F|^qqdl%3A%2F%2F|^bt%3A%2F%2F).*", url) == 0)
	{
		ret = vod_add_video(vod, url, err);
		if (ret != 0)
		{
			*err = XL_ERROR_VIDEO_ADD_FAILED;
			return -1;
		}
		vod_update_list(vod);
		videos = xl_vod_get_videos(vod);
		current_count = xl_videos_get_count(videos);
		if (current_count > prev_count)
		{
			return 0;
		}
	}
	return -1;
}

char* xl_vod_get_video_play_url(XLVod *vod, VideoType type, XLVideo *video, XLErrorCode *err)
{
	char *name;
	char *src_url;
	char *orig_url;
	char get_url[1024];
	char *userid, *sessionid;
	XLHttp *req;
	VideoStatus video_status;
	char *play_url = NULL;
	int try = 0;

	if (!video)
		return NULL;

	video_status = xl_vod_get_video_status(vod, video, err);
	while((video_status == VIDEO_WAIT_DOWNLOAD || video_status == VIDEO_DOWNLOADING ) && try < 3)
	{
		xl_log(LOG_NOTICE, "This video is not ready for play: [%s]\n", xl_vod_str_video_status(video_status));
		sleep(1);
		video_status = xl_vod_get_video_status(vod, video, err);
		try++;
	}

	if (!(video_status == VIDEO_CONVERTED || video_status == VIDEO_READY || video_status == VIDEO_SEED_DOWNLOADED))
	{
		*err = XL_ERROR_VIDEO_NOT_READY;
		xl_log(LOG_NOTICE, "This video is not ready for play: [%s]\n",  xl_vod_str_video_status(video_status));
		return play_url;
	}

	userid = xl_client_get_cookie(vod->client, "userid");
	if (userid == NULL)
		return NULL;
	sessionid = xl_client_get_cookie(vod->client, "sessionid");
	if (sessionid == NULL)
		goto failed0;

	name = xl_video_get_file_name(video);
	src_url = xl_video_get_src_url(video);
	orig_url = xl_url_unquote(src_url);
	if (strncmp(orig_url, "bt://", 5) == 0)
	{
		char* bt_index = vod_get_bt_index(vod, orig_url);
		if (bt_index != NULL)
		{
			snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s%%2F%s&video_name=%s&from=vlist&platform=0&vip=1&userid=%s&sessionid=%s&cache=%ld", src_url, bt_index, name, userid, sessionid, get_current_timestamp());
			s_free(bt_index);
		} else {
			goto failed2;
		}
	} else {
		snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s&video_name=%s&from=vlist&platform=0&vip=1&userid=%s&sessionid=%s&cache=%ld", src_url, name, userid, sessionid, get_current_timestamp());
	}
	char *download_refer = "http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.989.01";

	req = xl_client_open_url(vod->client, get_url, HTTP_GET, NULL, download_refer, err);
	if (req == NULL){
		goto failed;
	}

	if (xl_http_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	const char* body =  xl_http_get_body(req);
	play_url = json_parse_get_download_url(body, type);
failed:
	xl_http_free(req);
failed2:
	s_free(name);
	s_free(src_url);
	s_free(orig_url);
	s_free(sessionid);
failed0:
	s_free(userid);
	return play_url;
}

static int vod_get_title_and_url(XLVod *vod, const char* url, char **name, char **real_url)
{
	char post_data[1024];
	char post_url[1024];
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

	const char* body = xl_http_get_body(req);
	ret = json_parse_get_name_and_url(body, name, real_url);

failed:
	xl_http_free(req);
	return ret;
}

static int vod_add_video(XLVod *vod, const char* url, XLErrorCode *err)
{
	char *title;
	XLHttp *req;
	char *userid;
	char *sessionid;
	char post_data[4096];
	char p_url[256];

	if (url == NULL)
		return -1;
	
	userid = xl_client_get_cookie(vod->client, "userid");
	if (userid == NULL)
		return -1;
	sessionid = xl_client_get_cookie(vod->client, "sessionid");
	if (sessionid == NULL)
		goto failed0;
	vod_get_title_and_url(vod, url, &title, NULL);
	if (title == NULL || strcmp(title, "") == 0 )
		goto failed1;

	memset(post_data, '\0', sizeof(post_data));
	char *en_url = xl_url_quote(url);
	char *en_title = xl_url_quote(title);
	snprintf(post_data, sizeof(post_data), "{\"urls\":[{\"id\":0, \"url\":\"%s\", \"name\":\"%s\"}]}", en_url, en_title);
	s_free(en_url);
	s_free(en_title);

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
	const char* response = xl_http_get_body(req);
	if (json_parse_get_return_code(response) == 0)
	{
		xl_http_free(req);
		return 0;
	}
failed:
	s_free(title);
	xl_http_free(req);
failed1:
	s_free(sessionid);
failed0:
	s_free(userid);
	return -1;
}

char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type, XLErrorCode *err)
{
	XLVideos *videos;
	XLVideo *video;
	if (xl_vod_remove_all_video(vod) != 0)
		return NULL;
	if (xl_vod_add_video(vod, url, err) != 0)
		return NULL;

	videos = xl_vod_get_videos(vod);
	if (xl_videos_get_count(videos) != 1)
		return NULL;
	video = xl_videos_get_nth_video(videos, 0);
	return xl_vod_get_video_play_url(vod, type, video, err);
}

VideoStatus xl_vod_get_video_status(XLVod *vod, XLVideo *video, XLErrorCode *err)
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
	char *url_hash;
	char post_data[1024];
	char post_url[1024];
	XLHttp *http;

	url_hash = xl_video_get_url_hash(video);
	snprintf(post_data, sizeof(post_data), "{\"req\":{\"url_hash_list\":[\"%s\"],\"platform\":0}}", url_hash);
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
	const char *body = xl_http_get_body(http);
	status = json_parse_get_video_status(body);
failed:
	s_free(url_hash);
	xl_http_free(http);
	return status;
}

static char* vod_upload_bt_file(XLVod *vod, const char *path)
{
	size_t file_size;
	char url[1024];
	XLErrorCode err;
	XLHttp *http;
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
	const char *body = xl_http_get_body(http);
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
	const char* body = xl_http_get_body(http);
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

const char *xl_vod_str_video_status(VideoStatus status)
{
	char* msg[]={
		"Status: waitting for download",
		"Status: downloading now",
		"Status: download failed",
		"Status: waitting for convert code",
		"Status: converting	now",
		"Status: converted",
		"Status: convert failed",
		"Status: video is ready",
		"Status: seed downloading now",
		"Status: seed downloaded",
		"Status: has no video",
		"Status: download failed",
		NULL,
	};
	if (status < 12)
		return msg[status];
	else
		return NULL;
}
