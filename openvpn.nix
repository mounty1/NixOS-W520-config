# { config, pkgs, ... }:

# Add `"x-systemd.requires=openvpn-officeVPN.service"` to remote mount options list
{
	services = {
		openvpn.servers = {
			office = {
				config = '' config /home/mounty/NGV/openvpn-michael-inline.ovpn '';
				autoStart = false;
				updateResolvConf = true;
			};
		};
                transmission.enable = true;
	};
}
