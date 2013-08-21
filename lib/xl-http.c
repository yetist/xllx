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

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <zlib.h>
#include <curl/curl.h>
//#include <ev.h>
//#include <ghttp.h>
#include "smemory.h"
#include "xllx.h"
#include "xl-http.h"
#include "xl-utils.h"
#include "logger.h"

#define XL_HTTP_USER_AGENT "User-Agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.36"


#define CHUNK 1024 * 1024
#define UPLOAD_FILE_MAX_SIZE 6291456

typedef struct _AsyncWatchData AsyncWatchData;

struct _XLHttp
{
	CURL *curl;
	XLHttpShare *hs;
	int http_code;
	char *response;	//body
    int resp_len;	//body_len

	struct curl_slist* header;
    struct curl_slist* recv_head;

	struct curl_httppost *form_start;
	struct curl_httppost *form_end;
};

struct _XLHttpShare
{
	CURLSH *share;
	pthread_mutex_t share_lock[4];
}

/* Those Code for async API */
struct _AsyncWatchData
{
	XLHttp *request;
	XLAsyncCallback callback;
	void *data;
};

static int initial_curl = 0;

static int xl_async_running = -1;
static pthread_t xl_async_tid;
static pthread_cond_t xl_async_cond = PTHREAD_COND_INITIALIZER;

static char *ungzip(const char *source, int len, int *total);
static void *xl_async_thread(void* data);
static void ev_io_come(EV_P_ ev_io* w,int revent);
static void  xl_http_set_default_header(XLHttp *request);
static int http_open(XLHttp *request, HttpMethod method, char *body, size_t body_len);

XLHttp *xl_http_new(const char *uri)
{
	XLHttp *http;
	CURLcode res;

	if (!uri) {
		return NULL;
	}

	if (initial_curl == 0)
		curl_global_init(CURL_GLOBAL_DEFAULT);

	http = s_malloc0(sizeof(*http));

	http->curl = curl_easy_init();
	if (!http->curl) {
		/* Seem like http->req must be non null. FIXME */
		goto failed;
	}
	if (curl_easy_setopt(http->curl, CURLOPT_URL, uri) != CURLE_OK)
		goto failed;
	if (curl_easy_setopt(http->curl, CURLOPT_FOLLOWLOCATION, 1L) != CURLE_OK)
	{
		xl_log(LOG_WARNING, "Invalid uri: %s\n", uri);
		goto failed;
	}

    curl_easy_setopt(request->http, CURLOPT_HEADERFUNCTION, write_header);
    curl_easy_setopt(request->http, CURLOPT_HEADERDATA, request);
    curl_easy_setopt(request->http, CURLOPT_WRITEFUNCTION, write_content);
    curl_easy_setopt(request->http, CURLOPT_WRITEDATA, request);
    curl_easy_setopt(request->http, CURLOPT_NOSIGNAL, 1);
    curl_easy_setopt(request->http, CURLOPT_FOLLOWLOCATION, 1);
    curl_easy_setopt(request->http, CURLOPT_CONNECTTIMEOUT, 30);
    //set normal operate timeout to 30.official value.
    //curl_easy_setopt(request->req,CURLOPT_TIMEOUT,30);
    //low speed: 5B/s
    curl_easy_setopt(request->http, CURLOPT_LOW_SPEED_LIMIT, 8*5);
    curl_easy_setopt(request->http, CURLOPT_LOW_SPEED_TIME, 30);
    curl_easy_setopt(request->http, CURLOPT_SSL_VERIFYPEER, 0);
    curl_easy_setopt(request->http, CURLOPT_DEBUGFUNCTION, curl_debug_redirect);
    request->do_request = lwqq_http_do_request;
    request->set_header = lwqq_http_set_header;
    request->get_header = lwqq_http_get_header;
    request->add_form = lwqq_http_add_form;
    request->add_file_content = lwqq_http_add_file_content;

    return http;

failed:
	if (http) {
		xl_http_free(http);
	}
	return NULL;
}

XLHttp *xl_http_create_default(const char *url, XLErrorCode *err)
{
	XLHttp *req;

	if (!url) {
		if (err)
			*err = XL_ERROR_ERROR;
		return NULL;
	}

	req = xl_http_new(url);
	if (!req) {
		//xl_log(LOG_ERROR, "Create request object for url: %s failed\n", url);
		if (err)
			*err = XL_ERROR_ERROR;
		return NULL;
	}

	xl_http_set_default_header(req);
	if (http->hs)
	{
		curl_easy_setopt(http->curl, CURLOPT_SHARE, hs->share);
	}
	//xl_log(LOG_DEBUG, "Create request object for url: %s sucessfully\n", url);
	return req;
}

void    xl_http_set_http_share(XLHttp *http, XLHttpShare *hs)
{
	http->hs = hs;
}

int xl_http_open(XLHttp *request, HttpMethod method, char *body)
{
	if (body != NULL)
		return http_open(request, method, body, strlen(body));
	else
		return http_open(request, method, NULL, 0);
}

int xl_http_upload_file(XLHttp *request, const char *field, const char *path)
{
	int len;
	char msg[6300000];
	size_t have_write_bytes;
	char buf[1024];
    char *boundary_;
	char *boundary;
	ssize_t count;
	int fd;

	len = get_file_size(path, &have_write_bytes);
	if (len != 0 || have_write_bytes > UPLOAD_FILE_MAX_SIZE)
	{
		return -1;
	}
	have_write_bytes = len = 0;

	//set header
    boundary_ = "----WebKitFormBoundaryk5nH7APtIbShxvqE";
	snprintf(buf, sizeof(buf), "multipart/form-data;boundary=%s", boundary_);
	xl_http_set_header(request, "Content-Type", buf);

	//char *filename = get_basename(path);

	s_asprintf(&boundary, "--%s", boundary_);
	len = snprintf(buf, sizeof(buf), "%s\r\n"
	"Content-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\n"
	"Content-Type: application/octet-stream\r\n\r\n", boundary, field, path);

	memcpy(msg + have_write_bytes, buf, len);
	have_write_bytes += len;

	fd = open(path, O_RDONLY);
	if (fd == -1)
		goto failed;
	while ((count = read(fd, buf, sizeof(buf))) != 0)
	{
		memcpy(msg + have_write_bytes, buf, count);
		have_write_bytes += count;
	}
	close(fd);

	len = snprintf(buf, sizeof(buf), "\r\n%s--\r\n", boundary);
	memcpy(msg + have_write_bytes, buf, len);
	have_write_bytes += len;

	s_free(boundary);
	return http_open(request, HTTP_POST, msg, have_write_bytes);
failed:
	s_free(boundary);
	return -1;
}

// return 0 for success.
static int http_open(XLHttp *request, HttpMethod method, char *body, size_t body_len)
{
    if (!request->curl)
        return -1;

    CURLcode ret;
    LwqqHttpRequest_* req_ = (LwqqHttpRequest_*) request;
    req_->retry_ = request->retry;
retry:
    ret=0;
    char **resp = &request->response;

    /* Clear off last response */
    http_clean(request);

	/* Set http method */
	if (method==HTTP_GET){
	}else if (method == HTTP_POST && body) {
		curl_easy_setopt(request->curl, CURLOPT_POST, 1);
		curl_easy_setopt(request->curl, CURLOPT_COPYPOSTFIELDS, body);
	} else {
		xl_log(LOG_WARNING, "Wrong http method\n");
		goto failed;
	}

    ret = curl_easy_perform(request->curl);
    composite_trunks(request);
    if(ret != CURLE_OK){
        xl_log(LOG_ERROR,"do_request fail curlcode:%d\n",ret);
        LwqqErrorCode ec;
        if(set_error_code(request, ret, &ec)){
            goto retry;
        }
        return ec;
    }
    //perduce timeout.
    req_->retry_ = request->retry;
    curl_easy_getinfo(request->curl, CURLINFO_RESPONSE_CODE, &request->http_code);

    // NB: *response may null 
    // jump it .that is no problem.
    if (*resp == NULL) {
        goto failed;
    }

    /* Uncompress data here if we have a Content-Encoding header */
    const char *enc_type = NULL;
    enc_type = xl_http_get_header(request, "Content-Encoding");
    if (enc_type && strstr(enc_type, "gzip")) {
        uncompress_response(request);
    }

    return 0;

failed:
    if (*resp) {
        s_free(*resp);
        *resp = NULL;
    }
    return 0;
}

void xl_http_set_header(XLHttp *request, const char *name, const char *value)
{
	if (!request->req || !name || !value)
		return ;

    //use libcurl internal cookie engine
    if(strcmp(name,"Cookie")==0) return;

    size_t name_len = strlen(name);
    size_t value_len = strlen(value);
    char* opt = s_malloc(name_len+value_len+3);

    strcpy(opt,name);
    opt[name_len] = ':';
    //need a blank space
    opt[name_len+1] = ' ';
    strcpy(opt+name_len+2,value);

    int use_old = 0;
    struct curl_slist* list = request->header;
    while(list){
        if(strncmp(list->data,name,strlen(name)) == 0){
            s_free(list->data);
            list->data = s_strdup(opt);
            use_old = 1;
            break;
        }
        list = list->next;
    }
    if(!use_old){
        request->header = curl_slist_append((struct curl_slist*)request->header,opt);
    }

    curl_easy_setopt(request->req, CURLOPT_HTTPHEADER, request->header);
    s_free(opt);
}

static void xl_http_set_default_header(XLHttp *request)
{
	xl_http_set_header(request, "User-Agent", XL_HTTP_USER_AGENT);
	xl_http_set_header(request, "Accept", "image/png,image/*;q=0.8,*/*;q=0.5");
	xl_http_set_header(request, "Accept-Language", "zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3");
	xl_http_set_header(request, "Accept-Charset", "GBK, utf-8, utf-16, *;q=0.1");
	xl_http_set_header(request, "Accept-Encoding", "gzip, deflate");
	xl_http_set_header(request, "Connection", "Keep-Alive");

}

char *xl_http_get_header(XLHttp *request, const char *name)
{
	if (!name) {
		xl_log(LOG_ERROR, "Invalid parameter\n");
		return NULL; 
	}

	char *h = NULL;
	struct curl_slist* list = request->recv_head;
	while(list!=NULL){
		if(strncmp(name, list->data, strlen(name))==0){
			h = s_strdup(list->data+strlen(name)+2);
			break;
		}
		list = list->next;
	}

	return h;
}

/*
 * return count of cookies
 * TODO
 */
int xl_http_get_cookie_names(XLHttp *request, char ***names)
{
    int ret;
    char **cookies;
    int nums;
    ret = ghttp_get_cookie_names(request->req, &cookies, &nums);
    if (ret != 0)
    {
        return 0;
    }
    *names = cookies;
    return nums;
}

//TODO
int xl_http_has_cookie(XLHttp *request, const char* key)
{
    int i, nums;
	char **cookies;
	int found = -1;
	char keyname[256];

	snprintf(keyname, sizeof(keyname), "%s=", key);
	nums = xl_http_get_cookie_names(request, &cookies);
	if (nums == 0)
		return found;
    for (i=0 ; i < nums; i++)
    {
        if (cookies[i] != NULL && strncmp(cookies[i], keyname, strlen(keyname)) == 0){
			found = 0;
			break;
        }
    }

    for (i=0 ; i < nums; i++)
    {
        if (cookies[i] != NULL){
            s_free(cookies[i]);
            cookies[i] = NULL;
        }
	}
	s_free(cookies);

	return found;
}

char *xl_http_get_cookie(XLHttp *request, const char *name)
{
    if (!name) {
        xl_log(LOG_ERROR, "Invalid parameter\n");
        return NULL; 
    }
	if (request->hs)
	{
		struct curl_slist* list;
		CURL* easy = curl_easy_init();
		curl_easy_setopt(easy, CURLOPT_SHARE, request->hs->share);
		curl_easy_getinfo(easy, CURLINFO_COOKIELIST, &list);
		curl_easy_cleanup(easy);
		char* n,*v;
		while(list!=NULL){
			v = strrchr(list->data,'\t')+1;
			n = v-2;
			while(n--,*n!='\t');
			n++;
			if(v-n-1 == strlen(name) && strncmp(name,n,v-n-1)==0){
				return s_strdup(v);
			}
			list = list->next;
		}
	}
    return NULL;
}

int xl_http_get_status(XLHttp *request)
{
	return request->http_code;
}

char* xl_http_get_body(XLHttp *request)
{
    return request->response;
}

int xl_http_get_body_len(XLHttp *request)
{
	return request->resp_len;
}

void xl_http_free(XLHttp *request)
{
	if (!request)
		return;

	if (request) {
		s_free(request->response);
		ghttp_request_destroy(request->req);
		s_free(request);
	}
}

static void uncompress_response(XLHttp* http)
{
    char *outdata;
    char **resp = &http->response;
    int total = 0;

    outdata = ungzip(*resp, req->resp_len, &total);
    if (!outdata) return;

    s_free(*resp);
    /* Update response data to uncompress data */
    *resp = outdata;
    http->resp_len = total;
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

static size_t write_header( void *ptr, size_t size, size_t nmemb, void *userdata)
{
    char* str = (char*)ptr;
    LwqqHttpRequest* request = (LwqqHttpRequest*) userdata;

    long http_code;
    curl_easy_getinfo(request->req,CURLINFO_RESPONSE_CODE,&http_code);
    //this is a redirection. ignore it.
    if(http_code == 301||http_code == 302){
        if(strncmp(str,"Location",strlen("Location"))==0){
            const char* location = str+strlen("Location: ");
            request->location = s_strdup(location);
            int len = strlen(request->location);
            //remove the last \r\n
            request->location[len-1] = 0;
            request->location[len-2] = 0;
            lwqq_verbose(3,"Location: %s\n",request->location);
        }
        return size*nmemb;
    }
    request->recv_head = curl_slist_append(request->recv_head,(char*)ptr);
    //read cookie from header;
    /*if(strncmp(str,"Set-Cookie",strlen("Set-Cookie"))==0){
        struct cookie_list * node = s_malloc0(sizeof(*node));
        sscanf(str,"Set-Cookie: %[^=]=%[^;];",node->name,node->value);
        request->cookie = slist_append(request->cookie,node);
        LwqqClient* lc = request->lc;
        if(lc&&!(req_->flags&LWQQ_HTTP_NOT_SET_COOKIE)){
            if(!lc->cookies) lc->cookies = s_malloc0(sizeof(LwqqCookies));
            lwqq_set_cookie(lc->cookies, node->name, node->value);
        }
    }*/
    return size*nmemb;
}

XLHttpShare* xl_http_share_new(void)
{
    int i;
	XLHttpShare *hs;

	hs = s_malloc0(sizeof(XLHttpShare));
	hs->share = curl_share_init();
	curl_share_setopt(hs->share, CURLSHOPT_SHARE, CURL_LOCK_DATA_DNS);
	curl_share_setopt(hs->share, CURLSHOPT_SHARE, CURL_LOCK_DATA_CONNECT);
	curl_share_setopt(hs->share, CURLSHOPT_SHARE, CURL_LOCK_DATA_SSL_SESSION);
	curl_share_setopt(hs->share, CURLSHOPT_SHARE, CURL_LOCK_DATA_COOKIE);
	curl_share_setopt(hs->share, CURLSHOPT_LOCKFUNC, http_share_lock);
	curl_share_setopt(hs->share, CURLSHOPT_UNLOCKFUNC, http_share_unlock);
	curl_share_setopt(hs->share, CURLSHOPT_USERDATA, hs);
    for(i=0;i<4;i++)
        pthread_mutex_init(&hs->share_lock[i], NULL);
	return hs;
}

void xl_http_share_free(XLHttpShare *hs)
{
	if(hs){
		int i;
		for(i=0;i<4;i++)
			pthread_mutex_destroy(&hs->share_lock[i]);
		curl_share_cleanup(hs->share);
		s_free(hs);
	}
}

static void http_share_lock(CURL* handle, curl_lock_data data, curl_lock_access access, void* user_data)
{
	//this is shared access.
	//no need to lock it.
	if(access == CURL_LOCK_ACCESS_SHARED)
		return;
	XLHttpShare *hs = user_data;
	int idx;
	switch(data){
		case CURL_LOCK_DATA_DNS:
			idx=0;
			break;
		case CURL_LOCK_DATA_CONNECT:
			idx=1;
			break;
		case CURL_LOCK_DATA_SSL_SESSION:
			idx=2;
			break;
		case CURL_LOCK_DATA_COOKIE:
			idx=3;
			break;
		default:
			return;
	}
	pthread_mutex_lock(&hs->share_lock[idx]);
}

static void http_share_unlock(CURL* handle, curl_lock_data data, void* user_data)
{
	int idx;
	XLHttpShare *hs = user_data;
	switch(data){
		case CURL_LOCK_DATA_DNS:
			idx=0;
			break;
		case CURL_LOCK_DATA_CONNECT:
			idx=1;
			break;
		case CURL_LOCK_DATA_SSL_SESSION:
			idx=2;
			break;
		case CURL_LOCK_DATA_COOKIE:
			idx=3;
			break;
		default:
			return;
	}
	pthread_mutex_unlock(&hs->share_lock[idx]);
}
