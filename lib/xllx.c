/* vi: set sw=4 ts=4 wrap ai: */
/*
 * xllx.c: This file is part of ____
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

#include "xllx.h"

struct _VerifyCode {
    char *str;
    char *type;
    char *img;
    char *uin;
};

/* XLClient API */
struct _XLClient {
    char *username;             /**< Username */
    char *password;             /**< Password */
    char *version;              /**< WebQQ version */
    VerifyCode *vc;         /**< Verify Code */
} XLClient;

XLClient *xl_client_new(const char *username, const char *password)
{
	struct timeval tv;
	long v;

	if (!username || !password) {
		xl_log(LOG_ERROR, "Username or password is null\n");
		return NULL;
	}

	XLClient *lc = s_malloc0(sizeof(*lc));
	lc->username = s_strdup(username);
	lc->password = s_strdup(password);

	lc->cookies = s_malloc0(sizeof(*(lc->cookies)));

	/* Set msg_id */
	gettimeofday(&tv, NULL);
	v = tv.tv_usec;
	v = (v - v % 1000) / 1000;
	v = v % 10000 * 10000;
	lc->msg_id = v;

	xl_log(LOG_DEBUG, "Create a new client with username:%s, password:%s "
			"successfully\n", lc->username, lc->password);
	return lc;

failed:
	xl_client_free(lc);
	return NULL;
}

static void get_verify_code(LwqqClient *lc, LwqqErrorCode *err)
{
    LwqqHttpRequest *req;
    char url[512];
    char response[256];
    int ret;
    char chkuin[64];

    snprintf(url, sizeof(url), "%s%s?uin=%s&appid=%s", LWQQ_URL_CHECK_HOST,
             VCCHECKPATH, lc->username, APPID);
    req = lwqq_http_create_default_request(url, err);
    if (!req) {
        goto failed;
    }
    
    snprintf(chkuin, sizeof(chkuin), "chkuin=%s", lc->username);
    req->set_header(req, "Cookie", chkuin);
    ret = req->do_request(req, 0, NULL);
    if (ret) {
        *err = LWQQ_EC_NETWORK_ERROR;
        goto failed;
    }
    if (req->http_code != 200) {
        *err = LWQQ_EC_HTTP_ERROR;
        goto failed;
    }

    /**
     * 
	 * The http message body has two format:
	 *
	 * ptui_checkVC('1','9ed32e3f644d968809e8cbeaaf2cce42de62dfee12c14b74');
	 * ptui_checkVC('0','!LOB');
	 * The former means we need verify code image and the second
	 * parameter is vc_type.
	 * The later means we don't need the verify code image. The second
	 * parameter is the verify code. The vc_type is in the header
	 * "Set-Cookie".
	 */
    snprintf(response, sizeof(response), "%s", req->response);
    lwqq_log(LOG_NOTICE, "Get response verify code: %s\n", response);

    char *c = strstr(response, "ptui_checkVC");
    char *s;
    if (!c) {
        *err = LWQQ_EC_HTTP_ERROR;
        goto failed;
    }
    c = strchr(response, '\'');
    if (!c) {
        *err = LWQQ_EC_HTTP_ERROR;
        goto failed;
    }
    c++;
    lc->vc = s_malloc0(sizeof(*lc->vc));
    if (*c == '0') {
        /* We got the verify code. */
        
        /* Parse uin first */
        lc->vc->uin = parse_verify_uin(response);
        if (!lc->vc->uin)
            goto failed;
        
        s = c;
        c = strstr(s, "'");
        s = c + 1;
        c = strstr(s, "'");
        s = c + 1;
        c = strstr(s, "'");
        *c = '\0';

        lc->vc->type = s_strdup("0");
        lc->vc->str = s_strdup(s);

        /* We need get the ptvfsession from the header "Set-Cookie" */
        update_cookies(lc->cookies, req, "ptvfsession", 1);
        lwqq_log(LOG_NOTICE, "Verify code: %s\n", lc->vc->str);
    } else if (*c == '1') {
        /* We need get the verify image. */

        /* Parse uin first */
        lc->vc->uin = parse_verify_uin(response);
        s = c;
        c = strstr(s, "'");
        s = c + 1;
        c = strstr(s, "'");
        s = c + 1;
        c = strstr(s, "'");
        *c = '\0';
        lc->vc->type = s_strdup("1");
        // ptui_checkVC('1','7ea19f6d3d2794eb4184c9ae860babf3b9c61441520c6df0', '\x00\x00\x00\x00\x04\x7e\x73\xb2');
        lc->vc->str = s_strdup(s);
        *err = LWQQ_EC_LOGIN_NEED_VC;
        lwqq_log(LOG_NOTICE, "We need verify code image: %s\n", lc->vc->str);
    }
    
    lwqq_http_request_free(req);
    return ;
    
failed:
    lwqq_http_request_free(req);
}

char *lwqq_get_cookies(LwqqClient *lc)
{
    if (lc->cookies && lc->cookies->lwcookies) {
        return s_strdup(lc->cookies->lwcookies);
    }

    return NULL;
}

void lwqq_vc_free(LwqqVerifyCode *vc)
{
    if (vc) {
        s_free(vc->str);
        s_free(vc->type);
        s_free(vc->img);
        s_free(vc->uin);
        s_free(vc);
    }
}

static void cookies_free(LwqqCookies *c)
{
    if (c) {
        s_free(c->ptvfsession);
        s_free(c->ptcz);
        s_free(c->skey);
        s_free(c->ptwebqq);
        s_free(c->ptuserinfo);
        s_free(c->uin);
        s_free(c->ptisp);
        s_free(c->pt2gguin);
        s_free(c->verifysession);
        s_free(c->lwcookies);
        s_free(c);
    }
}

static void lwqq_categories_free(LwqqFriendCategory *cate)
{
    if (!cate)
        return ;

    s_free(cate->name);
    s_free(cate);
}

/** 
 * Free LwqqClient instance
 * 
 * @param client LwqqClient instance
 */
void lwqq_client_free(LwqqClient *client)
{
    LwqqBuddy *b_entry, *b_next;
    LwqqFriendCategory *c_entry, *c_next;
    LwqqGroup *g_entry, *g_next;

    if (!client)
        return ;

    /* Free LwqqVerifyCode instance */
    s_free(client->username);
    s_free(client->password);
    s_free(client->version);
    lwqq_vc_free(client->vc);
    cookies_free(client->cookies);
    s_free(client->clientid);
    s_free(client->seskey);
    s_free(client->cip);
    s_free(client->index);
    s_free(client->port);
    s_free(client->status);
    s_free(client->vfwebqq);
    s_free(client->psessionid);
    lwqq_buddy_free(client->myself);
        
    /* Free friends list */
    LIST_FOREACH_SAFE(b_entry, &client->friends, entries, b_next) {
        LIST_REMOVE(b_entry, entries);
        lwqq_buddy_free(b_entry);
    }

    /* Free categories list */
    LIST_FOREACH_SAFE(c_entry, &client->categories, entries, c_next) {
        LIST_REMOVE(c_entry, entries);
        lwqq_categories_free(c_entry);
    }

    
    /* Free groups list */
    LIST_FOREACH_SAFE(g_entry, &client->groups, entries, g_next) {
        LIST_REMOVE(g_entry, entries);
        lwqq_group_free(g_entry);
    }

    /* Free msg_list */
    lwqq_recvmsg_free(client->msg_list);
    s_free(client);
}

/************************************************************************/
/* LwqqBuddy API */

/** 
 * 
 * Create a new buddy
 * 
 * @return A LwqqBuddy instance
 */
LwqqBuddy *lwqq_buddy_new()
{
    LwqqBuddy *b = s_malloc0(sizeof(*b));
    return b;
}

/** 
 * Free a LwqqBuddy instance
 * 
 * @param buddy 
 */
void lwqq_buddy_free(LwqqBuddy *buddy)
{
    if (!buddy)
        return ;

    s_free(buddy->uin);
    s_free(buddy->qqnumber);
    s_free(buddy->face);
    s_free(buddy->occupation);
    s_free(buddy->phone);
    s_free(buddy->allow);
    s_free(buddy->college);
    s_free(buddy->reg_time);
    s_free(buddy->constel);
    s_free(buddy->blood);
    s_free(buddy->homepage);
    s_free(buddy->stat);
    s_free(buddy->country);
    s_free(buddy->city);
    s_free(buddy->personal);
    s_free(buddy->nick);
    s_free(buddy->long_nick);
    s_free(buddy->shengxiao);
    s_free(buddy->email);
    s_free(buddy->province);
    s_free(buddy->gender);
    s_free(buddy->mobile);
    s_free(buddy->vip_info);
    s_free(buddy->markname);
    s_free(buddy->flag);
    s_free(buddy->cate_index);
    s_free(buddy->client_type);
    
    s_free(buddy->status);
    
    s_free(buddy);
}

/** 
 * Find buddy object by buddy's uin member
 * 
 * @param lc Our Lwqq client object
 * @param uin The uin of buddy which we want to find
 * 
 * @return 
 */
LwqqBuddy *lwqq_buddy_find_buddy_by_uin(LwqqClient *lc, const char *uin)
{
    LwqqBuddy *buddy;
    
    if (!lc || !uin)
        return NULL;

    LIST_FOREACH(buddy, &lc->friends, entries) {
        if (buddy->uin && (strcmp(buddy->uin, uin) == 0))
            return buddy;
    }

    return NULL;
}

/* LwqqBuddy API END*/
/************************************************************************/

/** 
 * Create a new group
 * 
 * @return A LwqqGroup instance
 */
LwqqGroup *lwqq_group_new()
{
    LwqqGroup *g = s_malloc0(sizeof(*g));
    return g;
}

/** 
 * Free a LwqqGroup instance
 * 
 * @param group
 */
void lwqq_group_free(LwqqGroup *group)
{
    LwqqBuddy *m_entry, *m_next;
    if (!group)
        return ;

    s_free(group->name);
    s_free(group->gid);
    s_free(group->code);
    s_free(group->account);
    s_free(group->markname);
    s_free(group->face);
    s_free(group->memo);
    s_free(group->class);
    s_free(group->fingermemo);
    s_free(group->createtime);
    s_free(group->level);
    s_free(group->owner);
    s_free(group->flag);
    s_free(group->option);

    /* Free Group members list */
    LIST_FOREACH_SAFE(m_entry, &group->members, entries, m_next) {
        LIST_REMOVE(m_entry, entries);
        lwqq_buddy_free(m_entry);
    }
	
    s_free(group);
}


/** 
 * Find group object by group's gid member
 * 
 * @param lc Our Lwqq client object
 * @param uin The gid of group which we want to find
 * 
 * @return A LwqqGroup instance 
 */
LwqqGroup *lwqq_group_find_group_by_gid(LwqqClient *lc, const char *gid)
{
    LwqqGroup *group;
    
    if (!lc || !gid)
        return NULL;

    LIST_FOREACH(group, &lc->groups, entries) {
        if (group->gid && (strcmp(group->gid, gid) == 0))
            return group;
    }

    return NULL;
}

/** 
 * Find group member object by member's uin
 * 
 * @param group Our Lwqq group object
 * @param uin The uin of group member which we want to find
 * 
 * @return A LwqqBuddy instance 
 */
LwqqBuddy *lwqq_group_find_group_member_by_uin(LwqqGroup *group, const char *uin)
{
    LwqqBuddy *member;
    
    if (!group || !uin)
        return NULL;

    LIST_FOREACH(member, &group->members, entries) {
        if (member->uin && (strcmp(member->uin, uin) == 0))
            return member;
    }

    return NULL;
}
