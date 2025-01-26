{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.programs.perf.enable = lib.mkEnableOption "perf, tools to analyze performance on linux";

  config = lib.mkIf config.programs.perf.enable {

    security.wrappers.perf = {
      #source = lib.getExe config.boot.kernelPackages.perf; # this doesn't work because it's a wrapping script and capabilities are not transitive by design
      source = "${config.boot.kernelPackages.perf}/bin/.perf-wrapped";
      owner = "root";
      group = "wheel";
      permissions = "u+rx,g+rx";
      # cap_dac_override - required to access and modify files in tracefs
      capabilities = "cap_sys_rawio,cap_dac_override,cap_perfmon,cap_bpf,cap_sys_ptrace,cap_ipc_lock,cap_syslog+pe";
    };

    # Perf takes a look at vmlinux file for debug symbols
    system.extraSystemBuilderCmds = ''
      ln -s ${config.boot.kernelPackages.kernel.dev}/vmlinux $out/vmlinux
    '';
  };
}
