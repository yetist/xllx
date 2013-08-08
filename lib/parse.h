/**
 * @file   logger.h
 * @author mathslinux <riegamaths@gmail.com>
 * @date   Sun May 20 23:27:05 2012
 * 
 * @brief  Linux WebQQ Logger API
 * 
 * 
 */

#ifndef LX_PARSE_H
#define LX_PARSE_H

char *taskName(char *taskContent);
char *taskSize(char *taskContent);
char *taskLoadProcess(char *taskContent);
char *taskRetainDays(char *taskContent);
char *taskAddTime(char *taskContent);
char *taskDownlaodNormalURL(char *taskContent);
char *GDriveID(char *orignData);
char *taskType(char *taskContent);
char *DCID(char *taskContent);
char *GCID(char *taskDownLoadURL);

char *nextPageSubURL(char *currentPageData);

char *string_by_matching(char *pattern, char *str);
char *get_gcid(char *taskDownLoadURL);

#endif
