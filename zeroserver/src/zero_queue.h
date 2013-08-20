#ifndef ZERO_QUEUE_H_
#define ZERO_QUEUE_H_

#include "zero_common.h"

struct zero_queue_item {
    void *data;
    zero_queue_item *next;
};

struct zero_queue {
    zero_queue_item *head;
    zero_queue_item *tail;
    pthread_mutex_t mutex;
};


zero_queue_item *zero_queue_item_new();
void zero_queue_item_free(zero_queue_item *item);

zero_queue *zero_queue_new();

void zero_queue_push(zero_queue *queue,void *data);
void* zero_queue_pop(zero_queue *queue);

#endif
