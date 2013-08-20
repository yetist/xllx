#ifndef ZERO_COMMON_H_
#define ZERO_COMMON_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define WORKER_LEN 4
#define BACKLOG 512
#define zero_new(struct_type, n_structs)  ((struct_type * ) malloc((n_structs)*sizeof (struct_type )))
#ifndef FALSE
#define FALSE (0)
#endif

#ifndef TRUE
#define TRUE    (!FALSE)
#endif

#define POINTER_TO_INT(p) ((int)  (long) (p))
#define INT_TO_POINTER(i) ((pointer) (long) (i))

typedef int boolean;
typedef void* pointer;
typedef struct zero_server          zero_server;
typedef struct zero_arbiter_thread  zero_arbiter_thread;
typedef struct zero_worker_thread   zero_worker_thread;
typedef struct zero_queue_item      zero_queue_item;
typedef struct zero_queue           zero_queue;

#endif
