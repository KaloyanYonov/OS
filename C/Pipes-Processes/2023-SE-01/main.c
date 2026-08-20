#include <unistd.h>
#include <err.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAX_PARALLEL 16

struct pending {
    pid_t pid;
    int fd;
    char name[4096];
};

int main(int argc, char *argv[]){

    if (argc != 2) {
        errx(1, "usage: %s <directory>", argv[0]);
    }

    int fd[2];
    if (pipe(fd) == -1) {
        err(1, "pipe");
    }

    pid_t pid = fork();
    if (pid == -1) {
        err(1, "fork");
    }

    if (pid == 0) {
        if (dup2(fd[1], 1) == -1) {
            err(1, "dup2");
        }
        close(fd[0]);
        close(fd[1]);
        execlp("find", "find", argv[1], "-type", "f", "!", "-name", "*.hash", (char *)NULL);
        err(1, "execlp");
    }

    close(fd[1]);

    struct pending jobs[MAX_PARALLEL];
    int njobs = 0;

    char buf[4096];
    char linebuf[4096];
    int linelen = 0;

    ssize_t n;
    while ((n = read(fd[0], buf, sizeof(buf))) > 0) {

        for (int i = 0; i < n; ++i) {
            if (buf[i] != '\n') {
                linebuf[linelen++] = buf[i];
            } 
	    else {
                linebuf[linelen] = '\0';
                linelen = 0;

                if (njobs == MAX_PARALLEL) {
                    int j = njobs - 1;
                    char hashbuf[128];
                    int hashlen = 0;
                    char tmp[4096];
                    ssize_t m;

                    while ((m = read(jobs[j].fd, tmp, sizeof(tmp))) > 0) {
                        for (int k = 0; k < m; ++k) {
                            if (hashlen < 32) {
                                hashbuf[hashlen++] = tmp[k];
                            }
                        }
                    }
                    if (m == -1) {
                        err(1, "read");
                    }
                    close(jobs[j].fd);

                    int status;
                    if (waitpid(jobs[j].pid, &status, 0) == -1) {
                        err(1, "waitpid");
                    }

                    char outpath[4200];
                    snprintf(outpath, sizeof(outpath), "%s.hash", jobs[j].name);

                    int outfd = open(outpath, O_WRONLY | O_CREAT | O_TRUNC, 0644);
                    if (outfd == -1) {
                        err(1, "open");
                    }
                    if (write(outfd, hashbuf, hashlen) == -1) {
                        err(1, "write");
                    }
                    close(outfd);

                    njobs--;
                }

                int mdfd[2];
                if (pipe(mdfd) == -1) {
                    err(1, "pipe");
                }
                pid_t mdpid = fork();
                if (mdpid == -1) {
                    err(1, "fork");
                }
                if (mdpid == 0) {
                    if (dup2(mdfd[1], 1) == -1) {
                        err(1, "dup2");
                    }
                    close(mdfd[0]);
                    close(mdfd[1]);
                    execlp("md5sum", "md5sum", linebuf, (char *)NULL);
                    err(1, "execlp");
                }

                close(mdfd[1]);

                jobs[njobs].pid = mdpid;
                jobs[njobs].fd = mdfd[0];
                strcpy(jobs[njobs].name, linebuf);
                njobs++;
            }
        }
    }
    if (n == -1) {
        err(1, "read");
    }
    close(fd[0]);

    int find_status;
    if (waitpid(pid, &find_status, 0) == -1) {
        err(1, "waitpid");
    }

    while (njobs > 0) {
        int j = njobs - 1;
        char hashbuf[128];
        int hashlen = 0;
        char tmp[4096];
        ssize_t m;

        while ((m = read(jobs[j].fd, tmp, sizeof(tmp))) > 0) {
            for (int k = 0; k < m; ++k) {
                if (hashlen < 32) {
                    hashbuf[hashlen++] = tmp[k];
                }
            }
        }
        if (m == -1) {
            err(1, "read");
        }
        close(jobs[j].fd);

        int status;
        if (waitpid(jobs[j].pid, &status, 0) == -1) {
            err(1, "waitpid");
        }

        char outpath[4200];
        snprintf(outpath, sizeof(outpath), "%s.hash", jobs[j].name);

        int outfd = open(outpath, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (outfd == -1) {
            err(1, "open");
        }
        if (write(outfd, hashbuf, hashlen) == -1) {
            err(1, "write");
        }
        close(outfd);

        njobs--;
    }

    return 0;
}
