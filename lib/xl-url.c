/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-url.c: This file is part of ____
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

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "base64.h"

/* Converts a hex character to its integer value */
static char from_hex(char ch)
{
  return isdigit(ch) ? ch - '0' : tolower(ch) - 'A' + 10;
}

/* Converts an integer value to its hex character*/
static char to_hex(char code)
{
  static char hex[] = "0123456789ABCDEF";
  return hex[code & 15];
}

/**
 * xl_url_quote:
 * @str: The text of the raw url 
 *
 * Creates a new quoted url with the given str. You should
 * free it.
 *
 * Return value: the url-encoded version of str
 **/
char* xl_url_quote(char *str)
{
    if (!str)
        return NULL;
    
    char *pstr = str, *buf = malloc(strlen(str) * 3 + 1), *pbuf = buf;
    while (*pstr) {
        if (isalnum(*pstr) || *pstr == '-' || *pstr == '_' || *pstr == '.' || *pstr == '~') 
            *pbuf++ = *pstr;
        else 
            *pbuf++ = '%', *pbuf++ = to_hex(*pstr >> 4), *pbuf++ = to_hex(*pstr & 15);
        pstr++;
    }
    *pbuf = '\0';
    return buf;
}

/** 
 * NB: be sure to free() the returned string after use
 * 
 * @param str 
 * 
 * @return A url-decoded version of str
 */
char* xl_url_unquote(char *str)
{
    if (!str) {
        return NULL;
    }
    char *pstr = str, *buf = malloc(strlen(str) + 1), *pbuf = buf;
    while (*pstr) {
        if (*pstr == '%') {
            if (pstr[1] && pstr[2]) {
                *pbuf++ = from_hex(pstr[1]) << 4 | from_hex(pstr[2]);
                pstr += 2;
            }
        } else if (*pstr == '+') { 
            *pbuf++ = ' ';
        } else {
            *pbuf++ = *pstr;
        }
        pstr++;
    }
    *pbuf = '\0';
    return buf;
}

char* xl_url_thunder_encode(const char* uri)
{
    char p[256]={0}, *b64, *url;
    size_t len;

    snprintf(p, sizeof(p), "AA%sZZ", uri);
    len = base64_encode(p, strlen(p), &b64);
	if (len < 0)
		return NULL;

    url = malloc(strlen(b64) + 10);
    sprintf(url, "thunder://%s", b64);

    free(b64);
    return url;
}

char* xl_url_thunder_decode(const char* euri)
{
    char u[256] = {0};
    char *p, *url;

    url = NULL;
    p = (char*) euri;

    if (strncmp(euri, "thunder://", 10) == 0) {
        p += 10;
        base64_decode(p, &u); 

        if ((strncmp(u, "AA", 2) == 0) && strncmp(u + strlen(u) - 2 , "ZZ", 2) == 0) {
            u[strlen(u) -2] = '\0';
            url = strdup(u+2);
        }
    }
    return url;
}

char* xl_url_qqdl_encode(const char* uri)
{
	char *b64, *url;
    size_t len;

    len = base64_encode(uri, strlen(uri), &b64);
	if (len < 0)
		return NULL;

    url = malloc(strlen(b64) + 7);
    sprintf(url, "qqdl://%s", b64);
    free(b64);
    return url;
}

char* xl_url_qqdl_decode(const char* euri)
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

char* xl_url_flashget_encode(const char* uri)
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

char* xl_url_flashget_decode(const char* euri)
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
char* xl_url_decode(const char* euri)
{
    char *url;

    if (strncmp(euri, "thunder://", 10) == 0) {
		url = xl_url_thunder_decode(euri);
	}else if (strncmp(euri, "qqdl://", 7) == 0) {
		url = xl_url_qqdl_decode(euri);
	}else if (strncmp(euri, "Flashget://", 11) == 0) {
		url = xl_url_flashget_decode(euri);
    }else{
    	url = strdup(euri);
    }
    return url;
}

#if 0
int main(int argc, char *argv[])
{
    char *buf = url_encode("http://www.-go8ogle. com");
    if (buf) {
        lwqq_log(LOG_NOTICE, "Encode data: %s\n", buf);
    } else 
    puts(buf);
    return 0;
}
#endif
