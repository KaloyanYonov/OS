#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <err.h>

#define BUFFER_SIZE 4096

struct Record
{
    uint32_t P;
    uint32_t N;
};

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        errx(1, "bad arguments");
    }

    int fd1 = open(argv[1], O_RDONLY);
    if (fd1 == -1)
    {
        err(1, "bad read file");
    }

    int fd2 = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd2 == -1)
    {
        err(1, "bad write file");
    }

    struct Record record;
    ssize_t readSize;
    char buffer[BUFFER_SIZE];

    while ((readSize = read(fd1, &record, sizeof(record))) > 0)
    {
        if (readSize != sizeof(record))
        {
            errx(1, "corrupt input file (partial header)");
        }

        if (lseek(fd2, (off_t)record.P, SEEK_SET) == -1)
        {
            err(1, "bad lseek");
        }

        uint32_t remaining = record.N;
        while (remaining > 0)
        {
            size_t chunk = remaining < BUFFER_SIZE ? remaining : BUFFER_SIZE;

            ssize_t dataRead = read(fd1, buffer, chunk);
            if (dataRead == -1)
            {
                err(1, "read data");
            }
            if (dataRead == 0)
            {
                errx(1, "unexpected EOF in data section");
            }

            ssize_t written = 0;
            while (written < dataRead)
            {
                ssize_t w = write(fd2, buffer + written, dataRead - written);
                if (w == -1)
                {
                    err(1, "write");
                }
                written += w;
            }

            remaining -= dataRead;
        }
    }

    if (readSize == -1)
    {
        err(1, "read header");
    }

    close(fd1);
    close(fd2);

    return 0;
}
