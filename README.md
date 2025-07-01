# AUDIO2MP3

This is a comprehensive Bash script that converts various audio file formats (e.g., `.wav`, `.flac`, `.ogg`, `.aac`, `.m4a`, `.alac`, `.aiff`, `.opus`) to `.mp3`. The script supports converting a single file or multiple audio files in a directory, with advanced features including recursive directory search, progress indicators, conversion statistics, metadata preservation, and multiple operation modes.

## Versions

**Current version**: 0.3.0

### What's New in v0.3.0

- ✨ **Dry Run Mode**: Preview operations with `--dry-run` before actual conversion
- 📊 **Progress Indicators**: Real-time progress bars for batch operations
- 📈 **Conversion Statistics**: Detailed summary with success/failure counts and timing
- 🔍 **Enhanced Validation**: Prerequisites checking and input file validation
- 💾 **File Size Display**: Human-readable file sizes throughout the process
- 🎨 **Improved UI**: Better visual indicators, icons, and formatted output
- 🛠️ **Better Error Handling**: More informative error messages and exit codes
- 📋 **Enhanced Documentation**: Comprehensive help with examples and troubleshooting

## Table of Contents

- [Badges](#badges)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
  - [Command Options](#command-options)
  - [Examples](#examples)
  - [Exit Codes](#exit-codes)
- [Features](#features)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Contributing](#contributing)

## Badges

![Bash](https://img.shields.io/badge/Bash-4.0+-blue)
![Version](https://img.shields.io/badge/Version-0.3.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)
![FFmpeg](https://img.shields.io/badge/Requires-FFmpeg-red)

## Prerequisites

Before using this script, ensure you have:

- **FFmpeg**: Required for audio file processing
- **Bash 4.0+**: Recommended for best compatibility
- **Sufficient disk space**: For conversion output files

The script automatically checks for these prerequisites and provides installation guidance if missing.

## Installation

1. **Install FFmpeg** (if not already installed):

    - On Ubuntu/Debian:  
      ```bash
      sudo apt install ffmpeg
      ```

    - On macOS (using Homebrew):  
      ```bash
      brew install ffmpeg
      ```

    - On Windows:  
      Download FFmpeg from [here](https://ffmpeg.org/download.html) and follow the instructions to set it up.

2. **Download and setup the script**:

    ```bash
    # Download the script
    wget https://raw.githubusercontent.com/your-repo/audio2mp3/main/audio2mp3.sh
    
    # Make it executable
    chmod +x audio2mp3.sh
    
    # Optionally, move to PATH for global access
    sudo mv audio2mp3.sh /usr/local/bin/audio2mp3
    ```

## Usage

The script provides comprehensive audio conversion capabilities with multiple operation modes and advanced features.

### Command Options

```txt
Usage: ./audio2mp3.sh -f <input_file> [-o <output_path>] | -d <directory> [-o <output_directory>] [OPTIONS]

Required Flags (Must provide either -f or -d):
  -f, --file <input_file>       Convert a single file
  -d, --directory <directory>   Convert all supported files in a directory

Optional Flags:
  -o, --output <output_path>    Specify output file (with -f) or output directory (with -d)
  -r, --recursive               Process directories recursively
  -c, --copy                    Convert without re-encoding if possible (faster, same quality)
  -s, --skip-existing           Skip existing files without prompt
  -nc, --no-confirm             Automatically overwrite existing files without asking
  --dry-run                     Show what would be processed without converting
  -h, --help                    Show detailed help message

Supported Formats: WAV, FLAC, OGG, AAC, M4A, ALAC, AIFF, OPUS
```

### Examples

**Convert a single audio file:**
```bash
./audio2mp3.sh -f song.flac
```

**Convert with specific output location:**
```bash
./audio2mp3.sh -f song.flac -o /path/to/output.mp3
```

**Convert all files in a directory:**
```bash
./audio2mp3.sh -d /path/to/music
```

**Recursive conversion with copy mode (faster for compatible files):**
```bash
./audio2mp3.sh -d /path/to/music -r -c
```

**Skip existing files during batch conversion:**
```bash
./audio2mp3.sh -d /path/to/music -s
```

**Preview what would be converted (dry run):**
```bash
./audio2mp3.sh -d /path/to/music --dry-run
```

**Automated conversion without prompts:**
```bash
./audio2mp3.sh -d /path/to/music -nc
```

**Complex example - Recursive, copy mode, skip existing:**
```bash
./audio2mp3.sh -d /path/to/music -r -c -s -o /path/to/output
```

### Exit Codes

The script uses standard exit codes for automation and error handling:

| Code | Meaning |
|------|---------|
| `0` | Success - All operations completed successfully |
| `1` | General error - Invalid arguments, no files found, etc. |
| `2` | Missing dependencies - FFmpeg not found |
| `3` | File/directory access issues - Permission or path errors |

## Features

### 🎯 **Core Functionality**
- Convert single files or entire directories
- Preserve audio metadata during conversion
- Support for 8+ popular audio formats
- Recursive directory processing

### 📊 **Progress & Statistics**
- Real-time progress bars for batch operations
- File-by-file processing indicators
- Comprehensive conversion summary
- Processing time tracking
- File size information (input/output)

### 🛡️ **Safety & Validation**
- Prerequisite checking at startup
- Input file format validation
- Directory existence verification
- Dry-run mode for safe previewing

### 🎨 **User Experience**
- Colorized output with clear icons
- Formatted file listings with sizes
- Professional summary tables
- Helpful error messages with solutions

### ⚙️ **Advanced Options**
- Copy mode for faster conversion of compatible files
- Skip existing files or auto-overwrite
- Custom output directories
- Recursive subdirectory processing

## Troubleshooting

### Common Issues

**FFmpeg not found:**
```bash
# Install FFmpeg using your package manager
sudo apt install ffmpeg  # Ubuntu/Debian
brew install ffmpeg      # macOS
```

**Permission errors:**
```bash
# Make script executable
chmod +x audio2mp3.sh

# Check file/directory permissions
ls -la /path/to/audio/files
```

**No files found:**
- Ensure the directory contains supported audio formats
- Use `--dry-run` to preview what would be processed
- Check if files have the correct extensions

**Conversion fails:**
- Verify input files are not corrupted
- Ensure sufficient disk space for output
- Check that output directory is writable

### Getting Help

Use the built-in help for detailed information:
```bash
./audio2mp3.sh --help
```

For dry-run testing:
```bash
./audio2mp3.sh -d /path/to/music --dry-run
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

### Development Guidelines
- Maintain backward compatibility
- Add appropriate error handling
- Update documentation for new features
- Test on multiple platforms when possible

### Reporting Issues
Please include:
- Your operating system
- Bash and FFmpeg versions
- Command used and error output
- Sample files (if applicable)
