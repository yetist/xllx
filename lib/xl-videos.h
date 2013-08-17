/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-videos.h: This file is part of ____
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

#ifndef __XL_VIDEOS_H__ 
#define __XL_VIDEOS_H__  1

typedef struct _XLVideo XLVideo;

typedef struct _XLVideos XLVideos;

XLVideo* xl_video_new(const char *url_hash, const char *url, const char *file_name, const char *src_url, size_t file_size, int64_t duration);
char*    xl_video_get_url_hash(XLVideo *video);
char*    xl_video_get_url(XLVideo *video);
char*    xl_video_get_file_name(XLVideo *video);
char*    xl_video_get_src_url(XLVideo *video);
size_t   xl_video_get_file_size(XLVideo *video);
int64_t  xl_video_get_duration(XLVideo *video);
int      xl_video_free(XLVideo *video);

XLVideos* xl_videos_append_video(XLVideos *videos, XLVideo *video);
int       xl_videos_get_count(XLVideos *videos);
XLVideos* xl_videos_get_nth(XLVideos *videos, int pos);
XLVideo*  xl_videos_get_nth_video(XLVideos *videos, int pos);
XLVideos* xl_videos_insert_video(XLVideos *videos, XLVideo *video, int pos);
XLVideos* xl_videos_remove (XLVideos *videos, XLVideo *video);

//int       xl_videos_delete_video(XLVideos *videos, int pos);
//int       xl_videos_clear(XLVideos *videos);
XLVideo*  xl_videos_find_video_by_url(XLVideos *videos, const char *url);
XLVideo*  xl_videos_find_video_by_url_hash(XLVideos *videos, const char *url_hash);
void      xl_videos_free(XLVideos *videos);

#endif /* __XL_VIDEOS_H__ */
