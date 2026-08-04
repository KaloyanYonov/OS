#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <err.h>

// find + sort + tail + cut -> 3 pipes

int main(int argc, char* argv[]) {

    if (argc != 2) {
        errx(1, "Usage: %s <directory>", argv[0]);
    }

    int pipe1[2], pipe2[2], pipe3[2];

    if (pipe(pipe1) == -1){ 
	    err(1, "pipe1 failed");
    }
    if (pipe(pipe2) == -1){
	    err(1, "pipe2 failed");
    }
    if (pipe(pipe3) == -1){
	    err(1, "pipe3 failed");
    }

    pid_t pid;

    pid = fork();
    if (pid == -1){
	    err(1, "fork failed");
    }
    if (pid == 0) {
        dup2(pipe1[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        close(pipe3[0]); close(pipe3[1]);
        execlp("find", "find", argv[1], "-type", "f", "-printf", "%T@ %p\n", NULL);
        err(1, "execlp find failed");
    }

    pid = fork();
    if (pid == -1)
    {
	    err(1, "fork failed");
    }
    if (pid == 0) {
        dup2(pipe1[0], STDIN_FILENO);
        dup2(pipe2[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        close(pipe3[0]); close(pipe3[1]);
        execlp("sort", "sort", "-n", NULL);
        err(1, "execlp sort failed");
    }

    
    pid = fork();
    if (pid == -1) err(1, "fork failed");
    if (pid == 0) {
        dup2(pipe2[0], STDIN_FILENO);
        dup2(pipe3[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        close(pipe3[0]); close(pipe3[1]);
        execlp("tail", "tail", "-n", "1", NULL);
        err(1, "execlp tail failed");
    }

    pid = fork();
    if (pid == -1) err(1, "fork failed");
    if (pid == 0) {
        dup2(pipe3[0], STDIN_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        close(pipe3[0]); close(pipe3[1]);
        execlp("cut", "cut", "-d", " ", "-f2-", NULL);
        err(1, "execlp cut failed");
    }

    close(pipe1[0]); close(pipe1[1]);
    close(pipe2[0]); close(pipe2[1]);
    close(pipe3[0]); close(pipe3[1]);

    int status;
    for (int i = 0; i < 4; i++) {
        wait(&status);
    }

    return 0;
}
