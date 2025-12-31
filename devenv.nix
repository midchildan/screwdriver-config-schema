{
  pkgs,
  inputs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  json-schema-to-nickel = inputs.json-schema-to-nickel.packages.${system}.default;
in
{
  packages = [
    pkgs.nls
    pkgs.nickel
    json-schema-to-nickel
  ];

  languages.javascript = {
    enable = true;
    npm = {
      enable = true;
      install.enable = true;
    };
  };

  enterTest = ''
    ./test.sh
  '';

  scripts.generate = {
    description = "Generate Screwdriver schema files";
    exec = ''
      cd "$DEVENV_ROOT/src"
      node index.js | sed 's|\\w-\.|\\w.-|g' > screwdriver.schema.json
      json-schema-to-nickel screwdriver.schema.json > screwdriver.schema.ncl
    '';
  };

  git-hooks.hooks.treefmt.enable = true;

  treefmt = {
    enable = true;
    config = {
      programs = {
        nickel.enable = true;
        nixfmt.enable = true;
        prettier.enable = true;
      };

      settings.global.excludes = [
        "node_modules/*"
        "src/screwdriver.schema.json"
        "src/screwdriver.schema.ncl"
        "third-party/*"
      ];
    };
  };
}
