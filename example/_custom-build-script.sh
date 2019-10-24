#!/usr/bin/env bash

lualatex hello_world.tex
echo -e "\n\nMaybe we need a second run?\n\n"
lualatex hello_world.tex
