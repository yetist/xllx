/* vi: set sw=4 ts=4 wrap ai: */
/*
 * converturl.c: This file is part of ____
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

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "base64.h"

char* thunder_url_encode(const char* uri)
{
    char p[256]={0}, *b64, *url;
    size_t l, len;

    snprintf(p, sizeof(p), "AA%sZZ", uri);
    len = base64_encode(p, strlen(p), &b64);
	if (len < 0)
		return NULL;

    url = malloc(strlen(b64) + 10);
    sprintf(url, "thunder://%s", b64);

    free(b64);
    return url;
}

char* thunder_url_decode(const char* euri)
{
    char u[256] = {0};
    char *p, *url;

    url = NULL;
    p = (char*) euri;

    if (strncmp(euri, "thunder://", 10) == 0) {
        size_t offset;
        p += 10;
        base64_decode(p, &u); 

        if ((strncmp(u, "AA", 2) == 0) && strncmp(u + strlen(u) - 2 , "ZZ", 2) == 0) {
            u[strlen(u) -2] = '\0';
            url = strdup(u+2);
        }
    }
    return url;
}

char* qq_url_encode(const char* uri)
{
	char *b64, *url;
    size_t l, len;

    len = base64_encode(uri, strlen(uri), &b64);
	if (len < 0)
		return NULL;

    url = malloc(strlen(b64) + 7);
    sprintf(url, "qqdl://%s", b64);
    free(b64);
    return url;
}

char* qq_url_decode(const char* euri)
{
    char u[256] = {0};
    char *p, *url;

    url = NULL;
    p = (char*) euri;

    if (strncmp(euri, "qqdl://", 7) == 0) {
        p += 7;
        base64_decode(p, &u);
		url = u;
    }
    return url;
}

char* flash_url_encode(const char* uri)
{
	char u[256] = {0};
	char *b64, *url = NULL;
	size_t len;

    //set up data
    snprintf(u, sizeof(u), "[FLASHGET]%s[FLASHGET]", uri);

    len = base64_encode(u, strlen(u), &b64);
	if (len < 0)
		return NULL;

    url = malloc(strlen(b64) + 11);
    sprintf(url, "Flashget://%s", b64);

    free(b64);
    return url;
}

char* flash_url_decode(const char* euri)
{
    char u[256] = {0};
    char *p, *url;

    url = NULL;
    p = (char*) euri;

    if (strncmp(euri, "Flashget://", 11) == 0) {
        p += 11;
        base64_decode(p, &u);
        if ((strncmp(u, "[FLASHGET]", 10) == 0) && strncmp(u + strlen(u) - 10 , "[FLASHGET]", 10) == 0) {
            u[strlen(u) - 10] = '\0';
            url = strdup(u+10);
        }
    }
    return url;
}

/*
 * you should free return value.
 */
char* url_decode(const char* euri)
{
    char *url;

    if (strncmp(euri, "thunder://", 10) == 0) {
		url = thunder_url_decode(euri);
	}else if (strncmp(euri, "qqdl://", 7) == 0) {
		url = qq_url_decode(euri);
	}else if (strncmp(euri, "Flashget://", 11) == 0) {
		url = flash_url_decode(euri);
    }else{
    	url = strdup(euri);
    }
    return url;
}

int main(int argc, char** argv)
{
    char *p;
	char *uri = "http://www.中国.com";
	char *euri;
    euri = thunder_url_encode(uri);
    p = thunder_url_decode(euri);
	if (strcmp(p, uri) == 0) {
		printf("[OK], uri=%s, euri=%s\n", uri, euri);
	}

	euri = qq_url_encode(uri);
	p = qq_url_decode(euri);
	if (strcmp(p, uri) == 0) {
		printf("[OK], uri=%s, euri=%s\n", uri, euri);
	}
}
