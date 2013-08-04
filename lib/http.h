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
#include "xllx.h"

typedef enum
{
	HTTP_GET = ghttp_type_get,
	HTTP_POST = ghttp_type_post,
} HttpMethod;

typedef int (*XLAsyncCallback) (XLErrorCode ec, char *response, void* data);

typedef struct _XLHttpRequest XLHttpRequest;

XLHttpRequest *xl_http_request_new(const char *url);
XLHttpRequest *xl_http_create_default_request(const char *url, XLErrorCode *err);

int xl_http_request_open(XLHttpRequest *request, HttpMethod method, char *body);
int xl_http_request_open_async(XLHttpRequest *request, HttpMethod method, char *body, XLAsyncCallback callback, void *data);

void xl_http_request_set_header(XLHttpRequest *request, const char *name, const char *value);

char*       xl_http_request_get_header(XLHttpRequest *request, const char *name);
char*       xl_http_request_get_cookie(XLHttpRequest *request, const char *name);
int         xl_http_request_get_status(XLHttpRequest *request);
const char* xl_http_request_get_response(XLHttpRequest *request);

void xl_http_request_free(XLHttpRequest *request);

#endif  /* XL_HTTP_H */
