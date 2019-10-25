#!/usr/bin/env bash

for name in World Alice "Dear Visitor"; do \
    sed -e "s/<% name %>/${name}/" \
        hello_world.tex \
        > "hello_${name}.tex"
    lualatex "hello_${name}.tex"
done
