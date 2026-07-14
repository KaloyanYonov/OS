#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <err.h>

// cat /etc/passwd | cut -d':' -f7 | sort | uniq -c | sort -n

int main(void)
{
    int p1[2], p2[2], p3[2], p4[2];

    if (pipe(p1) == -1) { err(1, "pipe p1 failed"); }
    if (pipe(p2) == -1) { err(1, "pipe p2 failed"); }
    if (pipe(p3) == -1) { err(1, "pipe p3 failed"); }
    if (pipe(p4) == -1) { err(1, "pipe p4 failed"); }

    pid_t pid1 = fork();
    if (pid1 == -1) { err(1, "fork failed"); }
    if (pid1 == 0)
    {
        dup2(p1[1], 1);
        close(p1[0]);
        close(p1[1]);
        close(p2[0]); close(p2[1]);
        close(p3[0]); close(p3[1]);
        close(p4[0]); close(p4[1]);

        execl("/bin/cat", "cat", "/etc/passwd", (char *)NULL);
        err(1, "execl cat failed");
    }

    pid_t pid2 = fork();
    if (pid2 == -1) { err(1, "fork failed"); }
    if (pid2 == 0)
    {
        dup2(p1[0], 0);
        dup2(p2[1], 1);
        close(p1[0]); close(p1[1]);
        close(p2[0]); close(p2[1]);
        close(p3[0]); close(p3[1]);
        close(p4[0]); close(p4[1]);

        execl("/bin/cut", "cut", "-d:", "-f7", (char *)NULL);
        err(1, "execl cut failed");
    }

    pid_t pid3 = fork();
    if (pid3 == -1) { err(1, "fork failed"); }
    if (pid3 == 0)
    {
        dup2(p2[0], 0);
        dup2(p3[1], 1);
        close(p1[0]); close(p1[1]);
        close(p2[0]); close(p2[1]);
        close(p3[0]); close(p3[1]);
        close(p4[0]); close(p4[1]);

        execl("/bin/sort", "sort", (char *)NULL);
        err(1, "execl sort failed");
    }

    pid_t pid4 = fork();
    if (pid4 == -1) { err(1, "fork failed"); }
    if (pid4 == 0)
    {
        dup2(p3[0], 0);
        dup2(p4[1], 1);
        close(p1[0]); close(p1[1]);
        close(p2[0]); close(p2[1]);
        close(p3[0]); close(p3[1]);
        close(p4[0]); close(p4[1]);

        execl("/bin/uniq", "uniq", "-c", (char *)NULL);
        err(1, "execl uniq failed");
    }

    pid_t pid5 = fork();
    if (pid5 == -1) { err(1, "fork failed"); }
    if (pid5 == 0)
    {
        dup2(p4[0], 0);
        close(p1[0]); close(p1[1]);
        close(p2[0]); close(p2[1]);
        close(p3[0]); close(p3[1]);
        close(p4[0]); close(p4[1]);

        execl("/bin/sort", "sort", "-n", (char *)NULL);
        err(1, "execl sort -n failed");
    }

    close(p1[0]); close(p1[1]);
    close(p2[0]); close(p2[1]);
    close(p3[0]); close(p3[1]);
    close(p4[0]); close(p4[1]);

    int status;
    waitpid(pid1, &status, 0);
    waitpid(pid2, &status, 0);
    waitpid(pid3, &status, 0);
    waitpid(pid4, &status, 0);
    waitpid(pid5, &status, 0);

    return 0;
}
