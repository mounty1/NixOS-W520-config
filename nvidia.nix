{ config, pkgs, ... }:

{
	boot.kernelPackages = pkgs.linuxPackages_5_15; # choices: 4_14 5_10 5_15 5_18 5_19

	services.xserver.videoDrivers = [ "nvidia" ];

	nixpkgs.config.allowUnfree = true;
	nixpkgs.config.nvidia.acceptLicense = true;

	hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.generic {
		version = "390.157";
	};

	hardware.nvidia.prime = {
		sync.enable = true;

		# Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
		nvidiaBusId = "PCI:1:0:0";

		# Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
		intelBusId = "PCI:0:2:0";
	};
}
