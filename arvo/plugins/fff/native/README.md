# fff_search native crate

Optional Rustler NIF over [fff-search](https://crates.io). When present, `Fff.Native.search/2` is provided by Rustler and used by `Fff.SearchTool`.

Without a Rust toolchain, the pure-Elixir path uses `rg` so the plugin still proves the load/activate/tool seam.
