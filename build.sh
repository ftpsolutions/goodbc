#!/bin/bash

which go 2>/dev/null 1>/dev/null
if [[ $? -ne 0 ]]; then
    echo "error: failed to find go binary- do you have Go 1.9 or Go 1.10 installed?"
    exit 1
fi

GOVERSION=`go version`
if [[ $GOVERSION != *"go1.9"* ]] && [[ $GOVERSION != *"go1.10"* ]]; then
    echo "error: Go version is not 1.9 or 1.10 (was $GOVERSION)"
    exit 1
fi

export GOPATH=`pwd`

export PYTHONPATH=`pwd`/src/github.com/go-python/gopy/

echo "cleaning up output folder"
rm -frv goodbc_python/*.pyc
rm -frv goodbc_python/py2/*.pyc
rm -frv goodbc_python/py2/*.so
rm -frv goodbc_python/py2/*.c
rm -frv goodbc_python/cffi/*.pyc
rm -frv goodbc_python/cffi/*.so
rm -frv goodbc_python/cffi/*.c
rm -frv goodbc_python/cffi/goodbc_python.py
echo ""

if [[ "$1" == "clean" ]]; then
    exit 0
fi

if [[ "$1" != "fast" ]]; then
    echo "getting assert"
    go get -v -a github.com/stretchr/testify/assert
    echo ""

    echo "getting sql"
    go get -v -a golang.org/pkg/database/sql
    
    echo "building sql"
    go build -a -x golang.org/pkg/database/sql

    echo "getting goodbc"
    go get -v -a github.com/alexbrainman/odbc
    echo ""

    echo "building goodbc"
    go build -a -x github.com/alexbrainman/odbc
    echo ""

    echo "getting gopy"
    go get -v -a github.com/go-python/gopy
    echo ""

    echo "installing gopy"
    go install -v -a github.com/go-python/gopy
    echo ""

    echo "building gopy"
    go build -x -a github.com/go-python/gopy
    echo ""

    echo "building goodbc_python"
    go build -x -a goodbc_python
    echo ""
fi

echo "build goodbc_python bindings for py2"
./gopy bind -lang="py2" -output="goodbc_python/py2" -symbols=true -work=false goodbc_python
echo ""

# gopy doesn't seem to support Python3 as yet
# echo "build goodbc_python bindings for py3"
# ./gopy bind -lang="py3" -output="goodbc_python/py3" -symbols=true -work=false goodbc_python
# echo ""

echo "build goodbc_python bindings for cffi"
./gopy bind -lang="cffi" -output="goodbc_python/cffi" -symbols=true -work=false goodbc_python
echo ""