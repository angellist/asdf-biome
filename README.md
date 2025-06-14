<div align="center">

# asdf-biome [![Build](https://github.com/angellist/asdf-biome/actions/workflows/build.yml/badge.svg)](https://github.com/angellist/asdf-biome/actions/workflows/build.yml) [![Lint](https://github.com/angellist/asdf-biome/actions/workflows/lint.yml/badge.svg)](https://github.com/angellist/asdf-biome/actions/workflows/lint.yml)

[biome](https://github.com/biomejs/biome) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).

# Install

Plugin:

```shell
asdf plugin add biome
# or
asdf plugin add biome https://github.com/angellist/asdf-biome.git
```

biome:

```shell
# Show all installable versions
asdf list-all biome

# Install specific version
asdf install biome latest

# Set a version globally (on your ~/.tool-versions file)
asdf global biome latest

# Now biome commands are available
biome --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/angellist/asdf-biome/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Alexander Stathis](https://github.com/stathis-alexander/)
