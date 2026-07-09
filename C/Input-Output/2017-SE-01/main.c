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

	int f1 = open(argv[1], O_RDONLY);
	if(f1 == -1) { err(1, "f1"); }

	int f2 = open(argv[2], O_RDONLY);
	if(f2 == -1) { err(1, "f2"); }

	int patch = open(argv[3], O_WRONLY | O_TRUNC | O_CREAT , 0666);
	if(patch == -1) { err(1, "patch"); }

	struct stat st;
	if(fstat(f1, &st) == -1) { err(1,"fstat"); }
	struct stat st2;
	if(fstat(f2, &st2) == -1){ err(1, "fstat"); }
	if(st.st_size != st2.st_size){
		err(1, "not same sizes");
	}
	struct Entry entry;


	for(off_t i = 0; i< st.st_size; i++){
		uint8_t f1Byte, f2Byte;
		if(read(f1, &f1Byte, sizeof(f1Byte)) == -1) {err(1, "read");}
		if(read(f2, &f2Byte, sizeof(f2Byte)) == -1) {err(1, "read");}

		if(f1Byte != f2Byte){
			entry.offset = (uint16_t)i;
			entry.oldByte = f1Byte;
			entry.newByte = f2Byte;
			if(write(patch, &entry, sizeof(entry)) == -1){
				err(1,"write");
			}
		} 
	}
	close(patch);
	close(f2);
	close(f1);

	return 0;

}

