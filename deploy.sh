#!/bin/bash

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}>> Gerando arquivos estáticos localmente...${NC}"
# Gera o site na pasta 'site/' mas não faz o push automático pelo MkDocs
mkdocs build --clean

echo -e "${BLUE}>> Movendo arquivos para a raiz e preparando push...${NC}"
# Copia o conteúdo gerado para a raiz (para o GitHub Pages ler)
cp -r site/* .

echo -e "${GREEN}>> Salvando tudo na Main...${NC}"
git add .
MESSAGE=${1:-"update: modificações no site e build"}
git commit -m "$MESSAGE"
git push origin main  # Mude para 'main' se for o nome do seu branch

echo -e "${BLUE}>> Sucesso! Tudo centralizado em um só lugar.${NC}"