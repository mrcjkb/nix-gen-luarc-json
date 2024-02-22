{
  description = "Generate a .luarc.json for Lua/Neovim devShells";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];
      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };
        luarc = pkgs.mk-luarc-json {
          plugins = with pkgs.vimPlugins; [telescope-nvim fidget-nvim];
        };
      in {
        devShells.default = pkgs.mkShell {
          shellHook = ''
            ln -fs ${pkgs.luarc-to-json luarc} .luarc.json
          '';
        };
      };
      flake = {
        overlays.default = final: prev: {
          mk-luarc = {
            # list of plugins that have a /lua directory
            nvim ? final.neovim-unwrapped,
            neodev-types ? "stable",
            plugins ? [],
            lua-version ? "5.1",
          }: let
            partitions = builtins.partition (plugin:
              builtins.hasAttr "vimPlugin" plugin
              && plugin.vimPlugin
              || plugin.pname == "nvim-treesitter")
            plugins;
            nvim-plugins = partitions.right;
            rocks = partitions.wrong;
            plugin-luadirs = builtins.map (plugin: "${plugin}/lua") nvim-plugins;
            pkg-libdirs = builtins.map (pkg: "${pkg}/lib/lua/${lua-version}") rocks;
            pkg-sharedirs = builtins.map (pkg: "${pkg}/share/lua/${lua-version}") rocks;
          in {
            runtime.version = "LuaJIT";
            Lua = {
              globals = [
                "vim"
              ];
              workspace = {
                library =
                  [
                    "${nvim}/share/nvim/runtime/lua"
                    "${final.vimPlugins.neodev-nvim}/types/${neodev-types}"
                    "\${3rd}/busted/library"
                    "\${3rd}/luassert/library"
                  ]
                  ++ plugin-luadirs
                  ++ pkg-libdirs
                  ++ pkg-sharedirs;
                ignoreDir = [
                  ".git"
                  ".github"
                  ".direnv"
                  "result"
                  "nix"
                  "doc"
                ];
              };
              diagnostics = {
                libraryFiles = "Disable";
                disable = [];
              };
            };
          };
          luarc-to-json = luarc:
            final.runCommand ".luarc.json" {
              buildInputs = [
                final.jq
              ];
              passAsFile = ["rawJSON"];
              rawJSON = builtins.toJSON luarc;
            } ''
              {
                jq . <"$rawJSONPath"
              } >$out
            '';
          mk-luarc-json = attrs: final.luarc-to-json (final.mk-luarc attrs);
        };
      };
    };
}
