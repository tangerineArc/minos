{self}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.minos;
in {
  options.services.minos = {
    enable = lib.mkEnableOption "Minos Shell";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The Minos package to run.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services.minos = {
      Unit = {
        Description = "Minos Shell";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/minos";
        Restart = "on-failure";
        RestartSec = "2";
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
