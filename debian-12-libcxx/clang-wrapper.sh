#!/bin/sh
ARGS=$(echo "$@" | sed -e "s/-Wno-builtin-macro-redefined//g" -e "s/-msse3//g" -e "s/-m64//g" -e "s/-ffp-contract=off//g" -e "s/-Wunknown-warning-option//g" -e "s/-Wno-deprecated-builtins//g" -e "s/-Wno-thread-safety-reference-return//g" -e "s/-split-threshold-for-reg-with-hint=0//g" -e "s/-Wno-c++11-narrowing-const-reference//g")
/usr/lib/llvm-16/bin/clang++ -stdlib=libc++ "$ARGS"
