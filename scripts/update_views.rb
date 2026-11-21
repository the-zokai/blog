#!/usr/bin/env ruby
# Atualiza _data/views.yml com as visualizações do GoatCounter.
# Uso: GOATCOUNTER_SITE=meusite GOATCOUNTER_TOKEN=xxx ruby scripts/update_views.rb
# (token com permissão "Ver estatísticas"; rode no CI antes do build)
require "net/http"
require "json"
require "yaml"

site  = ENV.fetch("GOATCOUNTER_SITE")
token = ENV.fetch("GOATCOUNTER_TOKEN")
uri   = URI("https://#{site}.goatcounter.com/api/v0/stats/hits?limit=100&start=2000-01-01")
req   = Net::HTTP::Get.new(uri, "Authorization" => "Bearer #{token}")
res   = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
abort "Erro #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)

views = {}
JSON.parse(res.body)["hits"].each do |h|
  next unless h["path"] =~ %r{\A/posts/([^/]+)/?\z}
  views[Regexp.last_match(1)] = h["count"]
end
File.write("_data/views.yml", "# gerado por scripts/update_views.rb\n" + views.to_yaml.sub(/\A---\n/, ""))
puts "#{views.size} posts atualizados"
