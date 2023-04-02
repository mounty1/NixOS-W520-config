{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		stack
		gnumake
		dosbox
	];
}
