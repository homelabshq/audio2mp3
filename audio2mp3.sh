#!/bin/bash
set -euo pipefail

# Script Description: Converts single or multiple audio files to MP3 using FFmpeg.
# Supports batch processing, metadata preservation, and optional copy mode.
# Saves output in the input file's directory or a specified location.
# Author: elvee
# Version: 0.3.0
# License: MIT
# Creation Date: 27-09-2024
# Last Modified: 14-03-2025
# Usage: audio2mp3.sh -f <input_file> [-o <output_path>] | -d <directory> [-o <output_directory>] [-r] [-c] [-s] [-nc] [--dry-run]
#
# Prerequisites:
#   - FFmpeg must be installed and available in PATH
#   - Bash 4.0 or higher
#
# Exit Codes:
#   0 - Success
#   1 - General error (invalid arguments, no files found, etc.)
#   2 - Missing dependencies (FFmpeg not found)
#   3 - File/directory access issues

# Color definitions
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
BOLD="\033[1m"
DIM="\033[2m"
NC="\033[0m" # No Color

# Progress bar characters
PROGRESS_CHAR="█"
PROGRESS_EMPTY="░"

# Default values
OUTPUT_FILE=""
OUTPUT_DIR=""
COPY_MODE=false
RECURSIVE_MODE=false
SKIP_EXISTING=false
NO_CONFIRM=false # -nc flag
DRY_RUN=false    # --dry-run flag

# Statistics tracking
TOTAL_FILES=0
PROCESSED_FILES=0
SKIPPED_FILES=0
FAILED_FILES=0
START_TIME=""

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
  echo -e "${MAGENTA}🎵 Audio to MP3 Converter - v0.3.0 🎵${NC}\n"
}

# Function to check prerequisites
check_prerequisites() {
  echo -e "[${BLUE}+${NC}] ${DIM}Checking prerequisites...${NC}"

  # Check if FFmpeg is installed
  if ! command -v ffmpeg &>/dev/null; then
    echo -e "[${RED}✗${NC}] ${RED}FFmpeg is not installed or not in PATH.${NC}"
    echo -e "    ${YELLOW}Please install FFmpeg:${NC}"
    echo -e "    ${CYAN}Ubuntu/Debian:${NC} sudo apt install ffmpeg"
    echo -e "    ${CYAN}macOS:${NC} brew install ffmpeg"
    echo -e "    ${CYAN}Windows:${NC} Download from https://ffmpeg.org/download.html"
    exit 2
  fi

  echo -e "[${GREEN}✓${NC}] ${GREEN}FFmpeg found: $(ffmpeg -version | head -n1 | cut -d' ' -f3)${NC}"

  # Check bash version
  if ((BASH_VERSINFO[0] < 4)); then
    echo -e "[${YELLOW}!${NC}] ${YELLOW}Warning: Bash version ${BASH_VERSION} detected. Some features may not work properly.${NC}"
    echo -e "    ${CYAN}Recommended: Bash 4.0 or higher${NC}"
  fi
}

# Function to format file size
format_file_size() {
  local size="$1"
  if ((size < 1024)); then
    echo "${size}B"
  elif ((size < 1048576)); then
    echo "$((size / 1024))KB"
  elif ((size < 1073741824)); then
    echo "$((size / 1048576))MB"
  else
    echo "$((size / 1073741824))GB"
  fi
}

# Function to show progress bar
show_progress() {
  local current="$1"
  local total="$2"
  local width=40
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  local empty=$((width - filled))

  printf "\r[${GREEN}"
  printf "%*s" "$filled" | tr ' ' "$PROGRESS_CHAR"
  printf "${DIM}"
  printf "%*s" "$empty" | tr ' ' "$PROGRESS_EMPTY"
  printf "${NC}] ${BOLD}%d%%${NC} (%d/%d)" "$percentage" "$current" "$total"
}

# Function to display help information
show_help() {
  echo -e "
${BOLD}Converts single or multiple audio files to MP3 using FFmpeg.${NC} Supports batch processing, metadata 
preservation, and optional copy mode. Saves output in the input file's directory or a specified 
location.

${YELLOW}Supported audio formats:${NC} WAV, FLAC, OGG, AAC, M4A, ALAC, AIFF, and OPUS.

${BOLD}Prerequisites:${NC}
  • FFmpeg must be installed and available in PATH
  • Bash 4.0 or higher recommended

${BOLD}Usage:${NC} $0 -f <input_file> [-o <output_path>] | -d <directory> [-o <output_directory>] [OPTIONS]

${GREEN}Options:${NC}
  ${BOLD}Required Flags${NC} (Must provide either -f or -d):
    ${BLUE}-f, --file <input_file>${NC}       Convert a single file.
    ${BLUE}-d, --directory <directory>${NC}   Convert all supported files in a directory.

  ${BOLD}Optional Flags:${NC}
    ${CYAN}-o, --output <output_path>${NC}    Specify output file (if using -f) or output directory (if using -d).
    ${CYAN}-r, --recursive${NC}               Process directories recursively.
    ${CYAN}-c, --copy${NC}                    Convert without re-encoding if possible (faster, same quality).
    ${CYAN}-s, --skip-existing${NC}           Skip existing files without prompt.
    ${CYAN}-nc, --no-confirm${NC}             Automatically overwrite existing files without asking.
    ${CYAN}--dry-run${NC}                     Show what would be processed without converting.
    ${CYAN}-h, --help${NC}                    Show this help message.

${BOLD}Examples:${NC}
  ${DIM}# Convert single file${NC}
  $0 -f song.flac

  ${DIM}# Convert single file to specific location${NC}
  $0 -f song.flac -o /path/to/output.mp3

  ${DIM}# Convert all files in directory${NC}
  $0 -d /path/to/music

  ${DIM}# Recursively convert with copy mode, skip existing${NC}
  $0 -d /path/to/music -r -c -s

  ${DIM}# Dry run to see what would be processed${NC}
  $0 -d /path/to/music --dry-run

${BOLD}Exit Codes:${NC}
  ${GREEN}0${NC} - Success
  ${RED}1${NC} - General error (invalid arguments, no files found, etc.)
  ${RED}2${NC} - Missing dependencies (FFmpeg not found)
  ${RED}3${NC} - File/directory access issues

${BOLD}Troubleshooting:${NC}
  • If FFmpeg is not found, install it using your package manager
  • For permission errors, check file/directory permissions
  • Use --dry-run to preview operations before executing
  • Check available disk space for large conversions
  "
}

# Function to convert a single audio file to MP3 while preserving metadata
convert_to_mp3() {
  local input_file="$1"
  local output_file="$2"
  local current_file="$3"
  local total_files="$4"

  # Show progress if processing multiple files
  if ((total_files > 1)); then
    show_progress "$current_file" "$total_files"
    echo # New line after progress bar
  fi

  # Get file size for information
  local input_size
  if [[ -f "$input_file" ]]; then
    input_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null || echo "0")
  else
    echo -e "[${RED}✗${NC}] ${RED}Input file not found: '${BOLD}$input_file${NC}${RED}'${NC}"
    ((FAILED_FILES++))
    return 1
  fi

  # Check if file exists and confirm overwrite only once
  if [ -f "$output_file" ]; then
    if [ "$SKIP_EXISTING" = true ]; then
      echo -e "[${YELLOW}↷${NC}] ${YELLOW}Skipping existing file '${BOLD}$(basename "$output_file")${NC}${YELLOW}' ($(format_file_size "$input_size"))${NC}"
      ((SKIPPED_FILES++))
      return
    fi
    if [ "$NO_CONFIRM" = false ]; then
      echo -e "[${YELLOW}!${NC}] ${YELLOW}Warning: '${BOLD}$output_file${NC}${YELLOW}' already exists.${NC}"
      echo -e "[${BLUE}?${NC}] ${BLUE}Do you want to overwrite it? (y/n)${NC}"
      read -r overwrite
      if [[ "$overwrite" != "y" ]]; then
        echo -e "[${YELLOW}↷${NC}] ${YELLOW}Skipping conversion for '${BOLD}$(basename "$input_file")${NC}${YELLOW}'.${NC}"
        ((SKIPPED_FILES++))
        return
      fi
    fi
  fi

  # Dry run mode
  if [ "$DRY_RUN" = true ]; then
    local mode_text="convert"
    [ "$COPY_MODE" = true ] && mode_text="copy"
    echo -e "[${CYAN}◎${NC}] ${CYAN}Would $mode_text '${BOLD}$(basename "$input_file")${NC}${CYAN}' → '${BOLD}$(basename "$output_file")${NC}${CYAN}' ($(format_file_size "$input_size"))${NC}"
    return
  fi

  # Record start time for this file
  local file_start_time
  file_start_time=$(date +%s)

  if [ "$COPY_MODE" = true ]; then
    echo -e "[${GREEN}⚡${NC}] ${GREEN}Copying '${BOLD}$(basename "$input_file")${NC}${GREEN}' → '${BOLD}$(basename "$output_file")${NC}${GREEN}' ($(format_file_size "$input_size"))${NC}"
    if ! ffmpeg -i "$input_file" -map_metadata 0:s:a:0 -acodec copy -y "$output_file" -loglevel error; then
      echo -e "[${RED}✗${NC}] ${RED}Failed to copy '${BOLD}$(basename "$input_file")${NC}${RED}'${NC}"
      ((FAILED_FILES++))
      return 1
    fi
  else
    echo -e "[${GREEN}⚙${NC}] ${GREEN}Converting '${BOLD}$(basename "$input_file")${NC}${GREEN}' → '${BOLD}$(basename "$output_file")${NC}${GREEN}' ($(format_file_size "$input_size"))${NC}"
    if ! ffmpeg -i "$input_file" -map_metadata 0:s:a:0 -q:a 0 -y "$output_file" -loglevel error; then
      echo -e "[${RED}✗${NC}] ${RED}Failed to convert '${BOLD}$(basename "$input_file")${NC}${RED}'${NC}"
      ((FAILED_FILES++))
      return 1
    fi
  fi

  # Calculate processing time and output size
  local file_end_time output_size processing_time
  file_end_time=$(date +%s)
  processing_time=$((file_end_time - file_start_time))
  output_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo "0")

  echo -e "[${MAGENTA}✓${NC}] ${MAGENTA}Completed in ${processing_time}s • Output: $(format_file_size "$output_size")${NC}"
  ((PROCESSED_FILES++))
}

# Function to process all audio files in a directory
process_directory() {
  local dir="$1"
  local output_dir="${OUTPUT_DIR:-}"

  # Validate directory
  if [[ ! -d "$dir" ]]; then
    echo -e "[${RED}✗${NC}] ${RED}Directory not found: '${BOLD}$dir${NC}${RED}'${NC}"
    exit 3
  fi

  local files
  if [ "$RECURSIVE_MODE" = true ]; then
    echo -e "[${BLUE}🔍${NC}] ${BLUE}Searching recursively in '${BOLD}$dir${NC}${BLUE}'...${NC}"
    files=$(find "$dir" -type f \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  else
    echo -e "[${BLUE}🔍${NC}] ${BLUE}Searching in '${BOLD}$dir${NC}${BLUE}'...${NC}"
    files=$(find "$dir" -maxdepth 1 -type f \( -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.aac" -o -iname "*.m4a" -o -iname "*.alac" -o -iname "*.aiff" -o -iname "*.opus" \))
  fi

  if [[ -z "$files" ]]; then
    echo -e "[${RED}✗${NC}] ${RED}No supported audio files found in '${BOLD}$dir${NC}${RED}'.${NC}"
    echo -e "    ${YELLOW}Supported formats: WAV, FLAC, OGG, AAC, M4A, ALAC, AIFF, OPUS${NC}"
    exit 1
  fi

  # Count files and display formatted list
  TOTAL_FILES=$(echo "$files" | wc -l)
  echo -e "[${GREEN}📁${NC}] ${GREEN}Found ${BOLD}$TOTAL_FILES${NC}${GREEN} audio file(s):${NC}\n"

  # Display files in a nice table format
  echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
  echo -e "${CYAN}│${NC} ${BOLD}Files to process:${NC}                                                           ${CYAN}│${NC}"
  echo -e "${CYAN}├─────────────────────────────────────────────────────────────────────────────────┤${NC}"

  local counter=1
  IFS=$'\n'
  for file in $files; do
    local file_name size_info
    file_name=$(basename "$file")
    local file_size
    file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
    size_info="($(format_file_size "$file_size"))"

    printf "${CYAN}│${NC} %3d. %-60s %10s ${CYAN}│${NC}\n" "$counter" "$file_name" "$size_info"
    ((counter++))
  done
  unset IFS

  echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────────────────┘${NC}\n"

  # Confirmation for non-dry-run mode
  if [ "$DRY_RUN" = false ]; then
    echo -e "[${YELLOW}?${NC}] ${YELLOW}Do you want to proceed with conversion? (y/n)${NC}"
    read -r confirmation
    if [[ "$confirmation" != "y" ]]; then
      echo -e "[${RED}✗${NC}] ${RED}Operation cancelled.${NC}"
      exit 0
    fi
  fi

  echo -e "[${BLUE}⚙${NC}] ${BLUE}Starting batch processing...${NC}\n"
  START_TIME=$(date +%s)

  # Process files
  local current_file=1
  IFS=$'\n'
  for file in $files; do
    local file_name
    file_name=$(basename "$file")

    local destination_dir="${output_dir:-$(dirname "$file")}"
    mkdir -p "$destination_dir"

    local output_file="${destination_dir}/${file_name%.*}.mp3"
    convert_to_mp3 "$file" "$output_file" "$current_file" "$TOTAL_FILES"
    ((current_file++))
  done
  unset IFS

  # Show final summary
  show_summary
}

# Function to show final summary
show_summary() {
  local end_time total_time
  end_time=$(date +%s)
  total_time=$((end_time - START_TIME))

  echo -e "\n${CYAN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC} ${BOLD}📊 CONVERSION SUMMARY${NC}                                                       ${CYAN}║${NC}"
  echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
  echo -e "${CYAN}║${NC} Total files found:    ${BOLD}$TOTAL_FILES${NC}                                             ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} Successfully processed: ${GREEN}${BOLD}$PROCESSED_FILES${NC}                                           ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} Skipped files:        ${YELLOW}${BOLD}$SKIPPED_FILES${NC}                                             ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} Failed conversions:   ${RED}${BOLD}$FAILED_FILES${NC}                                             ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC} Total time:           ${BOLD}${total_time}s${NC}                                             ${CYAN}║${NC}"

  if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}║${NC} ${MAGENTA}${BOLD}🔍 DRY RUN MODE - No files were actually converted${NC}                   ${CYAN}║${NC}"
  fi

  echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}\n"

  # Exit with appropriate code
  if ((FAILED_FILES > 0)); then
    echo -e "[${RED}!${NC}] ${RED}Some conversions failed. Check the output above for details.${NC}"
    exit 1
  elif ((PROCESSED_FILES == 0 && DRY_RUN == false)); then
    echo -e "[${YELLOW}!${NC}] ${YELLOW}No files were processed.${NC}"
    exit 1
  else
    if [ "$DRY_RUN" = false ]; then
      echo -e "[${GREEN}✅${NC}] ${GREEN}All conversions completed successfully!${NC}"
    else
      echo -e "[${CYAN}🔍${NC}] ${CYAN}Dry run completed. Use without --dry-run to perform actual conversions.${NC}"
    fi
  fi
}

# Function to validate input file
validate_input_file() {
  local input_file="$1"

  if [[ ! -f "$input_file" ]]; then
    echo -e "[${RED}✗${NC}] ${RED}Input file not found: '${BOLD}$input_file${NC}${RED}'${NC}"
    exit 3
  fi

  # Check if file is a supported format
  local ext="${input_file##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
  case "$ext" in
  wav | flac | ogg | aac | m4a | alac | aiff | opus)
    echo -e "[${GREEN}✓${NC}] ${GREEN}Input file validated: ${BOLD}$(basename "$input_file")${NC}${GREEN} ($(format_file_size "$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null || echo "0")"))${NC}"
    ;;
  *)
    echo -e "[${RED}✗${NC}] ${RED}Unsupported file format: ${BOLD}.$ext${NC}"
    echo -e "    ${YELLOW}Supported formats: WAV, FLAC, OGG, AAC, M4A, ALAC, AIFF, OPUS${NC}"
    exit 1
    ;;
  esac
}

# Main function
main() {
  local input_file=""
  local directory=""

  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -f | --file)
      if [[ -z "${2:-}" ]]; then
        echo -e "[${RED}✗${NC}] ${RED}Option $1 requires an argument${NC}"
        exit 1
      fi
      input_file="$2"
      shift 2
      ;;
    -o | --output)
      if [[ -z "${2:-}" ]]; then
        echo -e "[${RED}✗${NC}] ${RED}Option $1 requires an argument${NC}"
        exit 1
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -d | --directory)
      if [[ -z "${2:-}" ]]; then
        echo -e "[${RED}✗${NC}] ${RED}Option $1 requires an argument${NC}"
        exit 1
      fi
      directory="$2"
      shift 2
      ;;
    -r | --recursive)
      RECURSIVE_MODE=true
      shift
      ;;
    -c | --copy)
      COPY_MODE=true
      shift
      ;;
    -s | --skip-existing)
      SKIP_EXISTING=true
      shift
      ;;
    -nc | --no-confirm)
      NO_CONFIRM=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h | --help)
      show_ascii
      show_help
      exit 0
      ;;
    *)
      show_ascii
      show_help
      echo -e "[${RED}✗${NC}] ${RED}Invalid option: $1${NC}"
      exit 1
      ;;
    esac
  done

  # Show ASCII art
  show_ascii

  # Check prerequisites
  check_prerequisites
  echo

  # Initialize statistics
  TOTAL_FILES=1
  PROCESSED_FILES=0
  SKIPPED_FILES=0
  FAILED_FILES=0

  # Process based on input type
  if [[ -n "$directory" ]]; then
    process_directory "$directory"
  elif [[ -n "$input_file" ]]; then
    # Validate input file
    validate_input_file "$input_file"

    local file_name
    file_name=$(basename "$input_file")

    local destination_dir="${OUTPUT_DIR:-$(dirname "$input_file")}"
    mkdir -p "$destination_dir"

    local output_file="${destination_dir}/${file_name%.*}.mp3"

    START_TIME=$(date +%s)
    convert_to_mp3 "$input_file" "$output_file" 1 1

    # Show summary for single file
    if [ "$DRY_RUN" = false ] && ((PROCESSED_FILES > 0)); then
      echo -e "\n[${GREEN}✅${NC}] ${GREEN}Conversion completed successfully!${NC}"
    elif [ "$DRY_RUN" = true ]; then
      echo -e "\n[${CYAN}🔍${NC}] ${CYAN}Dry run completed. Remove --dry-run to perform actual conversion.${NC}"
    fi
  else
    show_help
    echo -e "[${RED}✗${NC}] ${RED}No input file or directory provided.${NC}"
    echo -e "    ${YELLOW}Use -f for single file or -d for directory conversion${NC}"
    exit 1
  fi
}

# Execute the main function
main "$@"
