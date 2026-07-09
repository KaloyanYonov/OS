#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <err.h>

int main(int argc, char *argv[]) {
    if (argc != 2) {
        errx(1, "usage: %s <filename>", argv[0]);
    }

    int fd[2];
    if (pipe(fd) == -1) {
        err(1, "pipe");
    }

    pid_t pid1 = fork();
    if (pid1 == -1) {
        err(1, "fork (cat)");
    }

    if (pid1 == 0) {
        
        if (dup2(fd[1], STDOUT_FILENO) == -1) {
            err(1, "dup2 (cat)");
        }
        close(fd[0]);
        close(fd[1]);

        execlp("cat", "cat", argv[1], NULL);
        err(1, "execlp cat");
    }

    pid_t pid2 = fork();
    if (pid2 == -1) {
        err(1, "fork (sort)");
    }

    if (pid2 == 0) {

        if (dup2(fd[0], STDIN_FILENO) == -1) {
            err(1, "dup2 (sort)");
        }
        close(fd[0]);
        close(fd[1]);

        execlp("sort", "sort", NULL);
        err(1, "execlp sort");
    }

    close(fd[0]);
    close(fd[1]);

    int status;
    if (waitpid(pid1, &status, 0) == -1) {
        err(1, "waitpid (cat)");
    }
    if (waitpid(pid2, &status, 0) == -1) {
        err(1, "waitpid (sort)");
    }

    return 0;
}
