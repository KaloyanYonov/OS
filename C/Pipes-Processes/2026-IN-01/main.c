#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <err.h>

#define N 3
#define ESC   0x7D
#define STUFF 0x55

static int is_special(unsigned char b)
{
	return b == 0x00 || b == 0x55 || b == 0x7D || b == 0xFF;
}

int main(int argc, char *argv[]){


	if (argc != 4){
		errx(1, "usage: %s prog1 prog2 prog3", argv[0]);
	}

	int to_child[N][2];
	int from_child[N][2];
	pid_t pid[N];
	int i, j;

	i=0;
	while (i < N) {

		if (pipe(to_child[i]) == -1){
			err(1, "pipe");
		}
		if (pipe(from_child[i]) == -1){
			err(1, "pipe");
		}
		i++;
	}

	i = 0;
	while (i < N) {
		pid[i] = fork();
		if (pid[i] == -1){
			err(1, "fork");

		}

		if (pid[i] == 0) {
			if (dup2(to_child[i][0], 0) == -1){
				err(1, "dup2 stdin");
			}
			if (dup2(from_child[i][1], 1) == -1){
				err(1, "dup2 stdout");
			}

			j = 0;
			while (j < N) {
				close(to_child[j][0]);
				close(to_child[j][1]);
				close(from_child[j][0]);
				close(from_child[j][1]);
				j++;
			}

			execl(argv[i + 1], argv[i + 1], (char *)NULL);
			err(1, "execl %s", argv[i + 1]);
		}

		close(to_child[i][0]);
		close(from_child[i][1]);
		i++;
	}

	unsigned char in_byte, prev_byte = 0;
	int have_prev = 0;
	unsigned char out_buf[2];
	int out_len;
	unsigned char confirm;
	ssize_t n;

	while ((n = read(0, &in_byte, 1)) > 0) {
		out_len = 0;

		if (is_special(in_byte)) {
			out_buf[out_len++] = ESC;
			out_buf[out_len++] = in_byte ^ 0x20;
		}
		else if (have_prev && in_byte == prev_byte) {
			out_buf[out_len++] = STUFF;
			out_buf[out_len++] = in_byte;
		} 
		else {
			out_buf[out_len++] = in_byte;
		}

		prev_byte = in_byte;
		have_prev = 1;

		i = 0;
		while (i < N) {

			if (write(to_child[i][1], out_buf, out_len) != out_len){
				err(1, "write to child %d", i);
			}
			i++;
		}

		i = 0;
		while (i < N) {
			ssize_t r = read(from_child[i][0], &confirm, 1);
			if (r == -1)
				err(1, "read confirmation from child %d", i);
			if (r == 0)
				errx(1, "child %d closed unexpectedly", i);
			i++;
		}
	}

	if (n == -1){
		err(1, "read stdin");
	}

	i = 0;
	while (i < N) {
		close(to_child[i][1]);
		i++;
	}
	i = 0;
	while (i < N) {
		close(from_child[i][0]);
		i++;
	}

	i = 0;
	while (i < N) {
		int status;
		if (waitpid(pid[i], &status, 0) == -1){
			err(1, "waitpid");

		}
		i++;
	}

	return 0;
}
