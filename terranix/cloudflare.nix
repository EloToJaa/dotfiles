{
  variable.cloudflare_account_id = {
    type = "string";
    description = "Cloudflare account containing elotoja.com.";
    sensitive = true;
  };

  resource.cloudflare_zone.elotoja = {
    account.id = "\${var.cloudflare_account_id}";
    name = "elotoja.com";
    type = "full";
    lifecycle.prevent_destroy = true;
  };

  output.cloudflare_zone = {
    description = "Cloudflare zone ID for DNS resources.";
    value = "\${cloudflare_zone.elotoja.id}";
  };

  output.cloudflare_name_servers = {
    description = "Authoritative Cloudflare name servers.";
    value = "\${cloudflare_zone.elotoja.name_servers}";
  };
}
