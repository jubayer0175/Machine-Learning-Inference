#!/bin/sh

nios2-app-generate-makefile \
   --bsp-dir=../hal_bsp \
   --elf-name=main.elf \
   --src-files=dataset.c  \
   --src-files=functions.c  \
   --src-files=loss_functions.c  \
   --src-files=mnist_infertest.c  \
   --src-files=neuralnet.c  \
   --src-files=optimizer.c  \
   --src-files=tensor.c
