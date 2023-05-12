{ config, pkgs, lib, ... }:

{
	services.xserver.videoDrivers = [ "nvidia" ];

	hardware.nvidia = {
		package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
		modesetting.enable = true;
		prime = {
			# offload.enable = true;
			sync.enable = true;

			# Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
			nvidiaBusId = "PCI:1:0:0";

			# Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
			intelBusId = "PCI:0:2:0";
		};
	};
}
