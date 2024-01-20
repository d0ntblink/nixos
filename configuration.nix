# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  ## IMPORTS
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      <home-manager/nixos>
    ];
  
  ## System Settings
  system = {
    copySystemConfiguration = true;
    autoUpgrade = {
      enable = true;
      persistent = true;
      allowReboot = true;
      flags = ["--keep-going" "--upgrade-all"];
      # channel = "https://channels.nixos.org/nixos-23.05";
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
    pulseaudio = {
      enable = false;
      support32Bit = true;
      daemon.config = {
        default-sample-format = "float32le";
        default-sample-rate = 48000;
        alternate-sample-rate = 44100;
        default-sample-channels = 2;
        default-channel-map = "front-left,front-right";
        default-fragments = 2;
        default-fragment-size-msec = 125;
        resample-method = "soxr-vhq";
        enable-lfe-remixing = "no";
        high-priority = "yes";
        nice-level = -11;
        realtime-scheduling = "yes";
        realtime-priority = 9;
        rlimit-rtprio = 9;
        daemonize = "no";
      };
    };
    # video = {
    #   hidpi.enable = true;
    # };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      prime = {
        sync.enable = true;
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
    overlays = [
      (self: super: {
        # Add the nix-gaming overlay.
        nix-gaming = super.nixpkgs.callPackage ./nix-gaming-overlay.nix {};
      })
      (final: prev: {
        steam = prev.steam.override ({ extraPkgs ? pkgs': [], ... }: {
          extraPkgs = pkgs': (extraPkgs pkgs') ++ (with pkgs'; [
            libgdiplus
          ]);
        });
      })
    ];
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
      permittedInsecurePackages = [
        "openssl-1.1.1v"
        "openssl-1.1.1w"
        "python-2.7.18.6"
        "zotero-6.0.26"
        "electron-24.8.6"
        "electron-19.1.9"
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
    initrd.luks.devices."luks-b76382ad-1cdf-4dac-beb3-54c8efb94460".device = "/dev/disk/by-uuid/b76382ad-1cdf-4dac-beb3-54c8efb94460";
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
      extraGroups = [ "wheel" "kvm" "input" "disk" "libvirtd" "vboxusers" "tss" "networkmanager"];
      packages = with pkgs; [
        yt-dlp
        youtube-tui
        librewolf
        microsoft-edge-dev
        qutebrowser
        notion-app-enhanced
        thunderbird
        rustdesk
        discord
        signal-desktop
        element-desktop
        plexamp
        plex-media-player
        gh
        github-desktop
        lutris
        gimp
        # davinci-resolve
        libreoffice
        qbittorrent
        torrenttools
        chromium
        onedrive
        vscode
        tailscale
        trayscale
        tailscale-systray
        ansible
        protonmail-bridge
        protonvpn-cli_2
        # protonvpn-gui
        # protonvpn-cli
        bitwarden
        bitwarden-cli
        # postman
        telegram-desktop 
        monero-gui
        monero-cli
        xmrig
        heroic
        prismlauncher
        steam
        steam-run
        (steam.override {
          # nativeOnly = true;
          # withPrimus = true; # Enable Primus support
          # withJava = true; # Enable Java support
          extraPkgs = pkgs: [ 
            mono
            gtk3
            gtk3-x11
            libgdiplus
            zlib
            bumblebee
            glxinfo
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
        }).run
        (lutris.override {
          extraPkgs = pkgs: [
            # List package dependencies here
            wineWowPackages.stable
            # wineWowPackages.staging
            wine
            winetricks
          ];
        })
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
      "pipewire/pipewire.conf.d/default.conf".text = ''
      context.properties = {
        default.clock.rate = 96000
        default.clock.quantum = 2048  
        default.clock.min-quantum = 512
        default.clock.max-quantum = 4096
    }
    '';
    };
    systemPackages = with pkgs; [
      vim
      glibc
      haskellPackages.gtk-sni-tray
      snixembed
      haskellPackages.status-notifier-item
      pantheon-tweaks
      wingpanel-indicator-ayatana
      wget
      busybox
      toybox
      # tor
      apparmor-pam
      apparmor-parser
      apparmor-profiles
      apparmor-utils
      home-manager
      appimage-run
      git
      zotero
      # qnotero
      hplip
      pipecontrol
      rnnoise-plugin
      helvum
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
      (python3.withPackages(ps: with ps; [requests tqdm matplotlib cryptography]))
      virtualenv
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
      p7zip
      pax
      ncompress
      burpsuite
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
      ffmpeg
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
      xorg.xrefresh
      autorandr
      rpi-imager
      etcher
      wineWowPackages.stable
      # wineWowPackages.staging
      wine
      winetricks
      qemu (
        pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
          qemu-system-x86_64 \
            -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
            "$@" ''
      )
    ];
    variables = { 
      EDITOR = "code";
      SHELL = "/run/current-system/sw/bin/fish";
      SUDO_EDITOR = "code";
      VISUAL = "code";
      BROWSER = "librewolf";
      TERMINAL = "wezterm";
      TERM_PROGRAM = "wezterm";
      TERM = "wezterm";
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
    gamemode.enable = true;
    dconf.enable = true;
    fish.enable = true;
    xwayland.enable = true;
    pantheon-tweaks.enable = true;
    java = {
      enable = true;
    };
    firejail = {
      enable = true;
      wrappedBinaries = {
        tor-browser = {
          executable = "${pkgs.tor-browser-bundle-bin}/bin/tor-browser";
          profile = "${pkgs.firejail}/etc/firejail/tor-browser_en-US.profile";
          desktop = "${pkgs.tor-browser-bundle-bin}/share/applications/torbrowser.desktop";
          extraArgs = [
            # Enforce dark mode
            "--env=GTK_THEME=Adwaita:dark"
            # Enable system notifications
            "--dbus-user.talk=org.freedesktop.Notifications"
          ];
        };
        tor = {
          executable = "${pkgs.tor}/bin/tor";
          profile = "${pkgs.firejail}/etc/firejail/tor.profile";
        };
      };
    };
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
    chromium = {
      enable = true;
      homepageLocation = "https://start.duckduckgo.com";
      defaultSearchProviderEnabled = true;
      defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "ahkbmjhfoplmfkpncgoedjgkajkehcgo" # The Great Suspender
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
        # "gphhapmejobijbbhgpjhcjognlahblep" # GNOME Shell integration
      ];
      extraOpts = {
        "BrowserSignin" = 0;
        "ExtensionsUIDeveloperMode" = true;
        "ExtensionAllowPrivateBrowsingByDefault" = true;
        "ExtensionAllowedTypes" = [
          "extension"
          "user_script"
        ];
        "BlockThirdPartyCookies" = true;
        "BlockExternalExtensions" = false;
        "ExtensionSettings" = {
          "installation_mode" = "allowed";
        };
        "SyncDisabled" = true;
        "SearchSuggestEnabled"  = false;
        "DefaultBrowserSettingEnabled" = false;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SavingBrowserHistoryDisabled" = true;
        "SpellcheckLanguage" = [
                                "en-CA"
                                "en-US"
        ];
      };
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
    hardware = {
      bolt.enable = true;
    };
    tailscale = {
      enable  = true;
      package = pkgs.tailscale;
    };
    gvfs = {
      enable = true;
      package = pkgs.gvfs;
    };
    gnome = {
      gnome-keyring.enable = true;
    };
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
        extraWingpanelIndicators = with pkgs; [ wingpanel-indicator-ayatana ];
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
      pulse.enable = true;
      jack.enable = true;
      audio.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
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
    dbus = {
      apparmor = "enabled";
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
    user = {
      services = {
        indicatorapp = {
          description = "indicator-application-gtk3";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.indicator-application-gtk3}/libexec/indicator-application/indicator-application-service";
            restart = "always";
          };
        };
        # protonmail-bridge = {
        #   description = "protonmail-bridge";
        #   wantedBy = [ "graphical-session.target" ];
        #   serviceConfig = {
        #     ExecStart = "screen -S d0ntblink -dm protonmail-bridge --cli";
        #     User = "d0ntblink";
        #     # restart = "always";
        #   };
        #   after = [ "indicatorapp.service" ];
        #   partOf = [ "graphical-session.target" ];
        # };
        flameshot = {
          description = "flameshot";
          wantedBy = [ "graphical-session.target" ];
          after = [ "indicatorapp.service" ];
          partOf = [ "graphical-session.target" ];
          script = "${pkgs.flameshot}/bin/flameshot";
        };
        kdeconnect-indicator = {
          description = "kdeconnect-indicator";
          wantedBy = [ "graphical-session.target" ];
          after = [ "indicatorapp.service" ];
          partOf = [ "graphical-session.target" ];
          script = "${pkgs.plasma5Packages.kdeconnect-kde}/bin/kdeconnect-indicator";
        };
      };
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;

  security = {
    rtkit.enable = true;
    chromiumSuidSandbox.enable = true;
    lockKernelModules = false;
    apparmor = {
      enable = true;
    };
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
