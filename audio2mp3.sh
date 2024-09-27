#!/bin/bash
set -euo pipefail

# Script Description: Converts various audio files to MP3 format.
# Can process a single file or various audio formats in a directory recursively if -r is specified.
# Author: elvee
# Version: 0.1.0
# License: MIT
# Creation Date: 27-09-2024
# Last Modified: 27-09-2024
# Usage: audio2mp3.sh -f <input_file> [-o <output_file>] [-c] | -d <directory> [-o <output_directory>] [-c] [-r] [-s]

# Default values
OUTPUT_FILE="${PWD}/audio2mp3-output.mp3"
COPY_MODE=false
RECURSIVE_MODE=false
SKIP_EXISTING=false

# Function to display ASCII art
show_ascii() {
  echo "

 █████╗ ██╗   ██╗██████╗ ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ ██████╗ 
██╔══██╗██║   ██║██╔══██╗██║██╔═══██╗╚════██╗████╗ ████║██╔══██╗╚════██╗
███████║██║   ██║██║  ██║██║██║   ██║ █████╔╝██╔████╔██║██████╔╝ █████╔╝
██╔══██║██║   ██║██║  ██║██║██║   ██║██╔═══╝ ██║╚██╔╝██║██╔═══╝  ╚═══██╗
██║  ██║╚██████╔╝██████╔╝██║╚██████╔╝███████╗██║ ╚═╝ ██║██║     ██████╔╝
╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝     ╚═════╝ 
                                                                                                              
"
}

# Function to display help information
show_help() {
  echo "
Usage: $0 -f <input_file> [-o <output_file>] [-c] | -d <directory> [-o <output_directory>] [-c] [-r]

Converts an audio file or all supported audio formats in a directory to MP3 format.
Supported formats: .wav, .flac, .ogg, .aac, .m4a, .alac, .aiff, .opus
Options:
  -f, --file <input_file>       Input audio file (required if not using -d).
  -o, --output <output_file>    Output MP3 file (default: ${PWD}/audio2mp3-output.mp3).
  -d, --directory <directory>   Convert all supported audio files in the specified directory.
  -r, --recursive               Recursively search for audio files in the directory.
  -c, --copy                    Convert without re-encoding if possible (for mp3 files).
  -s, --skip-existing           Skip confirmation and do not overwrite existing files.
  -h, --help                    Display this help message.
  "
}

# Function for error handling
error_exit() {
  echo "[+] Error: $1" >&2
  exit 1
}

# Function to convert a single audio file to MP3 or extract without re-encoding
convert_to_mp3() {
  local input_file="$1"
  local output_file="$2"

  if [ -f "$output_file" ]; then
    if [ "$SKIP_EXISTING" = true ]; then
      echo "[+] Skipping existing file '$output_file'."
      return
    fi
    echo "[+] Warning: '$output_file' already exists."
    echo "[+] Do you want to overwrite it? (y/n)"
    read -r overwrite
    if [[ "$overwrite" != "y" ]]; then
      echo "[+] Skipping conversion for '$input_file'."
      return
    fi
  fi

  if [ "$COPY_MODE" = true ]; then
    echo "[+] Copying '$input_file' to '$output_file'..."
    ffmpeg -i "$input_file" -acodec copy "$output_file"
  else
    echo "[+] Converting '$input_file' to '$output_file'..."
    ffmpeg -i "$input_file" -q:a 0 "$output_file"
  fi
  echo "[+] Operation completed."
}

# Function to process all audio files in a directory
process_directory() {
  local dir="$1"
  local output_dir="${2:-${PWD}}"

  # Find all supported audio files in the specified directory (recursively if enabled), excluding hidden files
  local files
  if [ "$RECURSIVE_MODE" = true ]; then
    files=$(find "$dir" -type f ! -name ".*" ! -name "._*" \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  else
    files=$(find "$dir" -maxdepth 1 -type f ! -name ".*" ! -name "._*" \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  fi

  if [[ -z "$files" ]]; then
    error_exit "[+] No supported audio files found in directory '$dir'."
  fi

  echo "[+] The following files were found in the directory '$dir':"
  echo "$files"
  echo "[+] Do you want to process all these files? (y/n)"
  read -r confirmation

  if [[ "$confirmation" != "y" ]]; then
    error_exit "[+] Operation cancelled by user."
  fi

  # Process each file, handling spaces in file names correctly
  IFS=$'\n'
  for file in $files; do
    local output_file="${output_dir}/$(basename "${file%.*}.mp3")"
    convert_to_mp3 "$file" "$output_file"
  done
  unset IFS
}

# Main function to encapsulate script logic
main() {
  local input_file=""
  local output_file="$OUTPUT_FILE"
  local directory=""
  local output_dir=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--file)
        input_file="$2"
        shift 2
        ;;
      -o|--output)
        output_file="$2"
        output_dir="$2"
        shift 2
        ;;
      -d|--directory)
        directory="$2"
        shift 2
        ;;
      -r|--recursive)
        RECURSIVE_MODE=true
        shift
        ;;
      -c|--copy)
        COPY_MODE=true
        shift
        ;;
      -s|--skip-existing)
        SKIP_EXISTING=true
        shift
        ;;
      -h|--help)
        show_ascii
        show_help
        exit 0
        ;;
      *)
        show_ascii
        show_help
        error_exit "Invalid option: $1"
        ;;
    esac
  done

  if [[ -n "$directory" ]]; then
    if [[ -z "$output_dir" ]]; then
      output_dir="$PWD"
    fi
    show_ascii
    process_directory "$directory" "$output_dir"
  elif [[ -n "$input_file" ]]; then
    if [[ -z "$output_file" || "$output_file" == "$PWD/audio2mp3-output.mp3" ]]; then
      output_file="${PWD}/$(basename "${input_file%.*}.mp3")"
    fi
    show_ascii
    convert_to_mp3 "$input_file" "$output_file"
  else
    show_ascii
    show_help
    error_exit "[+] No input file or directory provided"
  fi
}

# Execute the main function
main "$@"