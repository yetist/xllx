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
#include "info.h"

struct _XLCookies {
	char *verify_key;
	char *check_result;
	char *active;
	char *blogresult;
	char *downbyte;
	char *downfile;
	char *isspwd;
	char *isvip;
	char *jumpkey;
	char *logintype;
	char *nickname;
	char *onlinetime;
	char *order;
	char *safe;
	char *score;
	char *sessionid;
	char *sex;
	char *upgrade;
	char *userid;
	char *in_xl;

	char *cookie_strings;
};

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
static void update_cookies(XLCookies *cookies, XLHttpRequest *req, const char *key, int update_cache);
static char *xl_client_get_cookies(XLClient *client);
static void cookies_free(XLCookies *c);
static void receive_cookies(XLClient *client, XLHttpRequest *req, int update);

XLClient *xl_client_new(const char *username, const char *password)
{

	if (!username || !password) {
		xl_log(LOG_ERROR, "Username or password is null\n");
		return NULL;
	}

	XLClient *client = s_malloc0(sizeof(*client));
	client->username = s_strdup(username);
	client->password = s_strdup(password);
	client->cookies = s_malloc0(sizeof(*(client->cookies)));

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

static void receive_cookies(XLClient *client, XLHttpRequest *req, int update)
{
	update_cookies(client->cookies, req, "VERIFY_KEY", update);
	update_cookies(client->cookies, req, "check_result", update);
	update_cookies(client->cookies, req, "active", update);
	update_cookies(client->cookies, req, "blogresult", update);
	update_cookies(client->cookies, req, "downbyte", update);
	update_cookies(client->cookies, req, "downfile", update);
	update_cookies(client->cookies, req, "isspwd", update);
	update_cookies(client->cookies, req, "isvip", update);
	update_cookies(client->cookies, req, "jumpkey", update);
	update_cookies(client->cookies, req, "logintype", update);
	update_cookies(client->cookies, req, "nickname", update);
	update_cookies(client->cookies, req, "onlinetime", update);
	update_cookies(client->cookies, req, "order", update);
	update_cookies(client->cookies, req, "safe", update);
	update_cookies(client->cookies, req, "score", update);
	update_cookies(client->cookies, req, "sessionid", update);
	update_cookies(client->cookies, req, "sex", update);
	update_cookies(client->cookies, req, "upgrade", update);
	update_cookies(client->cookies, req, "userid", update);
	update_cookies(client->cookies, req, "in_xl", update);
}

void do_login(XLClient *client, XLErrorCode *err)
{
    char msg[512] ={0};
	XLHttpRequest *req;
	char url[512];
	char *cookies;
	char response[256];
	int ret;

	snprintf(url, sizeof(url), "http://login.xunlei.com/sec2login/");
	req = xl_http_request_create_default(url, err);
	if (!req) {
		goto failed;
	}

    cookies = xl_client_get_cookies(client);
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

	receive_cookies(client, req, 1);
	if (client->cookies->userid != NULL)
	{
		printf("login successfully!\nuserid=%s\n", client->cookies->userid);
	}

failed:
	xl_http_request_free(req);
}

void do_login2(XLClient *client, const char* encpwd, XLErrorCode *err)
{
    char msg[512] ={0};
	XLHttpRequest *req;
	char url[512];
	char *cookies;

	char response[256];
	int ret;

	snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/login?cachetime=%ld&from=0", get_current_timestamp());
	req = xl_http_request_create_default(url, err);
	if (!req) {
		goto failed;
	}
    cookies = xl_client_get_cookies(client);
    if (cookies != NULL) {
		xl_log(LOG_NOTICE, "cookies=%s\n", cookies);
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

<<<<<<< HEAD
	char* userid;
	userid = xl_http_request_get_cookie(req, "userid");
	printf("the user id is %s\n", userid);
	xl_log(LOG_NOTICE, "Get response userid: %s\n", userid);
=======
	receive_cookies(client, req, 1);
>>>>>>> 6569126b872fd3acb4a1098d11526b7930719698
failed:
	xl_http_request_free(req);
}

int xl_client_login(XLClient *client, XLErrorCode *err)
{
	long now;
    if (!client) {
        xl_log(LOG_ERROR, "Invalid pointer\n");
        return XL_ERROR_ERROR;
    }

	now = get_current_timestamp();

	if (!client->vcode) {
		get_verify_code(client, err);
		printf("err=%d\n", *err);
		switch (*err) {
			case XL_ERROR_LOGIN_NEED_VC:
				get_verify_image(client);
				xl_log(LOG_WARNING, "Need to enter verify code\n");
				return ;
			case XL_ERROR_NETWORK_ERROR:
				xl_log(LOG_ERROR, "Network error\n");
				return ;
			case XL_ERROR_OK:
				xl_log(LOG_DEBUG, "Get verify code OK\n");
				break;
			default:
				xl_log(LOG_ERROR, "Unknown error\n");
				return ;
		}
	}
    
    /* Third: calculate the md5 */
    char *md5;// = lwqq_enc_pwd(client->password, client->vcode);

    /* Last: do real login */
    do_login(client, err);
    //do_login2(client, md5, err);
//    s_free(md5);

    /* Free old value */
//    lwqq_vc_free(client->vc);
//    client->vc = NULL;
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
	char response[256];
	int ret;

	snprintf(url, sizeof(url), "http://login.xunlei.com/check?u=%s&cachetime=%ld", client->username, get_current_timestamp());
	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_request_create_default(url, err);
	if (!req) {
		goto failed;
	}

    cookies = xl_client_get_cookies(client);
    if (cookies != NULL) {
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

	// TODO
	//update_cookies(client->cookies, req, "VERIFY_KEY", 1);
	//update_cookies(client->cookies, req, "check_result", 1);
	receive_cookies(client, req, 1);
	char* check_result;
	//char* verify_key;
	check_result = xl_http_request_get_cookie(req, "check_result");
	//verify_key = xl_http_request_get_cookie(req, "VERIFY_KEY");
	//xl_log(LOG_NOTICE, "Get response verify code: %s\n", check_result);
	//client->cookies->check_result = s_strdup(check_result);
	//client->cookies->verify_key = s_strdup(verify_key);

	//update_cookies(client->cookies, req, "verify_key", 1);
	//update_cookies(client->cookies, req, "check_result", 1);
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
    char image_file[256];
	char response[256];
	int ret;
	XLErrorCode err;

	snprintf(url, sizeof(url), "http://verify2.xunlei.com/image?cachetime=%ld", get_current_timestamp());
	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_request_create_default(url, &err);
	if (!req) {
		goto failed;
	}

    cookies = xl_client_get_cookies(client);
    if (cookies != NULL) {
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

	receive_cookies(client, req, 1);

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
	cookies_free(client->cookies);

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
    int ret = -1;

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

<<<<<<< HEAD
static void xl_tasks_with_URL(char *task_url, boolean has_next_page,TaskListType listtype)
{
	XLHttpRequest *req;
	char response[256];
	int ret;
	XLErrorCode err;
	xl_log(LOG_NOTICE, "Request URL=%s\n", url);
	req = xl_http_request_create_default(url, &err);
	if (!req) {
		goto failed;
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
		char *response = xl_http_request_get_response(req);
		//here parse the response
	}

failed:
	xl_http_request_free(req);

}

static void xl_tasks_with_status(TaskListType listType)
{
	char url[512];
	char *userid = "288543553";
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

	xl_tasks_with_URL(url, false, listType);
}

static void xl_tasks_with_status(TaskListType listType,int pg,bool hasNextPage)
{
	char* userid = "288543553";
	char url[512];
	switch (listType) {
		case TLTAll:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=0&p=%ld",userid,pg);
			break;
		case TLTComplete:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=2&p=%ld",userid,pg);
			break;
		case TLTDownloadding:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_task?userid=%@&st=1&p=%ld",userid,pg);
			break;
		case TLTOutofDate:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_history?type=1&userid=%@&p=%ld",userid,pg);
			break;
		case TLTDeleted:
			snprintf(url, sizeof(url), "http://dynamic.cloud.vip.xunlei.com/user_history?type=0&userid=%@&p=%ld",userid,pg);
			break;
		default:
			break;
	}
	xl_tasks_with_URL(url, hasNextPage, listType);
}

void xl_read_all_tasks_with_stat(TaskListType listType){
	int pg=1;
	bool hasNP=false;
	do {
		xl_tasks_with_status(listType, pg, &hasNP);
		pg++;
	} while (hasNP);
	return;
}

void xl_read_all_complete_tasks()
{
	xl_read_all_tasks_with_stat(TLTComplete);
}
void xl_read_complete_tasks_with_page(int pg)
{
	xl_tasks_with_status(TLTComplete, pg, NULL);
}
void xl_read_all_downloading_tasks()
{
	xl_read_all_tasks_with_stat(TLTDownloadding);
}
void xl_read_downloading_tasks_with_page(int pg)
{
	xl_tasks_with_status(TLTDownloadding, pg, NULL);
}
void xl_read_all_outofdate_tasks()
{
	xl_read_all_tasks_with_stat(TLTOutofDate);
}
void xl_read_outofdate_tasks_with_page(int pg)
{
	xl_tasks_with_status(TLTOutofDate, pg, NULL);
}
void xl_read_all_delete_tasks()
{
	xl_read_all_tasks_with_stat(TLTDeleted);
}
void xl_read_delete_tasks_with_page(int pg)
{
	xl_tasks_with_status(TLTDeleted, pg, NULL);
}

=======
/** 
 * Update the cookies needed by xunlei
 *
 * @param req  
 * @param key 
 * @param value 
 * @param update_cache Weather update cookie_strings member
 */
static void update_cookies(XLCookies *cookies, XLHttpRequest *req, const char *key, int update_cache)
{
    if (!cookies || !req || !key) {
        xl_log(LOG_ERROR, "Null pointer access\n");
        return ;
    }

    char *value = xl_http_request_get_cookie(req, key);
    if (value == NULL)
        return ;
    
#define FREE_AND_STRDUP(a, b)                   \
    if (a != NULL)                              \
        s_free(a);                              \
    a = s_strdup(b);
    
    if (!strcmp(key, "VERIFY_KEY")) {
        FREE_AND_STRDUP(cookies->verify_key, value);
    } else if (!strcmp(key, "check_result")) {
        FREE_AND_STRDUP(cookies->check_result, value);
    } else if (!strcmp(key, "active")) {
        FREE_AND_STRDUP(cookies->active, value);
    } else if (!strcmp(key, "blogresult")) {
        FREE_AND_STRDUP(cookies->blogresult, value);
    } else if (!strcmp(key, "downbyte")) {
        FREE_AND_STRDUP(cookies->downbyte, value);
    } else if (!strcmp(key, "downfile")) {
        FREE_AND_STRDUP(cookies->downfile, value);
    } else if (!strcmp(key, "isspwd")) {
        FREE_AND_STRDUP(cookies->isspwd, value);
    } else if (!strcmp(key, "isvip")) {
        FREE_AND_STRDUP(cookies->isvip, value);
    } else if (!strcmp(key, "jumpkey")) {
        FREE_AND_STRDUP(cookies->jumpkey, value);
    } else if (!strcmp(key, "logintype")) {
        FREE_AND_STRDUP(cookies->logintype, value);
    } else if (!strcmp(key, "nickname")) {
        FREE_AND_STRDUP(cookies->nickname, value);
    } else if (!strcmp(key, "onlinetime")) {
        FREE_AND_STRDUP(cookies->onlinetime, value);
    } else if (!strcmp(key, "order")) {
        FREE_AND_STRDUP(cookies->order, value);
    } else if (!strcmp(key, "safe")) {
        FREE_AND_STRDUP(cookies->safe, value);
    } else if (!strcmp(key, "score")) {
        FREE_AND_STRDUP(cookies->score, value);
    } else if (!strcmp(key, "sessionid")) {
        FREE_AND_STRDUP(cookies->sessionid, value);
    } else if (!strcmp(key, "sex")) {
        FREE_AND_STRDUP(cookies->sex, value);
    } else if (!strcmp(key, "upgrade")) {
        FREE_AND_STRDUP(cookies->upgrade, value);
    } else if (!strcmp(key, "userid")) {
        FREE_AND_STRDUP(cookies->userid, value);
    } else if (!strcmp(key, "in_xl")) {
        FREE_AND_STRDUP(cookies->in_xl, value);
    } else {
        xl_log(LOG_WARNING, "No this cookie: %s\n", key);
    }
    s_free(value);

    if (update_cache) {
        char buf[4096] = {0};           /* 4K is enough for cookies. */
        int buflen = 0;
        if (cookies->verify_key) {
            snprintf(buf, sizeof(buf), "VERIFY_KEY=%s; ", cookies->verify_key);
            buflen = strlen(buf);
        }
        if (cookies->check_result) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "check_result=%s; ", cookies->check_result);
            buflen = strlen(buf);
        }
        if (cookies->active) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "active=%s; ", cookies->active);
            buflen = strlen(buf);
        }
        if (cookies->blogresult) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "blogresult=%s; ", cookies->blogresult);
            buflen = strlen(buf);
        }
        if (cookies->downbyte) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "downbyte=%s; ", cookies->downbyte);
            buflen = strlen(buf);
        }
        if (cookies->downfile) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "downfile=%s; ", cookies->downfile);
            buflen = strlen(buf);
        }
        if (cookies->isspwd) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "isspwd=%s; ", cookies->isspwd);
            buflen = strlen(buf);
        }
        if (cookies->isvip) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "isvip=%s; ", cookies->isvip);
            buflen = strlen(buf);
        }
        if (cookies->jumpkey) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "jumpkey=%s; ", cookies->jumpkey);
            buflen = strlen(buf);
        }
        if (cookies->logintype) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "logintype=%s; ", cookies->logintype);
            buflen = strlen(buf);
        }
        if (cookies->nickname) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "nickname=%s; ", cookies->nickname);
            buflen = strlen(buf);
        }
        if (cookies->onlinetime) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "onlinetime=%s; ", cookies->onlinetime);
            buflen = strlen(buf);
        }
        if (cookies->order) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "order=%s; ", cookies->order);
            buflen = strlen(buf);
        }
        if (cookies->safe) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "safe=%s; ", cookies->safe);
            buflen = strlen(buf);
        }
        if (cookies->score) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "score=%s; ", cookies->score);
            buflen = strlen(buf);
        }
        if (cookies->sessionid) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "sessionid=%s; ", cookies->sessionid);
            buflen = strlen(buf);
        }
        if (cookies->sex) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "sex=%s; ", cookies->sex);
            buflen = strlen(buf);
        }
        if (cookies->upgrade) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "upgrade=%s; ", cookies->upgrade);
            buflen = strlen(buf);
        }
        if (cookies->userid) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "userid=%s; ", cookies->userid);
            buflen = strlen(buf);
        }
        if (cookies->in_xl) {
            snprintf(buf + buflen, sizeof(buf) - buflen, "in_xl=%s; ", cookies->in_xl);
            buflen = strlen(buf);
        }
        
        FREE_AND_STRDUP(cookies->cookie_strings, buf);
    }
#undef FREE_AND_STRDUP
}

static char *xl_client_get_cookies(XLClient *client)
{
    if (client->cookies && client->cookies->cookie_strings) {
        return s_strdup(client->cookies->cookie_strings);
    }
    return NULL;
}

static void cookies_free(XLCookies *c)
{
	if (c != NULL) {
		s_free(c->verify_key);
		s_free(c->check_result);
		s_free(c->active);
		s_free(c->blogresult);
		s_free(c->downbyte);
		s_free(c->downfile);
		s_free(c->isspwd);
		s_free(c->isvip);
		s_free(c->jumpkey);
		s_free(c->logintype);
		s_free(c->nickname);
		s_free(c->onlinetime);
		s_free(c->order);
		s_free(c->safe);
		s_free(c->score);
		s_free(c->sessionid);
		s_free(c->sex);
		s_free(c->upgrade);
		s_free(c->userid);
		s_free(c->in_xl);
		s_free(c->cookie_strings);
		s_free(c);
	}
}
>>>>>>> 6569126b872fd3acb4a1098d11526b7930719698
