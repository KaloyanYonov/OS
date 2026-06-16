#include <unistd.h>
#include <fcntl.h>
#include <err.h>
#include <string.h>
#include <stdint.h>



int main(int argc, char* argv[]){

	if(argc < 3) { err(1, "bad args"); }

	if(strcmp(argv[1], "-c") == 0){
		if(argc != 3){ err(1, "Usage: -c <num> OR -c <num>-<num>"); }
		
		uint8_t byte;
		ssize_t readSize;
		int left, right;
		if(argv[2][1] == '-'){
			left = argv[2][0] - '0';
			right = argv[2][2] - '0' ;
		}
		else{
			left = argv[2][0] - '0';
			right = left;
		}
		int count = 0;
		while ((readSize = read(0, &byte, sizeof(byte))) > 0) {
   			if (byte == '\n') {
   				if (write(1, &byte, sizeof(byte)) == -1) {
            				err(1, "write");
        			}
       		 		count = 0; 
    			} 
			else {
        			count++;
        			if (count >= left && count <= right) {
            				if (write(1, &byte, sizeof(byte)) == -1) {
                				err(1, "write");
            				}
        			}
    			}		
		}
		
		if(readSize == -1){ err(1, "read"); }


	}
	else if(strcmp(argv[1] , "-d") == 0){
		if(argc != 5) { 
			err(1, "Usage: -d <delimiter> -f <number> ");
		}
		char delimiter = argv[2][0];
		if(strcmp(argv[3], "-f") != 0) { errx(1, "third param must be -f"); }

		int left, right;
		if(argv[4][1] == '-'){
			left = argv[4][0] - '0';
			right = argv[4][2] - '0';
		}
		else{
			left = argv[4][0] - '0';
			right = left;
		}
		ssize_t readSize;
		uint8_t byte;
		int delimCounter = 1;
		while((readSize= read(0,&byte, sizeof(byte))) > 0){

			if(byte == '\n'){
				if(write(1,&byte, sizeof(byte)) == -1){
					err(1,"write");
				}
				delimCounter = 1;
			}
			if(byte == delimiter){
				delimCounter++;
			}
			if(delimCounter >= left && delimCounter <= right){
				if(write(1, &byte, sizeof(byte)) == -1) {
					err(1, "write");

				}

			}

		}
		if(readSize == -1) { err(1, "read"); }


	}

	return 0;
}
