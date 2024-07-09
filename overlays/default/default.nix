{ inputs, ... }:
(final: prev:
let
  binaryName = "Discord";


  patch-krisp = prev.writeScript "patch-krisp" ''
    discord_version="${prev.discord.version}"
    file="$HOME/.config/discord/$discord_version/modules/discord_krisp/discord_krisp.node"
    if [ -f "$file" ]; then
    addr=$("${prev.rizin}/bin/rz-find" -x '4881ec00010000' "$file" | head -n1)
    "${prev.rizin}/bin/rizin" -q -w -c "s $addr + 0x30 ; wao nop" "$file"
    fi
  '';
in
{
  inherit patch-krisp;
  vesktop = (prev.vesktop.override {
    withSystemVencord = false;
  });




  gnome = prev.gnome.overrideScope (gfinal: gprev: {
    gnome-keyring = gprev.gnome-keyring.overrideAttrs (oldAttrs: {
      configureFlags = oldAttrs.configureFlags or [ ] ++ [
        "--disable-ssh-agent"
      ];
    });
  });
  tpm2-pkcs11 = prev.tpm2-pkcs11.override { fapiSupport = false; };
  patch-discord = prev.discord.overrideAttrs (previousAttrs: {
    postInstall =
      previousAttrs.postInstall
      + ''
        wrapProgramShell $out/opt/${binaryName}/${binaryName} \
        --run "${patch-krisp}"
      '';
    passthru = removeAttrs previousAttrs.passthru [ "updateScript" ];
    meta =
      {
        # nyx.bypassLicense = true;
      }
      // previousAttrs.meta;
  });
})
