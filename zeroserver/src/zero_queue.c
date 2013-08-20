#include "zero_queue.h"
#include <pthread.h>


#define FREE_ITEM_LEN 256

static pthread_mutex_t free_list_locker = PTHREAD_MUTEX_INITIALIZER;
static zero_queue_item *free_item_list;

zero_queue_item *zero_queue_item_new() {
    zero_queue_item *item = NULL;
    if(free_item_list != NULL){
        pthread_mutex_lock(&free_list_locker);
        item = free_item_list;
        free_item_list = free_item_list->next;
        pthread_mutex_unlock(&free_list_locker);
    }
    if (item == NULL){
        item = zero_new(zero_queue_item,FREE_ITEM_LEN);
        if (item == NULL)
            return NULL;
        int i;
        for(i=2;i<FREE_ITEM_LEN;i++){
            item[i - 1].next = item + i;
        }
        pthread_mutex_lock(&free_list_locker);
        item[FREE_ITEM_LEN - 1].next = free_item_list;
        free_item_list = item + 1;
        pthread_mutex_unlock(&free_list_locker);
    }
    return item;
}

void zero_queue_item_free(zero_queue_item *item){
    pthread_mutex_lock(&free_list_locker);
    if (free_item_list != NULL){
        item->next = free_item_list;
    } else {
        item->next = NULL;
    }
    free_item_list = item;
    pthread_mutex_unlock(&free_list_locker);
}

zero_queue *zero_queue_new(){
    zero_queue *q = zero_new(zero_queue,1);
    q->head = NULL;
    q->tail = NULL;
    pthread_mutex_init(&q->mutex,NULL);
    return q;
}

void zero_queue_push(zero_queue *queue,void *data){
    zero_queue_item *item = zero_queue_item_new();
    item->data = data;
    item->next = NULL;
    pthread_mutex_lock(&queue->mutex);
    if(queue->tail != NULL){
        queue->tail->next = item;
    } else {
        queue->head = item;
    }
    queue->tail = item;
    pthread_mutex_unlock(&queue->mutex);
}

void *zero_queue_pop(zero_queue *queue){
    zero_queue_item *item = NULL;
    pthread_mutex_lock(&queue->mutex);
    item = queue->head;
    if (item != NULL){
        queue->head = item->next;
        if(item->next ==NULL){
            queue->tail = NULL;
        }
    }
    pthread_mutex_unlock(&queue->mutex);
    if(item){
        zero_queue_item_free(item);
        return item->data;
    } else {
        return NULL;
    }
}
