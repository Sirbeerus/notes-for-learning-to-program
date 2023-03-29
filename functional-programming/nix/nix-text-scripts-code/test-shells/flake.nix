{
    description = "Static Website for fire";
    inputs.styx.url = "https://github.com/Sirbeerus/styx/archive/master.tar.gz";
    outputs = {
        self,
        nixpkgs,
        stix,
        site,
    }:
    {
    site = stix.callPackage ./site.nix {
        inherit self;
        inherit nixpkgs;
        inherit stix;
    };
    }
