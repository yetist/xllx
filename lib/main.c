/* vi: set sw=4 ts=4 wrap ai: */
/*
 * main.c: This file is part of ____
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

#include "xl-http.h"
#include "smemory.h"
#include "logger.h"
#include "xl-client.h"
#include "xl-vod.h"

void test_http(const char *uri)
{
	XLHttp *req = xl_http_new(uri);
	if (req) {
		int ret = 0;
		ret = xl_http_open(req, 0, NULL);
		if (ret == 0) {
			xl_log(LOG_NOTICE, "Http response code: %d\n", xl_http_get_status(req));
			xl_log(LOG_NOTICE, "Http response buf: %s\n", xl_http_get_response(req));
			xl_log(LOG_NOTICE, "Http [cookie]BDSVRTM: %s\n", xl_http_get_cookie(req, "BDSVRTM"));
			xl_log(LOG_NOTICE, "Http [cookie]H_PS_PSSID: %s\n", xl_http_get_cookie(req, "H_PS_PSSID"));
			xl_log(LOG_NOTICE, "Http [header]BDQID: %s\n", xl_http_get_header(req, "BDQID"));
			if (xl_http_get_status(req) == 302)
			{
				xl_log(LOG_NOTICE, "Http [header]Location: %s\n", xl_http_get_header(req, "Location"));
			}
		}
		xl_http_free(req);
	}
}

void test_client(const char* username, const char* password)
{
    XLClient *client;
    XLErrorCode err = 0;
	char buf[4];
	int ret;

    client = xl_client_new(username, password);
	xl_client_set_verify_image_path(client, "/tmp/vcode.jpg");
    ret = xl_client_login(client, &err);
	int try = 0;
	printf("error = %d\n", err);
	while (ret != 0 && try < 3)
	{
		try++;
		if (err == XL_ERROR_HTTP_ERROR)
			printf("ERROR: http error\n");
		if (err == XL_ERROR_LOGIN_NEED_VC)
		{
			printf("please input the verify code(see /tmp/vcode.jpg):");
			fgets(buf, 5, stdin);
			printf("vcode=%s\n", buf);
			xl_client_set_verify_code(client, buf);
		}
		err = XL_ERROR_OK;
		ret = xl_client_login(client, &err);
	}
	if (ret != 0)
	{
		printf("login failed! return code = %d\n", err);
		return;
	}
	XLVod *vod = xl_vod_new(client);
//	int xl_vod_add_video(XLVod *vod, const char* url);
	xl_vod_add_video(vod, "thunder://QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa");
//	char *xl_vod_get_video_url(XLVod *vod, const char* url, VideoType type);
	xl_vod_get_video_url(vod, "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=", VIDEO_1080P);
	//int xl_vod_has_video(XLVod *vod, const char* url);
	xl_vod_has_video(vod, "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=");
	//xl_read_all_complete_tasks(client);
//	xl_add_yun_task(client, "thunder://QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NU MwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa");
//	xl_get_yun_url(client, "thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzAuZHlnb2Qub3JnOjEwOTAvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlOEYlQjYlRTklOTclQUUlRUYlQkMlOUElRTclQkIlODglRTYlOUUlODElRTQlQjglODAlRTYlODglOTguQkQuNzIwcC4lRTUlOUIlQkQlRTclQjIlQTQlRTUlOEYlOEMlRTglQUYlQUQlRTQlQjglQUQlRTUlQUQlOTcubWt2Wlo=", "[阳光电影www.ygdy8.com].叶问：终极一战.BD.720p.国粤双语中字.mkv");
}

int main(int argc, char** argv)
{
	if (argc != 3)
		return -1;

	char *username = argv[1];
	char *password = argv[2];
    //test_http("http://www.baidu.com");
    test_client(username, password);
	return 0;
}
