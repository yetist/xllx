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

#include <ghttp.h>

/* XL Error Code */
typedef enum {
    XL_ERROR_OK,
    XL_ERROR_ERROR,
    XL_ERROR_FILE_NOT_EXIST,
    XL_ERROR_LOGIN_NEED_VC = 10,
    XL_ERROR_LOGIN_EXPIRE,
    XL_ERROR_NETWORK_ERROR = 20,
    XL_ERROR_HTTP_ERROR = 30,
} XLErrorCode;

typedef enum
{
	HTTP_GET = ghttp_type_get,
	HTTP_POST = ghttp_type_post,
} HttpMethod;

typedef int (*XLAsyncCallback) (XLErrorCode ec, char *response, void* data);

typedef struct _XLHttp XLHttp;

XLHttp *xl_http_new(const char *url);
XLHttp *xl_http_create_default(const char *url, XLErrorCode *err);

int xl_http_open(XLHttp *request, HttpMethod method, char *body);
int xl_http_open_async(XLHttp *request, HttpMethod method, char *body, XLAsyncCallback callback, void *data);
int xl_http_upload_file(XLHttp *request, const char *field, const char *path);

void xl_http_set_header(XLHttp *request, const char *name, const char *value);

char* xl_http_get_header(XLHttp *request, const char *name);
char* xl_http_get_cookie(XLHttp *request, const char *name);
int   xl_http_get_cookie_names(XLHttp *request, char ***names);
int   xl_http_has_cookie(XLHttp *request, const char *name);
int   xl_http_get_status(XLHttp *request);
char* xl_http_get_body(XLHttp *request);
int   xl_http_get_body_len(XLHttp *request);

void xl_http_free(XLHttp *request);

#endif  /* XL_HTTP_H */
