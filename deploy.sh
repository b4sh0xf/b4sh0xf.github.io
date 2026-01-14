#!/bin/bash

# 1. Limpa o build anterior e gera o novo HTML
echo ">> Gerando novo build do site..."
mkdocs build --clean

# 2. Copia os arquivos da pasta 'site' para a raiz do repositório
echo ">> Sincronizando arquivos estáticos..."
cp -r site/* .

# 3. Adiciona as mudanças, faz o commit e sobe para a branch MAIN
echo ">> Enviando alterações para a branch main..."
git add .
MESSAGE=${1:-"update: deploy de novas alterações"}
git commit -m "$MESSAGE"
git push origin main

echo ">> Concluído! Verifique b4sh0xf.github.io em alguns instantes."