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

struct _XLVideo
{
	char *url_hash;
	char *url;
	char *file_name;
	char *src_url;
	size_t file_size;
	int64_t duration;
};

struct _XLVideos
{
	XLVideo *video;
	XLVideos *next;
};

static void      xl_videos_free_1(XLVideos *videos);

XLVideo* xl_video_new(const char *url_hash, const char *url, const char *file_name, const char *src_url, size_t file_size, int64_t duration)
{
	if (!url_hash || !url || !src_url )
	{
		return NULL;
	}
	XLVideo *video = s_malloc0(sizeof(XLVideo));
	if (video == NULL)
		return NULL;
	video->url_hash = s_strdup(url_hash);
	video->url = s_strdup(url);
	video->file_name = s_strdup(file_name);
	video->src_url = s_strdup(src_url);
	video->file_size = file_size;
	video->duration = duration;
	return video;
}

char*    xl_video_get_url_hash(XLVideo *video)
{
	if (!video)
		return NULL;
	return s_strdup(video->url_hash);
}

char*    xl_video_get_url(XLVideo *video)
{
	if (!video)
		return NULL;
	return s_strdup(video->url);
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
	s_free(video->url);
	s_free(video->file_name);
	s_free(video->src_url);
	s_free(video);
	return 0;
}

XLVideos* videos_get_last(XLVideos *videos)
{
  if (videos)
    {
      while (videos->next)
        videos = videos->next;
    }

  return videos;
}

XLVideos* xl_videos_prepend (XLVideos *videos, XLVideo *video)
{
	XLVideos *new_videos = NULL;

	new_videos = s_malloc0(sizeof(XLVideos));
	if (new_videos != NULL)
	{
		new_videos->video = video;
		new_videos->next = videos;
	}

	return new_videos;
}

XLVideos* xl_videos_append_video(XLVideos *videos, XLVideo *video)
{
	printf("%s:%s():%d\n", __FILE__, __FUNCTION__, __LINE__);
	if (!video)
		return videos;
	XLVideos *new_videos = NULL;
	XLVideos *last;

	new_videos = s_malloc0(sizeof(XLVideos));
	if (new_videos != NULL)
	{
		new_videos->video = video;
		new_videos->next = NULL;
	}

	if (videos)
	{
		last = videos_get_last(videos);
		last->next = new_videos;

		return videos;
	} else {
		return new_videos;
	}

}

int  xl_videos_get_count(XLVideos *videos)
{
	int i;

	i = 0;
	while (videos)
	{
		i++;
		videos = videos->next;
	}
	return i;
}

XLVideos*  xl_videos_get_nth(XLVideos *videos, int pos)
{
  while (pos-- > 0 && videos)
    videos = videos->next;

  return videos;
}

XLVideo*  xl_videos_get_nth_video(XLVideos *videos, int pos)
{
  while (pos-- > 0 && videos)
    videos = videos->next;

  return videos ? videos->video: NULL;
}

XLVideos*       xl_videos_insert_video(XLVideos *videos, XLVideo *video, int pos)
{
	XLVideos *prev_videos;
	XLVideos *tmp_videos;
	XLVideos *new_videos = NULL;

	if (pos < 0)
		return xl_videos_append_video(videos, video);
	else if (pos == 0)
		return xl_videos_prepend (videos, video);

	new_videos = s_malloc0(sizeof(XLVideos));
	if (new_videos != NULL)
	{
		new_videos->video = video;
	}

	if (!videos)
	{
		new_videos->next = NULL;
		return new_videos;
	}

	prev_videos = NULL;
	tmp_videos = videos;

	while ((pos-- > 0) && tmp_videos)
	{
		prev_videos = tmp_videos;
		tmp_videos = tmp_videos->next;
	}

	if (prev_videos)
	{
		new_videos->next = prev_videos->next;
		prev_videos->next = new_videos;
	}
	else
	{
		new_videos->next = videos;
		videos = new_videos;
	}

	return videos;
}

XLVideos* xl_videos_remove (XLVideos *videos, XLVideo *video)
{
	XLVideos *tmp, *prev = NULL;

	tmp = videos;
	while (tmp)
	{
		if (tmp->video == video)
		{
			if (prev)
				prev->next = tmp->next;
			else
				videos = tmp->next;

			xl_videos_free_1(tmp);
			s_free(tmp);
			break;
		}
		prev = tmp;
		tmp = prev->next;
	}

	return videos;
}

static void      xl_videos_free_1(XLVideos *videos)
{
	xl_video_free(videos->video);
	s_free(videos);
	videos = NULL;
}

XLVideo*  xl_videos_find_video_by_url(XLVideos *videos, const char *url)
{
	return NULL;
}

XLVideo*  xl_videos_find_video_by_url_hash(XLVideos *videos, const char *url_hash)
{
	XLVideos *tmp, *prev = NULL;

	tmp = videos;
	while (tmp!=NULL)
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
		tmp = tmp->next;
	}
	return NULL;
}

void xl_videos_free(XLVideos *videos)
{
	XLVideos *current;
	XLVideos *next;

	current = videos;
	while(current != NULL)
	{
		next = current->next;//借助于q存储p的链域，否则释放p后无法引用
		xl_videos_free_1(current);
		current = next;
	}
}

int main(int argc, char **argv)
{
	XLVideo *v1, *v2;
	XLVideo *v;
	XLVideos *vs = NULL;
	v1 = xl_video_new("url_hash", "url", "fname", "surl", 123, 3312);
	v2 = xl_video_new("url_hash2", "url2", "fname2", "surl2", 22, 2222);
	vs = xl_videos_append_video(vs, v1);
	vs = xl_videos_append_video(vs, v2);
	printf("videos count=%d, vs=%x\n", xl_videos_get_count(vs), &vs);
	v = xl_videos_find_video_by_url_hash(vs, "url_hash2");
	printf("videos url=%s\n", xl_video_get_url(v));

	return 0;
}
