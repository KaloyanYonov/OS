#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <err.h>

#define MAX_CMD 64
#define MAX_PATH 256

int main(void)
{
    char command[MAX_CMD];
    char path[MAX_PATH];
    char prompt[] = "$ ";

    while (1)
    {
        write(1, prompt, strlen(prompt));

        int pos = 0;
        ssize_t readSize;
        char c;
        int gotEOF = 0;

        while (pos < MAX_CMD - 1)
        {
            readSize = read(0, &c, 1);
            if (readSize == -1)
            {
                err(1, "read failed");
            }
            if (readSize == 0)
            {
                gotEOF = 1;
                break;
            }
            if (c == '\n')
            {
                break;
            }
            command[pos] = c;
            pos++;
        }
        command[pos] = '\0';

        if (gotEOF == 1 && pos == 0)
        {
            break;
        }

        if (pos == 0)
        {
            continue;
        }

        if (strcmp(command, "exit") == 0)
        {
            break;
        }

        int pathLen = snprintf(path, sizeof(path), "/bin/%s", command);
        if (pathLen < 0 || pathLen >= (int)sizeof(path))
        {
            errx(1, "command name too long");
        }

        pid_t pid = fork();
        if (pid == -1)
        {
            err(1, "fork failed");
        }

        if (pid == 0)
        {
            execl(path, command, (char *)NULL);
            err(1, "execl failed");
        }
        else
        {
            int status;
            waitpid(pid, &status, 0);
        }
    }

    return 0;
}
