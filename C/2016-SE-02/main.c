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

struct pair {
	uint32_t x;
	uint32_t y;

};

int main(int argc, char* argv[]){

	if(argc != 4){
		errx(1,"Error: bad arguments");
	}

	int fd1 = open(argv[1], O_RDONLY);
	int fd2 = open(argv[2], O_RDONLY);

	if(fd1 == -1){
		err(2, "Error: %s" , argv[1]);	
	}

	if(fd2 == -1){
		err(2, "Error: %s", argv[2]);
	}
	
	struct stat s;

	if(fstat(fd1, &s) == -1){
		err(3, "Could not fstat");
	}
	
	if(s.st_size % 8 != 0){
		errx(2, "Error: must be divisible by 8");
	}

	int fd3 = open(argv[3], O_WRONLY | O_TRUNC | O_CREAT, 0666);
	if(fd3 == -1){
		err(4, "Error: %s", argv[3]);
	}


	struct pair p;
	ssize_t readSize;

	while((readSize = read(fd1, &p, sizeof(p)) ) > 0) {
		if(lseek(fd2, p.x*4, SEEK_SET) == -1){
			err(5,"Couldn't lseek");
		}
		uint32_t b;

		for(uint32_t i =0; i < p.y; ++i){
			if(read(fd2, &b, sizeof(b)) == -1){
				err(6, "Could not read");
			}

			if(write(fd3, &b,sizeof(b)) == -1){
				err(7, "Could not write");
			}
		}
	}

	if(readSize == -1){
		err(8, "Read error");
	}

	close(fd3);
	close(fd2);
	close(fd1);


}

