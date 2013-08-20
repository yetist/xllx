#include "zero_server.h"
#include "zero_thread.h"
#include <sys/time.h>
#include <ev.h>
#include <assert.h>

void zero_sleep(int ms){
    struct timespec ts;
    ts.tv_sec = ms / 1000;
    ts.tv_nsec = (ms % 1000) * 1000L * 1000L;
    nanosleep(&ts,NULL);
}

zero_server* zero_server_create(int port){
    zero_server *srv = zero_new(zero_server,1);
    srv->port = port;
    srv->worker_len = WORKER_LEN;
    srv->ze_arbiter = zero_new(zero_arbiter_thread,1);
    srv->ze_workers = zero_new(zero_worker_thread,srv->worker_len);
    srv->init_count = 0;
    pthread_cond_init(&srv->cond,NULL);
    pthread_mutex_init(&srv->mutex,NULL);
    return srv;
}

boolean zero_server_start(zero_server *server){
    int i;
    for(i=0;i<server->worker_len;++i){
        zero_worker_init(&(server->ze_workers[i]));
        (server->ze_workers+i)->server = server;
    }
    for(i=0;i<server->worker_len;++i){
        zero_worker_start(&server->ze_workers[i]);
    }
    pthread_mutex_lock(&server->mutex);
    while(server->init_count < server->worker_len){
        pthread_cond_wait(&server->cond,&server->mutex);
    }
    pthread_mutex_unlock(&server->mutex);
    server->ze_arbiter->server = server;
    if(zero_arbiter_init(server->ze_arbiter)){
        zero_arbiter_start(server->ze_arbiter);
        return TRUE;
    }
    return FALSE;
}
