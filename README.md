<div align="center">
  <a href="https://slipless.xyz">
    <img src=".github/logo.svg" width="140" alt="Slipless" />
  </a>
</div>

<h1 align="center">@slipless/universal-router</h1>

<p align="center"><strong>Multi-step swap router. V2 + V3 + perps in a single transaction.</strong></p>

<p align="center">
  <a href="https://github.com/slipless-dex/universal-router/actions"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/slipless-dex/universal-router/ci.yml?branch=main&style=flat-square&color=5cd8ff&label=ci"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-ff6bdb?style=flat-square"></a>
  
</p>

<p align="center">
  <a href="https://slipless.xyz">Site</a> &middot;
  <a href="https://app.slipless.xyz">App</a> &middot;
  <a href="https://docs.slipless.xyz">Docs</a> &middot;
  <a href="https://twitter.com/slipless">Twitter</a>
</p>

---

Single-entrypoint multi-step swap router for Slipless. Decodes a packed `bytes` command stream and dispatches to V2 / V3 / perp / native modules — V2 spot, V3 concentrated, and perp fills can all happen in one transaction.

## Layout

```
src/
  UniversalRouter.sol   entry point: execute(commands, inputs, deadline)
  Commands.sol          opcode space (mirrored in @slipless/router-sdk)
  Dispatcher.sol        decodes one command and dispatches to a module
  modules/
    V2SwapModule.sol    constant-product swaps
    V3SwapModule.sol    concentrated-liquidity swaps
    PerpFillModule.sol  Slipless LimitOrderProtocol fills
    NativeModule.sol    wrap / unwrap WETH
ts/
  src/abi.ts            viem-typed ABI
  src/index.ts          re-exports the Commands enum
```

Build:

```bash
forge install
forge build
forge test
```

## License

MIT © Slipless Labs
