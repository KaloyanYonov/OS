CC=gcc
CFLAGS=-Wall -Wextra -std=c11 -O2
TARGET=main

SRC := $(wildcard *.c)
OBJ := $(SRC:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJ)
