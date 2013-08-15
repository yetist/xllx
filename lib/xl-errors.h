/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xl-errors.h: This file is part of ____
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

#ifndef __XL_ERRORS_H__ 
#define __XL_ERRORS_H__  1

/* XL Error Code */
typedef enum {
    XL_ERROR_OK,
    XL_ERROR_ERROR,
    XL_ERROR_FILE_NOT_EXIST,
    XL_ERROR_LOGIN_NEED_VC = 10,
    XL_ERROR_LOGIN_EXPIRE,
    XL_ERROR_NETWORK_ERROR = 20,
    XL_ERROR_HTTP_ERROR = 30,
    XL_ERROR_VIDEO_NOT_READY,
	XL_ERROR_VIDEO_URL_NOT_ALLOWED,
	XL_ERROR_VIDEO_ADD_FAILED,
} XLErrorCode;

#endif /* __XL_ERRORS_H__ */
