#!/bin/zsh
mkdocs build --clean
cp -r site/* .
git add .
git commit -m $1
git push origin master