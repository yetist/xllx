/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-videos.c: This file is part of ____
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

#include "xl-videos.h"
#include "smemory.h"
#include "list_head.h"

struct _XLVideo
{
	char *url_hash;
	char *file_name;
	char *src_url;
	size_t file_size;
	int64_t duration;
};

struct _XLVideos
{
	XLVideo *video;
	list_head_t list;
};

XLVideo* xl_video_new(const char *url_hash, const char *file_name, const char *src_url)
{
	if (!url_hash || !file_name|| !src_url )
	{
		return NULL;
	}
	XLVideo *video = s_malloc0(sizeof(XLVideo));
	if (video == NULL)
		return NULL;
	video->url_hash = s_strdup(url_hash);
	video->file_name = s_strdup(file_name);
	video->src_url = s_strdup(src_url);
	return video;
}

char*    xl_video_get_url_hash(XLVideo *video)
{
	if (!video)
		return NULL;
	return s_strdup(video->url_hash);
}

char*    xl_video_get_file_name(XLVideo *video)
{
	if (!video)
		return NULL;
	return s_strdup(video->file_name);
}

char*    xl_video_get_src_url(XLVideo *video)
{
	if (!video)
		return NULL;
	return s_strdup(video->src_url);
}

size_t   xl_video_get_file_size(XLVideo *video)
{
	if (!video)
		return 0;
	return video->file_size;
}

int64_t  xl_video_get_duration(XLVideo *video)
{
	if (!video)
		return 0;
	return video->duration;
}

int xl_video_free(XLVideo *video)
{
	if (!video)
		return -1;

	if (video->url_hash)
		s_free(video->url_hash);
	if (video->file_name)
		s_free(video->file_name);
	if (video->src_url)
		s_free(video->src_url);
	s_free(video);
	return 0;
}

/******** Videos below ********/

XLVideos* xl_videos_new(void)
{
	XLVideos *videos;
	videos = s_malloc0(sizeof(XLVideos));
	INIT_LIST_HEAD(&(videos)->list);
	if (list_empty(&(videos)->list))
		printf("list is empty\n");
	return videos;
}

XLVideos* xl_videos_append_video(XLVideos *videos, XLVideo *video)
{
	XLVideos *tmp;
	tmp = s_malloc0(sizeof(XLVideos));
	tmp->video = video;
	list_add_tail(&(tmp->list), &(videos)->list); 
	return videos;
}

int  xl_videos_get_count(XLVideos *videos)
{
	list_head_t *pos;
	int i;
	i = 0;

	list_for_each(pos, &(videos)->list) 
	{
		i++;
	}
	return i;
}

XLVideos*  xl_videos_get_nth(XLVideos *videos, int pos)
{
	XLVideos *entry;
	int i;
	i = 0;

	list_for_each_entry(entry, &(videos)->list, list)
	{
		if (i == pos)
			return entry;
		i++;
	}
	return NULL;
}

XLVideo*  xl_videos_get_nth_video(XLVideos *videos, int pos)
{
	XLVideos *entry;
	int i;
	i = 0;

	list_for_each_entry(entry, &(videos)->list, list)
	{
		if (i == pos)
			return entry->video;
		i++;
	}
	return NULL;
}

XLVideos* xl_videos_remove (XLVideos *videos, XLVideo *video)
{
	list_head_t *pos, *n;
	XLVideos *tmp;

	list_for_each_safe(pos, n, &(videos)->list) 
	{ 
		tmp = list_entry(pos, XLVideos, list); 
		if (tmp->video == video)
		{
			list_del_init(pos);
			xl_video_free(tmp->video);
			free(tmp);
		}
	} 
	return videos;
}

XLVideo*  xl_videos_find_video_by_url(XLVideos *videos, const char *url)
{
	return NULL;
}

XLVideo*  xl_videos_find_video_by_url_hash(XLVideos *videos, const char *url_hash)
{
	XLVideos *tmp = NULL;

	list_for_each_entry(tmp, &(videos)->list, list)
	{
		char *_url_hash;
		_url_hash = xl_video_get_url_hash(tmp->video);
		if (strncmp(_url_hash, url_hash, strlen(url_hash)) == 0)
		{
			s_free(_url_hash);
			return tmp->video;
		}else {
			s_free(_url_hash);
		}
	}
	return NULL;
}

void xl_videos_free(XLVideos *videos)
{
	list_head_t *pos, *n;
	XLVideos *entry;
	list_for_each_safe(pos, n, &(videos)->list)
	{
		entry = list_entry(pos, XLVideos, list);
		list_del_init(pos);
		xl_video_free(entry->video);
		free(entry);
	}
}

#if 0
int main(int argc, char **argv)
{
	XLVideo *v1, *v2;
	XLVideo *v;
	XLVideos *vs = NULL;
	v1 = xl_video_new("url_hash", "url", "fname", "surl", 123, 3312);
	v2 = xl_video_new("url_hash2", "url2", "fname2", "surl2", 22, 2222);
	vs = xl_videos_new();
	printf("videos count=%d, vs=%x\n", xl_videos_get_count(vs), &vs);
	vs = xl_videos_append_video(vs, v1);
	printf("videos count=%d, vs=%x\n", xl_videos_get_count(vs), &vs);
	vs = xl_videos_append_video(vs, v2);
	printf("videos count=%d, vs=%x\n", xl_videos_get_count(vs), &vs);
	v = xl_videos_find_video_by_url_hash(vs, "url_hash2");
	printf("videos url=%s\n", xl_video_get_url(v));
	v = xl_videos_get_nth_video(vs, 1);
	printf("videos url=%s\n", xl_video_get_url(v));
	xl_videos_free(vs);
	printf("videos count=%d, vs=%x\n", xl_videos_get_count(vs), &vs);

	return 0;
}
#endif
