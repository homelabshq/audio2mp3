# AUDIO2MP3

This is a Bash script that converts various audio file formats (e.g., `.wav`, `.flac`, `.ogg`, `.aac`, `.m4a`, `.alac`, `.aiff`, `.opus`) to `.mp3`. The script supports converting a single file or multiple audio files in a directory, with options for recursive directory search, skipping already existing files, and preserving metadata. It also includes a "no confirmation" mode for automatic overwriting of files.

## Versions

**Current version**: 0.2.1

## Table of Contents

- [Badges](#badges)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)
- [Contributing](#contributing)

## Badges

![Bash](https://img.shields.io/badge/Bash-5.0+-blue)
![Version](https://img.shields.io/badge/Version-0.2.1-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Installation

1. Ensure you have [FFmpeg](https://ffmpeg.org/download.html) installed on your system. FFmpeg is used for audio file processing.
    - On Ubuntu/Debian:  

      ```bash
      sudo apt install ffmpeg
      ```

    - On Mac (using Homebrew):  

      ```bash
      brew install ffmpeg
      ```

    - On Windows:  
      Download FFmpeg from [here](https://ffmpeg.org/download.html) and follow the instructions to set it up.

2. Download the script from this repository and make it executable:

    ```bash
    chmod +x audio2mp3.sh
    ```

## Usage

You can use the script to convert individual audio files or entire directories of audio files. Below are the command options and examples of usage:

### Command Options

```txt
Usage: ./audio2mp3.sh -f <input_file> [-o <output_path>] | -d <directory> [-o <output_directory>] [-r] [-c] [-s] [-nc]

Options:
  Required Flags (Must provide either -f or -d):
    -f, --file <input_file>       Convert a single file.
    -d, --directory <directory>   Convert all supported files in a directory.

  Optional Flags:
    -o, --output <output_path>    Specify output file (if using -f) or output directory (if using -d).
    -r, --recursive               Process directories recursively.
    -c, --copy                    Convert without re-encoding if possible.
    -s, --skip-existing           Skip existing files without prompt.
    -nc, --no-confirm             Automatically overwrite existing files without asking.
    -h, --help                    Show this help message.
```

### Examples

Convert a single audio file to MP3:

```bash
./audio2mp3.sh -f input.wav -o output.mp3
```

Convert all supported audio files in a directory:

```bash
./audio2mp3.sh -d /path/to/audio/files
```

Recursively search and convert all audio files in a directory and subdirectories:

```bash
./audio2mp3.sh -d /path/to/audio/files -r
```

Convert an audio file without re-encoding (if it is already in MP3 format):

```bash
./audio2mp3.sh -f input.mp3 -c
```

Skip existing files during conversion:

```bash
./audio2mp3.sh -d /path/to/audio/files -s
```

Automatically overwrite files without confirmation:

```bash
./audio2mp3.sh -d /path/to/audio/files -nc
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change. Make sure to update tests as appropriate.
