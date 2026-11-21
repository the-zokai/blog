# frozen_string_literal: true
#
# Plugin do tema Zokai (roda localmente; não é compatível com GitHub Pages "puro",
# use GitHub Actions ou outro CI para o build).
#
#  - injeta `views` em cada post (a partir de _data/views.yml)
#  - gera /categorias/<slug>/ e /tags/<slug>/ (com paginação)
#  - expõe site.data["zokai"]["category_list"] ordenado por quantidade de posts

module Zokai
  class ListPage < Jekyll::PageWithoutAFile
    def initialize(site, dir, layout, data)
      super(site, site.source, dir, "index.html")
      self.data = { "layout" => layout, "sitemap" => true }.merge(data)
      self.content = ""
    end
  end

  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      per_page = (site.config.dig("zokai", "posts_per_page") || 10).to_i
      views = site.data["views"] || {}
      views = {} unless views.is_a?(Hash)

      site.posts.docs.each do |post|
        post.data["views"] = views[post.data["slug"] || post.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, "")].to_i
      end

      # ---- playlists: posts com `playlist: <id>` e `playlist_order: <n>` ----
      pl_meta = site.data["playlists"] || {}
      groups = Hash.new { |h, k| h[k] = [] }
      site.posts.docs.each do |post|
        id = post.data["playlist"]
        next unless id
        id = id.to_s
        unless pl_meta.key?(id)
          Jekyll.logger.warn "Zokai:", "post '#{post.data['slug']}' usa playlist desconhecida '#{id}' (cadastre em _data/playlists.yml)"
          next
        end
        groups[id] << post
      end
      pl_list = []
      groups.each do |id, posts|
        meta = pl_meta[id]
        ordered = posts.sort_by { |p| [p.data["playlist_order"] || 9999, p.date] }
        ordered.each_with_index do |post, i|
          link = ->(d) { d && { "url" => d.url, "title" => d.data["title"] } }
          post.data["playlist_name"]  = meta["name"]
          post.data["playlist_color"] = meta["color"] || "#ffd23f"
          post.data["playlist_url"]   = "/playlists/#{id}/"
          post.data["playlist_pos"]   = i + 1
          post.data["playlist_total"] = ordered.size
          post.data["playlist_prev"]  = link.call(i > 0 ? ordered[i - 1] : nil)
          post.data["playlist_next"]  = link.call(ordered[i + 1])
          post.data["playlist_posts"] = ordered.map { |d| { "url" => d.url, "title" => d.data["title"] } }
        end
        pl_list << { "id" => id, "name" => meta["name"], "desc" => meta["desc"],
                     "color" => meta["color"] || "#ffd23f", "count" => ordered.size,
                     "first_url" => ordered.first.url, "posts" => ordered }
        site.pages << ListPage.new(site, "/playlists/#{id}/", "playlist", {
          "title" => meta["name"], "description" => meta["desc"], "playlist_id" => id,
          "playlist_name" => meta["name"], "playlist_desc" => meta["desc"],
          "playlist_color" => meta["color"] || "#ffd23f", "playlist_posts_all" => ordered
        })
      end
      # playlists cadastradas sem posts também aparecem (vazias)
      pl_meta.each do |id, meta|
        next if groups.key?(id)
        pl_list << { "id" => id, "name" => meta["name"], "desc" => meta["desc"],
                     "color" => meta["color"] || "#ffd23f", "count" => 0, "first_url" => nil, "posts" => [] }
        site.pages << ListPage.new(site, "/playlists/#{id}/", "playlist", {
          "title" => meta["name"], "description" => meta["desc"], "playlist_id" => id,
          "playlist_name" => meta["name"], "playlist_desc" => meta["desc"],
          "playlist_color" => meta["color"] || "#ffd23f", "playlist_posts_all" => []
        })
      end
      site.data["playlist_list"] = pl_list.sort_by { |pl| pl["name"].to_s }

      cats_meta = site.data["categories"] || {}

      site.categories.each do |slug, posts|
        meta = cats_meta[slug] || { "name" => slug.capitalize, "desc" => "", "color" => "#ff2a7a", "icon" => "◆" }
        paginate(site, "categorias/#{slug}", "category", posts, per_page,
                 "taxonomy" => "category", "term" => slug, "term_name" => meta["name"],
                 "term_desc" => meta["desc"], "term_color" => meta["color"], "term_icon" => meta["icon"],
                 "title" => meta["name"], "description" => meta["desc"])
      end

      site.tags.each do |slug, posts|
        paginate(site, "tags/#{Jekyll::Utils.slugify(slug)}", "category", posts, per_page,
                 "taxonomy" => "tag", "term" => slug, "term_name" => "##{slug}",
                 "term_desc" => "Posts marcados com ##{slug}.", "term_color" => "#b45cff", "term_icon" => "#",
                 "title" => "##{slug}")
      end

      list = site.categories.map do |slug, posts|
        meta = cats_meta[slug] || {}
        { "slug" => slug, "name" => meta["name"] || slug.capitalize, "desc" => meta["desc"],
          "color" => meta["color"] || "#ff2a7a", "icon" => meta["icon"] || "◆", "count" => posts.size }
      end
      site.data["category_list"] = list.sort_by { |c| [-c["count"], c["name"]] }
    end

    private

    def paginate(site, dir, layout, posts, per_page, data)
      sorted = posts.sort_by(&:date).reverse
      pages = [(sorted.size.to_f / per_page).ceil, 1].max
      (1..pages).each do |n|
        slice = sorted[(n - 1) * per_page, per_page] || []
        path = n == 1 ? "/#{dir}/" : "/#{dir}/pagina/#{n}/"
        site.pages << ListPage.new(site, path, layout, data.merge(
          "posts_slice" => slice, "total" => sorted.size, "page_num" => n, "page_count" => pages,
          "prev_url" => n > 1 ? (n == 2 ? "/#{dir}/" : "/#{dir}/pagina/#{n - 1}/") : nil,
          "next_url" => n < pages ? "/#{dir}/pagina/#{n + 1}/" : nil
        ))
      end
    end
  end
end
