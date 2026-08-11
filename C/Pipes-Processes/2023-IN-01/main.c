#include <err.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

#define MAX_PROC 8
#define WORD_LEN 4

int main(int argc, char *argv[])
{
    if (argc != 3) {
        errx(1, "Usage: %s NC WC", argv[0]);
    }

    // strtol wants long ....
    long NC = strtol(argv[1], NULL, 10);
    long WC = strtol(argv[2], NULL, 10);

    if (NC < 1 || NC > 7) {
        errx(1, "Child processes must be between 1 and 7");
    }
    if (WC < 1 || WC > 35) {
        errx(1, "Word count must be between 1 and 35");
    }

    const char *words[3] = { "tic ", "tac ", "toe\n" };
    int total = (int)NC + 1; 

    int pipes[MAX_PROC][2];
    for (int i = 0; i < total; i++) {
        if (pipe(pipes[i]) == -1) {
            err(1, "pipe");
        }
    }

    int idx = 0;        
    for (int i = 1; i <= NC; i++) {
        pid_t pid = fork();
        if (pid == -1) {
            err(1, "fork");
        }
        if (pid == 0) {
            idx = i;
            break;
        }
    }

    int next = (idx + 1) % total; 

    for (int i = 0; i < total; i++) {
        if (i != idx) {
            close(pipes[i][0]);
        }
        if (i != next) {
            close(pipes[i][1]);
        }
    }

    for (long t = idx; t < WC; t += total) {
        if (t != 0) {
            char buf;
            if (read(pipes[idx][0], &buf, 1) != 1) {
                errx(1, "pipe read failed");
            }
        }

        if (write(1, words[t % 3], WORD_LEN) != WORD_LEN) {
            err(1, "write");
        }

        if (t != WC - 1) {
            char buf = 1;
            if (write(pipes[next][1], &buf, 1) != 1) {
                errx(1, "pipe write failed");
            }
        }
    }

    close(pipes[idx][0]);
    close(pipes[next][1]);

    if (idx == 0) {
        for (int i = 0; i < NC; i++) {
            wait(NULL);
        }
    }

    return 0;
}
