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
#include "xllx.h"

typedef enum
{
	VIDEO_480P,
	VIDEO_720P,
	VIDEO_1080P,
} VideoType;

typedef struct _XLVod XLVod;

XLVod* xl_vod_new(XLClient *client);
void   xl_vod_free(XLVod *vod);

int xl_vod_has_video(XLVod *vod, const char* url);
int xl_vod_add_video(XLVod *vod, const char* url);
char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type);

#endif /* __XL_VOD_H__ */
