#include <err.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

struct Entry{
	uint16_t offset;
	uint8_t oldByte;
	uint8_t newByte; 
};


int main(int argc, char* argv[]){

	if(argc != 4) { errx(1, "bad args"); }

	int patch = open(argv[1], O_RDONLY);
	if(patch == -1) { err(1, "patch");}
	int f1 = open(argv[2], O_RDONLY);
	if(f1 == -1) { err(1, "f1"); }
	int f2 = open(argv[3], O_RDWR | O_TRUNC | O_CREAT, 0666);
	if(f2 == -1) { err(1, "f2"); }

	struct stat st;
	struct Entry entry;

	if(fstat(f1, &st) == -1 ) { err(1, "fstat"); }
	
	uint8_t byte;
	ssize_t readSize;
	while((readSize = read(f1, &byte, sizeof(byte))) > 0){
		if(write(f2, &byte, sizeof(byte)) == -1) {
			err(1, "write");
		}
	}
	if(readSize == -1) { err(1, "read"); }

	ssize_t patchRead;
	while((patchRead = read(patch, &entry, sizeof(entry))) > 0){
		uint8_t byte;
		if(lseek(f2, entry.offset, SEEK_SET) == -1) {
			err(1, "lseek");
		}
		if (read(f2, &byte, sizeof(byte)) != 1){
   			 errx(1, "bad offset");
		}
		if(lseek(f2, entry.offset, SEEK_SET) == -1){
			err(1, "lseek");
		}
		if(byte == entry.oldByte){
			byte = entry.newByte;
		}
		if(write(f2, &byte, sizeof(byte)) == -1) { err(1, "write"); }
	}
	
	close(f2);
	close(f1);
	close(patch);

	return 0;
}
