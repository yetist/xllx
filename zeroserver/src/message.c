/* vi: set sw=4 ts=4 wrap ai: */
/*
 * message.c: This file is part of ____
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

#include <netinet/in.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>

#include <xllx/xllx.h>

#include "message.h"
#include "protocol.h"
#include "debug.h"

static ssize_t msg_read(int fd, void *buffer, ssize_t length)
{
	ssize_t bytes_left;
	ssize_t readed_bytes;
	char *ptr;
	ptr=(char *)buffer;
	bytes_left = length;
	while(bytes_left > 0)
	{
		/* 开始读 */
		readed_bytes = read(fd, ptr, bytes_left);
		if(readed_bytes<=0) /* 出错了*/
		{   
			if(errno==EINTR) /* 中断错误 我们继续读 */
			{
				log_error("continue\n");
				continue;
			}
			else if(errno==EAGAIN) /* EAGAIN : Resource temporarily unavailable*/
			{
				sleep(1);//等待一秒，希望接收缓冲区能得到释放
				log_error("continue\n");
				continue;
			}
			else /* 其他错误 没有办法,只好退了*/
			{
				log_error("ERROR: errno = %d, strerror = %s \n" , errno, strerror(errno));
				return(-1);
			}
		}
		bytes_left-=readed_bytes;
		ptr+=readed_bytes;/* 从剩下的地方继续读?? */
	}
	return length;
}

static ssize_t msg_write(int fd, void *buffer, ssize_t length)
{
	ssize_t bytes_left;
	ssize_t written_bytes;
	char *ptr;
	ptr=(char *)buffer;
	bytes_left = length;
	while(bytes_left > 0)
	{
		/* 开始写 */
		written_bytes = write(fd, ptr, bytes_left);
		if(written_bytes<=0) /* 出错了*/
		{   
			if(errno==EINTR) /* 中断错误 我们继续写 */
			{
				//printf("error errno==EINTR continue\n");
				continue;
			}
			else if(errno==EAGAIN) /* EAGAIN : Resource temporarily unavailable*/
			{
				sleep(1);//等待一秒，希望发送缓冲区能得到释放
				//printf("error errno==EAGAIN continue\n");
				continue;
			}
			else /* 其他错误 没有办法,只好退了*/
			{
				log_error("ERROR: errno = %d, strerror = %s \n"
						, errno, strerror(errno));
				return(-1);
			}
		}
		bytes_left-=written_bytes;
		ptr+=written_bytes;/* 从剩下的地方继续写?? */
	}
	return length;
}

unsigned int get_verify_image_size(const char *path)  
{  
	unsigned int filesize = -1;      
	struct stat statbuff;  
	if(stat(path, &statbuff) < 0){  
		return filesize;  
	}else{  
		filesize = statbuff.st_size;  
	}  
	return filesize;  
}  

//登录
void msg_login(int fd, XLClient *client)
{
	LoginRequ body;
	ssize_t size = msg_read(fd, &body, sizeof(body));
	if (size < 0)
	{
		log_error("errno=%d\n", errno);
		perror("read error");
	}

	log_error("body{username=%d, password=%s}\n", body.username, body.password);

	XLErrorCode err = 0;
	char buf[4];
	int ret;

	client = xl_client_new(body.username, body.password);
	xl_client_set_verify_image_path(client, "/tmp/vcode.jpg");
	ret = xl_client_login(client, &err);

	if (ret != 0)
	{
		VerifyImageMsg verifyImageMsg;
		Header head;
		head.id = MGS_VERIFY_IMAGE;
		verifyImageMsg.head = head;
		int vsize = get_verify_image_size("/tmp/vcode.jpg");
		verifyImageMsg.size = vsize;
		size = msg_write(fd, &verifyImageMsg, sizeof(verifyImageMsg));
		if (size < 0)
		{
			log_error("errno=%d\n", errno);
			perror("write error");
		}

		// 发送验证图片的内容
		int vfd;
		char buffer[1024*512];
		vfd = open("/tmp/vcode.jpg", O_RDONLY);
		int ret = read(out,buffer,vsize);
		if (ret < 0)
		{
			perror("read verify image file error");
		}
		close(vfd);

		size = msg_write(fd, buffer, vsize);
		if (size < 0)
		{
			log_error("errno=%d\n", errno);
			perror("write error");
		}
		VerifyCodeMsg codeMsg;
		ssize_t size = msg_read(fd, &codeMsg, sizeof(codeMsg));
		if (size < 0)
		{
			log_error("errno=%d\n", errno);
			perror("read error");
		}

		if (codeMsg.head.id == MGS_VERIFY_CODE)
		{
			log_error("body{code=%s}\n", codeMsg.code);
			xl_client_set_verify_code(client, codeMsg.code);
			ret = xl_client_login(client, &err);
		}
	}

	if (ret != 0)
	{
		printf("login failed! return code = %d\n", err);
	}

	log_error("login result is %d\n", ret);

	LoginRespMsg respmsg;

	respmsg.head.id = MGS_LOGIN_INFO;
	respmsg.body.status = ret;

	//write PluginRespMsg
	size = msg_write(fd, &respmsg, sizeof(respmsg));
	if (size < 0)
	{
		log_error("errno=%d\n", errno);
		perror("write error");
	}

//	close(fd);
	// printf("list is %s\n", list);
	//write(cfd,buf,sizeof(buf));
}

void msg_video_url(int fd, XLClient *client)
{	
	VideoUrlRequ body;
	ssize_t size = msg_read(fd, &body, sizeof(body));
	if (size < 0)
	{
		log_error("errno=%d\n", errno);
		perror("read error");
	}

	XLVod *vod;
	XLErrorCode err = 0;
	vod = xl_vod_new(client);

	char *vurl = xl_vod_get_video_url(vod, body.url, VIDEO_1080P, &err);
	if (vurl == NULL)
	{
		if (err == XL_ERROR_VIDEO_NOT_READY) {
			//VideoStatus status;
			//status = xl_vod_get_video_status(vod, video_urls[i], &err);
			//printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video is not ready, status=%d\n", status);
		} else if (err == XL_ERROR_VIDEO_URL_NOT_ALLOWED) {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video url is not allowed\n");
		} else if (err == XL_ERROR_VIDEO_ADD_FAILED) {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛ video add failed\n");
		} else {
			printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛  got an error, error code is %d\n", err);
		}

	} else {
		printf("⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛⬛  play_url is %s\n", vurl);
		VideoUrlInfoResp videoUrl ;
		strncpy(videoUrl.url, vurl, sizeof(videoUrl.url));

		Header head;
		head.id = MGS_VIDEO_URL_INFO;
		//write the header
		size = msg_write(fd, &head, sizeof(head));
		if (size < 0)
		{
			log_error("errno=%d\n", errno);
			perror("write error");
		}
		size = msg_write(fd, &videoUrl, sizeof(videoUrl));
		if (size < 0)
		{
			log_error("errno=%d\n", errno);
			perror("write error");
		}
		free(vurl);
	}
}

void serve_message(int fd)
{
	XLClient client;
	Header head;
	int size = msg_read(fd, &head, sizeof(head));
    if (size < 0)
    {
        perror("read error");
    }
	debug("head.id=%d\n", head.id);

	switch(head.id) {
		case MGS_LOGIN:		/* 获取插件列表 */
			log_info("get MGS_LOGIN\n");
			msg_login(fd, &client);
			break;
		case MGS_VIDEO_URL:		/* 关键字查询 */
			log_info("get MGS_VIDEO_URL\n");
			msg_video_url(fd, &client);
			break;
		default:
			log_error("error header\n");
	}
	close(fd);
}