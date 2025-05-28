CC = clang
CFLAGS = -g -target arm64-apple-macos -mcpu=apple-m4

all: main

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

main: main.o outer_product.o gemm_ncopy_16.o gemm_tcopy_16.o
	$(CC) $(CFLAGS) main.o outer_product.o gemm_ncopy_16.o gemm_tcopy_16.o -o main

run:
	./main

clean:
	rm -f *.o main

