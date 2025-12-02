#!/usr/bin/bash

cat input02.txt | tr ,- '\n ' | xargs -L 1 seq | \
    grep -E '^(.+)\1+$' | paste -sd+ -| bc
