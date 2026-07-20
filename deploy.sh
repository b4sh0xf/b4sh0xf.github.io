#!/bin/zsh
mkdocs build -c
cp -r site/* .
git add .
git commit -m "chore"
git push origin master