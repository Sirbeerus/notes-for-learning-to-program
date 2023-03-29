{
  imports = [
    ./default.nix
  ];

  components = {
    index = {
      type = "static";
      source = ./.;
    };
  };

  routes = {
    "/" = {
      component = "index";
    };
  };
}
