/* vi: set sw=4 ts=4 wrap ai: */
/*
 * protocol.h: This file is part of ____
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

#ifndef __PROTOCOL_H__ 
#define __PROTOCOL_H__  1

/* 消息类型定义 */
typedef enum
{
	MGS_UNKNOWN,		/* 未知 */
	MGS_LOGIN,		/* 请求登录 */
	MGS_VERIFY_IMAGE, /* 验证码图片信息 */
	MGS_VERIFY_CODE, /* 验证码图片信息 */
	MGS_BT_FILE, /* Bt文件信息 */
	MGS_VIDEO_URL,  /* 请求得到视频播放地址 */
	MGS_LOGIN_INFO,	/* 返回登录信息 */
	MGS_VIDEO_URL_INFO,	/* 返回视频播放地址信息 */
} HeaderId;

struct _Header
{
	HeaderId id;          /* 消息体类型 */
};

typedef struct _Header Header;

struct _videoUrlRequ
{
	char       url[1024];	/* 请求的视频网络地址或种子的路径 */
};

typedef struct _videoUrlRequ VideoUrlRequ;

struct _VideoUrlRequMsg
{
	Header head;
	VideoUrlRequ body;
};

/* 请求查询插件消息定义 */
struct _LoginRequ
{
	char      username[60];	/* 迅雷用户名*/
	char      password[16];	/* 密码 6-16位*/
};

typedef struct _LoginRequ LoginRequ;

struct _LoginRequMsg
{
	Header head;
	LoginRequ body;
};

/* 返回插件列表消息定义 */
struct _LoginInfoResp
{
	int status;  /* 登录成功为0 登录失败非0*/
};

typedef struct _LoginInfoResp LoginInfoResp;

struct _LoginRespMsg
{
	Header head;
	LoginInfoRespResp body;
};

/* 返回视频地址消息定义 */
struct _VideoUrlInfoResp
{
	char    url[1024];
};

typedef struct _VideoUrlInfoResp VideoUrlInfoResp;

struct _VideoUrlRespMsg
{
	Header head;
	VideoUrlInfoResp body;
};

struct _VerifyImageMsg
{
	Header head;
	unsigned int size;
};
struct _BtFileRequ
{
	char       name[1024];	/* 请求种子的名称 */
	unsigned int size;
};
typedef struct _BtFileRequ	BtFileRequ;

struct _BtFileMsg
{
	Header head;
	BtFileRequ body;
};

struct _VerifyCodeMsg
{
	Header head;
	char code[4];
}

typedef struct _LoginRequMsg	LoginRequMsg;
typedef struct _VideoUrlRequMsg	VideoUrlRequMsg;

typedef struct _LoginRespMsg	LoginRespMsg;
typedef struct _VideoUrlRespMsg	VideoUrlRespMsg;

typedef struct _VerifyImageMsg	VerifyImageMsg;
typedef struct _VerifyCodeMsg	VerifyCodeMsg;
typedef struct _BtFileMsg	BtFileMsg;

/*
 * 消息包格式：
 *
 * 请求信息包：
 * |LoginRequMsg|
 * |VideoUrlRequMsg|
 *
 * 应答消息包：
 * |LoginRespMsg|
 * |VideoUrlRespMsg|
 *
 * 传输过程：
 *
 * 登录信息：
 * [CLIENT]                      [SERVER]
 * 1.         LoginRequMsg  ->
 *			  <- VerifyImageMsg	
 *			  VerifyCodeMsg ->	
 * 2.     <-  LoginRespMsg
 *
 *  获取视频地址关键字：
 * [CLIENT]                      [SERVER]
 * 1.          MovieUrlRequMsg    ->
 * 2.       <- MovieUrlRespMsg 
 *
 * */

#endif /* __PROTOCOL_H__ */
