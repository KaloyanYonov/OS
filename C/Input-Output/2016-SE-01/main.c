#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <err.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <stdbool.h>


int main(int argc, char* argv[]){

	if(argc != 2){
		errx(1, "Usage: <file.bin>");
	}
	
	int fd = open(argv[1], O_RDWR);
	if(fd == -1){
		err(2, "Error while opening");
	}

	uint8_t byte;
	int bytes[256] = {0}
	ssize_t readSize;

	while ((readSize = read(fd, &byte, sizeof(byte)) > 0)) {
		bytes[byte]++;
	}
	if(readSize == -1){
		err(3,"Error while reading");
	}

	if (lseek(fd, 0, SEEK_SET) == -1){
    		err(4, "lseek");
	}

	for (int i = 0; i < 256; i++) {
    		char b = (char)i;
    		for (int j = 0; j < bytes[i]; j++) {
        		if (write(fd, &b, sizeof(b)) == -1){
            			err(5, "write");
			}
    		}
	}


	close(fd);



	return 0;
}


