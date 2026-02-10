{
  description = "Apache Solr 8.4.1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "solr";
          version = "8.4.1";

          src = pkgs.fetchurl {
            url = "https://archive.apache.org/dist/lucene/solr/${version}/solr-${version}.tgz";
            sha256 = "sha256-7Dnh4CSy43QFFJ3kHjnodaOb8RpT9QbQfZa0e40qQwE=";
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pkgs.openjdk11 ];

          installPhase = ''
            mkdir -p $out
            cp -r * $out/

            wrapProgram $out/bin/solr \
              --set JAVA_HOME "${pkgs.openjdk11.home}"
          '';

          meta = with pkgs.lib; {
            description = "Apache Solr 8.4.1";
            homepage = "https://solr.apache.org/";
            platforms = platforms.all;
          };
        };
      }
    );
}
