{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.allenyou.motd;
  displayBanner =
    if cfg.banner == null then
      ""
    else
      ''
        echo "${builtins.replaceStrings [ "\\" "`" ] [ "\\\\" "\\`" ] cfg.banner}" | lolcat
      '';
  displayDescription =
    if cfg.description == null then
      ""
    else
      ''
        printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Role" "${cfg.description}"
      '';
  motd = pkgs.writeShellScriptBin "motd" ''
    		#! /usr/bin/env bash
        [[ $- != *i* ]] && return
    		source /etc/os-release
    		RED="\e[31m"
    		GREEN="\e[32m"
    		BOLD="\e[1m"
    		ENDCOLOR="\e[0m"
    		LOAD1=`cat /proc/loadavg | awk {'print $1'}`
    		LOAD5=`cat /proc/loadavg | awk {'print $2'}`
    		LOAD15=`cat /proc/loadavg | awk {'print $3'}`

    		MEMORY=`free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100 / $2 }'`

    		# time of day
    		HOUR=$(date +"%H")
    		if [ $HOUR -lt 12  -a $HOUR -ge 0 ]
    		then TIME="morning"
    		elif [ $HOUR -lt 17 -a $HOUR -ge 12 ]
    		then TIME="afternoon"
    		else
    			TIME="evening"
    		fi


    		uptime=`cat /proc/uptime | cut -f1 -d.`
    		upDays=$((uptime/60/60/24))
    		upHours=$((uptime/60/60%24))
    		upMins=$((uptime/60%60))
    		upSecs=$((uptime%60))

    		${displayBanner}

    		printf "$BOLD Welcome to $(hostname)!$ENDCOLOR\n"
    		${displayDescription}
    		printf "\n"
    		printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Release" "$PRETTY_NAME"
    		printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Kernel" "$(uname -rs)"
    		[ -f /var/run/reboot-required ] && printf "\n$RED  * %-20s$ENDCOLOR %s\n" "A reboot is required"
    		printf "\n"
    		printf "$BOLD  * %-20s$ENDCOLOR %s\n" "CPU usage" "$LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)"
    		printf "$BOLD  * %-20s$ENDCOLOR %s\n" "Memory" "$MEMORY"
    		printf "$BOLD  * %-20s$ENDCOLOR %s\n" "System uptime" "$upDays days $upHours hours $upMins minutes $upSecs seconds"

    		printf "\n"
    	'';
in
{
  options.system.allenyou.motd = {
    enable = lib.mkEnableOption "MOTD";
    banner = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Banner to display before the MOTD. Leave empty to disable.";
    };
    description = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Description of the server. Leave empty to disable.";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      motd
      pkgs.lolcat
    ];
    programs.bash.interactiveShellInit = lib.mkIf config.programs.bash.enable ''
      motd
    '';
  };
}
