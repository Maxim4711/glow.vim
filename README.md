# glow.vim

A Vim plugin for previewing Markdown files using [glow](https://github.com/charmbracelet/glow) in a synchronized vertical split.

This plugin is a Vimscript reimplementation of the original idea from [glow.nvim](https://github.com/ellisonleao/glow.nvim), bringing the same functionality to classic Vim users.

## Features

- 📖 **Live Preview**: Real-time Markdown rendering using glow
- 🔄 **Synchronized Scrolling**: Preview window follows your cursor position
- ⚡ **Auto-update**: Preview updates on text changes and file saves
- 🎨 **Configurable**: Customizable glow settings and appearance
- 🪟 **Split View**: Clean vertical split layout
- ⌨️  **Simple Commands**: Easy-to-use commands and key mappings

## Requirements

- Vim 8.0+ or Neovim
- [glow](https://github.com/charmbracelet/glow) binary installed

## Installation

### Using vim-plug

```vim
Plug 'Maxim4711/glow.vim'
```

### Using Vundle

```vim
Plugin 'Maxim4711/glow.vim'
```

### Using Pathogen

```bash
cd ~/.vim/bundle
git clone https://github.com/Maxim4711/glow.vim.git
```

### Manual Installation

1. Download the plugin files
2. Copy the directories to your Vim configuration:
   - `plugin/glow.vim` → `~/.vim/plugin/`
   - `autoload/glow.vim` → `~/.vim/autoload/`
   - `doc/glow.txt` → `~/.vim/doc/`

## Installing Glow

### macOS (Homebrew)
```bash
brew install glow
```

### Linux (most distributions)
```bash
# Arch Linux
sudo pacman -S glow

# Ubuntu/Debian (via snap)
sudo snap install glow

# Or download from GitHub releases
curl -s https://api.github.com/repos/charmbracelet/glow/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep linux | wget -i -
```

### Windows
Download from [Glow releases](https://github.com/charmbracelet/glow/releases)

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:GlowToggle` | Toggle the preview window |
| `:GlowOpen` | Open the preview window |
| `:GlowClose` | Close the preview window |
| `:GlowToggleSync` | Toggle scroll synchronization |

### Default Key Mappings

| Key | Command |
|-----|---------|
| `<Leader>p` | Toggle preview window |
| `<Leader>P` | Toggle scroll synchronization |

## Configuration

Add these options to your `.vimrc`:

```vim
" Set glow binary path (default: 'glow')
let g:glow_binary_path = '/usr/local/bin/glow'

" Set preview width in characters (default: 80)
let g:glow_width = 100

" Set glow style theme (default: 'auto')
" Options: 'auto', 'dark', 'light', 'notty'
let g:glow_style = 'dark'

" Enable pager mode (default: 0)
let g:glow_pager = 1

" Disable default key mappings (default: 0)
let g:glow_disable_default_mappings = 1

" Disable scroll synchronization by default (default: 1)
let g:glow_sync_scroll = 0
```

### Custom Key Mappings

If you disabled default mappings, you can create your own:

```vim
" Custom mappings
nnoremap <silent> <F5> :GlowToggle<CR>
nnoremap <silent> <F6> :GlowToggleSync<CR>
```

## How It Works

1. **Preview Generation**: The plugin captures your Markdown buffer content and passes it to the `glow` binary
2. **Split Management**: Creates and manages a vertical split window for the preview
3. **Synchronization**: Calculates relative scroll positions to keep source and preview in sync
4. **Auto-updates**: Uses Vim's autocmd system to update the preview on text changes

## Troubleshooting

### Glow not found
```
Error: Glow binary not found at: glow
```
**Solution**: Install glow or set the correct path:
```vim
let g:glow_binary_path = '/path/to/glow'
```

### Preview not updating
- Ensure you're editing a `.md` file
- Check if glow is executable: `:!which glow`
- Try manually refreshing: `:GlowClose` then `:GlowOpen`

### Scroll sync issues
- Toggle sync off and on: `:GlowToggleSync`
- Check that both windows are visible

## Acknowledgments

This plugin is inspired by and reimplements the functionality of [glow.nvim](https://github.com/ellisonleao/glow.nvim) by [@ellisonleao](https://github.com/ellisonleao). The original Lua implementation for Neovim provided the foundation for this Vimscript version.

Special thanks to:
- [Charm](https://github.com/charmbracelet) for the excellent `glow` terminal markdown reader
- The original `glow.nvim` contributors for the plugin concept

## License

MIT License - see LICENSE file for details.

## Contributing

Issues and pull requests are welcome! Please feel free to contribute improvements or report bugs.
