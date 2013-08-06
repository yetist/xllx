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

#ifndef __INFO_H__ 
#define __INFO_H__  1

#define LoginURL @"http://login.xunlei.com/sec2login/"
#define DEFAULT_USER_AGENT  @"User-Agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.106 Safari/535.2"
#define DEFAULT_REFERER @"http://lixian.vip.xunlei.com/"

typedef enum {
	TLTAll,
	TLTDownloadding,
	TLTComplete,
	TLTOutofDate,
	TLTDeleted
} TaskListType;


typedef enum{
	QMiddleQuality=1,
	QLowQuality=2,
	QHighQuality=3
}YUNZHUANMAQuality;

typedef enum{
	sWaiting=0,
	sDownloadding=1,
	sComplete=2,
	sFail=3,
	sPending=4
}TaskStatus;

struct _XunleiItemInfo
{
	char taskid[64];
	char name[64];
	char size[64];
	char readableSize[64];
	char downloadPercent[16];
	char retainDays[16];
	char addDate[16];
	char downloadURL[256];
	char originalURL[256];
	char isBT[8];
	char type[8];
	char dcid[32];
	TaskStatus  status;
	char ifvod[32];
};

typedef struct _XunleiItemInfo XunleiItemInfo;

struct _XunleiItemInfoArray
{
	XunleiItemInfo xunleiItemInfo[100];
	int count;
};

typedef struct _XunleiItemInfoArray XunleiItemInfoArray;
 
struct _KuaiItemInfo
{
	char urlString[256];
	char name[64];
	char size[64];
	char gcid[32];
	char cid[32];
	char gcid_resid[32];
	char fid[32];
	char tid[32];
	char namehex[64];
	char internalid[32];
	char taskid[64];
};

typedef struct _KuaiItemInfo KuaiItemInfo;

#endif /* __INFO_H__ */
