#!/bin/bash

# Directories to compress
dirs=("/opt/bazarr" "/opt/docs" "/opt/jellyfin" "/opt/jellyseerr" "/opt/paperless" "/opt/photos" "/opt/prowlarr" "/opt/qbittorrent" "/opt/radarr" "/opt/radicale" "/opt/sonarr" "/opt/uptime" "/var/lib/acme" "/var/lib/authelia-main" "/var/lib/cleanuparr" "/var/lib/glance" "/var/lib/hass" "/var/lib/jellystat" "/var/lib/karakeep" "/var/lib/lldap" "/var/lib/meilisearch" "/var/lib/n8n" "/var/lib/nextcloud" "/var/lib/ntfy-sh" "/var/lib/paperless" "/var/lib/pgadmin" "/var/lib/postgresql" "/var/lib/profilarr" "/var/lib/prometheus" "/var/lib/prowlarr" "/var/lib/radicale" "/var/lib/redis-authelia" "/var/lib/redis-main" "/var/lib/redis-paperless" "/var/lib/rustdesk" "/var/lib/uptime-kuma" "/var/lib/vaultwarden")

# Output directory
output_dir="./backups"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Compress each directory
for dir in "${dirs[@]}"; do
  if [ -d "$dir" ]; then
    filename=$(basename "$dir")_$(date +%Y%m%d_%H%M%S).tar.gz
    tar -czf "$output_dir/$filename" "$dir"
    echo "✓ Compressed: $dir → $output_dir/$filename"
  else
    echo "✗ Directory not found: $dir"
  fi
done

echo "Done!"
