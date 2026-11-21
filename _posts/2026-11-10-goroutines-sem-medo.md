---
title: "Goroutines sem medo"
description: "Concorrência em Go explicada com um exemplo pequeno e honesto."
categories: [go]
tags: [concorrência, tutorial]
playlist: go-na-pratica
playlist_order: 2
---
Goroutines são leves, mas ainda precisam de disciplina.

## Um exemplo mínimo

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	for i := 1; i <= 3; i++ {
		wg.Add(1)
		go func(n int) {
			defer wg.Done()
			fmt.Println("worker", n)
		}(i)
	}
	wg.Wait()
}
```

## Cuidados

Sempre saiba **quem** encerra cada goroutine. Vazamento de goroutine é um bug silencioso.

### Contexto

Use `context.Context` para cancelamento e prazos.
