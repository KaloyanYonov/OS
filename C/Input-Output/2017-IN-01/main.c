#include <stdint.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <err.h>

struct Entry {
    uint16_t offset;
    uint8_t length;
    uint8_t reserved;
};

int main(int argc, char* argv[]) {

    if (argc != 5){
        errx(1, "bad args");
    }
    int f1Dat = open(argv[1], O_RDONLY);
    if (f1Dat == -1){
        err(1, "f1Dat");
    }
    int f1Index = open(argv[2], O_RDONLY);
    if (f1Index == -1){
        err(1, "f1Index");
    }
    int f2Dat = open(argv[3], O_WRONLY | O_TRUNC | O_CREAT, 0666);
    if (f2Dat == -1){
        err(1, "f2Dat");
    }
    int f2Index = open(argv[4], O_WRONLY | O_TRUNC | O_CREAT, 0666);
    if (f2Index == -1){
        err(1, "f2Index");
    }
    
    struct stat st;
    if (fstat(f1Index, &st) == -1){
        err(1, "fstat");
    }

    if (st.st_size % sizeof(struct Entry) != 0){
        errx(1, "bad file size");
    }

    struct stat st_dat;
    if (fstat(f1Dat, &st_dat) == -1){
        err(1, "fstat dat");
    }

    struct Entry entry;
    ssize_t readSize;
    uint16_t current_offset = 0;

    while ((readSize = read(f1Index, &entry, sizeof(entry))) > 0) {

        if (entry.offset + entry.length > st_dat.st_size){
            errx(1, "inconsistent index");
	}

        if (lseek(f1Dat, entry.offset, SEEK_SET) == -1){
            err(1, "lseek");
	}
        uint8_t buf[256];
        if (read(f1Dat, buf, entry.length) != entry.length){
            errx(1, "read string");
	}

        if (buf[0] >= 0x41 && buf[0] <= 0x5A) {
            if (write(f2Dat, buf, entry.length) != entry.length){
                err(1, "write dat");
	    }

            struct Entry new_entry = {current_offset, entry.length, 0};
            if (write(f2Index, &new_entry, sizeof(new_entry)) != sizeof(new_entry)){
                err(1, "write index");
	    }
            current_offset += entry.length;
        }
    }
    if (readSize == -1){
        err(1, "read");
    }

    close(f1Dat);
    close(f1Index);
    close(f2Dat);
    close(f2Index);

    return 0;
}
