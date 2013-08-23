/* vi: set sw=4 ts=4 wrap ai: */
/*
 * http.h: This file is part of ____
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

#ifndef XL_HTTP_H
#define XL_HTTP_H

#include "xl-errors.h"

typedef enum
{
	HTTP_GET = 0,
	HTTP_POST = 3,
} HttpMethod;

typedef struct _XLHttp XLHttp;

typedef struct _XLHttpShare XLHttpShare;

XLHttp *xl_http_new(const char *url);
XLHttp *xl_http_create_default(const char *url, XLErrorCode *err);
void    xl_http_set_http_share(XLHttp *http, XLHttpShare *share);

int xl_http_open(XLHttp *request, HttpMethod method, char *body);
int xl_http_upload_file(XLHttp *request, const char *field, const char *path);

void xl_http_set_header(XLHttp *request, const char *name, const char *value);
void xl_http_set_cookie(XLHttp *request, const char *name, const char* val);

char* xl_http_get_header(XLHttp *request, const char *name);
int   xl_http_get_status(XLHttp *request);
const char* xl_http_get_body(XLHttp *request);
int   xl_http_get_body_len(XLHttp *request);

void xl_http_free(XLHttp *request);

/* 在新创建的不同XLHttp对象之间保持的一个缓存对象，可缓存DNS解析、Cookie等等，用于提升性能。*/
XLHttpShare* xl_http_share_new(void);
int          xl_http_share_get_cookie_names(XLHttpShare *hs, char ***names);
int          xl_http_share_has_cookie(XLHttpShare *hs, const char* key);
char*        xl_http_share_get_cookie(XLHttpShare *hs, const char *name);
void         xl_http_share_free(XLHttpShare *hs);

#endif  /* XL_HTTP_H */
