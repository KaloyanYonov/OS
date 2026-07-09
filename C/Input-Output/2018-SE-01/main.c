#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <err.h>

int findChar(char *set, char c) {
    for (int i = 0; i < strlen(set); ++i) {
        if (set[i] == c) {
            return i;
        }
    }
    return -1;
}

int main(int argc, char* argv[]) {

    if (argc != 3) {
        errx(1, "bad args");
    }

    if (strcmp(argv[1], "-s") == 0) {
        char *str1 = argv[2];
        uint8_t byte;
        ssize_t readSize;
        int previousByte = -1;

        while ((readSize = read(0, &byte, sizeof(byte))) > 0) {
            int isRepeatInSet = (byte == previousByte && findChar(str1, byte) != -1);

            if (!isRepeatInSet) {
                if (write(1, &byte, sizeof(byte)) == -1) {
                    err(1, "write");
                }
            }
            previousByte = byte;
        }
        if (readSize == -1) {
            err(1, "read");
        }
    }
    else if (strcmp(argv[1], "-d") == 0) {
        char *str1 = argv[2];
        uint8_t byte;
        ssize_t readSize;

        while ((readSize = read(0, &byte, sizeof(byte))) > 0) {
            if (findChar(str1, byte) == -1) {
                if (write(1, &byte, sizeof(byte)) == -1) {
                    err(1, "write");
                }
            }
        }
        if (readSize == -1) {
            err(1, "read");
        }
    }
    else {
        char *str1 = argv[1];
        char *str2 = argv[2];

        if (strlen(str1) != strlen(str2)) {
            errx(1, "different string lengths");
        }

        uint8_t byte;
        ssize_t readSize;

        while ((readSize = read(0, &byte, sizeof(byte))) > 0) {
            int idx = findChar(str1, byte);
            if (idx != -1) {
                byte = str2[idx];
            }
            if (write(1, &byte, sizeof(byte)) == -1) {
                err(1, "write");
            }
        }
        if (readSize == -1) {
            err(1, "read");
        }
    }

    return 0;
}
