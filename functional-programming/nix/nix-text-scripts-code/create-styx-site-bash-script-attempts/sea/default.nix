{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  networking.hostName = "sea";
  environment.systemPackages = with pkgs; [
    haskellPackages.styx
  ];
}
