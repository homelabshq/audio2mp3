#!/bin/bash
set -euo pipefail

# Script Description: Converts single or multiple audio files to MP3 using FFmpeg.
# Supports batch processing, metadata preservation, and optional copy mode.
# Saves output in the input file's directory or a specified location.
# Author: elvee
# Version: 0.2.1
# License: MIT
# Creation Date: 27-09-2024
# Last Modified: 14-03-2025
# Usage: audio2mp3.sh -f <input_file> [-o <output_path>] | -d <directory> [-o <output_directory>] [-r] [-c] [-s] [-nc]

# Default values
OUTPUT_FILE=""
OUTPUT_DIR=""
COPY_MODE=false
RECURSIVE_MODE=false
SKIP_EXISTING=false
NO_CONFIRM=false  # -nc flag

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
Converts single or multiple audio files to MP3 using FFmpeg. Supports batch processing, metadata 
preservation, and optional copy mode. Saves output in the input file's directory or a specified 
location.

Supported audio formats: WAV, FLAC, OGG, AAC, M4A, ALAC, AIFF, and OPUS.

Usage: $0 -f <input_file> [-o <output_path>] | -d <directory> [-o <output_directory>] [-r] [-c] [-s] [-nc]

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
  "
}

# Function to convert a single audio file to MP3 while preserving metadata
convert_to_mp3() {
  local input_file="$1"
  local output_file="$2"

  # Check if file exists and confirm overwrite only once
  if [ -f "$output_file" ]; then
    if [ "$SKIP_EXISTING" = true ]; then
      echo "[+] Skipping existing file '$output_file'."
      return
    fi
    if [ "$NO_CONFIRM" = false ]; then
      echo "[+] Warning: '$output_file' already exists."
      echo "[+] Do you want to overwrite it? (y/n)"
      read -r overwrite
      if [[ "$overwrite" != "y" ]]; then
        echo "[+] Skipping conversion for '$input_file'."
        return
      fi
    fi
  fi

  if [ "$COPY_MODE" = true ]; then
    echo "[+] Copying '$input_file' to '$output_file' while preserving metadata..."
    ffmpeg -i "$input_file" -map_metadata 0:s:a:0 -acodec copy -y "$output_file"
  else
    echo "[+] Converting '$input_file' to '$output_file' while preserving metadata..."
    ffmpeg -i "$input_file" -map_metadata 0:s:a:0 -q:a 0 -y "$output_file"
  fi
  echo "[+] Operation completed."
}

# Function to process all audio files in a directory
process_directory() {
  local dir="$1"
  local output_dir="${OUTPUT_DIR:-}"

  local files
  if [ "$RECURSIVE_MODE" = true ]; then
    files=$(find "$dir" -type f \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  else
    files=$(find "$dir" -maxdepth 1 -type f \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  fi

  if [[ -z "$files" ]]; then
    echo "[+] No supported audio files found in '$dir'."
    exit 1
  fi

  echo "[+] Found the following audio files in '$dir':"
  echo "$files"
  echo "[+] Do you want to proceed with conversion? (y/n)"
  read -r confirmation
  if [[ "$confirmation" != "y" ]]; then
    echo "[+] Operation cancelled."
    exit 0
  fi

  IFS=$'\n'
  for file in $files; do
    local file_name
    file_name=$(basename "$file")

    local destination_dir="${output_dir:-$(dirname "$file")}"
    mkdir -p "$destination_dir"

    local output_file="${destination_dir}/${file_name%.*}.mp3"
    convert_to_mp3 "$file" "$output_file"
  done
  unset IFS
}

# Main function
main() {
  local input_file=""
  local directory=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--file)
        input_file="$2"
        shift 2
        ;;
      -o|--output)
        OUTPUT_DIR="$2"
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
      -nc|--no-confirm)
        NO_CONFIRM=true
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
        echo "Invalid option: $1"
        exit 1
        ;;
    esac
  done

  if [[ -n "$directory" ]]; then
    show_ascii
    process_directory "$directory"
  elif [[ -n "$input_file" ]]; then
    local file_name
    file_name=$(basename "$input_file")

    local destination_dir="${OUTPUT_DIR:-$(dirname "$input_file")}"
    mkdir -p "$destination_dir"

    local output_file="${destination_dir}/${file_name%.*}.mp3"
    show_ascii
    convert_to_mp3 "$input_file" "$output_file"
  else
    show_ascii
    show_help
    echo "[+] No input file or directory provided."
    exit 1
  fi
}

# Execute the main function
main "$@"
