# Zokai blog

Jekyll 4.4 + tema próprio inspirado na logo.

```bash
bundle install
bundle exec jekyll serve --livereload
```

- Novos posts: `_posts/AAAA-MM-DD-slug.md` com `categories: [go, devops]` (várias permitidas) e `tags`.
- Categorias (nome, cor, descrição): `_data/categories.yml`.
- Mais lidos: `ruby scripts/update_views.rb` (GoatCounter) grava `_data/views.yml`.
- Opções (giscus, newsletter, redes): `_config.yml` → `zokai:`.
