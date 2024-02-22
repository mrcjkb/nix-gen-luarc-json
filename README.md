# nix-gen-luarc-json

Generate a .luarc.json for Lua/Neovim devShells

## Usage

Apply this flake's overlay.
It provides a `mk-luarc-json` function,
which takes an attrset with the following arguments:

- `nvim`: The neovim package. Defaults to `neovim-unwrapped`.
- `neodev-types`: neodev.nvim types to add to the `workspace.library`.
  Defaults to `"stable"`.
- Plugins: List of Neovim plugins and/or luarocks packages.
  Defaults to an empty list.

## License

This flake is [licensed according to GPL version 2](./LICENSE),
with the following exception:

The license applies only to the Nix infrastructure provided by this
repository, including any modifications made to it.
Any software that uses this flake may be licensed under any
[OSI approved open source license](https://opensource.org/licenses/),
without being subject to the GPL version 2 license of this template.
