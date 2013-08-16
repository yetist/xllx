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

char video_urls[][3600] = {
	"http://dl1.c17.sendfile.vip.xunlei.com:8000/%5B%E5%BF%AB%E4%BC%A0%E4%B8%8B%E8%BD%BDwww%2Eyycaf%2Enet%5D%E6%96%B0%E6%81%8B%E7%88%B1%E6%97%B6%E4%BB%A307%2EHDTV%2Ermvb?key=3ddde693c247410894b6a53bbca102ae&file_url=%2Fgdrive%2Fresource%2FFF%2FEA%2FFF3BE80C965A2C32265A18A651D650BBF55508EA&file_type=0&authkey=C53BE9A99DF0BC93A39D05F1A1BABF8590A5D51F33B0C8426B53C150038FD3B5&exp_time=1378570291&from_uid=267261&task_id=5890378446229006594&get_uid=288543553&f=lixian.vip.xunlei.com&reduce_cdn=1&fid=TMig7BAOBJvBwyT4O8YB8qevWxbzWB0NAAAAAP876AyWWiwyJloYplHWULv1VQjq&mid=666&threshold=150&tid=CD6C2D1D6AA7BFF121BECC24DB3EC20F&srcid=7&verno=1",
	"ed2k://|file|Ladri.di.Biciclette.1948.%E5%81%B7%E8%87%AA%E8%A1%8C%E8%BD%A6%E7%9A%84%E4%BA%BA.%E5%8F%8C%E8%AF%AD%E5%AD%97%E5%B9%95.HR-HDTV.AAC.768X576.x264-%E4%BA%BA%E4%BA%BA%E5%BD%B1%E8%A7%86%E5%88%B6%E4%BD%9C.mkv|1443233940|79f2af361965aa8056d143e3c4e40ee0|h=mvo6veh7uoy6d6qprvtraeoixhqxqsvf|/",
	"thunder://QUFmdHA6Ly9keWdvZDE6ZHlnb2QxQGQwNzkuZHlnb2Qub3JnOjkxMjUvJTVCJUU5JTk4JUIzJUU1JTg1JTg5JUU3JTk0JUI1JUU1JUJEJUIxd3d3LnlnZHk4LmNvbSU1RC4lRTUlODElQTUlRTclOTQlQjclRTYlOEElQTIlRTklOTIlQjElRTUlOUIlQTIuQkQuNzIwcC4lRTQlQjglQUQlRTglOEIlQjElRTUlOEYlOEMlRTUlQUQlOTclRTUlQjklOTUucm12Ylpa",
//	"thunder://QUFodHRwOi8vdGh1bmRlci5mZmR5LmNjLzk2NUMwQTk5NERDQUE1MzQ4REQwMTA4N0NDRDY1MzY0OEVFQjREM0Yv5Lit5Zu95ZCI5LyZ5Lq6QkQucm12Ylpa",
	"magnet:?xt=urn:btih:32dbf49152cf116cbc0f0cfcf502ce288d3e56ad&tr.0=http://tracker.openbittorrent.com/announce&tr.1=udp://tracker.openbittorrent.com:80/announce&tr.2=http://tracker.thepiratebay.org/announce&tr.3=http://tracker.publicbt.com/announce&tr.4=http://tracker.prq.to/announce&tr.5=udp://tracker.publicbt.com:80/announce",
	"http://bbs.btwuji.com/job.php?action=download&pid=tpc&tid=333350&aid=225934",
	"http://bbs.btwuji.com/job.php?action=download&pid=tpc&tid=333635&aid=226138",
	"http://bbs.btwuji.com/job.php?action=download&pid=tpc&tid=333636&aid=226139",
	{0},
};

void test_client(const char* username, const char* password, const char *url)
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
				buf[4] = '\0';
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
	char *vurl;

	vurl = xl_vod_get_video_url(vod, url, VIDEO_1080P, &err);
	if (vurl == NULL)
	{
		if (err == XL_ERROR_VIDEO_NOT_READY) {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video is not ready\n");
		} else if (err == XL_ERROR_VIDEO_URL_NOT_ALLOWED) {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video url is not allowed\n");
		} else if (err == XL_ERROR_VIDEO_ADD_FAILED) {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video add failed\n");
		} else {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛  got an error, error code is %d\n", err);
		}

	} else {
		printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛  play_url is %s\n", vurl);
		free(vurl);
	}
}

int main(int argc, char** argv)
{
	if (argc != 4)
	{
		fprintf(stderr, "Usage:\n\t%s <username> <userpassword> <source url|torrent path>\n\n", argv[0]);
		return -1;
	}

	char *username = argv[1];
	char *password = argv[2];
	char *url = argv[3];
	test_client(username, password, url);
	return 0;
}
