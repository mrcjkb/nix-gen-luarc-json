# nix-gen-luarc-json

Generate a .luarc.json for Lua/Neovim devShells

## Usage

Apply this flake's overlay.
It provides a `mk-luarc-json` function,
which takes an attrset with the following arguments:

- `nvim`: The neovim package. Defaults to `neovim-unwrapped`.
- `plugins`: List of Neovim plugins and/or luarocks packages.
  Defaults to an empty list.
- `lua-version`: Defaults to `"5.1"`.
- `disabled-diagnostics`: Defaults to an empty list..

Example:

Import this flake:

```nix
#flake.nix
inputs.gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";
```

Add the overlay:

```nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [
    gen-luarc.overlays.default
  ];
};
```

Generate a `.luarc.json` in your `shellHook`:

```nix
shellHook = let
  luarc = pkgs.mk-luarc-json { plugins = with pkgs.vimPlugins; [ nvim-treesitter ]; };
in /* bash */ ''
  ln -fs ${luarc} .luarc.json
'';
```

## License

This flake is [licensed according to GPL version 2](./LICENSE),
with the following exception:

The license applies only to the Nix infrastructure provided by this
repository, including any modifications made to it.
Any software that uses this flake may be licensed under any
[OSI approved open source license](https://opensource.org/licenses/),
without being subject to the GPL version 2 license of this template.
