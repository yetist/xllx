/* vi: set sw=4 ts=4 wrap ai: */
/*
 * http.c: This file is part of ____
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
#include <zlib.h>
#include <ev.h>
#include <ghttp.h>
#include "smemory.h"
#include "xllx.h"
#include "http.h"
#include "logger.h"

#define XL_HTTP_USER_AGENT "User-Agent: Mozilla/5.0 \
	(X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0"

#define CHUNK 16 * 1024

typedef struct _AsyncWatchData AsyncWatchData;

struct _XLHttpRequest
{
	void *req;
	int http_code;
	char *response;
	int resp_len;
};

/* Those Code for async API */
struct _AsyncWatchData
{
	XLHttpRequest *request;
	XLAsyncCallback callback;
	void *data;
};

static int xl_async_running = -1;
static pthread_t xl_async_tid;
static pthread_cond_t xl_async_cond = PTHREAD_COND_INITIALIZER;

static char *ungzip(const char *source, int len, int *total);
static void *xl_async_thread(void* data);
static void ev_io_come(EV_P_ ev_io* w,int revent);
static void  xl_http_request_set_default_header(XLHttpRequest *request);

XLHttpRequest *xl_http_request_new(const char *uri)
{
	if (!uri) {
		return NULL;
	}

	XLHttpRequest *request;
	request = s_malloc0(sizeof(*request));

	request->req = ghttp_request_new();
	if (!request->req) {
		/* Seem like request->req must be non null. FIXME */
		goto failed;
	}
	if (ghttp_set_uri(request->req, (char *)uri) == -1) {
		xl_log(LOG_WARNING, "Invalid uri: %s\n", uri);
		goto failed;
	}

	return request;

failed:
	if (request) {
		xl_http_request_free(request);
	}
	return NULL;
}

XLHttpRequest *xl_http_create_default_request(const char *url, XLErrorCode *err)
{
	XLHttpRequest *req;

	if (!url) {
		if (err)
			*err = XL_ERROR_ERROR;
		return NULL;
	}

	req = xl_http_request_new(url);
	if (!req) {
		xl_log(LOG_ERROR, "Create request object for url: %s failed\n", url);
		if (err)
			*err = XL_ERROR_ERROR;
		return NULL;
	}

	xl_http_request_set_default_header(req);
	xl_log(LOG_DEBUG, "Create request object for url: %s sucessfully\n", url);
	return req;
}

int xl_http_request_open(XLHttpRequest *request, HttpMethod method, char *body)
{
	if (!request->req)
		return -1;

	ghttp_status status;
	char *buf;
	int have_read_bytes = 0;
	char **resp = &request->response;

	/* Clear off last response */
	if (*resp) {
		s_free(*resp);
		*resp = NULL;
	}

	if (ghttp_set_type(request->req, method) == -1) {
		xl_log(LOG_WARNING, "Set request type error\n");
		goto failed;
	}

	/* For POST method, set http body */
	if (method == HTTP_POST && body) {
		ghttp_set_body(request->req, body, strlen(body));
	}

	if (ghttp_prepare(request->req)) {
		goto failed;
	}

	for ( ; ; ) {
		int len = 0;
		status = ghttp_process(request->req);
		if(status == ghttp_error) {
			xl_log(LOG_ERROR, "Http request failed: %s\n", ghttp_get_error(request->req));
			goto failed;
		}
		/* NOTE: buf may NULL, notice it */
		buf = ghttp_get_body(request->req);
		if (buf) {
			len = ghttp_get_body_len(request->req);
			*resp = s_realloc(*resp, have_read_bytes + len);
			memcpy(*resp + have_read_bytes, buf, len);
			have_read_bytes += len;
		}
		if(status == ghttp_done) {
			/* NOTE: Ok, done */
			break;
		}
	}

	/* NB: *response may null */
	if (*resp == NULL) {
		goto failed;
	}

	/* Uncompress data here if we have a Content-Encoding header */
	char *enc_type = NULL;
	enc_type = xl_http_request_get_header(request, "Content-Encoding");
	if (enc_type && strstr(enc_type, "gzip")) {
		char *outdata;
		int total = 0;

		outdata = ungzip(*resp, have_read_bytes, &total);
		if (!outdata) {
			s_free(enc_type);
			goto failed;
		}

		s_free(*resp);
		/* Update response data to uncompress data */
		*resp = s_strdup(outdata);
		s_free(outdata);
		have_read_bytes = total;
	}
	s_free(enc_type);

	/* OK, done */
	if ((*resp)[have_read_bytes -1] != '\0') {
		/* Realloc a byte, cause *resp hasn't end with char '\0' */
		*resp = s_realloc(*resp, have_read_bytes + 1);
		(*resp)[have_read_bytes] = '\0';
	}
	request->http_code = ghttp_status_code(request->req);
	return 0;

failed:
	if (*resp) {
		s_free(*resp);
		*resp = NULL;
	}
	return -1;
}

int xl_http_request_open_async(XLHttpRequest *request, HttpMethod method,
		char *body, XLAsyncCallback callback,
		void *data)
{
	int status;

	if (ghttp_set_type(request->req, method) == -1) {
		xl_log(LOG_WARNING, "Set request type error\n");
		xl_http_request_free(request);
		return -1;
	}

	/* For POST method, set http body */
	if (method == HTTP_POST && body) {
		ghttp_set_body(request->req, body, strlen(body));
	}

	ghttp_set_sync(request->req, ghttp_async);
	if (ghttp_prepare(request->req)) {
		xl_http_request_free(request);
		return -1;
	}

	status = ghttp_process(request->req);
	if (status != ghttp_not_done){
		xl_log(LOG_ERROR, "BUG!!!async error\n");
		xl_http_request_free(request);
		return -1;
	}

	ev_io *watcher = (ev_io *)s_malloc(sizeof(ev_io));

	ghttp_request* req = (ghttp_request*)request->req;

	ev_io_init(watcher, ev_io_come, ghttp_get_socket(req), EV_READ);
	AsyncWatchData *d = s_malloc(sizeof(AsyncWatchData));
	d->request = request;
	d->callback = callback;
	d->data = data;
	watcher->data = d;

	ev_io_start(EV_DEFAULT, watcher);

	if (xl_async_running == -1) {
		xl_async_running = 1;
		pthread_create(&xl_async_tid, NULL, xl_async_thread, NULL);
	} else if(xl_async_running == 0) {
		pthread_cond_signal(&xl_async_cond);
	}

	return 0;
}

static void xl_http_set_header(XLHttpRequest *request, const char *name, const char *value)
{
	if (!request->req || !name || !value)
		return ;

	ghttp_set_header(request->req, name, value);
}

static void xl_http_request_set_default_header(XLHttpRequest *request)
{
	xl_http_set_header(request, "User-Agent", XL_HTTP_USER_AGENT);
	xl_http_set_header(request, "Accept", "text/html, application/xml;q=0.9, "
			"application/xhtml+xml, image/png, image/jpeg, "
			"image/gif, image/x-xbitmap, */*;q=0.1");
	xl_http_set_header(request, "Accept-Language", "en-US,zh-CN,zh;q=0.9,en;q=0.8");
	xl_http_set_header(request, "Accept-Charset", "GBK, utf-8, utf-16, *;q=0.1");
	xl_http_set_header(request, "Accept-Encoding", "deflate, gzip, x-gzip, " "identity, *;q=0");
	xl_http_set_header(request, "Connection", "Keep-Alive");
}

char *xl_http_request_get_header(XLHttpRequest *request, const char *name)
{
	if (!name) {
		xl_log(LOG_ERROR, "Invalid parameter\n");
		return NULL; 
	}

	const char *h = ghttp_get_header(request->req, name);
	if (!h) {
		return NULL;
	}

	return s_strdup(h);
}

char *xl_http_request_get_cookie(XLHttpRequest *request, const char *name)
{
	if (!name) {
		xl_log(LOG_ERROR, "Invalid parameter\n");
		return NULL; 
	}

	char *cookie = ghttp_get_cookie(request->req, name);
	if (!cookie) {
		xl_log(LOG_WARNING, "No cookie: %s\n", name);
		return NULL;
	}

	xl_log(LOG_DEBUG, "Parse Cookie: %s=%s\n", name, cookie);
	return cookie;
}

int xl_http_request_get_status(XLHttpRequest *request)
{
	return request->http_code;
}

const char* xl_http_request_get_response(XLHttpRequest *request)
{
	return request->response;
}

void xl_http_request_free(XLHttpRequest *request)
{
	if (!request)
		return;

	if (request) {
		s_free(request->response);
		ghttp_request_destroy(request->req);
		s_free(request);
	}
}

static char *unzlib(const char *source, int len, int *total, int isgzip)
{
	int ret;
	unsigned have;
	z_stream strm;
	unsigned char out[CHUNK];
	int totalsize = 0;
	char *dest = NULL;

	if (!source || len <= 0 || !total)
		return NULL;

	/* allocate inflate state */
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.avail_in = 0;
	strm.next_in = Z_NULL;

	if(isgzip) {
		/**
		 * 47 enable zlib and gzip decoding with automatic header detection,
		 * So if the format of compress data is gzip, we need passed it to
		 * inflateInit2
		 */
		ret = inflateInit2(&strm, 47);
	} else {
		ret = inflateInit(&strm);
	}

	if (ret != Z_OK) {
		xl_log(LOG_ERROR, "Init zlib error\n");
		return NULL;
	}

	strm.avail_in = len;
	strm.next_in = (Bytef *)source;

	do {
		strm.avail_out = CHUNK;
		strm.next_out = out;
		ret = inflate(&strm, Z_NO_FLUSH);
		switch (ret) {
			case Z_STREAM_END:
				break;
			case Z_BUF_ERROR:
				xl_log(LOG_ERROR, "Unzlib error\n");
				break;
			case Z_NEED_DICT:
				ret = Z_DATA_ERROR; /* and fall through */
				break;
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
			case Z_STREAM_ERROR:
				xl_log(LOG_ERROR, "Ungzip stream error!", strm.msg);
				inflateEnd(&strm);
				goto failed;
		}
		have = CHUNK - strm.avail_out;
		totalsize += have;
		dest = s_realloc(dest, totalsize);
		memcpy(dest + totalsize - have, out, have);
	} while (strm.avail_out == 0);

	/* clean up and return */
	(void)inflateEnd(&strm);
	if (ret != Z_STREAM_END) {
		goto failed;
	}
	*total = totalsize;
	return dest;

failed:
	if (dest) {
		s_free(dest);
	}
	xl_log(LOG_ERROR, "Unzip error\n");
	return NULL;
}

static char *ungzip(const char *source, int len, int *total)
{
	return unzlib(source, len, total, 1);
}

static void *xl_async_thread(void* data)
{
	struct ev_loop* loop = EV_DEFAULT;
	pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
	while (1) {
		xl_async_running = 1;
		ev_run(loop, 0);
		xl_async_running = 0;
		pthread_mutex_lock(&mutex);
		pthread_cond_wait(&xl_async_cond, &mutex);
		pthread_mutex_unlock(&mutex);
	}
}

static void ev_io_come(EV_P_ ev_io* w, int revent)
{
	AsyncWatchData *d = (AsyncWatchData *) w->data;
	XLErrorCode ec;
	char *buf;
	XLHttpRequest *lhr = d->request;
	ghttp_request *req = lhr->req;


	int status = ghttp_process(req);
	if (status == ghttp_error) {
		ec = XL_ERROR_ERROR;
		goto done;
	}

	/* NOTE: buf may NULL, notice it */
	buf = ghttp_get_body(req);
	if (buf) {
		int len;
		len = ghttp_get_body_len(req);
		lhr->response = s_realloc(lhr->response, lhr->resp_len + len);
		memcpy(lhr->response + lhr->resp_len, buf, len);
		lhr->resp_len += len;
	}
	if (status == ghttp_done) {
		ec = XL_ERROR_OK;
		goto done;
	}

	/* Go on */
	return ;

done:
	if (ec == XL_ERROR_OK && lhr->response) {
		/* Uncompress data here if we have a Content-Encoding header */
		char *enc_type = NULL;
		enc_type = xl_http_request_get_header(lhr, "Content-Encoding");
		if (enc_type && strstr(enc_type, "gzip")) {
			char *outdata;
			int total = 0;

			outdata = ungzip(lhr->response, lhr->resp_len, &total);
			if (outdata) {
				s_free(lhr->response);
				/* Update response data to uncompress data */
				lhr->response = s_strdup(outdata);
				s_free(outdata);
				lhr->resp_len = total;
			}
		}
		s_free(enc_type);

		/* OK, done */
		if (lhr->response[lhr->resp_len -1] != '\0') {
			/* Realloc a byte, cause lhr->response hasn't end with char '\0' */
			lhr->response = s_realloc(lhr->response, lhr->resp_len + 1);
			lhr->response[lhr->resp_len] = '\0';
		}
	}

	/* Callback */
	d->callback(ec, lhr->response, d->data);

	/* OK, exit this request */
	ev_io_stop(EV_DEFAULT, w);
	xl_http_request_free(d->request);
	s_free(d);
	s_free(w);
}
