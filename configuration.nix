# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  ## IMPORTS
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos> 
    ];
  
  ## System Settings
  system = {
    copySystemConfiguration = true;
    autoUpgrade = {
      enable = true;
      persistent = true;
      allowReboot = true;
      flags = [];
      channel = "https://channels.nixos.org/nixos-23.05";
    };
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "23.05"; # Did you read the comment?
  };

  ## Hardware settings (Intel i9-8950HK, NVIDIA Quadro P2000 Mobile)
  hardware = {
    pulseaudio.support32Bit = true;
    pulseaudio.enable = false;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;
      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Do not disable this unless your GPU is unsupported or if you have a good reason to.
      open = false;
      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.production;
      prime = {
        sync.enable = true;
        # Make sure to use the correct Bus ID values for your system!
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };

  ## Nix Package Manager settings
  nix = {
    settings = {
      substituters = ["https://nix-gaming.cachix.org"];
      trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
  
  ## NixPKGs settings
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (pkg: builtins.elem (builtins.parseDrvName pkg.name).name [ "steam" ]);
      permittedInsecurePackages = [
        "openssl-1.1.1v"
        "python-2.7.18.6"
      ];
    };
  };

  ## Kernel.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModprobeConfig = ''
      options snd slots=snd_hda_codec_realtek
      options snd_hda_intel enable=0,1
      options kvm_intel nested=1
    '';
    loader = {
      timeout = 10;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  ## Network settings
  networking = {
    firewall.enable = false;
    enableIPv6 = false;
    hostName = "w1ngz"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  ## USERS
  users = {
    defaultUserShell = "/run/current-system/sw/bin/fish";
    users.d0ntblink = {
      isNormalUser = true;
      home = "/home/d0ntblink";
      description = "d0ntblink";
      extraGroups = [ "wheel" "kvm" "input" "disk" "libvirtd" "vboxusers" "tss"];
      packages = with pkgs; [
        librewolf
        qutebrowser
        thunderbird
        discord
        signal-desktop
        element-desktop
        plex-media-player
        plexamp
        steam
        gh
        github-desktop
        steam-run
        lutris
        gimp
        # davinci-resolve
        libreoffice
        qbittorrent
        ungoogled-chromium
        onedrive
        vscode
        tailscale
        ansible
        protonvpn-gui
        protonmail-bridge
        protonvpn-cli_2
        bitwarden
        bitwarden-cli
        postman
        telegram-desktop 
      ];
    };
  };

  ## System Environments
  environment = {
    pathsToLink = [ "/libexec" ];
    etc = {
      "ovmf/edk2-x86_64-secure-code.fd" = {
        source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
      };
      "ovmf/edk2-i386-vars.fd" = {
        source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
      };
    };
    systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      busybox
      toybox
      home-manager
      appimage-run
      git
      hplip
      fish
      fishPlugins.tide
      powerline-go
      direnv
      indicator-application-gtk3
      coreutils-full
      zsh
      unzip
      jq
      wireguard-tools
      openvpn
      util-linux
      zathura
      nettools
      docker
      tshark
      wireshark
      ruby
      lua
      pipx
      groovy
      nmap
      (python3.withPackages(ps: with ps; [requests matplotlib]))
      # python
      # python.pkgs.pip
      vscode
      lshw
      wezterm
      weston
      kitty
      powershell
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      phodav
      win-virtio
      win-spice
      virtualbox
      swtpm
      libverto
      libguestfs
      guestfs-tools
      mpv
      neovim
      neofetch
      flatpak
      flameshot
      gcc
      gnulib
      gnutls
      gnubg
      gnuchess
      gnupg
      clang
      mangohud
      nfs-utils
      nodejs
      rustc
      rustup
      cargo
      ninja
      protonup-ng
      protonup-qt
      protontricks
      xorg.libX11
      xorg.libX11.dev
      xorg.libxcb
      xorg.libXft
      xorg.libXinerama
      xorg.xinit
      xorg.xinput
      qemu
      (
        pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
          qemu-system-x86_64 \
            -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
            "$@" ''
      )
      (lutris.override {
        extraPkgs = pkgs: [
          # List package dependencies here
          wineWowPackages.stable
          winetricks
        ];
      })
    ];
    variables = { 
      EDITOR = "code";
      SHELL = "/run/current-system/sw/bin/fish";
      SUDO_EDITOR = "code";
      VISUAL = "code";
      BROWSER = "librewolf";
      TERMINAL = "wezterm";
      TERM_PROGRAM = "wezterm";
    };
  };

  ## Fonts
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      nerdfonts
      corefonts
      google-fonts
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["FiraMono Nerd Font"];
        sansSerif = ["FiraCode Nerd Font"];
        serif = ["FiraCode Nerd Font"];
      };
    };
  };

  ## Theme settings
  qt = {
    enable = true;
    style = lib.mkForce "adwaita-dark";
    platformTheme = "gnome";
  };

  ## Program Specific Settings
  programs = {
    dconf.enable = true;
    fish.enable = true;
    kdeconnect = {
      enable = true;
      package = pkgs.plasma5Packages.kdeconnect-kde;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

  ## Virtualization and Containerzation
  virtualisation = {
    docker.enable = true;
    podman.enable = false;
    waydroid.enable = true;
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
      onBoot = "ignore";
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
      };
    };
  };

  ## Services
  services = {
    flatpak.enable = true;
    dbus.enable = true;
    openssh.enable = true;
    cron.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd = {
      enable = true;
      package = pkgs.phodav;
    };
    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint hplipWithPlugin ];
      browsing = true;
      defaultShared = true;
    };
    ntp = {
      enable = true;
      servers = [ "ca.pool.ntp.org" "0.ca.pool.ntp.org" "1.ca.pool.ntp.org" "2.ca.pool.ntp.org" "3.ca.pool.ntp.org" ];
    };
    xserver = {
      enable = true;
      autorun = true;
      desktopManager.pantheon = {
        enable = true;
        extraWingpanelIndicators = with pkgs; [ monitor wingpanel-indicator-ayatana];
      };
      displayManager.lightdm.enable = true;
      layout = "us";
      xkbVariant = "";
      libinput = {
        enable = true;
      };
      videoDrivers = ["nvidia"];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    logind = {
      # overrideStrategy = "asDropin";
      lidSwitch = "suspend-then-hibernate";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "ignore";
      killUserProcesses = true;
      extraConfig = ''
        HandlePowerKey=poweroff
        HandlePowerKeyLongPress=reboot
        IdleActionSec=15min
        # IdleAction=lock
      '';
    };
  };

  ## Systemd
  systemd = {
    services = {
      tune-usb-autosuspend = {
        description = "Disable USB autosuspend";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = { Type = "oneshot"; };
        unitConfig.RequiresMountsFor = "/sys";
        script = ''
          echo -1 > /sys/module/usbcore/parameters/autosuspend
          echo Y > /sys/module/usbcore/parameters/old_scheme_first
          echo Y > /sys/module/usbcore/parameters/use_both_schemes
        '';
      };
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;

  security = {
    rtkit.enable = true;
    lockKernelModules = false;
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}