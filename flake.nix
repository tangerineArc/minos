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
      nativeBuildInputs = with pkgs; [
        qt6.wrapQtAppsHook
      ];

      buildInputs = with pkgs; [
        quickshell.packages.${system}.default
        qt6.qtbase
        qt6.qtdeclarative
        qt6.qtsvg
        qt6.qtwayland
        qt6.qt5compat
      ];

      shellHook = ''
        export QT_QPA_PLATFORM=wayland
        export QS_ICON_THEME="Adwaita"
        export QML2_IMPORT_PATH="${pkgs.qt6.qt5compat}/lib/qt-6/qml:''${QML2_IMPORT_PATH:-}"

        echo "Minos Quickshell Dev Shell loaded"
      '';
    };

    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = pname;
      src = ./.;

      installPhase = ''
        mkdir -p $out/share/minos
        cp -r *.qml components/ scripts/ $out/share/minos

        mkdir -p $out/bin
        cat <<EOF > $out/bin/minos
        #! /bin/sh
        export QS_ICON_THEME="Adwaita"
        export QML2_IMPORT_PATH="${pkgs.qt6.qt5compat}/lib/qt-6/qml:\$QML2_IMPORT_PATH"
        exec ${quickshell.packages.${system}.default}/bin/quickshell -p $out/share/minos/shell.qml "\$@"
        EOF

        chmod +x $out/bin/minos
        chmod -R +x $out/share/minos/scripts/
      '';
    };

    homeManagerModules.default = import ./module.nix {
      inherit self;
    };
  };
}
