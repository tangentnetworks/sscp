# SELECTIVE SCP (selective_scp.sh)

A robust KSH script that automates the secure transfer of files from a local directory to a remote server. It specifically targets efficiency by skipping files that already exist at the destination with the exact same size, saving bandwidth and time.

## Why this?

While `rsync` is a powerful tool, it can sometimes be opaque or difficult to integrate into specific automation workflows. This script provides:

* **Clear, Verbose Output:** Real-time visibility into exactly which files are being copied and which are being skipped.
* **Simplicity:** No need to manage complex `rsync` flags; it does exactly one thing well.
* **Automated Setup:** It handles SSH key generation and distribution automatically to ensure a seamless, passwordless experience.

## Features

* **Smart Skipping:** Compares local and remote file sizes before initiating an `scp` transfer.
* **Passwordless Automation:** Automatically generates and installs SSH keys if they are missing on the target host.
* **Cross-Platform:** Uses conditional `stat` commands to ensure compatibility with both BSD (macOS) and GNU/Linux environments.
* **Dry-Run Mode:** Safely preview actions without modifying the remote destination.

## Installation

01. Ensure you have `ksh` (KornShell) available.

02. Clone the repo
```sh
git clone https://gitlab.com/tangentnetworks/sscp.git

03. Make the script executable:
```sh
chmod +x selective_scp.sh && cp $_ /usr/local/bin/
```

## Usage

```sh
./selective_scp.sh user@remote_host:/remote/path /local/source/directory [--dry-run]
```

### Examples

**Standard Run:**

```sh
./selective_scp.sh jdoe@server.com:/var/www/html /home/jdoe/uploads
```

**Testing (Dry Run):**

```sh
./selective_scp.sh jdoe@server.com:/var/www/html /home/jdoe/uploads --dry-run
```

## Requirements

* `ssh` and `scp` (OpenSSH client).
* `stat` command available on both source and destination machines.

---

## Author and Attribution

Primary Author: David Peter
Organization:   Tangent Networks
Web:            https://tangentnet.top
Email:          tangent.net@zohomail.in

---

## License

BSD 3-Clause License

Copyright (c) 2025-2026 David Peter, Tangent Networks
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions, and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions, and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY CLAIM,
DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

**End of README.md**
