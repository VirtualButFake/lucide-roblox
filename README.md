<div align="center">

# lucide-roblox

A simple library for easy access to the entire [Lucide Icons](https://lucide.dev/icons/) set, in Roblox.

[![License](https://img.shields.io/github/license/virtualbutfake/lucide-roblox)](https://github.com/VirtualButFake/lucide-roblox/blob/master/LICENSE.md)
[![CI](https://github.com/virtualbutfake/lucide-roblox/actions/workflows/ci.yml/badge.svg)](https://github.com/virtualbutfake/lucide-roblox/actions)

</div>

[![Wally](./assets/wally-badge.svg)](https://wally.run/package/virtualbutfake/lucide-roblox)
[![Roblox](./assets/roblox-badge.svg)](https://github.com/virtualbutfake/lucide-roblox/releases/)

## Credits

This library would not have existed without [this](https://github.com/latte-soft/lucide-roblox) library; lucide-roblox came to be after I found myself wanting different sizes of the icons, but Tarmac was broken and didn't allow me to resize the icons, leading to me writing my own way of creating these icons.

**If you are looking for 48px and 256px icons, please use the original library. This library is a bandaid fix and once Tarmac is fixed, there is no reason to use this over the original library.**

## Installation

### Wally (recommended)

lucide-roblox is available on Wally, and can be installed by adding `lucide-roblox = "virtualbutfake/lucide-roblox@1.1.2"` to your wally.toml.

### Roblox

lucide-roblox is available through Roblox if you don't use Wally, and can be installed by adding the latest release to your game and then requiring it.

## Usage

lucide-roblox is extremely straightforward:

```lua
local lucide = require(path.to.lucide-roblox)
local icon = lucide.GetAsset("name", size) -- conveniently mimics the original lucide-roblox API, so you can easily port your code back later
```

The complete list of icons can be found [here](./md/icon-index.md)

## Updating

In order to update the definitions of the icons, you can run the following command:

```bash
lune run lune/setup
```

This will pull the latest icons, process them, add them to Tarmac and update the icons in the package. If any new icons appear, feel free to open a PR to add them.

## License

lucide-roblox is licensed under the MIT License. See [LICENSE](./LICENSE.md) for more information.
Lucide Icons is licensed under the [ISC License](https://github.com/lucide-icons/lucide/blob/main/LICENSE).
