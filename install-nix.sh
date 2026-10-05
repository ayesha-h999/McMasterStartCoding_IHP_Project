sh <(curl -L https://nixos.org/nix/install)

. /home/vscode/.nix-profile/etc/profile.d/nix.sh

sudo apt update
sudo apt install direnv

nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
nix-env -iA cachix -f https://cachix.org/api/v1/install

mkdir -p ~/.config/direnv; touch ~/.config/direnv/direnv.toml; echo -e "[whitelist]\nprefix = ['/workspaces/']" >> ~/.config/direnv/direnv.toml
mkdir -p ~/.config/nix/; touch ~/.config/nix/nix.conf; echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
echo "trusted-users = root vscode" | sudo tee -a /etc/nix/nix.conf && sudo pkill nix-daemon; cachix use cachix; cachix use digitallyinduced;

sh ./usr/local/share/nix-entrypoint.sh; ( if [ ! -e "Main.hs" ]; then rm -rf /tmp/ihp-boilerplate; git clone https://github.com/digitallyinduced/ihp-boilerplate.git /tmp/ihp-boilerplate; rm -rf /tmp/ihp-boilerplate/.git; cp -r /tmp/ihp-boilerplate/. .; fi) && git add . && nix develop --accept-flake-config --impure --command make -s all;


if [ ! -d "Web" ]; then (nix develop --accept-flake-config --impure --command new-application Web) fi


echo -e "\n. ~/.nix-profile/etc/profile.d/nix.sh" >> ~/.bashrc

sudo apt install direnv; echo -e '\neval "$(direnv hook bash)"' >> ~/.bashrc

echo 'export IHP_BASEURL=$(if [ -n "${CODESPACE_NAME}" ]; then echo "https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"; else echo "http://localhost:8000"; fi)' >> ~/.bashrc
echo 'export APPROOT=$(if [ -n "${CODESPACE_NAME}" ]; then echo "https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"; else echo "http://localhost:8000"; fi)' >> ~/.bashrc
echo 'export IHP_IDE_BASEURL=$(if [ -n "${CODESPACE_NAME}" ]; then echo "https://${CODESPACE_NAME}-8001.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"; else echo "http://localhost:8001"; fi)' >> ~/.bashrc

sudo apt install acl; sudo setfacl -k /tmp

nix develop --accept-flake-config --impure --command make -s all

direnv allow
