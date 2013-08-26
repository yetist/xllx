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
#include "smemory.h"
#include "xllx.h"
#include "xl-http.h"
#include "xl-utils.h"
#include "logger.h"

#define XL_HTTP_USER_AGENT "User-Agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.36"


#define CHUNK 1024 * 1024

typedef enum{
    HTTP_UNEXPECTED_RECV = 1<<1,
    HTTP_FORCE_CANCEL = 1<<2
}HttpBits;

struct MemoryStruct {
	char *memory;
	size_t size;
};

struct _XLHttp
{
	CURL *curl;
	XLHttpShare *hs;
	int http_code;
    char *location;
	char *response;	//body
    int resp_len;	//body_len
	HttpBits bits;
	struct MemoryStruct trunk;
	int retry;
    int flags;              /**store http option settings**/

	struct curl_slist* header;
    struct curl_slist* recv_head;

	struct curl_httppost *form_start;
	struct curl_httppost *form_end;
};

struct _XLHttpShare
{
	CURLSH *share;
	pthread_mutex_t share_lock[4];
};

static int initial_curl = 0;

static void http_clean(XLHttp* req);
static void xl_http_set_default_header(XLHttp *request);
static int http_open(XLHttp *request, HttpMethod method, char *body, size_t body_len);
static size_t write_header(void *ptr, size_t size, size_t nmemb, void *user_data);
static size_t write_content(const char* ptr, size_t size, size_t nmemb, void* user_data);
static void composite_trunks(XLHttp* req);
static void uncompress_response(XLHttp* http);
static char *ungzip(const char *source, int len, int *total);
static int curl_debug_redirect(CURL* h,curl_infotype t,char* msg,size_t len,void* data);

static void http_share_lock(CURL* handle, curl_lock_data data, curl_lock_access access, void* user_data);
static void http_share_unlock(CURL* handle, curl_lock_data data, void* user_data);

/* create and setup options */

void  xl_http_init(void)
{
	if (initial_curl == 0)
	{
		curl_global_init(CURL_GLOBAL_DEFAULT);
		initial_curl = 1;
	}
}

void xl_http_cleanup(void)
{
	if (initial_curl == 1)
	{
        curl_global_cleanup();
		initial_curl = 0;
	}
}

XLHttp *xl_http_new(const char *uri)
{
	XLHttp *http;

	if (!uri) {
		return NULL;
	}

	xl_http_init();

	http = s_malloc0(sizeof(*http));
	if (http == NULL)
		return NULL;

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

    curl_easy_setopt(http->curl, CURLOPT_HEADERFUNCTION, write_header);
    curl_easy_setopt(http->curl, CURLOPT_HEADERDATA, http);
    curl_easy_setopt(http->curl, CURLOPT_WRITEFUNCTION, write_content);
    curl_easy_setopt(http->curl, CURLOPT_WRITEDATA, http);
    curl_easy_setopt(http->curl, CURLOPT_NOSIGNAL, 1);
    curl_easy_setopt(http->curl, CURLOPT_FOLLOWLOCATION, 1);
    curl_easy_setopt(http->curl, CURLOPT_CONNECTTIMEOUT, 30);
    //set normal operate timeout to 30.official value.
    //curl_easy_setopt(http->curl,CURLOPT_TIMEOUT,30);
    //low speed: 5B/s
    curl_easy_setopt(http->curl, CURLOPT_LOW_SPEED_LIMIT, 8*5);
    curl_easy_setopt(http->curl, CURLOPT_LOW_SPEED_TIME, 30);
    curl_easy_setopt(http->curl, CURLOPT_SSL_VERIFYPEER, 0);
    curl_easy_setopt(http->curl, CURLOPT_DEBUGFUNCTION, curl_debug_redirect);

    return http;

failed:
	if (http) {
		xl_http_free(http);
	}
	return NULL;
}

XLHttp *xl_http_create_default(const char *url, XLErrorCode *err)
{
	XLHttp *http;

	if (!url) {
		if (err)
			*err = XL_ERROR_ERROR;
		return NULL;
	}

	http = xl_http_new(url);
	if (!http) {
		if (err)
			*err = XL_ERROR_ERROR;
		return NULL;
	}

	xl_http_set_default_header(http);
	return http;
}

void    xl_http_set_http_share(XLHttp *http, XLHttpShare *hs)
{
	if (!http->hs)
	{
		http->hs = hs;
		curl_easy_setopt(http->curl, CURLOPT_SHARE, hs->share);
	}
}

void xl_http_set_header(XLHttp *request, const char *name, const char *value)
{
	if (!request->curl || !name || !value)
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
    strcpy(opt+name_len+2, value);

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

    curl_easy_setopt(request->curl, CURLOPT_HTTPHEADER, request->header);
    s_free(opt);
}

void xl_http_set_cookie(XLHttp *request, const char *name, const char* value)
{
	char buf[1024];
	if (!name) {
		xl_log(LOG_ERROR, "Invalid parameter\n");
		return ; 
	}

	if(!value)
		value = "";

	snprintf(buf, sizeof(buf), "%s=%s", name, value);

	curl_easy_setopt(request->curl, CURLOPT_COOKIE, buf);
}

void xl_http_add_form(XLHttp* request, FormType type, const char* name, const char* value)
{
    struct curl_httppost** post = (struct curl_httppost**)&request->form_start;
    struct curl_httppost** last = (struct curl_httppost**)&request->form_end;
    switch(type){
        case FORM_FILE:
            curl_formadd(post, last, CURLFORM_COPYNAME, name, CURLFORM_FILE, value, CURLFORM_END);
            break;
        case FORM_CONTENT:
            curl_formadd(post, last, CURLFORM_COPYNAME, name, CURLFORM_COPYCONTENTS, value, CURLFORM_END);
            break;
    }
    curl_easy_setopt(request->curl, CURLOPT_HTTPPOST, request->form_start);
}

void  xl_http_set_option(XLHttp *http, HttpOption opt, ...)
{
    if (!http)
		return;
    va_list args;
    va_start(args, opt);
    long val=0;
    switch(opt){
        case HTTP_TIMEOUT:
            curl_easy_setopt(http->curl, CURLOPT_LOW_SPEED_TIME, va_arg(args, unsigned long));
            break;
        case HTTP_ALL_TIMEOUT:
            curl_easy_setopt(http->curl, CURLOPT_TIMEOUT, va_arg(args, unsigned long));
            break;
        case HTTP_NOT_FOLLOW:
            curl_easy_setopt(http->curl, CURLOPT_FOLLOWLOCATION, !va_arg(args, long));
            break;
        case HTTP_SAVE_FILE:
            curl_easy_setopt(http->curl, CURLOPT_WRITEFUNCTION, NULL);
            curl_easy_setopt(http->curl, CURLOPT_WRITEDATA, va_arg(args, FILE*));
            break;
        case HTTP_RESET_URL:
            curl_easy_setopt(http->curl, CURLOPT_URL, va_arg(args, const char*));
            break;
        case HTTP_VERBOSE:
            curl_easy_setopt(http->curl, CURLOPT_VERBOSE, va_arg(args, long));
            break;
        case HTTP_MAXREDIRS:
            curl_easy_setopt(http->curl, CURLOPT_MAXREDIRS, va_arg(args, long));
            break;
        default:
            val = va_arg(args, long);
            val ? (http->flags &= opt) : (http->flags |= ~opt);
            break;
    }
    va_end(args);
}

/* connect to server, and request */

int xl_http_open(XLHttp *request, HttpMethod method, char *body)
{
	if (body != NULL)
	{
		return http_open(request, method, body, strlen(body));
	}
	else
	{
		return http_open(request, method, NULL, 0);
	}
}

int xl_http_upload_file(XLHttp *request, const char *field, const char *path)
{
	xl_http_add_form(request, FORM_FILE, field, path);
	return http_open(request, HTTP_GET, NULL, 0);
}

/* server response, get data */

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

int xl_http_get_status(XLHttp *request)
{
	return request->http_code;
}

const char* xl_http_get_body(XLHttp *request)
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

	if (request)
	{
		composite_trunks(request);
		s_free(request->response);
		s_free(request->location);
        curl_slist_free_all(request->header);
        curl_slist_free_all(request->recv_head);
        curl_formfree(request->form_start);
        if(request->curl)
		{
            curl_easy_cleanup(request->curl);
        }
		s_free(request);
	}
}

static void http_clean(XLHttp* req)
{
    composite_trunks(req);
    s_free(req->response);
    req->resp_len = 0;
    req->http_code = 0;
    curl_slist_free_all(req->recv_head);
    req->recv_head = NULL;
    req->bits = 0;
}

static void composite_trunks(XLHttp* req)
{
	struct MemoryStruct *mem = &req->trunk;

	if (mem->size == 0)
	{
		req->response = NULL;
		req->resp_len = 0;
	}else{
		if (req->response)
			s_free(req->response);
		req->response = s_malloc0(mem->size);
		req->resp_len = mem->size;
		memcpy(req->response, mem->memory, mem->size);
	}
}

// return 0 for success.
static int http_open(XLHttp *request, HttpMethod method, char *body, size_t body_len)
{
    if (!request->curl)
        return -1;

    CURLcode ret;
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
		if(ret == CURLE_ABORTED_BY_CALLBACK && request->bits & HTTP_FORCE_CANCEL){
			request->retry = 0;
		}
		if(ret == CURLE_TOO_MANY_REDIRECTS){
			request->retry = 0;
		}
		if(ret == CURLE_COULDNT_RESOLVE_HOST)
			request->retry = 0;
		request->retry--;
		if(request->retry >= 0){
			xl_log(LOG_DEBUG, "retry to open url.................\n");
			goto retry;
		}
        return -1;
    }
    //perduce timeout.
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

static void xl_http_set_default_header(XLHttp *request)
{
	xl_http_set_header(request, "User-Agent", XL_HTTP_USER_AGENT);
	xl_http_set_header(request, "Accept", "image/png,image/*;q=0.8,*/*;q=0.5");
	xl_http_set_header(request, "Accept-Language", "zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3");
	xl_http_set_header(request, "Accept-Charset", "GBK, utf-8, utf-16, *;q=0.1");
	xl_http_set_header(request, "Accept-Encoding", "gzip, deflate");
	xl_http_set_header(request, "Connection", "Keep-Alive");
}

static void uncompress_response(XLHttp* http)
{
    char *outdata;
    char **resp = &http->response;
    int total = 0;

    outdata = ungzip(*resp, http->resp_len, &total);
    if (!outdata) return;

    s_free(*resp);
    /* Update response data to uncompress data */
    *resp = outdata;
    http->resp_len = total;
	/* fixed the body string */
	outdata[total] = '\0';
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
		dest = s_realloc(dest, totalsize +1);
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

static size_t write_header(void *ptr, size_t size, size_t nmemb, void *user_data)
{
    char* str = (char*)ptr;
    XLHttp* request = (XLHttp*) user_data;

    long http_code;
    curl_easy_getinfo(request->curl, CURLINFO_RESPONSE_CODE, &http_code);
    //this is a redirection. ignore it.
    if(http_code == 301||http_code == 302)
	{
        if(strncmp(str, "Location", strlen("Location"))==0 )
		{
            const char* location = str+strlen("Location: ");
            request->location = s_strdup(location);
            int len = strlen(request->location);
            //remove the last \r\n
            request->location[len-1] = '\0';
            request->location[len-2] = '\0';
            xl_log(LOG_DEBUG, "Location: %s\n", request->location);
        }
        return size*nmemb;
    }
    request->recv_head = curl_slist_append(request->recv_head, (char*)ptr);
    return size*nmemb;
}

static size_t write_content(const char* contents, size_t size, size_t nmemb, void* user_data)
{
    long http_code;

    XLHttp* req = (XLHttp*) user_data;

	size_t realsize = size * nmemb;

	struct MemoryStruct *mem = &req->trunk;

    curl_easy_getinfo(req->curl, CURLINFO_RESPONSE_CODE, &http_code);
    //this is a redirection. ignore it.
    if(http_code == 301||http_code == 302){
        return realsize;
    }

	mem->memory = s_realloc(mem->memory, mem->size + realsize + 1);
	if(mem->memory == NULL) {
		/* out of memory! */ 
		printf("not enough memory (realloc returned NULL)\n");
		return 0;
	}

	memcpy(&(mem->memory[mem->size]), contents, realsize);
	mem->size += realsize;
	mem->memory[mem->size] = 0;

	return realsize;
}

static int curl_debug_redirect(CURL* h, curl_infotype t, char* msg, size_t len, void* data)
{
    static char buffer[8192*10];
    size_t sz = sizeof(buffer) - 1;

    sz = sz > len ? sz : len;
    strncpy(buffer, msg, sz);
    buffer[sz] = '\0';
    xl_log(LOG_DEBUG, "%s", buffer);
    return 0;
}

/* XLHttpShare Object */

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

/*
 * return count of cookies
 */
int xl_http_share_get_cookie_names(XLHttpShare *hs, char ***names)
{
	if (names == NULL)
		return -1;

	*names = NULL;

	int l_num_cookies = 0;
	char **l_cookies;
	{
		struct curl_slist* list;
		struct curl_slist* p;
		CURL* easy = curl_easy_init();
		curl_easy_setopt(easy, CURLOPT_SHARE, hs->share);
		curl_easy_getinfo(easy, CURLINFO_COOKIELIST, &list);
		curl_easy_cleanup(easy);

		p = list;
		while (p != NULL)
		{
			l_num_cookies++;
			p = p->next;
		}
		if (l_num_cookies == 0)
			return 0;
		l_cookies = s_malloc0(sizeof(char *) * l_num_cookies);
		if (l_cookies == NULL)
			return -1;

		char* n,*v;
		int j=0;
		p = list;
		while (p != NULL)
		{
			v = strrchr(p->data,'\t')+1;
			n = v-2;
			while(n--, *n!='\t');
			n++;
			l_cookies[j] = strndup(n, v-n-1);
			if (l_cookies[j] == NULL)
				goto ec;
			p = p->next;
			j++;
		}
	}
	*names = l_cookies;
	return l_num_cookies;
ec:
	if (l_cookies)
	{
		int i;
		for (i=0; i < l_num_cookies; i++)
		{
			if (l_cookies[i])
			{
				s_free(l_cookies[i]);
				l_cookies[i] = NULL;
			}
		}
		s_free(l_cookies);
		*names = NULL;
	}
	return -1;
}

int xl_http_share_has_cookie(XLHttpShare *hs, const char* key)
{
    int i, nums;
	char **cookies;
	int found = -1;

	nums = xl_http_share_get_cookie_names(hs, &cookies);
	if (nums == 0)
		return found;
    for (i=0 ; i < nums; i++)
    {
        if (cookies[i] != NULL && strncmp(cookies[i], key, strlen(key)) == 0)
		{
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

char *xl_http_share_get_cookie(XLHttpShare *hs, const char *name)
{
	struct curl_slist* list;
	CURL* easy = curl_easy_init();
	curl_easy_setopt(easy, CURLOPT_SHARE, hs->share);
	curl_easy_getinfo(easy, CURLINFO_COOKIELIST, &list);
	curl_easy_cleanup(easy);
	char* n,*v;
	while (list != NULL)
	{
		v = strrchr(list->data,'\t')+1;
		n = v-2;
		while(n--, *n!='\t');
		n++;
		if(v-n-1 == strlen(name) && strncmp(name,n,v-n-1)==0)
		{
			return s_strdup(v);
		}
		list = list->next;
	}
	return NULL;
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
