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

#include "xllx.h"
#include "client.h"
#include "http.h"
#include "smemory.h"
#include "logger.h"
#include "url.h"
#include "md5.h"
#include "info.h"
#include "cookies.h"

struct _XLClient
{
    char *username;             /**< Username */
    char *password;             /**< Password */
	char *vcode;
	char *vimgpath;
    XLCookies *cookies;
};

static long get_current_timestamp(void);
static void get_verify_code(XLClient *client, XLErrorCode *err);
static void get_verify_image(XLClient *client);
static char *string_toupper(const char *str);
static char* encode_password(const char* password, const char* vcode);
static int re_match(const char* pattern, const char* str);

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

    cookies = xl_cookies_get_string(client->cookies);
	printf("Set-Cookie=%s\n", cookies);
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

	snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/login?cachetime=%ld&from=0", get_current_timestamp());
	req = xl_http_request_create_default(url, err);
	if (!req) {
		goto failed;
	}
	xl_cookies_set_pagenum(client->cookies, 1);
    cookies = xl_cookies_get_string(client->cookies);
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
	xl_cookies_set_pagenum(client->cookies, 100);

	char *page;
	page = xl_http_request_get_response(req);
	if (strlen(page) > 512)
	{
		s_free(page);
		xl_cookies_receive(client->cookies, req, 1);
		xl_http_request_free(req);
		return 0;
	}
failed:
	xl_http_request_free(req);
	return 1;
}

int xl_client_login(XLClient *client, XLErrorCode *err)
{
    if (!client) {
        xl_log(LOG_ERROR, "Invalid pointer\n");
        return XL_ERROR_ERROR;
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
    //do_login2(client, md5, err);
//    s_free(md5);

    /* Free old value */
//    lwqq_vc_free(client->vc);
//    client->vc = NULL;
    return 0;
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

    cookies = xl_cookies_get_string(client->cookies);
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

    cookies = xl_cookies_get_string(client->cookies);
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

static void xl_tasks_with_URL(XLClient *client, char *url, int *has_next_page,TaskListType listtype)
{
	XLHttpRequest *req;
	int ret;
	char *cookies;
	XLErrorCode err;
	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_request_create_default(url, &err);
    cookies = xl_cookies_get_string(client->cookies);
	if (!req) {
		goto failed;
	}
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
	char *content_length = xl_http_request_get_header(req, "Content-Length");
	if (content_length) {
		const char *res =	xl_http_request_get_response(req);
		xl_log(LOG_NOTICE, "Request response is %s\n", res);
		//here parse the response
	}

failed:
	xl_log(LOG_NOTICE, "Errored");
	xl_http_request_free(req);

}

static void xl_tasks_with_status(XLClient *client, TaskListType listType)
{
	char url[512];
	//char *userid = "288543553";
	char *userid = xl_cookies_get_userid(client);
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
	char *userid = xl_cookies_get_userid(client);
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

