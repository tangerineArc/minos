{
  description = "Minos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    quickshell,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pname = "minos-quickshell";
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        quickshell.packages.${system}.default
        qt6.qtbase
        qt6.qtdeclarative
        qt6.qtwayland
      ];

      shellHook = ''
        export QT_QPA_PLATFORM=wayland
        echo "Minos Quickshell Dev Shell loaded"
      '';
    };

    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = pname;
      src = ./.;

      installPhase = ''
        mkdir -p $out/share/minos
        cp -r *.qml components/ $out/share/minos

        mkdir -p $out/bin
        cat <<EOF > $out/bin/minos
        #! /bin/sh
        exec ${quickshell.packages.${system}.default}/bin/quickshell -p $out/share/minos/shell.qml
        EOF

        chmod +x $out/bin/minos
      '';
    };

    homeManagerModules.default = import ./module.nix {
      inherit self;
    };
  };
}
