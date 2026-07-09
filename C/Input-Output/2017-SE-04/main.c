#include <fcntl.h>
#include <unistd.h>
#include <err.h>
#include <string.h>
#include <stdint.h>

void copyFromFd(int fd){
	
	uint8_t byte;
	ssize_t readSize;

	while((readSize= read(fd,&byte, sizeof(byte)))>0){
		if(write(1, &byte, sizeof(byte)) == -1){
			err(1, "read");
		}

	}
	if(readSize == -1){
		err(1, "read");
	}

}


int main(int argc, char* argv[]){

	if(argc == 1){
		copyFromFd(0);
	}

	for(int i=1; i < argc; ++i){
		if(argv[i][0] == '-'){
			copyFromFd(0);
		}
		else{
			int fd = open(argv[i], O_RDONLY);
			if(fd == -1){
				err(1, "read");
			}
			copyFromFd(fd);
			close(fd);
		}
	}
	

	return 0;
}
