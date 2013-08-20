#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import sys
import struct
import time
import binascii
from pprint import pprint

#HeaderId
(
        MGS_UNKNOWN,
        MGS_LIST,
        MGS_SEARCH,
        MGS_DOWNLOAD,
        MGS_PLUGIN_INFO,
        MGS_SEARCH_INFO,
        MGS_MOVIEDB_INFO,
        MGS_DOWNLOAD_INFO
) = range(8)

#PluginType;
(
        PLUGIN_TYPE_LYRIC,
        PLUGIN_TYPE_SUBTITLE,
        PLUGIN_TYPE_MOVIEDB,
) = range(3)

def conn():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('localhost', 1989))
    return sock

def list_plugin_requ(t):
    sock = conn()
    # HeaderId, PluginType, language 
    msg = struct.pack("@ii20s", MGS_LIST, t, "zh_cn");
    m = sock.send(msg)

    header = struct.Struct('@i')
    data = sock.recv(header.size)
    header_id, = header.unpack(data)

    plugins = []
    if header_id == MGS_PLUGIN_INFO:
        # type, count
        pr = struct.Struct('@ii')
        data = sock.recv(pr.size)
        pr_type, pr_count = pr.unpack(data)
        # pid, name, version, author, email, platform, icon, description
        pinfo = struct.Struct('@256s256s16s16s256s16s16s512s')
        n = pr_count
        while n > 0:
            data = sock.recv(pinfo.size)
            pid, name, version, author, email, platform, icon, description = pinfo.unpack(data)
            item = {'pid':pid.rstrip('\x00'),
            'name':name.rstrip('\x00'), 
            'version':version.rstrip('\x00'),
            'author':author.rstrip('\x00'),
            'email':email.rstrip('\x00'),
            'platform':platform.rstrip('\x00'),
            'icon':icon.rstrip('\x00'),
            'description':description.rstrip('\x00')
            }
            plugins.append(item)
            n = n -1
    sock.close()
    return plugins

def search_lyrics(pid, title, artist=""):
    sock = conn()
    # HeaderId, PluginType, pid, title, artist
    msg = struct.pack("@ii256s256s256s", MGS_SEARCH, PLUGIN_TYPE_LYRIC, pid, title, artist)
    m = sock.send(msg)

    # HeaderId
    header = struct.Struct('@i')
    data = sock.recv(header.size)
    header_id, = header.unpack(data)
    plugins = []
    if header_id == MGS_SEARCH_INFO:
        # pid, count
        sr = struct.Struct('@256si')
        data = sock.recv(sr.size)
        sr_pid, sr_count = sr.unpack(data)
        #title, pid, url
        pinfo = struct.Struct('@256s256s512s')
        n = sr_count
        while n > 0:
            data = sock.recv(pinfo.size)
            title, pid, url = pinfo.unpack(data)
            item = {
                    'title':title.rstrip('\x00'),
                    'pid':pid.rstrip('\x00'), 
                    'url':url.rstrip('\x00'),
                    }
            plugins.append(item)
            n = n -1
    sock.close()
    return plugins

def download_lyrics(pid, url):
    sock = conn()
    # HeaderId, PluginType, pid, title, artist
    msg = struct.pack("@ii256s256s", MGS_DOWNLOAD, PLUGIN_TYPE_LYRIC, pid, url)
    m = sock.send(msg)

    # HeaderId
    header = struct.Struct('@i')
    data = sock.recv(header.size)
    header_id, = header.unpack(data)
    sr_path = ""
    if header_id == MGS_DOWNLOAD_INFO:
        # pid, count
        sr = struct.Struct('@256s')
        data = sock.recv(sr.size)
        sr_path = sr.unpack(data)
    sock.close()
    return sr_path

if __name__ == "__main__":
    s = list_plugin_requ(PLUGIN_TYPE_LYRIC)
    print("========== Lyric plugins ==========")
    pprint(s)
    m = search_lyrics('addon.meta.lyric.lrc123', '童话', '光良')
    print("========== search lyric for 童年 ==========")
    pprint(m)
    print m[0]['title'], m[0]['url']
    n = search_lyrics(m[0]['pid'], m[0]['url'])
    print n
    #list_plugin_requ(PLUGIN_TYPE_SUBTITLE)
    #list_plugin_requ(PLUGIN_TYPE_MOVIEDB)
