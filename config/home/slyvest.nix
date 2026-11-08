{ config, lib, pkgs, ... }:
let
  cfg = config.services.slyvest;
  integration = lib.cleanSourceWith {
    src = ../../slyvest;
    filter = path: type: builtins.baseNameOf path != "__pycache__";
  };
  settings = pkgs.writeText "slyvest-service.json" (builtins.toJSON {
    journal = cfg.journal;
    state = cfg.stateDirectory;
    port = cfg.port;
    authoring = cfg.enableAuthoring;
    backupDirectory = cfg.backupDirectory;
    readinessTimeout = cfg.readinessTimeout;
    unit = "slyvest-viewer.service";
    runtimeName = "slyvest-viewer";
    buildFlake = "${integration}/build";
    builder = "${integration}/build/build.sh";
  });
  command = action: pkgs.writeShellScriptBin "slyvest-${action}" ''
    # No shell tracing: runtime capabilities must never enter diagnostics.
    set +x
    export PATH=${lib.makeBinPath [ pkgs.git pkgs.gh pkgs.nix pkgs.systemd pkgs.bash ]}:"$PATH"
    exec ${pkgs.python3}/bin/python3 ${integration}/manager.py --config ${settings} ${action} "$@"
  '';
  supervisor = command "serve";
  cleanup = command "cleanup";
in {
  options.services.slyvest = {
    enable = lib.mkEnableOption "personal loopback Slyvest user service";
    journal = lib.mkOption { type = lib.types.str; description = "Explicit existing absolute journal path. Never initialized or migrated."; };
    stateDirectory = lib.mkOption { type = lib.types.str; default = "${config.xdg.stateHome}/slyvest-service"; };
    port = lib.mkOption { type = lib.types.port; default = 0; description = "0 selects a dynamic loopback port."; };
    enableAuthoring = lib.mkOption { type = lib.types.bool; default = false; };
    backupDirectory = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; description = "Existing explicit backup destination; independent from authoring."; };
    readinessTimeout = lib.mkOption { type = lib.types.ints.between 5 120; default = 45; };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = lib.hasPrefix "/" cfg.journal && lib.hasPrefix "/" cfg.stateDirectory;
        message = "Slyvest journal and stateDirectory must be explicit absolute paths."; }
      { assertion = cfg.backupDirectory == null || lib.hasPrefix "/" cfg.backupDirectory;
        message = "Slyvest backupDirectory must be an absolute existing directory."; }
    ];
    home.packages = map command [ "url" "status" "update" "rollback" ];
    systemd.user.services.slyvest-viewer = {
      Unit = {
        Description = "Private loopback Slyvest journal viewer";
        ConditionPathExists = [ cfg.journal "${cfg.stateDirectory}/current/bin/slyvest-viewer" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${supervisor}/bin/slyvest-serve";
        ExecStopPost = "${cleanup}/bin/slyvest-cleanup";
        RuntimeDirectory = "slyvest-viewer";
        RuntimeDirectoryMode = "0700";
        UMask = "0077";
        KillSignal = "SIGINT";
        KillMode = "mixed";
        TimeoutStopSec = 30;
        Restart = "no";
        LimitCORE = 0;
        NoNewPrivileges = true;
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
