{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.trezord;
in
{

  ### docs

  meta = {
    doc = ./trezord.md;
  };

  ### interface

  options = {
    services.trezord = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable Trezor bridge daemon, for use with Trezor hardware bitcoin wallets.
        '';
      };

      emulator.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable Trezor emulator support.
        '';
      };

      emulator.port = lib.mkOption {
        type = lib.types.port;
        default = 21324;
        description = ''
          Listening port for the Trezor emulator.
        '';
      };
    };
  };

  ### implementation

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.trezor-udev-rules ];

    systemd.services.trezord = {
      description = "Trezor Bridge";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.trezord}/bin/trezord-go ${lib.optionalString cfg.emulator.enable "-e ${builtins.toString cfg.emulator.port}"}";
        User = "trezord";
      };
    };

    users.users.trezord = {
      group = "trezord";
      description = "Trezor bridge daemon user";
      isSystemUser = true;
    };

    users.groups.trezord = { };
  };
}
