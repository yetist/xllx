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
	/* received from http://login.xunlei.com/check?u=USERNAME&cachetime=NOW */
	char *check_result;
	/* received from http://login.xunlei.com/check?u=USERNAME&cachetime=NOW or get image url */
	char *_verify_key;	/* key: VERIFY_KEY */
	/* received from http://login.xunlei.com/sec2login/ */
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
	char *usernewno;
	char *usernick;
	char *usertype;
	char *usrname;

	/* received from http://dynamic.cloud.vip.xunlei.com/login?cachetime=NOW&from=0 */
	char *in_xl;
	char *lx_sessionid;
	char *dl_enable;
	char *_isnewer;		/* key: isnewer_${userid}, like isnewer_288543553; */
	char *lx_login;
	char *vip_expiredate;
	char *user_type;
	char *vip_level;
	char *vip_paytype;
	char *vip_isvip;
	char *_initbg_pop;	/* key: initbg_pop${userid}; like initbg_pop288543553; */
	char *last_userid;
	char *vip_is_good_number;
	char *loadding_img;

	/* client setup cookie */
	char *pagenum;
	char *lx_nf_all;
	char *lsessionid; 
	char *gdriveid;

	/* cookie string for http request */
	char *string_line;
};

#define free_and_strdup(a,b) \
do{	\
	if (a != NULL) \
		s_free(a); \
	a = s_strdup(b); \
}while(0)

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
 * @param update_cache Weather update string member
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
    
    if (!strcmp(key, "check_result")) {
        free_and_strdup(cookies->check_result, value);
    } else if (!strcmp(key, "VERIFY_KEY")) {
        free_and_strdup(cookies->_verify_key, value);
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
    } else if (!strcmp(key, "usernewno")) {
        free_and_strdup(cookies->usernewno, value);
    } else if (!strcmp(key, "usernick")) {
        free_and_strdup(cookies->usernick, value);
    } else if (!strcmp(key, "usertype")) {
        free_and_strdup(cookies->usertype, value);
    } else if (!strcmp(key, "usrname")) {
        free_and_strdup(cookies->usrname, value);

    } else if (!strcmp(key, "in_xl")) {
        free_and_strdup(cookies->in_xl, value);
    } else if (!strcmp(key, "lx_sessionid")) {
        free_and_strdup(cookies->lx_sessionid, value);

    } else if (!strcmp(key, "dl_enable")) {
        free_and_strdup(cookies->dl_enable, value);
    } else if (!strncmp(key, "isnewer_", 8)) {
        free_and_strdup(cookies->_isnewer, value);
    } else if (!strcmp(key, "lx_login")) {
        free_and_strdup(cookies->lx_login, value);
    } else if (!strcmp(key, "vip_expiredate")) {
        free_and_strdup(cookies->vip_expiredate, value);
    } else if (!strcmp(key, "user_type")) {
        free_and_strdup(cookies->user_type, value);
    } else if (!strcmp(key, "vip_level")) {
        free_and_strdup(cookies->vip_level, value);
    } else if (!strcmp(key, "vip_paytype")) {
        free_and_strdup(cookies->vip_paytype, value);
    } else if (!strncmp(key, "initbg_pop", 10)) {
        free_and_strdup(cookies->_initbg_pop, value);
    } else if (!strcmp(key, "last_userid")) {
        free_and_strdup(cookies->last_userid, value);
    } else if (!strcmp(key, "vip_is_good_number")) {
        free_and_strdup(cookies->vip_is_good_number, value);
    } else if (!strcmp(key, "loadding_img")) {
        free_and_strdup(cookies->loadding_img, value);
    } else {
        xl_log(LOG_WARNING, "No this cookie: %s\n", key);
    }
    s_free(value);

	if (update_cache) {
		xl_cookies_update_string_line(cookies);
	}
}

void xl_cookies_update_string_line(XLCookies *cookies)
{
	char buf[4096] = {0};           /* 4K is enough for cookies. */
	int buflen = 0;
	if (cookies->check_result) {
		snprintf(buf, sizeof(buf), "check_result=%s; ", cookies->check_result);
		buflen = strlen(buf);
	}
	if (cookies->_verify_key) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "VERIFY_KEY=%s; ", cookies->_verify_key);
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
	if (cookies->usernewno) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "usernewno=%s; ", cookies->usernewno);
		buflen = strlen(buf);
	}
	if (cookies->usernick) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "usernick=%s; ", cookies->usernick);
		buflen = strlen(buf);
	}
	if (cookies->usertype) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "usertype=%s; ", cookies->usertype);
		buflen = strlen(buf);
	}
	if (cookies->usrname) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "usrname=%s; ", cookies->usrname);
		buflen = strlen(buf);
	}

	if (cookies->in_xl) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "in_xl=%s; ", cookies->in_xl);
		buflen = strlen(buf);
	}
	if (cookies->lx_sessionid) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "lx_sessionid=%s; ", cookies->lx_sessionid);
		buflen = strlen(buf);
	}
	if (cookies->dl_enable) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "dl_enable=%s; ", cookies->dl_enable);
		buflen = strlen(buf);
	}
	if (cookies->_isnewer) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "isnewer_%s=%s; ", cookies->userid, cookies->_isnewer);
		buflen = strlen(buf);
	}
	if (cookies->lx_login) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "lx_login=%s; ", cookies->lx_login);
		buflen = strlen(buf);
	}
	if (cookies->vip_expiredate) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "vip_expiredate=%s; ", cookies->vip_expiredate);
		buflen = strlen(buf);
	}
	if (cookies->user_type) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "user_type=%s; ", cookies->user_type);
		buflen = strlen(buf);
	}
	if (cookies->vip_level) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "vip_level=%s; ", cookies->vip_level);
		buflen = strlen(buf);
	}
	if (cookies->vip_paytype) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "vip_paytype=%s; ", cookies->vip_paytype);
		buflen = strlen(buf);
	}
	if (cookies->vip_isvip) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "vip_isvip=%s; ", cookies->vip_isvip);
		buflen = strlen(buf);
	}
	if (cookies->_initbg_pop) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "initbg_pop%s=%s; ", cookies->userid, cookies->_initbg_pop);
		buflen = strlen(buf);
	}
	if (cookies->last_userid) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "last_userid=%s; ", cookies->last_userid);
		buflen = strlen(buf);
	}
	if (cookies->vip_is_good_number) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "vip_is_good_number=%s; ", cookies->vip_is_good_number);
		buflen = strlen(buf);
	}
	if (cookies->loadding_img) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "loadding_img=%s; ", cookies->loadding_img);
		buflen = strlen(buf);
	}

	if (cookies->pagenum) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "pagenum=%s; ", cookies->pagenum);
		buflen = strlen(buf);
	}
	if (cookies->lx_nf_all) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "lx_nf_all=%s; ", cookies->lx_nf_all);
		buflen = strlen(buf);
	}
	if (cookies->lsessionid) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "lsessionid=%s; ", cookies->lsessionid);
		buflen = strlen(buf);
	}
	if (cookies->gdriveid) {
		snprintf(buf + buflen, sizeof(buf) - buflen, "gdriveid=%s; ", cookies->gdriveid);
		buflen = strlen(buf);
	}

	free_and_strdup(cookies->string_line, buf);
}

void xl_cookies_receive(XLCookies *cookies, XLHttpRequest *req, int update)
{
	char buf[256];

	xl_cookies_update(cookies, req, "check_result", update);
	xl_cookies_update(cookies, req, "VERIFY_KEY", update);
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
	xl_cookies_update(cookies, req, "usernewno", update);
	xl_cookies_update(cookies, req, "usernick", update);
	xl_cookies_update(cookies, req, "usertype", update);
	xl_cookies_update(cookies, req, "usrname", update);

	xl_cookies_update(cookies, req, "in_xl", update);
	xl_cookies_update(cookies, req, "lx_sessionid", update);
	xl_cookies_update(cookies, req, "dl_enable", update);
	if (cookies->userid) {
		snprintf(buf, sizeof(buf), "isnewer_%s", cookies->userid);
		xl_cookies_update(cookies, req, buf, update);
	}
	xl_cookies_update(cookies, req, "lx_login", update);
	xl_cookies_update(cookies, req, "vip_expiredate", update);
	xl_cookies_update(cookies, req, "user_type", update);
	xl_cookies_update(cookies, req, "vip_level", update);
	xl_cookies_update(cookies, req, "vip_paytype", update);
	xl_cookies_update(cookies, req, "vip_isvip", update);
	if (cookies->userid) {
		snprintf(buf, sizeof(buf), "initbg_pop%s", cookies->userid);
		xl_cookies_update(cookies, req, buf, update);
	}
	xl_cookies_update(cookies, req, "last_userid", update);
	xl_cookies_update(cookies, req, "vip_is_good_number", update);
	xl_cookies_update(cookies, req, "loadding_img", update);
}

void xl_cookies_free(XLCookies *cookies)
{
	if (cookies != NULL) {
		s_free(cookies->check_result);
		s_free(cookies->_verify_key);
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
		s_free(cookies->usernewno);
		s_free(cookies->usernick);
		s_free(cookies->usertype);
		s_free(cookies->usrname);

		s_free(cookies->in_xl);
		s_free(cookies->lx_sessionid);
		s_free(cookies->dl_enable);
		s_free(cookies->_isnewer);		/* key: isnewer_${userid}, like isnewer_288543553; */
		s_free(cookies->lx_login);
		s_free(cookies->vip_expiredate);
		s_free(cookies->user_type);
		s_free(cookies->vip_level);
		s_free(cookies->vip_paytype);
		s_free(cookies->vip_isvip);
		s_free(cookies->_initbg_pop);	/* key: initbg_pop${userid}; like initbg_pop288543553; */
		s_free(cookies->last_userid);
		s_free(cookies->vip_is_good_number);
		s_free(cookies->loadding_img);

		s_free(cookies->pagenum);
		s_free(cookies->lx_nf_all);
		s_free(cookies->lsessionid); 
		s_free(cookies->gdriveid);
		s_free(cookies->string_line);

		s_free(cookies);
	}
}

#define get_cookie_func(a) \
char* xl_cookies_get_##a(XLCookies *cookies) \
{	\
	if (cookies != NULL && cookies->a != NULL) {	\
		return s_strdup(cookies->a);	\
	}	\
	return NULL;	\
}

get_cookie_func(string_line);
get_cookie_func(userid);
get_cookie_func(gdriveid);
get_cookie_func(lx_login);
get_cookie_func(sessionid);

#define set_cookie_func(a) \
void xl_cookies_set_##a(XLCookies *cookies, const char* a) \
{	\
	if (!cookies) {	\
		return;	\
	}	\
	free_and_strdup(cookies->a, a);	\
	xl_cookies_update_string_line(cookies);	\
}

set_cookie_func(pagenum);
set_cookie_func(gdriveid);
set_cookie_func(lx_nf_all);

#define clear_cookie_func(a) \
void  xl_cookies_clear_##a(XLCookies *cookies) \
{ \
	if (cookies != NULL && cookies->a != NULL) \
		s_free(cookies->a); \
	cookies->a = NULL; \
	xl_cookies_update_string_line(cookies); \
}

clear_cookie_func(sessionid);
clear_cookie_func(lsessionid);
clear_cookie_func(lx_sessionid);
clear_cookie_func(lx_login);
