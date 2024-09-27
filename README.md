# AUDIO2MP3

This is a Bash script that converts various audio file formats (e.g., `.wav`, `.flac`, `.ogg`, `.aac`, `.m4a`, `.alac`, `.aiff`, `.opus`) to `.mp3`. The script supports converting a single file or multiple audio files in a directory, with options for recursive directory search and skipping already existing files.

## Versions
**Current version**: 0.1.0

## Table of Contents
- [Badges](#badges)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)
- [Contributing](#contributing)

## Badges
![Bash](https://img.shields.io/badge/Bash-5.0+-blue)
![Version](https://img.shields.io/badge/Version-0.5.1-orange)
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
```bash
Usage: ./audio2mp3.sh -f <input_file> [-o <output_file>] [-c] | -d <directory> [-o <output_directory>] [-c] [-r] [-s]

Options:
  -f, --file <input_file>       Input audio file (required if not using -d).
  -o, --output <output_file>    Output MP3 file (default: ./audio2mp3-output.mp3).
  -d, --directory <directory>   Convert all supported audio files in the specified directory.
  -r, --recursive               Recursively search for audio files in the directory.
  -c, --copy                    Convert without re-encoding if possible (for mp3 files).
  -s, --skip-existing           Skip confirmation and do not overwrite existing files.
  -h, --help                    Display help message.
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

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change. Make sure to update tests as appropriate.