#include <ev.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>
#include <pthread.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/eventfd.h>
#include "zero_thread.h"
#include "zero_queue.h"

#include "message.h"

void sock_set_non_block(int fd){
    int flags;
    flags = fcntl(fd,F_GETFL);
    flags |= O_NONBLOCK;
    fcntl(fd,F_SETFL,flags);
}

static void arbiter_conn_cb(struct ev_loop *l,struct ev_io *watcher,int revents){
    zero_arbiter_thread *th = watcher->data;
    int cfd;
    if((cfd = accept(th->sockfd,NULL,NULL)) == -1){
        perror("accept error");
        return;
    }
    sock_set_non_block(cfd);
    int idx;
    idx = (th->last_thread + 1) % (th->server->worker_len);
    th->last_thread = idx;
    zero_worker_thread *worker = th->server->ze_workers + idx;
    zero_queue_push(worker->queue,INT_TO_POINTER(cfd));
    uint64_t n = 1;
    write(worker->notify_fd,&n,sizeof(n));
}

static void worker_notify_cb(struct ev_loop *l,struct ev_io *watcher,int revents){
    zero_worker_thread *worker = watcher->data;
    uint64_t n;
    read(worker->notify_fd,&n,sizeof(n));
    if (n != 1){
        perror("notify data error");
    }

    // we can handle the client sock here
    //
    int cfd = POINTER_TO_INT(zero_queue_pop(worker->queue));
    printf("cfd=%d\n", cfd);
    serve_message(cfd);
#if 0
    char buf[1024];
    int size = read(cfd,buf,sizeof(buf));
    if (size < 0)
    {
        perror("read error\n");
    }

    printf("i got the data %s\n",buf);
    char *list = get_plugin_list();
	
   // printf("list is %s\n", list);

    write(cfd,list,strlen(list));

    //write(cfd,buf,sizeof(buf));
    close(cfd);
#endif
}

static void* worker_thread_handler(void* data){
    zero_worker_thread *th = data;
    pthread_mutex_lock(&(th->server->mutex));
    th->server->init_count++;
    pthread_cond_signal(&(th->server->cond));
    pthread_mutex_unlock(&(th->server->mutex));
    th->worker_id = pthread_self();
    ev_run(th->loop,0);
    return NULL;
}

static void* arbiter_thread_handler(void* data){
    zero_arbiter_thread *th = data;
    th->arbiter_id = pthread_self();
    ev_run(th->loop,0);
    return NULL;
}

boolean zero_arbiter_init(zero_arbiter_thread *th){
    assert(th!=NULL);
    int port = th->server->port;
    
    struct sockaddr_in addr;
    memset(&addr,0,sizeof(addr));
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);

    int sock = socket(AF_INET,SOCK_STREAM,0);
    int flag = 1;
    setsockopt(sock,SOL_SOCKET,SO_KEEPALIVE,&flag,sizeof(flag));
    setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&flag,sizeof(flag));

    if(bind(sock,(struct sockaddr*) &addr,sizeof(addr)) == -1){
        perror("bind");
        return FALSE;
    }
    
    if(listen(sock,BACKLOG) == -1){
        perror("listen");
        return FALSE;
    }
    sock_set_non_block(sock);
    th->sockfd = sock;
    th->last_thread = -1;
    th->loop = ev_loop_new(0);
    th->watcher.data = th;
    ev_io_init(&th->watcher,arbiter_conn_cb,sock,EV_READ);
    ev_io_start(th->loop,&th->watcher);
    return TRUE;
}

boolean zero_arbiter_start(zero_arbiter_thread *th){
    pthread_t pid;
    int ret = pthread_create(&pid,NULL,arbiter_thread_handler,th);
    if (ret == -1){
        perror("create arbiter thread error");
        return FALSE;
    }
    return TRUE;
}

void zero_worker_init(zero_worker_thread *th){
    th->loop = ev_loop_new(0);
    th->notify_fd = eventfd(0,0);
    th->queue = zero_queue_new();
    th->watcher.data = th;
    ev_io_init(&th->watcher,worker_notify_cb,th->notify_fd,EV_READ);
    ev_io_start(th->loop,&th->watcher);
}

void zero_worker_start(zero_worker_thread *th){
    pthread_t pid;
    pthread_create(&pid,NULL,worker_thread_handler,th);
}
