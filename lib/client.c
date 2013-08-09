/* vi: set sw=4 ts=4 wrap ai: */
/*
 * client.c: This file is part of ____
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

#include <sys/time.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <unistd.h>
#include <ctype.h>
#include <regex.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <json.h>

#include "xllx.h"
#include "client.h"
#include "http.h"
#include "smemory.h"
#include "logger.h"
#include "url.h"
#include "md5.h"
#include "info.h"
#include "cookies.h"

#include "parse.h"

struct _XLClient
{
    char *username;             /**< Username */
    char *password;             /**< Password */
	char *vcode;
	char *vimgpath;
    XLCookies *cookies;
};
struct _XLYun
{
    char *size;             /**< Username */
    char *url;             /**< Password */
	char *dcid;
	char *filename;
    YUNZHUANMAQuality q;
};

static long get_current_timestamp(void);
static void get_verify_code(XLClient *client, XLErrorCode *err);
static void get_verify_image(XLClient *client);
static char *string_toupper(const char *str);
static char* encode_password(const char* password, const char* vcode);
static int re_match(const char* pattern, const char* str);
//static char *parse_string(const char* pattern, const char* str);

XLClient *xl_client_new(const char *username, const char *password)
{

	if (!username || !password) {
		xl_log(LOG_ERROR, "Username or password is null\n");
		return NULL;
	}
	XLClient *client = s_malloc0(sizeof(*client));
	client->username = s_strdup(username);
	client->password = s_strdup(password);
	client->cookies = xl_cookies_new();

	xl_log(LOG_DEBUG, "Create a new client with username:%s, password:%s successfully\n", client->username, client->password);
	return client;
}

static void create_post_data(XLClient *client, char *buf, int buflen)
{
    char *s;
    char m[512];
	char* encpwd;

	encpwd =  encode_password(client->password, client->vcode);
    snprintf(m, sizeof(m), "u=%s&p=%s&verifycode=%s", client->username, encpwd, client->vcode);
	s_free(encpwd);
    s = url_encode(m);
    snprintf(buf, buflen, "%s", m);
    s_free(s);
}

void do_login(XLClient *client, XLErrorCode *err)
{
    char msg[512] ={0};
	XLHttpRequest *req;
	char url[512];
	char *cookies;
	int ret;

	snprintf(url, sizeof(url), "http://login.xunlei.com/sec2login/");
	req = xl_http_request_create_default(url, err);
	if (!req) {
		goto failed;
	}

    cookies = xl_cookies_get_string_line(client->cookies);
    if (cookies != NULL) {
		printf("Set-Cookie=%s\n", cookies);
		xl_http_request_set_header(req, "Cookie", cookies);
        s_free(cookies);
    }

	create_post_data(client, msg, sizeof(msg));
	xl_log(LOG_NOTICE, "%s\n", msg);
	ret = xl_http_request_open(req, HTTP_POST, msg);
	if (ret != 0) {
		*err = XL_ERROR_NETWORK_ERROR;
		goto failed;
	}

	if (xl_http_request_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	char **cooks;
	xl_http_request_get_cookie_names(req, &cooks);

	xl_cookies_receive(client->cookies, req, 1);
	char *userid;
	userid = xl_cookies_get_userid(client->cookies);
	if (userid != NULL)
	{
		*err = XL_ERROR_OK;
		printf("login successfully!\nuserid=%s\n", userid);
	}

failed:
	xl_http_request_free(req);
}

int is_login_ok(XLClient *client, XLErrorCode *err)
{
	XLHttpRequest *req;
	char url[512];
	char *cookies;
	int ret;

	//"http://vip.xunlei.com/domain.html"
	//http://dynamic.cloud.vip.xunlei.com/login?cachetime=1375861841423&cachetime=1375861842103&from=0
	snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/login?cachetime=%ld&from=0", get_current_timestamp());
	req = xl_http_request_create_default(url, err);
	if (!req) {
		goto failed;
	}
	xl_cookies_set_pagenum(client->cookies, "1");
    cookies = xl_cookies_get_string_line(client->cookies);
    if (cookies != NULL) {
		printf("Set-Cookie=%s\n", cookies);
		xl_http_request_set_header(req, "Cookie", cookies);
        s_free(cookies);
    }
	ret = xl_http_request_open(req, HTTP_GET, NULL);
	if (ret != 0) {
		*err = XL_ERROR_NETWORK_ERROR;
		goto failed;
	}
	xl_cookies_receive(client->cookies, req, 1);

	printf("status code=%d\n", xl_http_request_get_status(req));
	int status_code = xl_http_request_get_status(req);
	if (status_code != 302)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	char **cooks;
	xl_http_request_get_cookie_names(req, &cooks);
	xl_cookies_receive(client->cookies, req, 1);
	xl_cookies_set_pagenum(client->cookies, "100");
	*err = XL_ERROR_OK;
	return 0;

#if 0
	char *page;
	page = xl_http_request_get_body(req);
	if (page && strlen(page) > 70)
	{
		s_free(page);
		xl_http_request_free(req);
		*err = XL_ERROR_OK;
		return 0;
	} else {
		*err = XL_ERROR_ERROR;
	}
	printf("page=%s\n", page);
#endif
failed:
	xl_http_request_free(req);
	return -1;
}

int xl_client_login(XLClient *client, XLErrorCode *err)
{
    if (!client) {
        xl_log(LOG_ERROR, "Invalid pointer\n");
        *err = XL_ERROR_ERROR;
		return -1;
    }

	if (!client->vcode) {
		get_verify_code(client, err);
		printf("err=%d\n", *err);
		switch (*err) {
			case XL_ERROR_LOGIN_NEED_VC:
				get_verify_image(client);
				xl_log(LOG_WARNING, "Need to enter verify code\n");
				return -1;
			case XL_ERROR_NETWORK_ERROR:
				xl_log(LOG_ERROR, "Network error\n");
				return -1;
			case XL_ERROR_OK:
				xl_log(LOG_DEBUG, "Get verify code OK\n");
				break;
			default:
				xl_log(LOG_ERROR, "Unknown error\n");
				return -1;
		}
	}
    do_login(client, err);
	return is_login_ok(client, err);
}

/*
 *有两种方法可以实现logout
 *第一种清空Cookies，第二种访问http://dynamic.vip.xunlei.com/login/indexlogin_contr/logout/，本方法采用了第一种速度快，现在也没发现什么问题。
 */
//int xl_client_logout(XLClient *client, XLErrorCode *err)
//{
//		ckeys = ["vip_isvip","lx_sessionid","vip_level","lx_login","dl_enable","in_xl","ucid","lixian_section"]
//		ckeys1 = ["sessionid","usrname","nickname","usernewno","userid"]
//		gdriveid
//
//		self.del_cookie('.vip.xunlei.com', 'gdriveid')
//		for k in ckeys:
//			self.set_cookie('.vip.xunlei.com', k, '')
//		for k in ckeys1:
//			self.set_cookie('.xunlei.com', k, '')
//		self.save_cookies()
//}

static char* encode_password(const char* password, const char* vcode)
{
	char buf[128] = {0};
	char new_buf[128] = {0};

	if (re_match("^[0-9a-f]{32}$", password) != 0)
	{
		lutil_md5_data((const unsigned char *)password, strlen(password), (char *)buf);
		lutil_md5_data((const unsigned char *)buf, strlen(buf), (char *)buf);
	} else {
		strcpy(buf, password);
	}
	char *vcode_upper = string_toupper(vcode);
	snprintf(new_buf, sizeof(new_buf), "%s%s", buf, vcode_upper);
	s_free(vcode_upper);
	lutil_md5_data((const unsigned char *)new_buf, strlen(new_buf), (char*)buf);
	return s_strdup(buf);
}

static long get_current_timestamp(void)
{
    struct timeval tv;
    long v;

    gettimeofday(&tv, NULL);
    v = tv.tv_usec;
    v = (v - v % 1000) / 1000;
    v = tv.tv_sec * 1000 + v;
    xl_log(LOG_NOTICE, "current timestamp=%ld\n", v);
	return v;
}

static void get_verify_code(XLClient *client, XLErrorCode *err)
{
	XLHttpRequest *req;
	char url[512];

	char *cookies;
	int ret;

	snprintf(url, sizeof(url), "http://login.xunlei.com/check?u=%s&cachetime=%ld", client->username, get_current_timestamp());
	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_request_create_default(url, err);
	if (!req) {
		goto failed;
	}

    cookies = xl_cookies_get_string_line(client->cookies);
    if (cookies != NULL) {
		printf("Set-Cookie=%s\n", cookies);
		xl_http_request_set_header(req, "Cookie", cookies);
        s_free(cookies);
    }
	ret = xl_http_request_open(req, HTTP_GET, NULL);
	if (ret != 0) {
		*err = XL_ERROR_NETWORK_ERROR;
		goto failed;
	}

	if (xl_http_request_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}

	xl_cookies_receive(client->cookies, req, 1);
	char* check_result;
	check_result = xl_http_request_get_cookie(req, "check_result");
	if (*check_result == '0' && strlen(check_result) == 6) {
		*err = XL_ERROR_OK;
		client->vcode = s_strdup(check_result+2);
	} else if (*check_result == '1') {
		*err = XL_ERROR_LOGIN_NEED_VC;
	}
	s_free(check_result);
failed:
	xl_http_request_free(req);
}

static void get_verify_image(XLClient *client)
{
	XLHttpRequest *req;
	char url[512];

	char *cookies;
	int ret;
	XLErrorCode err;

	snprintf(url, sizeof(url), "http://verify2.xunlei.com/image?cachetime=%ld", get_current_timestamp());
	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_request_create_default(url, &err);
	if (!req) {
		goto failed;
	}

    cookies = xl_cookies_get_string_line(client->cookies);
    if (cookies != NULL) {
		printf("Set-Cookie=%s\n", cookies);
		xl_http_request_set_header(req, "Cookie", cookies);
        s_free(cookies);
    }
	ret = xl_http_request_open(req, HTTP_GET, NULL);
	if (ret != 0) {
		goto failed;
	}

	if (xl_http_request_get_status(req) != 200)
	{
		goto failed;
	}

	xl_cookies_receive(client->cookies, req, 1);

    int image_length = 0;
    char *content_length = xl_http_request_get_header(req, "Content-Length");
    if (content_length) {
        image_length = atoi(content_length);
        s_free(content_length);
    }

	if (client->vimgpath != NULL) {
		//snprintf(image_file, sizeof(image_file), "/tmp/xl_%s.jpeg", client->username);
		/* Delete old file first */
		printf("saving image to %s\n", client->vimgpath);
		unlink(client->vimgpath);
		int fd = creat(client->vimgpath, S_IRUSR | S_IWUSR);
		if (fd != -1) {
			ret = write(fd, xl_http_request_get_response(req), image_length);
			if (ret <= 0) {
				xl_log(LOG_ERROR, "Saving verify image file error\n");
			}
			close(fd);
		}
		s_free(client->vimgpath);
	}

failed:
	xl_http_request_free(req);
}

void xl_client_set_verify_code(XLClient *client, const char *vcode)
{
	if (!client)
		return ;

	if (client->vcode != NULL)
		s_free(client->vcode);
	client->vcode = strdup(vcode);
}

void xl_client_set_verify_image_path(XLClient *client, const char *path)
{
	if (!client)
		return ;

	if (client->vimgpath)
		s_free(client->vimgpath);
	client->vimgpath = strdup(path);
}

void xl_client_free(XLClient *client)
{
	if (!client)
		return ;

	s_free(client->username);
	s_free(client->password);
	s_free(client->vcode);
	xl_cookies_free(client->cookies);

	s_free(client);
}

static char *string_toupper(const char *str)
{
	char *newstr, *p;
	p = newstr = s_strdup(str);
	while(*p) {
		*p=toupper(*p);
		p++;
	}
	return newstr;
}

/*
 * return value:
 * error: -1
 * no match: 1
 * matched: 0
 */

static int re_match(const char* pattern, const char* str)
{
    regex_t re;            
    int err;
    err = regcomp(&re, pattern, REG_EXTENDED|REG_NOSUB);
    if (err)
    {
        return -1;
    }
    err = regexec(&re, str, 0, NULL, 0);
    if (err == REG_NOMATCH)
    {
         regfree(&re);
         return 1;
    }
    else if (err)
    {  
         return 1;
    }
    regfree(&re);
    return 0;
}

char *getGDriveID(XLCookies *cookies){
	char *gid = xl_cookies_get_gdriveid(cookies);
	return gid;
}
int isGDriveIDInCookiei(XLCookies *cookies){
	int result = 0;
	char *gid = getGDriveID(cookies);
	if (gid){
		result=1;
		s_free(gid);
	}
	return result;
}

void setGdriveID(XLCookies *cookies, char *gdriveid){
	xl_cookies_set_gdriveid(cookies, gdriveid);
}

int if_has_next_page(char *site_data)
{
	int result = 0;
	char *next_page_url = nextPageSubURL(site_data);
	if (next_page_url)
	{
		result = 1;
		s_free(next_page_url);
	}
	return 0;
}
static void xl_tasks_with_URL(XLClient *client, char *url, int *has_next_page,TaskListType listtype)
{
	XLHttpRequest *req;
	int ret;
	char *cookies;
	XLErrorCode err;

	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_request_create_default(url, &err);
	if (!req) {
		goto failed;
	}

	if(listtype==TLTOutofDate||listtype==TLTDeleted){
		xl_cookies_set_lx_nf_all(client -> cookies, "page_check_all%3Dhistory%26fltask_all_guoqi%3D1%26class_check%3D0%26page_check%3Dtask%26fl_page_id%3D0%26class_check_new%3D0%26set_tab_status%3D11");
	}else{
		xl_cookies_set_lx_nf_all(client -> cookies, "");
	}

   	cookies = xl_cookies_get_string_line(client->cookies);
    if (cookies != NULL) {
		xl_log(LOG_NOTICE, "cookies=%s\n", cookies);
		xl_http_request_set_header(req, "Cookie", cookies);
        s_free(cookies);
    }

	ret = xl_http_request_open(req, HTTP_GET, NULL);
	if (ret != 0) {
		goto failed;
	}

	if (xl_http_request_get_status(req) != 200)
	{
		goto failed;
	}

	char *site_data =	xl_http_request_get_body(req);
	printf("the data is %s\n", site_data);
	char *gdriveID = GDriveID(site_data);
	if (site_data && (strlen(gdriveID) > 0)) 
	{
		setGdriveID(client->cookies, gdriveID);
		s_free(gdriveID);
		if(has_next_page){
			*has_next_page=if_has_next_page(site_data);
		}

		char *re1="<div\\s*class=\"rwbox\"([\\s\\S]*)?<!--rwbox-->";
		char *tmpD1=string_by_matching(re1, site_data);
		printf("the rwbox is %s\n", tmpD1);
		char *re2=NULL;
		if(listtype==TLTAll|listtype==TLTComplete|listtype==TLTDownloadding){
			re2="<div\\s*class=\"rw_list\"[\\s\\S]*?<!--\\s*rw_list\\s*-->";
		}else if (listtype==TLTOutofDate|listtype==TLTDeleted){
			re2="<div\\s*class=\"rw_list\"[\\s\\S]*?<input\\s*id=\"d_tasktype\\d+\"\\s*type=\"hidden\"\\s*value=[^>]*>";
		}

	}

failed:
	xl_log(LOG_NOTICE, "Errored\n");
	xl_http_request_free(req);

}

static void xl_tasks_with_status(XLClient *client, TaskListType listType)
{
	char url[512];
	char *userid = xl_cookies_get_userid(client->cookies);
	switch (listType) {
		case TLTAll:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=0",userid);
			break;
		case TLTComplete:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=2",userid);
			break;
		case TLTDownloadding:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=1",userid);
			break;
		case TLTOutofDate:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_history?type=1&userid=%s",userid);
			break;
		case TLTDeleted:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_history?type=0userid=%s",userid);
			break;
		default:
			break;
	}

	xl_tasks_with_URL(client, url, 0, listType);
}

static void xl_tasks_with_status_with_page(XLClient *client, TaskListType listType,int pg,int *hasNextPage)
{
	//char* userid = "288543553";
	char *userid = xl_cookies_get_userid(client->cookies);
	char url[512];
	switch (listType) {
		case TLTAll:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=0&p=%d",userid,pg);
			break;
		case TLTComplete:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=2&p=%d",userid,pg);
			break;
		case TLTDownloadding:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=1&p=%d",userid,pg);
			break;
		case TLTOutofDate:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_history?type=1&userid=%s&p=%d",userid,pg);
			break;
		case TLTDeleted:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_history?type=0&userid=%s&p=%d",userid,pg);
			break;
		default:
			break;
	}
	xl_tasks_with_URL(client, url, hasNextPage, listType);
}

void xl_read_all_tasks_with_stat(XLClient *client, TaskListType listType){
	int pg=1;
	int hasNP=0;
	do {
		xl_tasks_with_status_with_page(client, listType, pg, &hasNP);
		pg++;
	} while (hasNP);
	return;
}

void xl_read_all_complete_tasks(XLClient *client)
{
	xl_read_all_tasks_with_stat(client, TLTComplete);
}
void xl_read_complete_tasks_with_page(XLClient *client, int pg)
{
	xl_tasks_with_status_with_page(client, TLTComplete, pg, NULL);
}
void xl_read_all_downloading_tasks(XLClient *client)
{
	xl_read_all_tasks_with_stat(client, TLTDownloadding);
}
void xl_read_downloading_tasks_with_page(XLClient *client, int pg)
{
	xl_tasks_with_status_with_page(client, TLTDownloadding, pg, NULL);
}
void xl_read_all_outofdate_tasks(XLClient *client)
{
	xl_read_all_tasks_with_stat(client, TLTOutofDate);
}
void xl_read_outofdate_tasks_with_page(XLClient *client, int pg)
{
	xl_tasks_with_status_with_page(client, TLTOutofDate, pg, NULL);
}
void xl_read_all_delete_tasks(XLClient *client)
{
	xl_read_all_tasks_with_stat(client,TLTDeleted);
}
void xl_read_delete_tasks_with_page(XLClient *client, int pg)
{
	xl_tasks_with_status_with_page(client, TLTDeleted, pg, NULL);
}

int xl_add_yun_task(XLClient *client, char *url)
{

	XLHttpRequest *req;
	char *cookies;
	int ret;
	XLErrorCode *err;
	url = "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=";
	char *userid;
	char *sessionid;
	struct json_object *new_obj;
	struct json_object *new_array;
	struct json_object *urls_obj;
	char *pname_argument;
	userid = xl_cookies_get_userid(client->cookies);
	if (userid != NULL)
	{
		printf("\nuserid=%s\n", userid);
	}

	sessionid = xl_cookies_get_sessionid(client->cookies);
	if (sessionid != NULL)
	{
		printf("\nsessionid=%s\n", sessionid);
	}
	new_obj = json_object_new_object();
	json_object_object_add(new_obj, "id", json_object_new_int(0));
	if (url)
	{
		char *en_url = url_encode(url);
		json_object_object_add(new_obj, "url", json_object_new_string(en_url));
		json_object_get(new_obj);
	}
	new_array = json_object_new_array();
	json_object_array_add(new_array, new_obj);
	urls_obj = json_object_new_object();
	json_object_object_add(urls_obj, "urls", new_array);
	json_object_get(new_array);
//	json_object_get(urls_obj);
	
	printf("to_string()=%s\n", json_object_to_json_string(urls_obj));
	pname_argument = (char *)json_object_to_json_string(urls_obj);


//	char *post_argument = "{\"urls\":[{\"id\":0,\"url\":\"thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=\"}]}";
	//snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/interface/cloud_build_task/");

	char post_url[512];
	snprintf(post_url, sizeof(post_url), "http://i.vod.xunlei.com/req_video_name?from=vlist&platform=0");
	req = xl_http_request_create_default(post_url, err);
	if (!req) {
		goto failed;
	}

	cookies = xl_cookies_get_string_line(client->cookies);
	if (cookies != NULL) {
		printf("Set-Cookie=%s\n", cookies);
		xl_http_request_set_header(req, "Cookie", cookies);
		s_free(cookies);
	}


	xl_log(LOG_NOTICE, "%s\n", pname_argument);
	ret = xl_http_request_open(req, HTTP_POST, pname_argument);
	if (ret != 0) {
		*err = XL_ERROR_NETWORK_ERROR;
		goto failed;
	}

	if (xl_http_request_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}

	printf("get response %s\n",  xl_http_request_get_response(req));
	char *response = xl_http_request_get_response(req);
	printf("get body %s\n", xl_http_request_get_body(req));
	xl_http_request_free(req);
	struct json_object *resp;
	struct json_object *resp_obj;
	struct json_object *res_array;
	struct json_object *obj;
	char *name = NULL;

	resp = json_tokener_parse(response);
	int rest = json_object_object_get(resp, "ret");
	printf("the ret is %d\n", rest);
	if (rest == 0)
	{
		resp_obj = json_object_object_get(resp, "resp"); 
		if (resp_obj)
		{
			printf ("resp_obj: %s\n", json_object_to_json_string(resp_obj));
			res_array = json_object_object_get(resp_obj, "res"); 
			if (res_array)
			{
				printf ("res_array: %s\n", json_object_to_json_string(res_array));
				obj = json_object_array_get_idx(res_array, 0);
				if (obj)
				{
					printf ("obj: %s\n", json_object_to_json_string(obj));
					char *n = json_object_object_get(obj, "name"); 
					char *url = json_object_object_get(obj, "url"); 
					if (n)
					{
						name = strdup(json_object_to_json_string(n));
						printf("name : %s\n", name);
					}
				}
			}
		}
	}
	if (name)
	{
		printf("name : %s\n", name);
		char *en_name = url_encode(name);

		//int json_object_array_put_idx(struct json_object *obj, int idx,
		//				     struct json_object *val);
		json_object_object_add(new_obj, "name", json_object_new_string(en_name));
		printf("to_string()=%s\n", json_object_to_json_string(new_obj));
		json_object_array_put_idx(new_array, 0, new_obj);
		printf("to_string()=%s\n", json_object_to_json_string(new_array));
		json_object_object_add(urls_obj, "urls", new_array);
		printf("to_string()=%s\n", json_object_to_json_string(urls_obj));
		pname_argument = (char *)json_object_to_json_string(urls_obj);

		char p_url[512];
		snprintf(p_url, sizeof(p_url), "http://i.vod.xunlei.com/req_add_record?from=vlist&platform=0&userid=%s&sessionid=%s", userid, sessionid);
		printf("p_url is %s \n", p_url);

		req = xl_http_request_create_default(p_url, err);
		if (!req) {
			json_object_put(urls_obj);
			goto failed;
		}
		cookies = xl_cookies_get_string_line(client->cookies);
		if (cookies != NULL) {
			printf("Set-Cookie=%s\n", cookies);
			xl_http_request_set_header(req, "Cookie", cookies);
			s_free(cookies);
		}
		ret = xl_http_request_open(req, HTTP_POST, pname_argument);
		json_object_put(urls_obj);
		if (ret != 0) {
			*err = XL_ERROR_NETWORK_ERROR;
			goto failed;
		}

		if (xl_http_request_get_status(req) != 200)
		{
			*err = XL_ERROR_HTTP_ERROR;
			goto failed;
		}

		response = xl_http_request_get_response(req);
		printf("get response %s\n",  xl_http_request_get_response(req));
		printf("get body %s\n", xl_http_request_get_body(req));
		resp = json_tokener_parse(response);
		resp_obj = json_object_object_get(resp, "resp"); 
		if (resp_obj)
		{
			printf ("resp_obj: %s\n", json_object_to_json_string(resp_obj));
			int rest = json_object_object_get(resp, "ret");
			if (rest == 0)
				xl_log(LOG_NOTICE, "Add yun tasks successfully\n");
				return 1;
		}

	}

failed:
	xl_http_request_free(req);
	return 0;
}

char *xl_get_yun_url(XLClient *client, char *vurl, char *vname)
{
	char get_url[1024];
	char *userid, *sessionid;
	userid = xl_cookies_get_userid(client->cookies);
	if (userid != NULL)
	{
		printf("\nuserid=%s\n", userid);
	}
	sessionid = xl_cookies_get_sessionid(client->cookies);
	if (sessionid != NULL)
	{
		printf("\nsessionid=%s\n", sessionid);
	}

	char *en_url = url_encode(vurl);
	char *en_name = url_encode(vname);

	snprintf(get_url, sizeof(get_url), "http://i.vod.xunlei.com/req_get_method_vod?url=%s&video_name=%s&from=vlist&platform=0&userid=%s&sessionid=%s&cache=%ld", en_url, en_name, userid, sessionid, get_current_timestamp());
	printf("the get_url is : %s\n", get_url);
	XLHttpRequest *req;
	int ret;
	char *cookies;
	XLErrorCode err;

	xl_log(LOG_NOTICE, "Request URL=%s\n", get_url);
	req = xl_http_request_create_default(get_url, &err);
	if (!req) {
		goto failed;
	}

	cookies = xl_cookies_get_string_line(client->cookies);
	if (cookies != NULL) {
		xl_log(LOG_NOTICE, "cookies=%s\n", cookies);
		xl_http_request_set_header(req, "Cookie", cookies);
		s_free(cookies);
	}

	ret = xl_http_request_open(req, HTTP_GET, NULL);
	if (ret != 0) {
		goto failed;
	}

	if (xl_http_request_get_status(req) != 200)
	{
		goto failed;
	}
	printf("get response %s\n",  xl_http_request_get_response(req));

failed:
	xl_http_request_free(req);


	//char *get_url ="http://i.vod.xunlei.com/req_get_method_vod?url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&video_name=%22%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv%22&platform=0&userid=288543553&vip=1&sessionid=F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filesize=1261414195&cache=1375959475212&from=vlist&jsonp=XL_CLOUD_FX_INSTANCEqueryBack";

}
