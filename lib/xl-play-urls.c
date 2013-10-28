/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-play_urls.c: This file is part of ____
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
#include <malloc.h>
#include <string.h>
#include <sys/types.h>

#include "xl-play-urls.h"
#include "smemory.h"
#include "list_head.h"

struct _XLPlayUrl
{
	char *file_name;
	char *play_url;
};

struct _XLPlayUrls
{
	XLPlayUrl *play_url;
	list_head_t list;
};

XLPlayUrl* xl_play_url_new(const char *file_name, const char *src_url)
{
	if (!file_name|| !src_url )
	{
		return NULL;
	}
	XLPlayUrl *play_url = s_malloc0(sizeof(XLPlayUrl));
	if (play_url == NULL)
		return NULL;
	play_url->file_name = s_strdup(file_name);
	play_url->play_url = s_strdup(src_url);
	return play_url;
}

/*
char*    xl_play_url_get_url_hash(XLPlayUrl *play_url)
{
	if (!play_url)
		return NULL;
	return s_strdup(play_url->url_hash);
}
*/

char*    xl_play_url_get_file_name(XLPlayUrl *play_url)
{
	if (!play_url)
		return NULL;
	return s_strdup(play_url->file_name);
}

char*    xl_play_url_get_play_url(XLPlayUrl *play_url)
{
	if (!play_url)
		return NULL;
	return s_strdup(play_url->play_url);
}

/*
size_t   xl_play_url_get_file_size(XLPlayUrl *play_url)
{
	if (!play_url)
		return 0;
	return play_url->file_size;
}

int64_t  xl_play_url_get_duration(XLPlayUrl *play_url)
{
	if (!play_url)
		return 0;
	return play_url->duration;
}
*/
int xl_play_url_free(XLPlayUrl *play_url)
{
	if (!play_url)
		return -1;

	if (play_url->file_name)
		s_free(play_url->file_name);
	if (play_url->play_url)
		s_free(play_url->play_url);
	s_free(play_url);
	return 0;
}

/******** PlayUrls below ********/

XLPlayUrls* xl_play_urls_new(void)
{
	XLPlayUrls *play_urls;
	play_urls = s_malloc0(sizeof(XLPlayUrls));
	INIT_LIST_HEAD(&(play_urls)->list);
	return play_urls;
}

XLPlayUrls* xl_play_urls_append_play_url(XLPlayUrls *play_urls, XLPlayUrl *play_url)
{
	XLPlayUrls *tmp;
	tmp = s_malloc0(sizeof(XLPlayUrls));
	tmp->play_url = play_url;
	list_add_tail(&(tmp->list), &(play_urls)->list); 
	return play_urls;
}

int  xl_play_urls_get_count(XLPlayUrls *play_urls)
{
	list_head_t *pos;
	int i;
	i = 0;

	list_for_each(pos, &(play_urls)->list) 
	{
		i++;
	}
	return i;
}

XLPlayUrls*  xl_play_urls_get_nth(XLPlayUrls *play_urls, int pos)
{
	XLPlayUrls *entry;
	int i;
	i = 0;

	list_for_each_entry(entry, &(play_urls)->list, list)
	{
		if (i == pos)
			return entry;
		i++;
	}
	return NULL;
}

XLPlayUrl*  xl_play_urls_get_nth_play_url(XLPlayUrls *play_urls, int pos)
{
	XLPlayUrls *entry;
	int i;
	i = 0;

	list_for_each_entry(entry, &(play_urls)->list, list)
	{
		if (i == pos)
			return entry->play_url;
		i++;
	}
	return NULL;
}

XLPlayUrls* xl_play_urls_remove (XLPlayUrls *play_urls, XLPlayUrl *play_url)
{
	list_head_t *pos, *n;
	XLPlayUrls *tmp;

	list_for_each_safe(pos, n, &(play_urls)->list) 
	{ 
		tmp = list_entry(pos, XLPlayUrls, list); 
		if (tmp->play_url == play_url)
		{
			list_del_init(pos);
			xl_play_url_free(tmp->play_url);
			free(tmp);
		}
	} 
	return play_urls;
}

XLPlayUrl*  xl_play_urls_find_play_url_by_url(XLPlayUrls *play_urls, const char *url)
{
	return NULL;
}
/*
XLPlayUrl*  xl_play_urls_find_play_url_by_url_hash(XLPlayUrls *play_urls, const char *url_hash)
{
	XLPlayUrls *tmp = NULL;

	list_for_each_entry(tmp, &(play_urls)->list, list)
	{
		char *_url_hash;
		//_url_hash = xl_play_url_get_url_hash(tmp->play_url);
		if (strncmp(_url_hash, url_hash, strlen(url_hash)) == 0)
		{
			s_free(_url_hash);
			return tmp->play_url;
		}else {
			s_free(_url_hash);
		}
	}
	return NULL;
}
*/

void xl_play_urls_free(XLPlayUrls *play_urls)
{
	list_head_t *pos, *n;
	XLPlayUrls *entry;
	list_for_each_safe(pos, n, &(play_urls)->list)
	{
		entry = list_entry(pos, XLPlayUrls, list);
		list_del_init(pos);
		xl_play_url_free(entry->play_url);
		free(entry);
	}
}

#if 0
int main(int argc, char **argv)
{
	XLPlayUrl *v1, *v2;
	XLPlayUrl *v;
	XLPlayUrls *vs = NULL;
	v1 = xl_play_url_new("url_hash", "url", "fname", "surl", 123, 3312);
	v2 = xl_play_url_new("url_hash2", "url2", "fname2", "surl2", 22, 2222);
	vs = xl_play_urls_new();
	printf("play_urls count=%d, vs=%x\n", xl_play_urls_get_count(vs), &vs);
	vs = xl_play_urls_append_play_url(vs, v1);
	printf("play_urls count=%d, vs=%x\n", xl_play_urls_get_count(vs), &vs);
	vs = xl_play_urls_append_play_url(vs, v2);
	printf("play_urls count=%d, vs=%x\n", xl_play_urls_get_count(vs), &vs);
	v = xl_play_urls_find_play_url_by_url_hash(vs, "url_hash2");
	printf("play_urls url=%s\n", xl_play_url_get_url(v));
	v = xl_play_urls_get_nth_play_url(vs, 1);
	printf("play_urls url=%s\n", xl_play_url_get_url(v));
	xl_play_urls_free(vs);
	printf("play_urls count=%d, vs=%x\n", xl_play_urls_get_count(vs), &vs);

	return 0;
}
#endif
