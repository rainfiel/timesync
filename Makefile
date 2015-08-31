all : timesync

timesync : ltimesync.c
	gcc -Wall -g -o $@.dll --shared $^ -I/usr/local/include -L/usr/local/bin -llua53
