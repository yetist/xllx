/* vi: set sw=4 ts=4 wrap ai: */
/*
 * info.c: This file is part of ____
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
#include "smemory.h"
#include "cookies.h"
#include "logger.h"

struct _XLCookies {
	/* received cookie */
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
	/* client setup cookie */
	char *pagenum;
	/* cookie string for http request */
	char *cookie_string;
};

#define free_and_strdup(a,b) \
	if (a != NULL) \
		s_free(a); \
	a = s_strdup(b);

XLCookies* xl_cookies_new(void)
{
	return s_malloc0(sizeof(XLCookies));
}
/** 
 * Update the cookies needed by xunlei
 *
 * @param req  
 * @param key 
 * @param value 
 * @param update_cache Weather update cookie_string member
 */
void xl_cookies_update(XLCookies *cookies, XLHttpRequest *req, const char *key, int update_cache)
{
    if (!cookies || !req || !key) {
        xl_log(LOG_ERROR, "Null pointer access\n");
        return ;
    }

    char *value = xl_http_request_get_cookie(req, key);
    if (value == NULL)
        return ;
    
    if (!strcmp(key, "VERIFY_KEY")) {
        free_and_strdup(cookies->verify_key, value);
    } else if (!strcmp(key, "check_result")) {
        free_and_strdup(cookies->check_result, value);
    } else if (!strcmp(key, "active")) {
        free_and_strdup(cookies->active, value);
    } else if (!strcmp(key, "blogresult")) {
        free_and_strdup(cookies->blogresult, value);
    } else if (!strcmp(key, "downbyte")) {
        free_and_strdup(cookies->downbyte, value);
    } else if (!strcmp(key, "downfile")) {
        free_and_strdup(cookies->downfile, value);
    } else if (!strcmp(key, "isspwd")) {
        free_and_strdup(cookies->isspwd, value);
    } else if (!strcmp(key, "isvip")) {
        free_and_strdup(cookies->isvip, value);
    } else if (!strcmp(key, "jumpkey")) {
        free_and_strdup(cookies->jumpkey, value);
    } else if (!strcmp(key, "logintype")) {
        free_and_strdup(cookies->logintype, value);
    } else if (!strcmp(key, "nickname")) {
        free_and_strdup(cookies->nickname, value);
    } else if (!strcmp(key, "onlinetime")) {
        free_and_strdup(cookies->onlinetime, value);
    } else if (!strcmp(key, "order")) {
        free_and_strdup(cookies->order, value);
    } else if (!strcmp(key, "safe")) {
        free_and_strdup(cookies->safe, value);
    } else if (!strcmp(key, "score")) {
        free_and_strdup(cookies->score, value);
    } else if (!strcmp(key, "sessionid")) {
        free_and_strdup(cookies->sessionid, value);
    } else if (!strcmp(key, "sex")) {
        free_and_strdup(cookies->sex, value);
    } else if (!strcmp(key, "upgrade")) {
        free_and_strdup(cookies->upgrade, value);
    } else if (!strcmp(key, "userid")) {
        free_and_strdup(cookies->userid, value);
    } else if (!strcmp(key, "in_xl")) {
        free_and_strdup(cookies->in_xl, value);
    } else {
        xl_log(LOG_WARNING, "No this cookie: %s\n", key);
    }
    s_free(value);

	if (update_cache) {
		xl_cookies_update_string(cookies);
	}
}

void xl_cookies_update_string(XLCookies *cookies)
{
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
	if (cookies->pagenum) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "pagenum=%s; ", cookies->pagenum);
		buflen = strlen(buf);
	}
	free_and_strdup(cookies->cookie_string, buf);
}

void xl_cookies_receive(XLCookies *cookies, XLHttpRequest *req, int update)
{
	xl_cookies_update(cookies, req, "VERIFY_KEY", update);
	xl_cookies_update(cookies, req, "check_result", update);
	xl_cookies_update(cookies, req, "active", update);
	xl_cookies_update(cookies, req, "blogresult", update);
	xl_cookies_update(cookies, req, "downbyte", update);
	xl_cookies_update(cookies, req, "downfile", update);
	xl_cookies_update(cookies, req, "isspwd", update);
	xl_cookies_update(cookies, req, "isvip", update);
	xl_cookies_update(cookies, req, "jumpkey", update);
	xl_cookies_update(cookies, req, "logintype", update);
	xl_cookies_update(cookies, req, "nickname", update);
	xl_cookies_update(cookies, req, "onlinetime", update);
	xl_cookies_update(cookies, req, "order", update);
	xl_cookies_update(cookies, req, "safe", update);
	xl_cookies_update(cookies, req, "score", update);
	xl_cookies_update(cookies, req, "sessionid", update);
	xl_cookies_update(cookies, req, "sex", update);
	xl_cookies_update(cookies, req, "upgrade", update);
	xl_cookies_update(cookies, req, "userid", update);
	xl_cookies_update(cookies, req, "in_xl", update);
}

void xl_cookies_set_pagenum(XLCookies *cookies, int pagesize)
{
	if (!cookies) {
		return;
	}
	char buf[10];
	snprintf(buf, sizeof(buf), "%d", pagesize);
	free_and_strdup(cookies->pagenum, buf);
	xl_cookies_update_string(cookies);
}

char *xl_cookies_get_string(XLCookies *cookies)
{
    if (cookies && cookies->cookie_string) {
        return s_strdup(cookies->cookie_string);
    }
    return NULL;
}

char* xl_cookies_get_userid(XLCookies *cookies)
{
	if (cookies != NULL) {
		return s_strdup(cookies->userid);
	}
	return NULL;
}

void xl_cookies_free(XLCookies *cookies)
{
	if (cookies != NULL) {
		s_free(cookies->verify_key);
		s_free(cookies->check_result);
		s_free(cookies->active);
		s_free(cookies->blogresult);
		s_free(cookies->downbyte);
		s_free(cookies->downfile);
		s_free(cookies->isspwd);
		s_free(cookies->isvip);
		s_free(cookies->jumpkey);
		s_free(cookies->logintype);
		s_free(cookies->nickname);
		s_free(cookies->onlinetime);
		s_free(cookies->order);
		s_free(cookies->safe);
		s_free(cookies->score);
		s_free(cookies->sessionid);
		s_free(cookies->sex);
		s_free(cookies->upgrade);
		s_free(cookies->userid);
		s_free(cookies->in_xl);
		s_free(cookies->pagenum);
		s_free(cookies->cookie_string);
		s_free(cookies);
	}
}
