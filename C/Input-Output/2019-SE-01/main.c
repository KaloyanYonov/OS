#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <err.h>
#include <stdint.h>
#include <stdio.h>

struct User {
    uint32_t uid;
    uint16_t reserved1;
    uint16_t reserved2;
    uint32_t startSession;
    uint32_t endSession;
};

int main(int argc, char* argv[]) {

    if (argc != 2) {
        errx(1, "bad args");
    }

    int fd = open(argv[1], O_RDONLY);
    if (fd == -1) {
        err(1, "fd");
    }

    struct stat st;
    if (fstat(fd, &st) == -1) {
        err(1, "fstat");
    }
    if (st.st_size % sizeof(struct User) != 0) {
        errx(1, "bad file size");
    }

    struct User users[16384];
    int userCount = 0;

    struct User user;
    ssize_t readSize;
    while ((readSize = read(fd, &user, sizeof(user))) > 0) {
        users[userCount] = user;
        userCount++;
    }
    if (readSize == -1) {
        err(1, "read");
    }
    close(fd);

    uint64_t sum = 0;
    for (int i = 0; i < userCount; i++) {
        uint32_t duration = users[i].endSession - users[i].startSession;
        sum += duration;
    }
    double mean = (double)sum / userCount;

    double varianceSum = 0;
    for (int i = 0; i < userCount; i++) {
        uint32_t duration = users[i].endSession - users[i].startSession;
        double diff = (double)duration - mean;
        varianceSum += diff * diff;
    }
    double D = varianceSum / userCount;

    uint32_t uniqueUids[2048];
    uint32_t maxDuration[2048];
    int uniqueCount = 0;

    for (int i = 0; i < userCount; i++) {

        uint32_t duration = users[i].endSession - users[i].startSession;
        int found = -1;

        for (int j = 0; j < uniqueCount; j++) {
            if (uniqueUids[j] == users[i].uid) {
                found = j;
                break;
            }
        }

        if (found == -1) {
            uniqueUids[uniqueCount] = users[i].uid;
            maxDuration[uniqueCount] = duration;
            uniqueCount++;
        } else {

            if (duration > maxDuration[found]) {
                maxDuration[found] = duration;
            }
        }
    }

    for (int i = 0; i < uniqueCount; i++) {
        uint64_t squared = (uint64_t)maxDuration[i] * (uint64_t)maxDuration[i];

        if ((double)squared > D) {
            char buf[64];
            int len = snprintf(buf, sizeof(buf), "%u %u\n", uniqueUids[i], maxDuration[i]);
            write(1, buf, len);
        }
    }

    return 0;
}
