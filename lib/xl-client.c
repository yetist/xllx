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

#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <json.h>

#include "xl-client.h"
#include "xl-url.h"
#include "xl-utils.h"
#include "smemory.h"
#include "logger.h"
#include "md5.h"

struct _XLClient
{
    char *username;             /**< Username */
    char *password;             /**< Password */
	char *vcode;
	char *vimgpath;
    //XLCookies *cookies;
	XLHttpShare *hs;
};
static void  get_verify_code(XLClient *client, XLErrorCode *err);
static void  get_verify_image(XLClient *client);
static char* encode_password(const char* password, const char* vcode);
//static void    client_show_cookie_names(XLClient *client);
static XLHttp* client_open_url(XLClient *client, const char *url, HttpMethod method, const char* post_data, const char* refer, XLErrorCode *err);
static XLHttp *client_create_http(XLClient *client, const char *url, XLErrorCode *err);

XLClient *xl_client_new(const char *username, const char *password)
{

	if (!username || !password) {
		xl_log(LOG_ERROR, "Username or password is null\n");
		return NULL;
	}
	XLClient *client = s_malloc0(sizeof(*client));
	client->username = s_strdup(username);
	client->password = s_strdup(password);
	//client->cookies = xl_cookies_new();
	client->hs = xl_http_share_new();

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
    s = xl_url_quote(m);
    snprintf(buf, buflen, "%s", m);
    s_free(s);
}

int xl_client_check_verify_code(XLClient *client, XLErrorCode *err)
{
    char msg[512] ={0};
	XLHttp *req;
	int ret = -1;

	create_post_data(client, msg, sizeof(msg));
	req = client_open_url(client, "http://login.xunlei.com/sec2login/", HTTP_POST, msg, NULL, err);
	if (req == NULL)
		return -1;
	if (xl_http_get_status(req) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	if (xl_http_share_has_cookie(client->hs, "userid") != 0)
	{
    	*err = XL_ERROR_LOGIN_NEED_VC;
		goto failed;
	}
	ret = 0;
	//client_show_cookie_names(client);
	//xl_cookies_receive(client->cookies, client->hs, 1);
failed:
	xl_http_free(req);
	return ret;
}

int do_login(XLClient *client, XLErrorCode *err)
{
	XLHttp *http;
	char url[512];

	//"http://vip.xunlei.com/domain.html"
	//http://dynamic.cloud.vip.xunlei.com/login?cachetime=1375861841423&cachetime=1375861842103&from=0
	snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/login?cachetime=%ld&from=0", get_current_timestamp());

	http = client_create_http(client, url, err);
	if (http == NULL)
		return -1;
	xl_http_set_cookie(http, "pagenum", "1");
	if (xl_http_open(http, HTTP_GET, NULL) != 0)
		goto failed;

	if (xl_http_get_status(http) != 200)
	{
		printf("[----html----\n%s\n----html----]\n", xl_http_get_body(http));
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}
	*err = XL_ERROR_OK;
	return 0;
failed:
	xl_http_free(http);
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
				xl_log(LOG_ERROR, "Unknown error, err=%d\n", *err);
				return -1;
		}
	}

	if (xl_client_check_verify_code(client, err) != 0)
	{
		if (*client->vcode != '!')
		{
			s_free(client->vcode);
			client->vcode = NULL;
			get_verify_image(client);
		}else{
			s_free(client->vcode);
			client->vcode = NULL;
			get_verify_code(client, err);
		}
		return -1;
	}

	return do_login(client, err);
}

/*
 *有两种方法可以实现logout
 *第一种清空Cookies，第二种访问http://dynamic.vip.xunlei.com/login/indexlogin_contr/logout/，本方法采用了第一种速度快，现在也没发现什么问题。
 */
void xl_client_logout(XLClient *client)
{
	if (client->hs)
	{
		xl_http_share_free(client->hs);
		client->hs = xl_http_share_new();
	}
}

/**
 * client_has_logged_in:
 * @client: the XLClient
 *
 * check if user is logged in.
 *
 * Return value: if has logged in, return 0; else return -1;
 **/
int xl_client_has_logged_in(XLClient *client)
{
	int ret = -1;
	char *userid;
	char url[512];
	XLHttp *http;
	XLErrorCode err;

	userid = xl_http_share_get_cookie(client->hs, "userid");
	if (!userid)
		return ret;
	snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%s&st=0", userid);
	s_free(userid);

	http = client_create_http(client, url, &err);
	if (http == NULL)
		return -1;
	xl_http_set_cookie(http, "pagenum", "1");
	if (xl_http_open(http, HTTP_GET, NULL) != 0)
		goto failed;

	if (xl_http_get_status(http) != 200)
		goto failed;
	if (xl_http_get_body_len(http) > 512)
	{
		ret = 0;
	}
	xl_http_free(http);
	return ret;
failed:
	xl_http_free(http);
	return ret;
}

/*
 * setup cookies and request url
 * then XLHttp pointer
 * don't forget to free it with xl_http_free(req);
 * */
XLHttp *xl_client_open_url(XLClient *client, const char *url, HttpMethod method, const char* post_data, const char* refer, XLErrorCode *err)
{
#if 0
	if (client_has_logged_in(client) != 0)
	{
		*err = XL_ERROR_LOGIN_EXPIRE;
		return NULL;
	}
#endif
	return client_open_url(client, url, method, post_data, refer, err);
}

static XLHttp *client_create_http(XLClient *client, const char *url, XLErrorCode *err)
{
	XLHttp *http;

	http = xl_http_create_default(url, err);
	if (!http) {
		return NULL;
	}
	xl_http_set_http_share(http, client->hs);
	xl_log(LOG_NOTICE, "URL[%s]\n", url);
	return http;
}

/*
 * setup cookies and request url
 * then XLHttp pointer
 * don't forget to free it with xl_http_free(req);
 * */
static XLHttp *client_open_url(XLClient *client, const char *url, HttpMethod method, const char* post_data, const char* refer, XLErrorCode *err)
{
	XLHttp *req;
	int ret;

	req = client_create_http(client, url, err);
	if (!req) {
		return NULL;
	}

    if (refer != NULL) {
		//xl_log(LOG_NOTICE, "Refer[%s]\n", refer);
		xl_http_set_header(req, "Refer", refer);
    }
	if (post_data != NULL)
	{
		char *post = s_strdup(post_data);
		//xl_log(LOG_NOTICE, "POST[%s]\n", post);
		ret = xl_http_open(req, method, post);
		s_free(post);
	}else{
		ret = xl_http_open(req, method, NULL);
	}
	if (ret != 0) {
		*err = XL_ERROR_NETWORK_ERROR;
		goto failed;
	}
	if (xl_http_get_status(req) == 408) {
		xl_log(LOG_NOTICE, "HTTP STATUS[408]\n");
		*err = XL_ERROR_HTTP_TIMEOUT;
		goto failed;
	}

	const char *body = xl_http_get_body(req);
	int body_len = xl_http_get_body_len(req);
	if (body_len > 0  && body_len < 9000 && body_len == strlen(body))
	{
		printf("[====================html(%d)====================\n%s\n=====================html========================]\n", xl_http_get_status(req), body);
	}
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

static void get_verify_code(XLClient *client, XLErrorCode *err)
{
	XLHttp *http;
	char url[512];

	snprintf(url, sizeof(url), "http://login.xunlei.com/check?u=%s&cachetime=%ld", client->username, get_current_timestamp());
	http = client_open_url(client, url, HTTP_GET, NULL, NULL, err);
	if (http == NULL){
		*err = XL_ERROR_HTTP_ERROR;
		return;
	}

	if (xl_http_get_status(http) != 200)
	{
		*err = XL_ERROR_HTTP_ERROR;
		goto failed;
	}

	char* check_result;
	check_result = xl_http_share_get_cookie(client->hs, "check_result");
	if (*check_result == '0' && strlen(check_result) == 6) {
		*err = XL_ERROR_OK;
		client->vcode = s_strdup(check_result+2);
	} else if (*check_result == '1') {
		*err = XL_ERROR_LOGIN_NEED_VC;
	}
	s_free(check_result);
failed:
	xl_http_free(http);
}

static void get_verify_image(XLClient *client)
{
	XLHttp *http;
	char url[512];
	XLErrorCode err;

	snprintf(url, sizeof(url), "http://verify2.xunlei.com/image?cachetime=%ld", get_current_timestamp());
	http = client_open_url(client, url, HTTP_GET, NULL, NULL, &err);
	if (http == NULL){
		return;
	}
	if (xl_http_get_status(http) != 200) {
		goto failed;
	}

	if (client->vimgpath != NULL) {
		printf("saving image to %s\n", client->vimgpath);
		/* Delete old file first */
		unlink(client->vimgpath);
		int fd = creat(client->vimgpath, S_IRUSR | S_IWUSR);
		if (fd != -1) {
			int ret;
			ret = write(fd, xl_http_get_body(http), xl_http_get_body_len(http));
			if (ret <= 0) {
				xl_log(LOG_ERROR, "Saving verify image file error\n");
			}
			close(fd);
		}
	}

failed:
	xl_http_free(http);
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
	s_free(client->vimgpath);
	xl_http_share_free(client->hs);
	xl_http_cleanup();
	s_free(client);
}

XLHttp* xl_client_upload_file(XLClient *client, const char* url, const char *field, const char *path, XLErrorCode *err)
{
	int ret;
	XLHttp *http;
	http = xl_http_create_default(url, err);
	if (!http) {
		goto failed;
	}
    xl_log(LOG_NOTICE, "URL[%s]\n", url);
    //cookies = xl_cookies_get_string_line(client->cookies);
    //if (cookies != NULL) {
	//	//xl_log(LOG_NOTICE, "Set-Cookie[%s]\n", cookies);
	//	xl_http_set_header(http, "Cookie", cookies);
    //    s_free(cookies);
    //}
	if ((ret = xl_http_upload_file(http, field, path)) != 0) {
		*err = XL_ERROR_NETWORK_ERROR;
		goto failed;
	}
//	if (xl_http_get_body_len(http) <= 6000)
//		printf("[====================html(%d)====================\n%s\n=====================html========================]\n", xl_http_get_status(http), xl_http_get_body(http));
	//client_show_cookie_names(http);
	return http;
failed:
	xl_http_free(http);
	return NULL;
}

char* xl_client_get_cookie(XLClient *client, const char *name)
{
	return xl_http_share_get_cookie(client->hs, name);
}
