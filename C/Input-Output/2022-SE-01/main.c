#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <err.h>
#include <sys/types.h>
#include <sys/stat.h>

#define DATA_MAGIC 0x21796F4A
#define CMP_MAGIC1 0xAFBC7A37
#define CMP_MAGIC2 0x1C27

struct data_header {
    uint32_t magic;
    uint32_t count;
} __attribute__((packed));

struct cmp_header {
    uint32_t magic1;
    uint16_t magic2;
    uint16_t reserved;
    uint64_t count;
} __attribute__((packed));

struct cmp_record {
    uint16_t type;
    uint16_t reserved[3];
    uint32_t offset1;
    uint32_t offset2;
} __attribute__((packed));

int main(int argc, char *argv[]) {

    if (argc != 3){
        errx(1, "bad arguments");
    }

    int data_fd = open(argv[1], O_RDWR);
    if (data_fd == -1){
        err(1, "open data_Fd");
    }

    int cmp_fd = open(argv[2], O_RDONLY);
    if (cmp_fd == -1){
        err(1, "open cmp_fd");
    }

    struct stat data_st;
    if (fstat(data_fd, &data_st) == -1){
        err(1, "fstat data");
    }

    struct stat cmp_st;
    if (fstat(cmp_fd, &cmp_st) == -1){
        err(1, "fstat cmp");
    }

    struct data_header data_hdr;
    ssize_t readSize = read(data_fd, &data_hdr, sizeof(data_hdr));
    if (readSize == -1){
        err(1, "read data_fd");
    }
    if ((size_t)readSize != sizeof(data_hdr)){
        errx(1, "readSize doesn not match data header (data_fd)");
    }
    if (data_hdr.magic != DATA_MAGIC){
        errx(1, "invalid magic (data_fd)");
    }

    if ((uint64_t)data_st.st_size != sizeof(data_hdr) + (uint64_t)data_hdr.count * sizeof(uint64_t)){
        errx(1, "file size does not match header count");
    }

    struct cmp_header cmp_hdr;
    readSize = read(cmp_fd, &cmp_hdr, sizeof(cmp_hdr));
    if (readSize == -1){
        err(1, "read cmp_fd");
    }
    if ((size_t)readSize != sizeof(cmp_hdr)){
        errx(1, "read size does not match cmp_header");
    }
    if (cmp_hdr.magic1 != CMP_MAGIC1 || cmp_hdr.magic2 != CMP_MAGIC2){
        errx(1, "invalid magic (cmp_header)");
    }

    if ((uint64_t)cmp_st.st_size != sizeof(cmp_hdr) + cmp_hdr.count * sizeof(struct cmp_record)){
        errx(1, "file size does not match header count");
    }

    uint64_t i = 0;
    while (i < cmp_hdr.count) {
        struct cmp_record rec;
        readSize = read(cmp_fd, &rec, sizeof(rec));
        if (readSize == -1){
            err(1, "read cmp_record");
	}
        if ((size_t)readSize != sizeof(rec)){
            errx(1, "readSize does not match record size");
	}

        off_t off1 = (off_t)sizeof(data_hdr) + (off_t)rec.offset1 * (off_t)sizeof(uint64_t);
        off_t off2 = (off_t)sizeof(data_hdr) + (off_t)rec.offset2 * (off_t)sizeof(uint64_t);

        if (lseek(data_fd, off1, SEEK_SET) == -1){
            err(1, "lseek data_fd");
	}
        uint64_t val1;
        readSize = read(data_fd, &val1, sizeof(val1));
        if (readSize == -1){
            err(1, "read data_fd");
	}
        if ((size_t)readSize != sizeof(val1)){
            errx(1, "unexpected end of file while reading element");
	}

        if (lseek(data_fd, off2, SEEK_SET) == -1){
            err(1, "lseek data_fd");
	}
        uint64_t val2;
        readSize = read(data_fd, &val2, sizeof(val2));
        if (readSize == -1){
            err(1, "read data_fd");
	}
        if ((size_t)readSize != sizeof(val2)){
            errx(1, "unexpected end of file while reading element");
	}

        int need_swap = 0;
        if (val1 != val2) {
            if (rec.type == 0) {
                if (!(val1 < val2))
                    need_swap = 1;
            } else if (rec.type == 1) {
                if (!(val1 > val2))
                    need_swap = 1;
            } else {
                errx(1, "%s: invalid record type %u at record %llu",
                     argv[2], rec.type, (unsigned long long)i);
            }
        }

        if (need_swap) {
            if (lseek(data_fd, off1, SEEK_SET) == -1){
                err(1, "lseek data_Fd");
	    }
            ssize_t w = write(data_fd, &val2, sizeof(val2));
            if (w == -1){
                err(1, "write data_fd");
	    }
            if ((size_t)w != sizeof(val2)){
                errx(1, "short write");
	    }


            if (lseek(data_fd, off2, SEEK_SET) == -1){
                err(1, "lseek data_fd");
	    }
            w = write(data_fd, &val1, sizeof(val1));
            if (w == -1){
                err(1, "write data_fd");
	    }
            if ((size_t)w != sizeof(val1)){
                errx(1, "short write");
	    }
        }

        i++;
    }

    close(data_fd);
    close(cmp_fd);
    return 0;
}
