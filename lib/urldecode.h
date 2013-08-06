/* vi: set sw=4 ts=4 wrap ai: */
/*
 * converturl.h: This file is part of ____
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

#ifndef __URLDECODE_H__ 
#define __URLDECODE_H__  1

char* thunder_url_encode(const char* uri);
char* thunder_url_decode(const char* euri);
char* qq_url_encode(const char* uri);
char* qq_url_decode(const char* euri);
char* flashget_url_encode(const char* uri);
char* flashget_url_decode(const char* euri);
char* url_decode(const char* euri);

#endif /* __URLDECODE_H__ */