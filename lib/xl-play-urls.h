/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-vurls.h: This file is part of ____
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

#ifndef __XL_PLAY_URLS_H__ 
#define __XL_PLAY_URLS_H__  1

typedef struct _XLPlayUrl XLPlayUrl;
typedef struct _XLPlayUrls XLPlayUrls;

XLPlayUrl* xl_play_url_new(const char *file_name, const char *src_url);
char*    xl_play_url_get_file_name(XLPlayUrl *play_url);
char*    xl_play_url_get_play_url(XLPlayUrl *play_url);
int      xl_play_url_free(XLPlayUrl *play_url);

XLPlayUrls* xl_play_urls_new(void);
XLPlayUrls* xl_play_urls_append_play_url(XLPlayUrls *play_urls, XLPlayUrl *play_url);
int       xl_play_urls_get_count(XLPlayUrls *play_urls);
XLPlayUrls* xl_play_urls_get_nth(XLPlayUrls *play_urls, int pos);
XLPlayUrl*  xl_play_urls_get_nth_play_url(XLPlayUrls *play_urls, int pos);
XLPlayUrls* xl_play_urls_remove (XLPlayUrls *play_urls, XLPlayUrl *play_url);

//XLPlayUrl*  xl_play_urls_find_play_url_by_url(XLPlayUrls *play_urls, const char *url);
//XLPlayUrl*  xl_play_urls_find_play_url_by_url_hash(XLPlayUrls *play_urls, const char *url_hash);
void      xl_play_urls_free(XLPlayUrls *play_urls);

#endif /* __XL_VIDEOS_H__ */
