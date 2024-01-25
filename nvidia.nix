{ config, pkgs, lib, ... }:

{
	services.xserver.videoDrivers = [ "modesetting" ];

	# hardware.nvidia.modesetting.enable = true;
}
