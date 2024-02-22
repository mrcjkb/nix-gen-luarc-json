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
      flake = {
        overlays.default = final: prev: {
          mk-luarc-json = {
            # list of plugins that have a /lua directory
            nvim ? final.neovim-unwrapped,
            neodev-types ? "stable",
            plugins ? [],
          }: let
            lib = final.lib;
            plugin-lib-dirs = lib.lists.map (plugin:
              if
                builtins.hasAttr "vimPlugin" plugin
                && plugin.vimPlugin
                || plugin.pname == "nvim-treesitter"
              then "${plugin}/lua"
              else "${plugin}/lib/lua/5.1")
            plugins;
            luarc = {
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
                    ++ plugin-lib-dirs;
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
          in
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
        };
      };
    };
}
