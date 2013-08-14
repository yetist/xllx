/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-parse.h: This file is part of ____
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

#ifndef __XL_PARSE_H__ 
#define __XL_PARSE_H__  1

#include "xl-vod.h"

int if_response_has_url(char *response, const char *url);
char *xl_get_name_from_response(char *response);
int xl_get_ret_from_response(char *response);
char *get_download_url_from_response(char *response, VideoType type, char *vtype);
int xl_get_index_from_response(char *response);
char *xl_get_infohash_from_response(char *response);
#endif

