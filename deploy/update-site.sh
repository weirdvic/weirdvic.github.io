#!/bin/env bash

cd ~/weirdvic.github.io

# После экспорта в Markdown файлы обновляем граф связей между страницами
~/.emacs.d/venv/bin/python3 ~/.emacs.d/roam2graph.py > ./static/graph.json

# Теперь нужно сделать экспорт сайта при помощи Hugo
rm -rf public/*
hugo

#
docker run --rm -v $PWD/public:/tmp tinysearch/cli index.json
sudo chown -Rv $USER:$USER ./public/wasm_output
