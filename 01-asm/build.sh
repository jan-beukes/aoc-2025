#!/bin/sh
set -xe

nasm -o main.o main.asm -felf64
ld -o main main.o
