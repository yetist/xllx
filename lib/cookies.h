/* vi: set sw=4 ts=4 wrap ai: */
/*
 * cookies.h: This file is part of ____
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

#ifndef __COOKIES_H__ 
#define __COOKIES_H__  1

#include "http.h"

typedef struct _XLCookies XLCookies;

XLCookies*  xl_cookies_new(void);
void  xl_cookies_update(XLCookies *cookies, XLHttpRequest *req, const char *key, int update_cache);
void  xl_cookies_update_string(XLCookies *cookies);
void  xl_cookies_receive(XLCookies *cookies, XLHttpRequest *req, int update);

void  xl_cookies_set_pagenum(XLCookies *cookies, int pagesize);
char* xl_cookies_get_string(XLCookies *cookies);
char* xl_cookies_get_userid(XLCookies *cookies);
void  xl_cookies_free(XLCookies *cookies);

#endif /* __COOKIES_H__ */
