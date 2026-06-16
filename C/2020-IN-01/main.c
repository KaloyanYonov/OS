#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <err.h>
#include <sys/stat.h>

struct Header {
    uint32_t magic;
    uint8_t headerVersion;
    uint8_t dataVersion;
    uint16_t count;
    uint32_t reserved1;
    uint32_t reserved2;
} __attribute__((packed));

struct RecordV0 {
    uint16_t offset;
    uint8_t original_byte;
    uint8_t new_byte;
} __attribute__((packed));

struct RecordV1 {
    uint32_t offset;
    uint16_t original_word;
    uint16_t new_word;
} __attribute__((packed));

int main(int argc, char* argv[]) {

    if (argc != 4) {
        errx(1, "Bad arguments");
    }

    int patch = open(argv[1], O_RDONLY);
    if (patch == -1) { err(1, "bad patch file"); }

    int f1 = open(argv[2], O_RDONLY);
    if (f1 == -1) { err(1, "bad f1 file"); }

    int f2 = open(argv[3], O_RDWR | O_TRUNC | O_CREAT, 0666);
    if (f2 == -1) { err(1, "bad f2 file"); }

    struct stat st;
    struct stat st2;
    if (fstat(patch, &st) == -1) { err(1, "fstat - patch"); }
    if (fstat(f1, &st2) == -1) { err(1, "fstat - f1"); }

    struct Header header;
    ssize_t readSize = read(patch, &header, sizeof(header));
    if (readSize != sizeof(header)) {
        errx(1, "bad size");
    }
    if (header.magic != 0xDEADBEEF) {
        errx(1, "Magic number is incorrect");
    }
    if (header.headerVersion != 0x01) {
        errx(1, "Incorrect header version");
    }

    if (header.dataVersion == 0x00) {
        size_t expected = sizeof(header) + (size_t)header.count * sizeof(struct RecordV0);
        if ((size_t)st.st_size != expected) {
            errx(1, "bad patch file size");
        }
    }
    else if (header.dataVersion == 0x01) {
        size_t expected = sizeof(header) + (size_t)header.count * sizeof(struct RecordV1);
        if ((size_t)st.st_size != expected) {
            errx(1, "bad patch file size");
        }
    }
    else {
        errx(1, "unsupported data version");
    }

    uint8_t copyByte;
    ssize_t copyReadSize;
    while ((copyReadSize = read(f1, &copyByte, sizeof(copyByte))) > 0) {
        if (write(f2, &copyByte, sizeof(copyByte)) == -1) {
            err(1, "write copy");
        }
    }
    if (copyReadSize == -1) {
        err(1, "read f1");
    }

    if (header.dataVersion == 0x00) {
        for (int i = 0; i < header.count; i++) {
            struct RecordV0 record;
            ssize_t recReadSize = read(patch, &record, sizeof(record));
            if (recReadSize != sizeof(record)) {
                errx(1,"bad size");
            }

            off_t bytePos = (off_t)record.offset * sizeof(uint8_t);

            if (lseek(f2, bytePos, SEEK_SET) == -1) {
                err(1, "lseek f2");
            }
            uint8_t currentByte;
            if (read(f2, &currentByte, sizeof(currentByte)) != 1) {
                errx(1, "read");
            }

            if (currentByte != record.original_byte) {
                errx(1, "byte mismatch",
                     record.offset, record.original_byte, currentByte);
            }

            if (lseek(f2, bytePos, SEEK_SET) == -1) {
                err(1, "lseek f2 back");
            }
            if (write(f2, &record.new_byte, sizeof(record.new_byte)) == -1) {
                err(1, "write f2");
            }
        }
    }
    else { 
        for (int i = 0; i < header.count; i++) {
            struct RecordV1 record;
            ssize_t recReadSize = read(patch, &record, sizeof(record));
            if (recReadSize != sizeof(record)) {
                errx(1, "read" );
            }

            off_t bytePos = (off_t)record.offset * sizeof(uint16_t);

            if (lseek(f2, bytePos, SEEK_SET) == -1) {
                err(1, "lseek f2");
            }
            uint16_t currentWord;
            if (read(f2, &currentWord, sizeof(currentWord)) != sizeof(currentWord)) {
                errx(1, "read");
            }

            if (currentWord != record.original_word) {
                errx(1, "word mismatch",
                     record.offset, record.original_word, currentWord);
            }

            if (lseek(f2, bytePos, SEEK_SET) == -1) {
                err(1, "lseek f2 back");
            }
            if (write(f2, &record.new_word, sizeof(record.new_word)) == -1) {
                err(1, "write f2");
            }
        }
    }

    close(patch);
    close(f1);
    close(f2);

    return 0;
}
