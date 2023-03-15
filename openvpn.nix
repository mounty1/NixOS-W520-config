# { config, pkgs, ... }:

{
	services = {
		openvpn.servers = {
			office = {
				config = '' config /root/office-untangle.conf '';
				autoStart = false;
				updateResolvConf = true;
			};
		};
                transmission.enable = true;
	};
}
