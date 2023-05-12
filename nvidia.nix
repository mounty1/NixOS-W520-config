{ config, pkgs, lib, ... }:

{
	services.xserver.videoDrivers = [ "nouveau" ];
}
