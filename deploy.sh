#!/bin/zsh
mkdocs build --clean
cp -r site/* .
git add .
git commit -m "update"
git push origin master