{
  config,
  settings,
  ...
}: {
  imports = [
    ./../settings.nix

    ./cybersec
    ./desktop
    ./dev
    ./home
  ];
}
