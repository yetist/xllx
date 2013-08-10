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
#include "xl-client.h"
#include "xl-http.h"
#include "smemory.h"
#include "logger.h"
#include "url.h"
#include "md5.h"
#include "info.h"
#include "xl-cookies.h"

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
static void xl_client_show_cookie_names(XLHttp *request);
static XLHttp *xl_client_open_url(XLClient *client, const char *url, HttpMethod method, const char* post_data, const char* refer, XLErrorCode *err);
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

	//xl_log(LOG_DEBUG, "Create a new client with username:%s, password:%s successfully\n", client->username, client->password);
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

int xl_client_check_verify_code(XLClient *client, XLErrorCode *err)
{
    char msg[512] ={0};
	XLHttp *req;
	int ret = -1;

	create_post_data(client, msg, sizeof(msg));
	req = xl_client_open_url(client, "http://login.xunlei.com/sec2login/", HTTP_POST, msg, NULL, err);
	if (req == NULL)
		return -1;
	if (xl_http_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	if (xl_http_has_cookie(req, "userid") != 0)
	{
    	*err = XL_ERROR_LOGIN_NEED_VC;
		goto failed;
	}
	ret = 0;
	xl_cookies_receive(client->cookies, req, 1);
failed:
	xl_http_free(req);
	return ret;
}

int do_login(XLClient *client, XLErrorCode *err)
{
	XLHttp *req;
	char url[512];

	//"http://vip.xunlei.com/domain.html"
	//http://dynamic.cloud.vip.xunlei.com/login?cachetime=1375861841423&cachetime=1375861842103&from=0
	snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/login?cachetime=%ld&from=0", get_current_timestamp());
	xl_cookies_set_pagenum(client->cookies, "1");
	req = xl_client_open_url(client, url, HTTP_GET, NULL, NULL, err);
	if (req == NULL){
		goto failed;
	}
	xl_cookies_receive(client->cookies, req, 1);
	printf("status code=%d\n", xl_http_get_status(req));
	int status_code = xl_http_get_status(req);
	if (status_code != 302)
	{
		printf("[----html----\n%s\n----html----]\n", xl_http_get_response(req));
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	xl_cookies_clear_sessionid(client->cookies);
	xl_cookies_clear_lx_login(client->cookies);
	xl_cookies_clear_lx_sessionid(client->cookies);
	xl_cookies_clear_lsessionid(client->cookies);
	xl_cookies_receive(client->cookies, req, 1);
	*err = XL_ERROR_OK;
	return 0;
#if 0
	char *page;
	page = xl_http_get_body(req);
	if (page && strlen(page) > 70)
	{
		s_free(page);
		xl_http_free(req);
		*err = XL_ERROR_OK;
		return 0;
	} else {
		*err = XL_ERROR_ERROR;
	}
	printf("page=%s\n", page);
#endif
failed:
	xl_cookies_set_pagenum(client->cookies, "100");
	xl_http_free(req);
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
		switch (*err) {
			case XL_ERROR_LOGIN_NEED_VC:
				get_verify_image(client);
				xl_log(LOG_WARNING, "Need to enter verify code\n");
				return -1;
			case XL_ERROR_HTTP_ERROR:
			case XL_ERROR_NETWORK_ERROR:
				xl_log(LOG_ERROR, "Network error\n");
				return -1;
			case XL_ERROR_OK:
				//xl_log(LOG_DEBUG, "Get verify code OK\n");
				break;
			default:
				xl_log(LOG_ERROR, "Unknown error\n");
				return -1;
		}
	}

	if (xl_client_check_verify_code(client, err) != 0)
	{
		s_free(client->vcode);
		client->vcode = NULL;
		return -1;
	}
	return do_login(client, err);
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
static void xl_client_show_cookie_names(XLHttp *request)
{
    int i, nums;
	char **cookies;

	nums = xl_http_get_cookie_names(request, &cookies);
	if (nums == 0)
		return;
    for (i=0 ; i < nums; i++)
    {
        if (cookies[i] != NULL){
            printf("[COOKIE_%d]%s\n", i, cookies[i]);
        }
    }

	if (cookies)
	{
		for (i=0 ; i < nums; i++)
		{
			if (cookies[i]){
				s_free(cookies[i]);
				cookies[i] = NULL;
			}
		}
		s_free(cookies);
	}
}

/*
 * setup cookies and request url
 * then XLHttp pointer
 * don't forget to free it with xl_http_free(req);
 * */
static XLHttp *xl_client_open_url(XLClient *client, const char *url, HttpMethod method, const char* post_data, const char* refer, XLErrorCode *err)
{
	XLHttp *req;
	char *cookies;
	int ret;
	req = xl_http_create_default(url, err);
	if (!req) {
		goto failed;
	}
    xl_log(LOG_NOTICE, "URL=%s\n", url);
    cookies = xl_cookies_get_string_line(client->cookies);
    if (cookies != NULL) {
		xl_log(LOG_NOTICE, "Set-Cookie=%s\n", cookies);
		xl_http_set_header(req, "Cookie", cookies);
        s_free(cookies);
    }
    if (refer != NULL) {
		xl_log(LOG_NOTICE, "Refer=%s\n", refer);
		xl_http_set_header(req, "Refer", refer);
    }
	if (post_data != NULL)
	{
		char *post = s_strdup(post_data);
		ret = xl_http_open(req, method, post);
		s_free(post);
	}else{
		ret = xl_http_open(req, method, NULL);
	}
	if (ret != 0) {
		*err = XL_ERROR_NETWORK_ERROR;
		goto failed;
	}
	xl_client_show_cookie_names(req);
	return req;
failed:
	xl_http_free(req);
	return NULL;
}

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
    //xl_log(LOG_NOTICE, "current timestamp=%ld\n", v);
	return v;
}

static void get_verify_code(XLClient *client, XLErrorCode *err)
{
	XLHttp *req;
	char url[512];

	snprintf(url, sizeof(url), "http://login.xunlei.com/check?u=%s&cachetime=%ld", client->username, get_current_timestamp());
	req = xl_client_open_url(client, url, HTTP_GET, NULL, NULL, err);
	if (req == NULL){
		goto failed;
	}

	if (xl_http_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}

	xl_cookies_receive(client->cookies, req, 1);
	char* check_result;
	check_result = xl_http_get_cookie(req, "check_result");
	if (*check_result == '0' && strlen(check_result) == 6) {
		*err = XL_ERROR_OK;
		client->vcode = s_strdup(check_result+2);
	} else if (*check_result == '1') {
		*err = XL_ERROR_LOGIN_NEED_VC;
	}
	s_free(check_result);
failed:
	xl_http_free(req);
}

static void get_verify_image(XLClient *client)
{
	XLHttp *req;
	char url[512];
	XLErrorCode err;

	snprintf(url, sizeof(url), "http://verify2.xunlei.com/image?cachetime=%ld", get_current_timestamp());
	req = xl_client_open_url(client, url, HTTP_GET, NULL, NULL, &err);
	if (req == NULL){
		goto failed;
	}
	if (xl_http_get_status(req) != 200) {
		goto failed;
	}
	xl_cookies_receive(client->cookies, req, 1);

    int image_length = 0;
    char *content_length = xl_http_get_header(req, "Content-Length");
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
			int ret;
			ret = write(fd, xl_http_get_response(req), image_length);
			if (ret <= 0) {
				xl_log(LOG_ERROR, "Saving verify image file error\n");
			}
			close(fd);
		}
		s_free(client->vimgpath);
	}

failed:
	xl_http_free(req);
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
	char *next_page_url = nextPageSubURL(site_data);
	if (next_page_url)
	{
		s_free(next_page_url);
	}
	return 0;
}
static void xl_tasks_with_URL(XLClient *client, char *url, int *has_next_page,TaskListType listtype)
{
	XLHttp *req;
	int ret;
	char *cookies;
	XLErrorCode err;

	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_create_default(url, &err);
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
		xl_http_set_header(req, "Cookie", cookies);
        s_free(cookies);
    }

	ret = xl_http_open(req, HTTP_GET, NULL);
	if (ret != 0) {
		goto failed;
	}

	if (xl_http_get_status(req) != 200)
	{
		goto failed;
	}

	char *site_data =	xl_http_get_body(req);
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
	xl_http_free(req);

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


static void create_get_name_post_data(char *url, char *buf, int buflen)
{
	struct json_object *new_obj;
	struct json_object *new_array;
	struct json_object *urls_obj;
	char *pname_argument;
	new_obj = json_object_new_object();
	json_object_object_add(new_obj, "id", json_object_new_int(0));
	if (url)
	{
		char *en_url = url_encode(url);
		json_object_object_add(new_obj, "url", json_object_new_string(en_url));
		s_free(en_url);
	}
	new_array = json_object_new_array();
	json_object_array_add(new_array, new_obj);
	urls_obj = json_object_new_object();
	json_object_object_add(urls_obj, "urls", new_array);

	printf("to_string()=%s\n", json_object_to_json_string(urls_obj));
	pname_argument = (char *)json_object_to_json_string(urls_obj);
	snprintf(buf, buflen, pname_argument);
	json_object_put(urls_obj);
}
static void create_add_yun_post_data(char *url, char *name, char *buf, int buflen)
{
	struct json_object *new_obj;
	struct json_object *new_array;
	struct json_object *urls_obj;
	char *pname_argument;
	new_obj = json_object_new_object();
	json_object_object_add(new_obj, "id", json_object_new_int(0));
	if (url)
	{
		char *en_url = url_encode(url);
		json_object_object_add(new_obj, "url", json_object_new_string(en_url));
		s_free(en_url);
		char *en_name = url_encode(name);
		json_object_object_add(new_obj, "name", json_object_new_string(en_name));
		s_free(en_name);
	}
	new_array = json_object_new_array();
	json_object_array_add(new_array, new_obj);
	urls_obj = json_object_new_object();
	json_object_object_add(urls_obj, "urls", new_array);

	printf("to_string()=%s\n", json_object_to_json_string(urls_obj));
	pname_argument = (char *)json_object_to_json_string(urls_obj);
	snprintf(buf, buflen, pname_argument);
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

	int rest = json_object_object_get(resp, "ret");
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
		snprintf(buf, buflen, name);
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
		int rest = json_object_object_get(resp, "ret");
		if (rest == 0)
			xl_log(LOG_NOTICE, "Add yun tasks successfully\n");
			return 0;
	}

	return 1;
}

int xl_add_yun_task(XLClient *client, char *url)
{

	XLHttp *req;
	int ret;
	XLErrorCode *err;
//	url = "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=";
	char *userid;
	char *sessionid;
	char buf[256];

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
	memset(buf, '\0', 256);
	create_get_name_post_data(url, buf, 256);

	char post_url[256];
	memset(post_url, '\0', 256);
	snprintf(post_url, sizeof(post_url), "http://i.vod.xunlei.com/req_video_name?from=vlist&platform=0");
	req = xl_client_open_url(client, post_url, HTTP_POST, buf, NULL, err);

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

	req = xl_client_open_url(client, p_url, HTTP_POST, buf, NULL, err);
	response = xl_http_get_response(req);
	printf("get response %s\n",  xl_http_get_response(req));
	if (xl_get_ret_from_response(response) == 0)
	{
		xl_http_free(req);
		return 1;
	}
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

	XLHttp *req;
	XLErrorCode err;
	req = xl_client_open_url(client, get_url, HTTP_GET, NULL, NULL, &err);
	printf("get response %s\n",  xl_http_get_response(req));

failed:
	xl_http_free(req);


	//char *get_url ="http://i.vod.xunlei.com/req_get_method_vod?url=thunder%3A%2F%2FQUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo%3D&video_name=%22%5B%E9%98%B3%E5%85%89%E7%94%B5%E5%BD%B1www.ygdy8.com%5D.%E5%8F%B6%E9%97%AE%EF%BC%9A%E7%BB%88%E6%9E%81%E4%B8%80%E6%88%98.BD.720p.%E5%9B%BD%E7%B2%A4%E5%8F%8C%E8%AF%AD%E4%B8%AD%E5%AD%97.mkv%22&platform=0&userid=288543553&vip=1&sessionid=F827301D73D5DA49AC524CE2B36574FE0D18667A764D6EAEAEFC45F7B510BCB4F9092B1DE6436403F587D60E1542F684598E95A9227619BAEB8C71718C76EA8C&gcid=A74C828D94C8E419D0238C168780C97C30AD6F15&cid=DECE9E4F67AA199E3D7135757AD686AF35228F9D&filesize=1261414195&cache=1375959475212&from=vlist&jsonp=XL_CLOUD_FX_INSTANCEqueryBack";

}
