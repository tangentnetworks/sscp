#!/bin/ksh
#
# SPDX-FileCopyrightText: 2026 David Peter, Tangent Networks
# SPDX-License-Identifier: BSD-3-Clause
# ==============================================================================
# Script Name: selective_scp.sh
# Description: Copies files from a local directory to a remote destination via
#              SCP, but skips files if a file with the same name and size
#              already exists at the destination.
#              Automatically sets up SSH keys if missing.
# Usage:      ./selective_scp.sh user@remote_host:/remote/path /local/source/directory [--dry-run]
# ==============================================================================

# --- Functions ---
usage() {
  cat << EOF
Usage: $(basename "$0") user@remote_host:/remote/path /local/source/directory [--dry-run]

Arguments:
  user@remote_host:/remote/path    Remote destination (e.g., user@server:/home/user/data)
  /local/source/directory          Local directory containing files to copy
  --dry-run                       Optional: Test run (no files copied)

Example:
  $(basename "$0") jdoe@server.com:/var/www/html /home/jdoe/local_files
  $(basename "$0") jdoe@server.com:/var/www/html /home/jdoe/local_files --dry-run
EOF
  exit 1
}

# Check if a command exists
command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# Set up SSH key for passwordless login
setup_ssh_key() {
  local remote_user_host="${1%%:*}"
  local ssh_dir="$HOME/.ssh"
  local pub_key="$ssh_dir/id_ed25519.pub"
  local priv_key="$ssh_dir/id_ed25519"

  # Create .ssh directory if it doesn't exist
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  # Generate SSH key if it doesn't exist
  if [ ! -f "$priv_key" ]; then
    print "Generating SSH key pair (ed25519)..."
    ssh-keygen -t ed25519 -f "$priv_key" -N "" -q
    chmod 600 "$priv_key"
    chmod 644 "$pub_key"
  fi

  # Copy public key to remote server
  print "Setting up passwordless SSH for $remote_user_host..."
  cat "$pub_key" | ssh "$remote_user_host" \
    "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 2> /dev/null

  # Test SSH connection
  if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$remote_user_host" true 2> /dev/null; then
    print "Error: Failed to set up passwordless SSH. Manual setup may be required."
    print "Try running: cat $pub_key | ssh $remote_user_host \"cat >> ~/.ssh/authorized_keys\""
    exit 1
  fi
  print "SSH key setup complete."
}

# --- Main Script ---
# Parse arguments
dry_run=false
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  usage
fi

if [ "$3" = "--dry-run" ]; then
  dry_run=true
  set -- "$1" "$2" # Remove --dry-run from arguments
fi

remote_dest="$1"
local_src="$2"

# Validate local source directory
if [ ! -d "$local_src" ]; then
  print "Error: $local_src is not a directory."
  exit 1
fi

# Extract remote user@host
remote_user_host="${remote_dest%%:*}"

# Check if SSH is available
if ! command_exists ssh; then
  print "Error: 'ssh' command not found. Install OpenSSH first."
  exit 1
fi

# Check if SCP is available
if ! command_exists scp; then
  print "Error: 'scp' command not found. Install OpenSSH first."
  exit 1
fi

# Check if stat is available
if ! command_exists stat; then
  print "Error: 'stat' command not found."
  exit 1
fi

# Set up SSH key if not already configured
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$remote_user_host" true 2> /dev/null; then
  setup_ssh_key "$remote_dest"
fi

# Iterate over files in local directory
for local_file in "$local_src"/*; do
  [ -f "$local_file" ] || continue # Skip if not a file

  filename=$(basename "$local_file")

  # Get local file size (supports BSD and GNU stat)
  local_size=$(stat -f "%z" "$local_file" 2> /dev/null || stat -c "%s" "$local_file")
  if [ -z "$local_size" ]; then
    print "Warning: Could not determine size for $local_file. Skipping."
    continue
  fi

  # Get remote file size
  remote_path="${remote_dest#*:}/$filename"
  remote_size=$(ssh "$remote_user_host" "stat -f \"%z\" \"$remote_path\" 2>/dev/null" \
    || ssh "$remote_user_host" "stat -c \"%s\" \"$remote_path\" 2>/dev/null")

  # Skip if sizes match
  if [ -n "$remote_size" ] && [ "$local_size" -eq "$remote_size" ]; then
    print "[SKIP] $filename (sizes match: $local_size bytes)"
    continue
  fi

  # Copy or simulate copy
  if [ "$dry_run" = true ]; then
    print "[DRY RUN] Would copy $filename (local: $local_size, remote: ${remote_size:-not found})"
  else
    print "[COPY] $filename (local: $local_size, remote: ${remote_size:-not found})"
    scp "$local_file" "$remote_dest/"
    if [ $? -ne 0 ]; then
      print "Error: Failed to copy $filename"
    fi
  fi
done

print "Done."
