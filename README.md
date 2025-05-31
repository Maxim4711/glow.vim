# glow.vim

A Vim plugin for previewing Markdown files using [glow](https://github.com/charmbracelet/glow) in a synchronized vertical split with beautiful color rendering.

This plugin is a Vimscript reimplementation of the original idea from [glow.nvim](https://github.com/ellisonleao/glow.nvim), bringing the same functionality to classic Vim users with enhanced color support.

## Features

- 📖 **Live Preview**: Real-time Markdown rendering using glow
- 🎨 **Rich Colors**: Custom ANSI renderer with beautiful syntax highlighting
- 🔄 **Synchronized Scrolling**: Preview window follows your cursor position
- ⚡ **Auto-update**: Preview updates on text changes
- 🪟 **Split View**: Clean vertical split layout
- ⌨️  **Simple Commands**: Easy-to-use commands and key mappings
- 🎯 **Pure Vimscript**: No external dependencies beyond glow

## Requirements

- Vim 8.0+ or Neovim
- [glow](https://github.com/charmbracelet/glow) binary installed
- `set termguicolors` for color support

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

## Quick Start

1. **Enable colors in your `.vimrc`:**
```vim
set termguicolors
let g:glow_use_colors = 1
let g:glow_render_colors = 1
```

2. **Open a markdown file and toggle preview:**
```vim
:edit README.md
<Leader>p
```

3. **Enjoy beautiful colored markdown preview!**

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
" Basic configuration for colored preview
set termguicolors                      " Required for colors
let g:glow_use_colors = 1              " Enable ANSI colors from glow
let g:glow_render_colors = 1           " Render colors in Vim

" Optional customization
let g:glow_binary_path = 'glow'        " Path to glow binary (default: 'glow')
let g:glow_width = 100                 " Preview width in characters (default: 80)
let g:glow_style = 'dark'              " Glow style theme (default: 'auto')
let g:glow_pager = 0                   " Enable pager mode (default: 0)
let g:glow_sync_scroll = 1             " Enable scroll sync (default: 1)

" Disable default key mappings
let g:glow_disable_default_mappings = 1
```

### Color Configuration

The plugin uses a custom ANSI renderer that creates beautiful colors for different markdown elements:

- **Headers** (`# Header`) → Bright red/pink with bold formatting
- **Bold text** (`**bold**`) → Bright green with bold formatting  
- **Italic text** (`*italic*`) → Light blue with italic formatting
- **Code blocks** (`` `code` ``) → Yellow highlighting
- **Links** (`[text](url)`) → Purple with underline

### Glow Style Options

| Style | Description |
|-------|-------------|
| `'auto'` | Automatically detect terminal theme (default) |
| `'dark'` | Dark theme with bright colors |
| `'light'` | Light theme |
| `'notty'` | Plain text without colors |

### Custom Key Mappings

If you disabled default mappings, you can create your own:

```vim
let g:glow_disable_default_mappings = 1

" Custom mappings
nnoremap <silent> <F5> :GlowToggle<CR>
nnoremap <silent> <F6> :GlowToggleSync<CR>
nnoremap <silent> <C-p> :GlowOpen<CR>
```

## How It Works

1. **Preview Generation**: Captures your Markdown buffer content and passes it to the `glow` binary with `FORCE_COLOR=1`
2. **ANSI Processing**: Custom Vimscript ANSI renderer parses color sequences and applies them as Vim highlighting
3. **Split Management**: Creates and manages a vertical split window for the preview
4. **Synchronization**: Calculates relative scroll positions to keep source and preview in sync
5. **Auto-updates**: Uses Vim's autocmd system to update the preview on text changes

## Color Rendering

This plugin features a **custom ANSI renderer** built in pure Vimscript that:

- ✅ **Parses glow's ANSI color sequences** without external dependencies
- ✅ **Maps formatting to Vim highlight groups** for optimal display
- ✅ **Handles complex sequences** like `;;1m` that other tools struggle with
- ✅ **Provides rich syntax highlighting** for all markdown elements
- ✅ **Works with any terminal and colorscheme**

Unlike solutions that depend on external plugins like AnsiEsc, this renderer is:
- **Faster**: No external command execution
- **More reliable**: No version compatibility issues  
- **More customizable**: Easy to modify colors and formatting
- **Lighter**: No additional plugin dependencies

## Troubleshooting

### Glow not found
```
Error: Glow binary not found at: glow
```
**Solution**: Install glow or set the correct path:
```vim
let g:glow_binary_path = '/path/to/glow'
```

### No colors in preview
**Solution**: Enable termguicolors and color rendering:
```vim
set termguicolors
let g:glow_use_colors = 1
let g:glow_render_colors = 1
```

### Preview not updating
- Ensure you're editing a `.md` file
- Check if glow is executable: `:!which glow`
- Try manually refreshing: `:GlowClose` then `:GlowOpen`

### Scroll sync issues
- Toggle sync off and on: `:GlowToggleSync`
- Check that both windows are visible

## Performance

The custom ANSI renderer is optimized for performance:
- **Minimal overhead**: Only processes visible content
- **Efficient highlighting**: Uses Vim's native `matchadd()` system
- **Smart caching**: Reuses highlight groups across updates
- **No external calls**: Everything happens within Vim

## Acknowledgments

This plugin is inspired by and reimplements the functionality of [glow.nvim](https://github.com/ellisonleao/glow.nvim) by [@ellisonleao](https://github.com/ellisonleao). The original Lua implementation for Neovim provided the foundation for this Vimscript version.

Special thanks to:
- [Charm](https://github.com/charmbracelet) for the excellent `glow` terminal markdown reader
- The original `glow.nvim` contributors for the plugin concept
- The Vim community for the inspiration to create a pure Vimscript solution

## License

MIT License - see LICENSE file for details.

## Contributing

Issues and pull requests are welcome! Please feel free to contribute improvements or report bugs.

