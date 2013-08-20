#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

#include "zero_server.h"

int main(int argc,char **argv){
    /* Our process ID and Session ID */
    pid_t pid, sid;
    
#if 0
    /* Fork off the parent process */
    pid = fork();
    if (pid < 0) {
            exit(EXIT_FAILURE);
    }
    /* If we got a good PID, then
        we can exit the parent process. */
    if (pid > 0) {
            exit(EXIT_SUCCESS);
    }
    /* Change the file mode mask */
    umask(0);
            
    /* Open any logs here */        
            
    /* Create a new SID for the child process */
    sid = setsid();
    if (sid < 0) {
            /* Log the failure */
            exit(EXIT_FAILURE);
    }
    

    
    /* Change the current working directory */
    if ((chdir("/")) < 0) {
            /* Log the failure */
            exit(EXIT_FAILURE);
    }
    
    /* Close out the standard file descriptors */
    //close(STDIN_FILENO);
    close(STDOUT_FILENO);
    //close(STDERR_FILENO);
#endif

    zero_server *server = zero_server_create(1989);

    if(!zero_server_start(server)) 
        exit(1);

    for(;;){
        zero_sleep(2000);
    }
    exit(0);
}
