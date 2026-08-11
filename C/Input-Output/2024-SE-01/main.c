#include <err.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>


struct Node{
	
	uint8_t next;
	uint8_t user_data[503];

}__attribute(packed)__;

int main(int argc, char* argv[]){

	if(argc != 2){
		errx(1, "Bad arguments")
	}

	return 0;
}
