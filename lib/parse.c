//
//  PhraseElements.m
//  XunleiLixian-API
//
//  Created by Liu Chao on 6/10/12.
//  Copyright (c) 2012 HwaYing. All rights reserved.
//
/*This file is part of XunleiLixian-API.
 
 XunleiLixian-API is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Foobar is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */


#include <stdio.h>
#include <regex.h>

char *substr(const char *s, int n1, int n2)/*从s中提取下标为n1~n2的字符组成一个新字符串，然后返回这个新串的首地址*/
{
	char *sp = malloc(sizeof(char)*(n2 - n1 + 2));
	int i, j = 0;
	for (i = n1; i <= n2; i++) {
		sp[j++] = s[i];
	}
	sp[j] = 0;
	return sp;
}

static char *parse_string(const char* pattern, const char* str, int i)
{
	regex_t re;
	int err;
	regmatch_t pm[256];
	const size_t nmatch = 256;
	err = regcomp(&re, pattern, REG_EXTENDED);
	if (err)
	{
		return NULL;
	}
	err = regexec(&re, str, nmatch, pm, 0);
	if (err == REG_NOMATCH)
	{
		printf("No Match here\n");
		regfree(&re);
		return NULL;
	}
	else if (err)
	{
		return NULL;
	}
	printf("Match\n");
	char *res = substr(str, pm[i].rm_so, pm[i].rm_eo);

	int x;
	for (x = 0; x < nmatch && pm[x].rm_so != -1; ++ x)
	{
		char *ret = substr(str, pm[x].rm_so, pm[x].rm_eo);
		printf("****************8ret is %s\n", ret);
	}

	regfree(&re);
	return res;
}





/*
+(NSArray *) taskPageData:(NSString *)orignData{
    //获得已经完成和已经过期Task列表汇总信息
    NSString *listBoxRex=@"<div\\sclass=\"rw_list\"\\sid=\"\\w+\"\\staskid=\"(\\d+)\"[^>]*>([\\s\\S]+?<input\\s+id=\"openformat\\d+\"[^>]+?>)";
    NSString *outofDateListBoxRex=@"<div\\sclass=\"rw_list\"\\staskid=[\"']?(\\d+)[\"']?\\sid=[\"']?\\w+[\"']?[^>]*>([\\s\\S]+?)<input\\s+id=[\"']?d_tasktype\\d+[\"']?[^>]+?>";
    
    NSArray *completeTaskArray=[orignData arrayOfCaptureComponentsMatchedByRegex:listBoxRex];
    NSArray *outOfDateTaskArray=[orignData arrayOfCaptureComponentsMatchedByRegex:outofDateListBoxRex];
    NSMutableArray *allTaskArray=[NSMutableArray arrayWithArray:completeTaskArray];
    [allTaskArray addObjectsFromArray:outOfDateTaskArray];
    
    return allTaskArray;
}
*/
/*
char *taskName(char *taskContent){
    char *pattern="<span\\s+[^>]*taskid=[\"']?\\d+[\"']?[^>]*title=[\"']?([^\"]*)[\"']?.*?</span>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
+(NSString *) taskSize:(NSString *)taskContent{
    NSString *re=@"<span\\s+class=\"rw_gray\"[^>]*?>([^<]+)</span>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
//读取下载进度
+(NSString *) taskLoadProcess:(NSString *)taskContent{
    NSString *re=@"<em\\s+class=\"loadnum\">([^<]+)</em>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result.length>1){
        return (result);
    }else {
        return (@"已经过期或已经删除");
    }
}
//提取保留时间
+(NSString *) taskRetainDays:(NSString *)taskContent{
    NSString *re=@"<div\\s*class=\"sub_barinfo\">\\s*<em[^>]*>([^<]+)</em>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
//任务添加时间
+(NSString *) taskAddTime:(NSString *)taskContent{
    NSString *re=@"<span\\s+class=\"c_addtime\">([^<]+)</span>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }}
//链接地址
+(NSString *) taskDownlaodNormalURL:(NSString *)taskContent{
    //NSString *re=@"<input\\s+id=\"dl_url\\d+\"\\s+type=\"\\w+\"\\s+value=[\"']?([^\"'>]+)[\"']?>";
    NSString *re=@"<input\\s+id=\"dl_url\\d*\"\\s+type=\"hidden\"\\s+value=\"([^>]*)\"";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
*/

void get_value(char *str, int *p1, int *p2)
{
	int count = 0;  //等号的数量
	int index = 0;  //下标

	while(str[index] != '\0')
	{
		if(str[index] == '=')
		{
			count++;
			if(count == 2)
				break;
		}
		index++;
	}

	*p1 = -1;  //第二个等号后的第一个引号下标
	*p2 = -1;  //第二个等号后的第二个引号下标
	while(str[index] != '\0')
	{
		if(str[index] == '\"')
		{
			if(*p1 == -1)
				*p1 = index;
			else if(*p2 == -1)
			{
				*p2 = index;
				break;
			}
		}
		index++;
	}
}

//获取GdriveID
char *GDriveID(char *taskHTMLOrignData){
	char *gdriveidRex="id=\"cok\"\\svalue=\"([^\"]+)\"";
	char *string = parse_string(gdriveidRex, taskHTMLOrignData, 0);
	if (string)
	{
		printf("The Result is %s\n", string);
		int i,j;
		get_value(string, &i, &j);
		char *gdriveID = substr(string, i, j);
    	printf("GDRIVEID:%s\n",gdriveID);
    	return gdriveID;
	}
	return NULL;
}
/*
//获取DCID（也是BT HASHID） 
+(NSString *) DCID:(NSString *)taskContent{
    NSString *re=@"<input\\s+id=\"dcid\\d+\".*?value=\"([^\"]*)\"\\s+/>";
    NSString *result=[taskContent stringByMatching:re capture:1];
    if(result){
        return result;
    }else {
        return @"未知信息";
    }
}
*/

//文件类型（BT/MOVIE/PDF/...)

//+(NSString *) taskType:(NSString *)taskContent{
  //  NSString *re=@"<input\\s+id=['\"]?openformat\\d+['\"]?.*?value=['\"]?([^'\"]+)?['\"]?\\s*/>";
    //NSString *result=[taskContent stringByMatching:re capture:1];
    //if(result){
        //如果result结果是other就代表bt文件
      //  return result;
   // }else {
     //   return @"未知类型";
   // }
//}
/*
+(NSMutableDictionary *)taskInfo:(NSString *)taskContent{
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithCapacity:0];
    NSString *re0=@"<input\\s+id=['\"]?([^0-9]+)(\\d+)['\"]?.*?value=?['\"]?([^\">]*)['\"]?";
    NSArray *data=[taskContent arrayOfCaptureComponentsMatchedByRegex:re0];
    NSArray *data1=[data objectAtIndex:0];
    [dic setObject:[data1 objectAtIndex:2] forKey:@"id"];
    for(NSArray *d in data){
        NSString *tmp;
        if(![d objectAtIndex:3]){
            tmp=@"";
        }else {
            tmp=[d objectAtIndex:3];
        }
        [dic setObject:tmp forKey:[d objectAtIndex:1]];
    }
    return dic;
}

//取得GCID
+(NSString *) GCID:(NSString *)taskDownLoadURL{
    NSString *rex=@"&g=([^&]*)&";
    NSString *r=[taskDownLoadURL stringByMatching:rex capture:1];
    return r;
}
*/
//获得下一页部分URL
/*
 href="/user_task?userid=642109&st=4&p=2&stype=0"
 */
char *nextPageSubURL(char *currentPageData){
    char *pattern = "<li\\s*class=\"next\"><a\\s*href=\"([^\"]+)\">[^<>]*</a></li>";
	char *string = parse_string(pattern, currentPageData, 0);
	if (string)
	{
		printf("The Result is %s\n", string);
		int i,j;
		get_value(string, &i, &j);
		char *sub_page_url = substr(string, i, j);
    	printf("sub_page_url:%s\n",sub_page_url);
    	return sub_page_url;
	}
	return NULL;
}

char *string_by_matching(char *pattern, char *str)
{
	printf("Pattern: %s \n", pattern);
	char *string = parse_string(pattern, str, 0);
	if (string)
	{
		printf("The Result is %s\n", string);
		int i,j;
		get_value(string, &i, &j);
		char *ret = substr(string, i, j);
    	printf("ret:%s\n",ret);
    	return ret;
	}
	return NULL;
}

//取得GCID
char *get_gcid(char *taskDownLoadURL){
	char *rex="&g=([^&]*)&";
	char *string = parse_string(rex, taskDownLoadURL, 0);
	if (string)
	{
		printf("GCID is %s", string);
		return string;
	}

	return NULL;
}

