.PHONY: clear build

clear:
	@ rm -rf test

build: clear test

test:
	@ gcc unity.c ll.c test.c -o test
	@ chmod +x test