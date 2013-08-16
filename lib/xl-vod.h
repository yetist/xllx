/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-vod.h: This file is part of ____
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

#ifndef __XL_VOD_H__ 
#define __XL_VOD_H__  1

#include "xl-client.h"

typedef enum
{
	VIDEO_480P,
	VIDEO_720P,
	VIDEO_1080P,
} VideoType;

typedef enum
{
	VIDEO_WAIT_DOWNLOAD,	// 0: "下载等待中",
	VIDEO_DOWNLOADING,		// 1: "下载中",
	VIDEO_DOWNLOAD_FAILED,	// 2: "下载失败",
	VIDEO_WAIT_CONVERT,		// 3: "转码等待中",
	VIDEO_CONVERTING,		// 4: "转码中",
	VIDEO_CONVERTED,		// 5: "转码完成",
	VIDEO_CONVERT_FAILED,	// 6: "转码失败",
	VIDEO_READY,			// 7: "完成",
	VIDEO_SEED_DOWNLOADING,	// 8: "种子下载中",
	VIDEO_SEED_DOWNLOADED,	// 9: "种子下载完成",
	VIDEO_NO_VIDEO,			// 10: "链接不含视频",
	//VIDEO_DOWNLOAD_FAILED=11,	// 11: "下载失败"
} VideoStatus;

typedef struct _XLVod XLVod;

XLVod* xl_vod_new(XLClient *client);
void   xl_vod_free(XLVod *vod);

//char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type);
char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type, XLErrorCode *err);
//VideoStatus xl_vod_get_video_status(XLVod *vod, const char* url, XLErrorCode *err);
VideoStatus xl_vod_get_video_status(XLVod *vod, const char* url, const char* url_hash, XLErrorCode *err);


#endif /* __XL_VOD_H__ */
