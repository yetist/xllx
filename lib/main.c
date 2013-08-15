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
#include <stdlib.h>
#include <string.h>

#include "xllx.h"

char video_urls[][200] = {
	//"thunder://QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NUMwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
	//"magnet:?xt=urn:btih:B23DC247B279437C74F85E06B44E7D0A4BA40B88",
	//"/home/jingqianqiu/Intolerable_Cruelty.torrent",
	//"/dev/shm/004f50950256e66f128d528d0773fdefbc298cce.torrent",
	//"/dev/shm/a.torrent",
	//"/dev/shm/b.torrent",
	"/dev/shm/c.torrent",
	//"/dev/shm/d.torrent",
	{0},
};

void test_http(const char *uri)
{
	XLHttp *req = xl_http_new(uri);
	if (req) {
		int ret = 0;
		ret = xl_http_open(req, 0, NULL);
		if (ret == 0) {
			printf("Http response code: %d\n", xl_http_get_status(req));
			printf("Http response buf: %s\n", xl_http_get_body(req));
			printf("Http [cookie]BDSVRTM: %s\n", xl_http_get_cookie(req, "BDSVRTM"));
			printf("Http [cookie]H_PS_PSSID: %s\n", xl_http_get_cookie(req, "H_PS_PSSID"));
			printf("Http [header]BDQID: %s\n", xl_http_get_header(req, "BDQID"));
			if (xl_http_get_status(req) == 302)
			{
				printf("Http [header]Location: %s\n", xl_http_get_header(req, "Location"));
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
	while (ret != 0 && try < 3)
	{
		try++;
		if (err == XL_ERROR_HTTP_ERROR || err == XL_ERROR_NETWORK_ERROR)
			printf("ERROR: http error\n");
		if (err == XL_ERROR_LOGIN_NEED_VC)
		{
			do{
				fflush(stdin);
				printf("please input the verify code(see /tmp/vcode.jpg):");
				fgets(buf, 5, stdin);
			}while(strlen(buf) != 4);
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
	XLVod *vod;
	vod = xl_vod_new(client);
	int i = 0;
	char *vurl;
	while (video_urls[i] && *(video_urls[i]))
	{
		vurl = xl_vod_get_video_url(vod, video_urls[i], VIDEO_1080P);
		printf("video_urls[%d]=%s\n", i, video_urls[i]);
		printf("@@@@@@@@@@@@@@@@@@ %s\n", vurl);
		free(vurl);
		i++;
	}
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
