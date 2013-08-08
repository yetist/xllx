/* vi: set sw=4 ts=4 wrap ai: */
/*
 * client.h: This file is part of ____
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

#ifndef __CLIENT_H__ 
#define __CLIENT_H__  1

#include "xllx.h"
#include "info.h"

typedef struct _XLClient XLClient;

XLClient*   xl_client_new(const char *username, const char *password);
int         xl_client_login(XLClient *client, XLErrorCode *err);
XLErrorCode xl_client_logout(XLClient *client);
void        xl_client_set_verify_image_path(XLClient *client, const char *path);
void        xl_client_set_verify_code(XLClient *client, const char *vcode);

void xl_read_all_complete_tasks(XLClient *client);
char *lwqq_get_cookies(XLClient *lc);

int xl_add_yun_task(XLClient *client, char *url);

//void lwqq_vc_free(LwqqVerifyCode *vc);

void xl_client_free(XLClient *client);

#endif /* __CLIENT_H__ */
