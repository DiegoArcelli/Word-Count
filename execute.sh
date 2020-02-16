#!/bin/bash
#shell script to compile and link the code

yasm -g dwarf2 -f elf64 wc.asm -l wc.lst
gcc -g -no-pie -o wc wc.o
./wc -l -m -w prova.txt
