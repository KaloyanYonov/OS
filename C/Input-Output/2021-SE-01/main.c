#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <err.h>

int get_bit(uint8_t byte, int i) {
    return (byte >> (7 - i)) & 1;
}

int encode_bit(int bit) {
    if (bit == 1) {
        return 0b10;
    } else {
        return 0b01;
    }
}

uint8_t encode_nibble(uint8_t byte, int start) {
    uint8_t outByte = 0;
    for (int i = start; i < start + 4; i++) {
        int bit = get_bit(byte, i);
        int encoded = encode_bit(bit);
        outByte = (outByte << 2) | encoded;
    }
    return outByte;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        errx(1, "bad args");
    }

    int input = open(argv[1], O_RDONLY);
    if (input == -1) {
        err(1, "input fd");
    }

    int output = open(argv[2], O_RDWR | O_TRUNC | O_CREAT, 0666);
    if (output == -1) {
        err(1, "output fd");
    }

    uint8_t inByte;
    ssize_t readSize;

    while ((readSize = read(input, &inByte, sizeof(inByte))) > 0) {

        uint8_t outByte1 = encode_nibble(inByte, 0);
        uint8_t outByte2 = encode_nibble(inByte, 4);

        if (write(output, &outByte1, sizeof(outByte1)) == -1) {
            err(1, "write");
        }
        if (write(output, &outByte2, sizeof(outByte2)) == -1) {
            err(1, "write");
        }
    }
    if (readSize == -1) {
        err(1, "read");
    }

    close(input);
    close(output);

    return 0;
}
