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

void play_online_videos(XLVod *vod)
{
	int count;
	int i;
	XLVideos* videos;
	XLVideo* video;
	XLErrorCode err;

	videos = xl_vod_get_videos(vod);
	count = xl_videos_get_count(videos);
	for (i=0; i < count; i++)
	{
		char *file_name;
		char *src_url;
		char *play_url;
		char *fname;
		video = xl_videos_get_nth_video(videos, i);
		file_name = xl_video_get_file_name(video);
		src_url = xl_video_get_src_url(video);
		play_url = xl_vod_get_video_play_url(vod, VIDEO_1080P, video, &err);
		fname = xl_url_unquote(file_name);
		printf("video: %s, url: %s\n play_url: %s\n", fname, src_url, play_url);
		free(file_name);
		free(src_url);
		free(play_url);
	}
}

void play_url_files(XLVod *vod, const char *path)
{
	FILE *fp;
	char buf[1024];
	XLErrorCode err;
	fp = fopen(path, "r+");
	while (fgets(buf, sizeof(buf), fp) != NULL)
	{
		int len;
		char *url;
		len = strlen(buf);
		buf[len-1] = '\0';
		url = xl_vod_get_video_url(vod, buf, VIDEO_1080P, &err);
		if (url == NULL)
		{
			if (err == XL_ERROR_VIDEO_NOT_READY) {
				printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video is not ready\n");
			} else if (err == XL_ERROR_VIDEO_URL_NOT_ALLOWED) {
				printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video url is not allowed\n");
			} else if (err == XL_ERROR_VIDEO_ADD_FAILED) {
				printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video add failed\n");
			} else {
				printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ got an error, error code is %d\n", err);
			}

		} else {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛  commandline for play is: mplayer -referrer \"http://vod.lixian.xunlei.com/media/vodPlayer_2.8.swf?v=2.8.991.01\" \"%s\" \n", url);
			free(url);
		}
	}
	fclose(fp);
}

void test_client(const char* username, const char* password, const char *path)
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
	//play_online_videos(vod);
	play_url_files(vod, path);
	xl_client_logout(client);
	xl_vod_free(vod);
}

int main(int argc, char** argv)
{
	if (argc != 4)
	{
		fprintf(stderr, "Usage:\n\t%s <username> <userpassword> <url file>\n\n", argv[0]);
		return -1;
	}

	char *username = argv[1];
	char *password = argv[2];
	char *url_file = argv[3];
	test_client(username, password, url_file);
	return 0;
}
