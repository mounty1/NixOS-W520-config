# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
	nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
		export __NV_PRIME_RENDER_OFFLOAD=1
		export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
		export __GLX_VENDOR_LIBRARY_NAME=nvidia
		export __VK_LAYER_NV_optimus=NVIDIA_only
		exec "$@"
	'';
in
{
	imports = [
		./hardware-configuration.nix
		./nvidia.nix
		./openvpn.nix
	];

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	boot.resumeDevice = "/dev/disk/by-label/swap";
	# Needed for myStream distribution directory creation.
	boot.kernel.sysctl."fs.protected_hardlinks" = false;

	swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

	networking.networkmanager = {
		enable = true;
		plugins = [ pkgs.networkmanager-openvpn ];
	};
	networking.hostName = "ida"; # Define your hostname.

	# Set your time zone.
	time.timeZone = "Australia/Brisbane";

	# The global useDHCP flag is deprecated, therefore explicitly set to false here.
	# Per-interface useDHCP will be mandatory in the future.
	networking.useDHCP = false;
	networking.interfaces = {
		enp0s25.useDHCP = true;
		wlp3s0.useDHCP = true;
		#vlan10.useDHCP = true;
	};
	#networking.vlans = {
	#	vlan10 = { id = 10; interface = "enp0s25"; };
	#};

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	# console = {
	#	font = "Lat2-Terminus16";
	#	keyMap = "us";
	# };

	fileSystems."/mnt/az-storage" =
		{ device = "//ngv.file.core.windows.net/office";
			fsType = "cifs";
			options = ["nofail" "noauto" "vers=3.0" "credentials=/root/az-storage.cred" "dir_mode=0777" "file_mode=0777" "serverino"];
		};

	fileSystems."/home/mounty/vault" =
		{ device = "/dev/disk/by-label/Vault";
			options = [ "noauto" "user" "rw" ];
		};

	fileSystems."/mnt/mymedia" =
		{ device = "172.16.47.8:/Media";
			fsType = "nfs";
			options = [ "nfsvers=3" "ro" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
		};

	services.xserver = {
		enable = true;
		# layout = "us";
		# xkbOptions = "eurosign:e";
		libinput.enable = true;
		displayManager.lightdm = {
			enable = true;
			# autoLogin.minimumUid = 500;
		};
		desktopManager = {
			cinnamon.enable = true;
		};
		displayManager.defaultSession = "cinnamon";
	};

	# Enable CUPS to print documents.
	services.printing.enable = true;

	# Enable sound.
	sound.enable = true;
	hardware.opengl.enable = true;
	hardware.pulseaudio.enable = true;
	nixpkgs.config.allowUnfree = true;

	users.users.mounty = {
		name = "mounty";
		description = "Michael Mounteney";
		home = "/home/mounty";
		shell = pkgs.bash;
		group = "users";
		uid = 573;
		createHome = false;
		extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
	};

	users.groups.trove = {
		gid = 1002;
	};

	# For mystream
	users.users.trove = {
		isNormalUser = true;
		name = "trove";
		description = "Mystream content owner";
		group = "trove";
		uid = 1002;
		createHome = false;
		shell = pkgs.shadow;
	};

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		# hardware and firmware
		pciutils usbutils nvidia-offload
		glmark2
		efibootmgr
		# Desktop
		cinnamon.cinnamon-common
		cinnamon.cinnamon-control-center
		cinnamon.cinnamon-settings-daemon
		cinnamon.cinnamon-session
		cinnamon.cinnamon-menus
		cinnamon.cinnamon-translations
		cinnamon.cinnamon-screensaver
		cinnamon.cinnamon-desktop
		gnome.gnome-screenshot
		shotwell
		# CLI
		nix-index binutils-unwrapped
		mysql-client postgresql
		file
		powershell
		gnupg unzip zip zlib.dev unrar
		tcpdump
		jq
		# Programming CLI
		gcc11 rustc cargo nodejs jdk openjdk kotlin php82
		git vim gh mercurial vim_configurable
		# python python3Full
		(python310.withPackages(ps: with ps; [
			pip
			setuptools
			psycopg2
			flask_sqlalchemy
			sqlalchemy
			flask
			requests
		]))
		jetbrains.idea-ultimate maven spring-boot
		awscli azure-cli stripe-cli
		# For building stripe-payments-proxy:
		azure-functions-core-tools
		# Desktop
		gnumeric
		libreoffice
		simplescreenrecorder
		vlc
		tigervnc
		gimp
		ffmpeg
		wine
		# mystream
		youtube-dl yt-dlp
		# Network CLI
		wget openssl putty inetutils networkmanager teamviewer x11vnc
		# Documentation
		graphviz
		(pkgs.texlive.combine {
			inherit (pkgs.texlive) scheme-full pgf ;
		})
		# Browsers
		firefox chromium
	];

	services.postgresql = {
		enable = true;
		package = pkgs.postgresql_14;
		dataDir = "/home/mounty/NGV/.PG14";
		enableTCPIP = true;
		initialScript = pkgs.writeText "backend-initScript" ''
			CREATE ROLE mediaman WITH LOGIN PASSWORD 'zem56$W7' CREATEDB;
			CREATE DATABASE mystream;
			GRANT ALL PRIVILEGES ON DATABASE mystream TO mediaman;
			'';
	};

	services.teamviewer.enable = true;

	environment.cinnamon.excludePackages = [
		pkgs.gnome.geary
	];

	programs.evolution = {
		enable = true;
		plugins = [ pkgs.evolution-ews ];
	};

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	enable = true;
	#	enableSSHSupport = true;
	# };
	programs.command-not-found.enable = true;

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		settings = {
			PasswordAuthentication = false;
		};
		ports = [ 3887 ];
	};

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	networking.firewall.enable = false;

	# Enables deployment of Kitten to Azure with private net and DNS
	networking.extraHosts = ''
10.245.0.5	rabbitv2-staging.azurewebsites.net
10.245.0.5	rabbitv2-staging.scm.azurewebsites.net
10.245.0.4	rabbitv2.azurewebsites.net
10.245.0.4	rabbitv2.scm.azurewebsites.net
	'';

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.11";
}
