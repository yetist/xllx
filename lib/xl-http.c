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

typedef enum {
    XL_FORM_FILE,// use add_file_content instead
    XL_FORM_CONTENT
} XL_FORM;

static int initial_curl = 0;

static char *ungzip(const char *source, int len, int *total);
static void  xl_http_set_default_header(XLHttp *request);
static int http_open(XLHttp *request, HttpMethod method, char *body, size_t body_len);
static size_t write_header(void *ptr, size_t size, size_t nmemb, void *user_data);
static size_t write_content(const char* ptr, size_t size, size_t nmemb, void* user_data);
static void http_share_lock(CURL* handle, curl_lock_data data, curl_lock_access access, void* user_data);
static void http_share_unlock(CURL* handle, curl_lock_data data, void* user_data);
static int curl_debug_redirect(CURL* h,curl_infotype t,char* msg,size_t len,void* data);
static void uncompress_response(XLHttp* http);
static void composite_trunks(XLHttp* req);

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
		//xl_log(LOG_ERROR, "Create request object for url: %s failed\n", url);
		if (err)
			*err = XL_ERROR_ERROR;
		return NULL;
	}

	xl_http_set_default_header(http);
	/*
	if (http->hs)
	{
		xl_log(LOG_DEBUG, "create share\n");
		curl_easy_setopt(http->curl, CURLOPT_SHARE, http->hs->share);
	}
	xl_log(LOG_DEBUG, "Create request object for url: %s sucessfully\n", url);
	*/
	return http;
}

void    xl_http_set_http_share(XLHttp *http, XLHttpShare *hs)
{
	if (!http->hs)
	{
		http->hs = hs;
		xl_log(LOG_DEBUG, "create share\n");
		curl_easy_setopt(http->curl, CURLOPT_SHARE, hs->share);
	}
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
	xl_log(LOG_DEBUG, "debug, size=%d\n", mem->size);

	if (mem->size == 0)
	{
		req->response = NULL;
		req->resp_len = 0;
	}else{
		xl_log(LOG_DEBUG, "debug, size=%d, body=%s\n", mem->size, mem->memory);
		req->response = s_malloc0(mem->size);
		req->resp_len = mem->size;
        memcpy(req->response, mem->memory, mem->size);

	}

#if 0
    size_t size = 0;
    struct trunk_entry* trunk;
    SIMPLEQ_FOREACH(trunk,&req_->trunks,entries){
        size += trunk->size;
    }
    req->response = s_malloc0(size+10);
    req->resp_len = 0;
    while((trunk = SIMPLEQ_FIRST(&req_->trunks))){
        SIMPLEQ_REMOVE_HEAD(&req_->trunks,entries);
        memcpy(req->response+req->resp_len,trunk->trunk,trunk->size);
        req->resp_len+=trunk->size;
        s_free(trunk->trunk);
        s_free(trunk);
    }
#endif
}

// return 0 for success.
static int http_open(XLHttp *request, HttpMethod method, char *body, size_t body_len)
{
    if (!request->curl)
        return -1;

    CURLcode ret;
    //XLHttp * req_ = (XLHttp*) request;
    //req_->retry_ = request->retry;
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
        //LwqqErrorCode ec;
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
			goto retry;
		}
        return -1;
    }
    //perduce timeout.
    //req->retry_ = request->retry;
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

    curl_easy_setopt(request->curl, CURLOPT_HTTPHEADER, request->header);
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
	if (names == NULL)
		return -1;

	*names = NULL;

	int l_num_cookies = 0;
	char **l_cookies;
	if (request->hs)
	{
		struct curl_slist* list;
		struct curl_slist* p;
		CURL* easy = curl_easy_init();
		curl_easy_setopt(easy, CURLOPT_SHARE, request->hs->share);
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
	//*a_num_cookies = l_num_cookies;
	return l_num_cookies;
ec:
	if (l_cookies)
	{
		int i;
		for (i=0; i < l_num_cookies; i++)
		{
			if (l_cookies[i])
			{
				free(l_cookies[i]);
				l_cookies[i] = NULL;
			}
		}
		free(l_cookies);
		*names = NULL;
	}
	//*a_num_cookies = 0;
	return -1;
}
#if 0
#endif

//TODO
int xl_http_has_cookie(XLHttp *request, const char* key)
{
    int i, nums;
	char **cookies;
	int found = -1;
	char keyname[256];

#if 0
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
			if(v-n-1 == strlen(key) && strncmp(key,n,v-n-1)==0){
				return s_strdup(v);
			}
			list = list->next;
		}
	}
#endif

	snprintf(keyname, sizeof(keyname), "%s=", key);
			xl_log(LOG_DEBUG, "debug\n");
	nums = xl_http_get_cookie_names(request, &cookies);
			xl_log(LOG_DEBUG, "debug\n");
	if (nums == 0)
		return found;
			xl_log(LOG_DEBUG, "debug\n");
    for (i=0 ; i < nums; i++)
    {
		xl_log(LOG_DEBUG, "debug, cookies[i]=%s, key=%s\n", cookies[i], key);
        if (cookies[i] != NULL && strncmp(cookies[i], key, strlen(key)) == 0)
		{
			xl_log(LOG_DEBUG, "debug\n");
			found = 0;
			break;
        }
    }

			xl_log(LOG_DEBUG, "debug\n");
    for (i=0 ; i < nums; i++)
    {
        if (cookies[i] != NULL){
            s_free(cookies[i]);
            cookies[i] = NULL;
        }
	}
	s_free(cookies);

	xl_log(LOG_DEBUG, "debug, found=%d\n", found);
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
		while (list != NULL)
		{
			v = strrchr(list->data,'\t')+1;
			n = v-2;
			while(n--, *n!='\t');
			n++;
			if(v-n-1 == strlen(name) && strncmp(name,n,v-n-1)==0)
			{
				//xl_log(LOG_DEBUG, "debug, name=%s, v=%s\n", name, v);
				return s_strdup(v);
			}
			list = list->next;
		}
	}
    return NULL;
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

static void uncompress_response(XLHttp* http)
{
    char *outdata;
    char **resp = &http->response;
    int total = 0;

    outdata = ungzip(*resp, http->resp_len, &total);
	xl_log(LOG_DEBUG, "body_len=%d, body=%s\n", strlen(outdata), outdata);
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

static size_t write_content(const char* contents, size_t size, size_t nmemb, void* user_data)
{
    long http_code;

    XLHttp* req = (XLHttp*) user_data;

	size_t realsize = size * nmemb;

	//struct MemoryStruct *mem = (struct MemoryStruct *)userp;
	struct MemoryStruct *mem = &req->trunk;

    curl_easy_getinfo(req->curl, CURLINFO_RESPONSE_CODE, &http_code);
	xl_log(LOG_DEBUG, "debug\n");
    //this is a redirection. ignore it.
    if(http_code == 301||http_code == 302){
        return realsize;
    }

	mem->memory = realloc(mem->memory, mem->size + realsize + 1);
	if(mem->memory == NULL) {
		/* out of memory! */ 
		printf("not enough memory (realloc returned NULL)\n");
		return 0;
	}

	memcpy(&(mem->memory[mem->size]), contents, realsize);
	mem->size += realsize;
	mem->memory[mem->size] = 0;

	return realsize;
	//
#if 0

    long http_code;
    size_t sz_ = size*nmemb;
    curl_easy_getinfo(req->curl, CURLINFO_RESPONSE_CODE, &http_code);
	xl_log(LOG_DEBUG, "debug\n");
    //this is a redirection. ignore it.
    if(http_code == 301||http_code == 302){
        return sz_;
    }
	xl_log(LOG_DEBUG, "debug\n");
    char* position = NULL;
    double length = 0.0;
	xl_log(LOG_DEBUG, "debug\n");
    curl_easy_getinfo(req->curl, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &length);
	xl_log(LOG_DEBUG, "debug\n");
    if(req->response==NULL)
	{
	xl_log(LOG_DEBUG, "debug, length=%g\n", length);
        if(length!=-1.0&&length!=0.0){
	xl_log(LOG_DEBUG, "debug\n");
            req->response = s_malloc0((unsigned long)(length)+10);
            position = req->response;
        }
        req->resp_len = 0;
    }
	xl_log(LOG_DEBUG, "debug\n");
    if(req->response){
	xl_log(LOG_DEBUG, "debug\n");
        position = req->response + req->resp_len;
        if(req->resp_len+sz_>(unsigned long)length){
            req->bits |= HTTP_UNEXPECTED_RECV;
            //assert(0);
            xl_log(LOG_WARNING, "[http unexpected]\n");
            return 0;
        }
    } /*
		 else{
        struct trunk_entry* trunk = s_malloc0(sizeof(*trunk));
        trunk->size = sz_;
        trunk->trunk = s_malloc0(sz_);
        position = trunk->trunk;
        SIMPLEQ_INSERT_TAIL(&req_->trunks,trunk,entries);
    }
*/
	xl_log(LOG_DEBUG, "debug, ptr=%s, strlen(ptr)=%d, length=%d\n", ptr, strlen(ptr), length);
    memcpy(position,ptr,sz_);
	xl_log(LOG_DEBUG, "debug\n");
    req->resp_len+=sz_;
	xl_log(LOG_DEBUG, "debug\n");
    return sz_;
#endif
}

static int curl_debug_redirect(CURL* h,curl_infotype t,char* msg,size_t len,void* data)
{
    static char buffer[8192*10];
    size_t sz = sizeof(buffer)-1;
    sz = sz>len?sz:len;
    strncpy(buffer,msg,sz);
    buffer[sz] = 0;
    xl_log(LOG_DEBUG, "%s", buffer);
    return 0;
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

static void xl_http_add_form(XLHttp* request, XL_FORM form, const char* name, const char* value)
{
    struct curl_httppost** post = (struct curl_httppost**)&request->form_start;
    struct curl_httppost** last = (struct curl_httppost**)&request->form_end;
    switch(form){
        case XL_FORM_FILE:
            curl_formadd(post, last, CURLFORM_COPYNAME, name, CURLFORM_FILE, value, CURLFORM_END);
            break;
        case XL_FORM_CONTENT:
            curl_formadd(post, last, CURLFORM_COPYNAME, name, CURLFORM_COPYCONTENTS, value, CURLFORM_END);
            break;
    }
    curl_easy_setopt(request->curl, CURLOPT_HTTPPOST, request->form_start);
}

static void xl_http_add_file_content(XLHttp* request, const char* name,
        const char* filename, const void* data, size_t size, const char* extension)
{
    struct curl_httppost** post = (struct curl_httppost**)&request->form_start;
    struct curl_httppost** last = (struct curl_httppost**)&request->form_end;
    char *type = NULL;
    if(extension == NULL){
        extension = strrchr(filename,'.');
        if(extension !=NULL) extension++;
    }
    if(extension == NULL) type = NULL;
    else{
        if(strcmp(extension,"jpg")==0||strcmp(extension,"jpeg")==0)
            type = "image/jpeg";
        else if(strcmp(extension,"png")==0)
            type = "image/png";
        else if(strcmp(extension,"gif")==0)
            type = "image/gif";
        else if(strcmp(extension,"bmp")==0)
            type = "image/bmp";
        else type = NULL;
    }
    if(type==NULL){
        curl_formadd(post,last,
                CURLFORM_COPYNAME,name,
                CURLFORM_BUFFER,filename,
                CURLFORM_BUFFERPTR,data,
                CURLFORM_BUFFERLENGTH,size,
                CURLFORM_END);
    }else{
        curl_formadd(post,last,
                CURLFORM_COPYNAME,name,
                CURLFORM_BUFFER,filename,
                CURLFORM_BUFFERPTR,data,
                CURLFORM_BUFFERLENGTH,size,
                CURLFORM_CONTENTTYPE,type,
                CURLFORM_END);
    }
    curl_easy_setopt(request->curl, CURLOPT_HTTPPOST, request->form_start);
}
