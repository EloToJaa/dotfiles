{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.terranix.flakeModule
  ];

  perSystem = {pkgs, ...}: {
    terranix.terranixConfigurations.infrastructure = {
      workdir = ".terranix";
      modules = [
        ./providers.nix
        ./cloudflare.nix
        ./hetzner.nix
      ];
      terraformWrapper = {
        package = pkgs.opentofu;
        extraRuntimeInputs = [
          pkgs.jq
          pkgs.sops
        ];
        prefixText = let
          secretsFile = "${self}/secrets/secrets.yaml";
        in ''
          secrets_json="$(sops --decrypt --output-type json ${secretsFile})"

          read_secret() {
            local path="$1"
            local value

            if ! value="$(jq --exit-status --raw-output "$path // empty" <<<"$secrets_json")" || [ -z "$value" ]; then
              echo "Missing Terranix secret at $path in secrets/secrets.yaml" >&2
              echo "See terranix/README.md for setup instructions." >&2
              exit 1
            fi

            printf '%s' "$value"
          }

          export CLOUDFLARE_API_TOKEN="$(read_secret '.cloudflare.apitoken')"
          export HCLOUD_TOKEN="$(read_secret '.terranix.hetzner_api_token')"
          export TF_VAR_cloudflare_account_id="$(read_secret '.terranix.cloudflare_account_id')"
          export TF_VAR_storage_box_id="$(read_secret '.terranix.storage_box.id')"
          export TF_VAR_storage_box_location="$(read_secret '.terranix.storage_box.location')"
          export TF_VAR_storage_box_name="$(read_secret '.terranix.storage_box.name')"
          export TF_VAR_storage_box_password="$(read_secret '.terranix.storage_box.password')"
          export TF_VAR_storage_box_type="$(read_secret '.terranix.storage_box.type')"
          unset secrets_json
        '';
      };
    };
  };
}
