#ifndef ZERO_SERVER_H_
#define ZERO_SERVER_H_

#include "zero_common.h"
#include <pthread.h>

struct zero_server {
    int     port;
    int     sockfd;
    zero_arbiter_thread *ze_arbiter;
    zero_worker_thread  *ze_workers;
    pthread_cond_t      cond;
    pthread_mutex_t     mutex;
    int worker_len;
    int init_count;
};

zero_server* zero_server_create(int port);
boolean zero_server_start(zero_server *server);
void zero_sleep(int ms);

#endif
