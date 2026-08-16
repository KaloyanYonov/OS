#include <unistd.h>
#include <fcntl.h>
#include <err.h>
#include <stdint.h>


int main(int argc, char* argv[]){

	if(argc != 2){
		errx(1, "bad arguments");
	}

	char *dir = argv[1];

	int fd[2];
	if(pipe(fd) == -1){
		err(1, "pipe");
	}
	pid_t pid = fork();

	if(pid == -1){
		err(1, "fork");
	}

	if(pid == 0){
		dup2(fd[1],1);
		close(fd[1]);
		close(fd[0]);
		
		execlp("tar", "tar" ,"cf", "-" , dir, NULL);
	}

	close(fd[1]);
	char buf[4096];

	while(n = (read(fd[0], &buf, sizeof(buf))) >0 ){

		unsigned int hash = 0;
		for(int i =0; i < n; ++i){
				
			has = hash ^ buf[i];

		}

	}

	return 0;

}

