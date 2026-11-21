---
title: "Docker multi-stage para apps Go"
description: "Imagens de poucos MB com build em múltiplos estágios."
categories: [go, devops]
tags: [docker, containers]
playlist: go-na-pratica
playlist_order: 3
---
Com multi-stage, compilamos num estágio e copiamos só o binário para uma imagem mínima.

```dockerfile
FROM golang:1.24 AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /app

FROM gcr.io/distroless/static
COPY --from=build /app /app
ENTRYPOINT ["/app"]
```

## Resultado

Imagem final na casa de 10 MB, sem shell e com superfície de ataque menor.
