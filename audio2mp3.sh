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

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
BOLD="\033[1m"
NC="\033[0m" # No Color

# Default values
OUTPUT_FILE=""
OUTPUT_DIR=""
COPY_MODE=false
RECURSIVE_MODE=false
SKIP_EXISTING=false
NO_CONFIRM=false  # -nc flag

# Function to display ASCII art
show_ascii() {
  echo -e "${CYAN}

 █████╗ ██╗   ██╗██████╗ ██╗ ██████╗ ██████╗ ███╗   ███╗██████╗ ██████╗ 
██╔══██╗██║   ██║██╔══██╗██║██╔═══██╗╚════██╗████╗ ████║██╔══██╗╚════██╗
███████║██║   ██║██║  ██║██║██║   ██║ █████╔╝██╔████╔██║██████╔╝ █████╔╝
██╔══██║██║   ██║██║  ██║██║██║   ██║██╔═══╝ ██║╚██╔╝██║██╔═══╝  ╚═══██╗
██║  ██║╚██████╔╝██████╔╝██║╚██████╔╝███████╗██║ ╚═╝ ██║██║     ██████╔╝
╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝     ╚═════╝                                                                                                               
${NC}"
  echo -e "${MAGENTA}🎵 Audio to MP3 Converter - v0.2.1 🎵${NC}\n"
}

# Function to display help information
show_help() {
  echo -e "
${BOLD}Converts single or multiple audio files to MP3 using FFmpeg.${NC} Supports batch processing, metadata 
preservation, and optional copy mode. Saves output in the input file's directory or a specified 
location.

${YELLOW}Supported audio formats:${NC} WAV, FLAC, OGG, AAC, M4A, ALAC, AIFF, and OPUS.

${BOLD}Usage:${NC} $0 -f <input_file> [-o <output_path>] | -d <directory> [-o <output_directory>] [-r] [-c] [-s] [-nc]

${GREEN}Options:${NC}
  ${BOLD}Required Flags${NC} (Must provide either -f or -d):
    ${BLUE}-f, --file <input_file>${NC}       Convert a single file.
    ${BLUE}-d, --directory <directory>${NC}   Convert all supported files in a directory.

  ${BOLD}Optional Flags:${NC}
    ${CYAN}-o, --output <output_path>${NC}    Specify output file (if using -f) or output directory (if using -d).
    ${CYAN}-r, --recursive${NC}               Process directories recursively.
    ${CYAN}-c, --copy${NC}                    Convert without re-encoding if possible.
    ${CYAN}-s, --skip-existing${NC}           Skip existing files without prompt.
    ${CYAN}-nc, --no-confirm${NC}             Automatically overwrite existing files without asking.
    ${CYAN}-h, --help${NC}                    Show this help message.
  "
}

# Function to convert a single audio file to MP3 while preserving metadata
convert_to_mp3() {
  local input_file="$1"
  local output_file="$2"

  # Check if file exists and confirm overwrite only once
  if [ -f "$output_file" ]; then
    if [ "$SKIP_EXISTING" = true ]; then
      echo -e "[${YELLOW}+${NC}] ${YELLOW}Skipping existing file '${BOLD}$output_file${NC}${YELLOW}'.${NC}"
      return
    fi
    if [ "$NO_CONFIRM" = false ]; then
      echo -e "[${YELLOW}+${NC}] ${YELLOW}Warning: '${BOLD}$output_file${NC}${YELLOW}' already exists.${NC}"
      echo -e "[${BLUE}+${NC}] ${BLUE}Do you want to overwrite it? (y/n)${NC}"
      read -r overwrite
      if [[ "$overwrite" != "y" ]]; then
        echo -e "[${RED}+${NC}] ${RED}Skipping conversion for '${BOLD}$input_file${NC}${RED}'.${NC}"
        return
      fi
    fi
  fi

  if [ "$COPY_MODE" = true ]; then
    echo -e "[${GREEN}+${NC}] ${GREEN}Copying '${BOLD}$input_file${NC}${GREEN}' to '${BOLD}$output_file${NC}${GREEN}' while preserving metadata...${NC}"
    ffmpeg -i "$input_file" -map_metadata 0:s:a:0 -acodec copy -y "$output_file"
  else
    echo -e "[${GREEN}+${NC}] ${GREEN}Converting '${BOLD}$input_file${NC}${GREEN}' to '${BOLD}$output_file${NC}${GREEN}' while preserving metadata...${NC}"
    ffmpeg -i "$input_file" -map_metadata 0:s:a:0 -q:a 0 -y "$output_file"
  fi
  echo -e "[${MAGENTA}+${NC}] ${MAGENTA}Operation completed.${NC}"
}

# Function to process all audio files in a directory
process_directory() {
  local dir="$1"
  local output_dir="${OUTPUT_DIR:-}"

  local files
  if [ "$RECURSIVE_MODE" = true ]; then
    echo -e "[${BLUE}+${NC}] ${BLUE}Searching recursively in '${BOLD}$dir${NC}${BLUE}'...${NC}"
    files=$(find "$dir" -type f \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  else
    echo -e "[${BLUE}+${NC}] ${BLUE}Searching in '${BOLD}$dir${NC}${BLUE}'...${NC}"
    files=$(find "$dir" -maxdepth 1 -type f \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  fi

  if [[ -z "$files" ]]; then
    echo -e "[${RED}+${NC}] ${RED}No supported audio files found in '${BOLD}$dir${NC}${RED}'.${NC}"
    exit 1
  fi

  echo -e "[${GREEN}+${NC}] ${GREEN}Found the following audio files in '${BOLD}$dir${NC}${GREEN}':${NC}"
  echo -e "${CYAN}$files${NC}"
  echo -e "[${YELLOW}+${NC}] ${YELLOW}Do you want to proceed with conversion? (y/n)${NC}"
  read -r confirmation
  if [[ "$confirmation" != "y" ]]; then
    echo -e "[${RED}+${NC}] ${RED}Operation cancelled.${NC}"
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
        echo -e "[${RED}+${NC}] ${RED}Invalid option: $1${NC}"
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
    echo -e "[${RED}+${NC}] ${RED}No input file or directory provided.${NC}"
    exit 1
  fi
}

# Execute the main function
main "$@"
