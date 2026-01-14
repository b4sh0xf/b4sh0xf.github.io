#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}>> Salvando código fonte no branch principal...${NC}"
git add .
# Pega a mensagem de commit como argumento ou usa uma padrão
MESSAGE=${1:-"update: modificações no site"}
git commit -m "$MESSAGE"
git push origin master

echo -e "${GREEN}>> Gerando e publicando o site (MkDocs)...${NC}"
mkdocs gh-deploy --clean

echo -e "${BLUE}>> Pronto! Seu site em b4sh0xf.github.io foi atualizado.${NC}"
