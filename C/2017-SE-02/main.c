#include <fcntl.h>
#include <unistd.h>
#include <err.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

void copyFromFd(int fd, int *lineNum, int numbered, int *atLineStart) {
    uint8_t byte;
    ssize_t readSize;

    while ((readSize = read(fd, &byte, sizeof(byte))) > 0) {
        if (numbered && *atLineStart) {
            char buf[16];
            int len = snprintf(buf, sizeof(buf), "%d ", *lineNum);
            if (write(1, buf, len) == -1) {
                err(1, "write");
            }
            *lineNum = *lineNum + 1;
            *atLineStart = 0;
        }

        if (write(1, &byte, sizeof(byte)) == -1) {
            err(1, "write");
        }

        if (byte == '\n') {
            *atLineStart = 1;
        }
    }
    if (readSize == -1) {
        err(1, "read");
    }
}

int main(int argc, char *argv[]) {

    int numbered = 0;
    int firstFileArg = 1;

    if (argc > 1 && strcmp(argv[1], "-n") == 0) {
        numbered = 1;
        firstFileArg = 2;
    }

    int lineNum = 1;
    int atLineStart = 1;

    if (firstFileArg == argc) {
        copyFromFd(0, &lineNum, numbered, &atLineStart);
    } else {
        for (int i = firstFileArg; i < argc; ++i) {
            if (strcmp(argv[i], "-") == 0) {
                copyFromFd(0, &lineNum, numbered, &atLineStart);
            } else {
                int fd = open(argv[i], O_RDONLY);
                if (fd == -1) {
                    err(1, "open");
                }
                copyFromFd(fd, &lineNum, numbered, &atLineStart);
                close(fd);
            }
        }
    }

    return 0;
}
