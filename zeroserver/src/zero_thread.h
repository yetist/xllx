#include "zero_server.h"
#include "zero_common.h"
#include <pthread.h>
#include <ev.h>

struct zero_arbiter_thread {
    pthread_t       arbiter_id;
    int             sockfd;
    int             last_thread;
    struct  ev_loop *loop;
    struct  ev_io   watcher;
    zero_server     *server;
};

struct zero_worker_thread {
    pthread_t       worker_id;
    int             notify_fd;
    struct  ev_loop *loop;
    struct  ev_io   watcher;
    zero_queue      *queue;
    zero_server     *server;
};

boolean zero_arbiter_init(zero_arbiter_thread *th);
boolean zero_arbiter_start(zero_arbiter_thread *th);

void zero_worker_init(zero_worker_thread *th);
void zero_worker_start(zero_worker_thread *th);

