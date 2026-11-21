---
title: "Deploy de site estático com CI"
description: "Do commit ao ar em minutos: pipeline simples para blogs estáticos."
categories: [devops, web]
tags: [ci, jekyll, deploy]
---
Um pipeline bom é entediante: commit, build, teste, publica.

## Etapas

1. Instalar dependências (`bundle install`)
2. Gerar o site (`bundle exec jekyll build`)
3. Publicar a pasta `_site`

## Dica

Cache de gems corta o tempo do build pela metade.
