# ModelSim on macOS (Docker + XQuartz)

Run on a Mac. ModelSim has no macOS build, so it runs in an Ubuntu container and its GUI is drawn on the Mac through XQuartz.

> Intel Macs only. On Apple Silicon, the x86 container would be emulated and unusably slow.

## Contents

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the `modelsim` image (Ubuntu 20.04 + 32‑bit libs + ModelSim) |
| `modelsim.sh` | Launcher: starts Docker and XQuartz, mounts a project folder, opens ModelSim |

The ModelSim installer is **not** included. Download it from Altera yourself.

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac, Intel chip)
- [XQuartz](https://www.xquartz.org/): `brew install --cask xquartz`
- `ModelSimSetup-20.1.x.xxx-linux.run` from the [Altera Download Center](https://www.altera.com/downloads) (Quartus Prime Lite → 20.1 → Linux → Individual Files). A free MyAltera account is required.

## Setup

1. **Configure XQuartz:** open it, go to *Settings → Security*, and tick **Allow connections from network clients**. Then log out and back in.
2. **Build the image:** put the installer and the `Dockerfile` to the same folder (ex. ~/Documents/modelsim_docker directory that contains the Dockerfile and the .run file) and run:
   ```bash
   docker build -t modelsim .
   ```
   The `.run` file can be deleted afterwards.
3. **Install the launcher:**
   ```bash
   chmod +x modelsim.sh
   echo "alias modelsim=\"$PWD/modelsim.sh\"" >> ~/.zshrc && source ~/.zshrc
   ```

## Usage

```bash
modelsim .             # open ModelSim on the current folder
modelsim ~/HDL/lab1    # open it on a specific folder
modelsim               # choose a folder in a Finder dialog
```

The chosen folder appears inside ModelSim as **`/work`**. Nothing else on the Mac is visible to it. Create and open projects (`.mpf`) there.

### Optional: Dock app

In Automator, create a new *Application* with one *Run Shell Script* action (shell `/bin/bash`) containing:

```bash
/path/to/modelsim.sh
```

Save it to `/Applications`.

## Recommended workflow

Edit HDL in VS Code (or any editor) on the Mac, and use ModelSim only to compile and simulate. After saving, choose *Compile → Compile Out‑of‑Date* in ModelSim.

## Troubleshooting

| Symptom | Fix |
|---|---|
| ModelSim window never appears | Make sure XQuartz is running and allows network clients, then run `xhost + 127.0.0.1` |
| `Permission denied` writing `/work` | Grant Docker access under *Privacy & Security → Files & Folders* (or Full Disk Access). Avoid iCloud‑synced folders and use e.g. `~/HDL` instead. Set Docker's file sharing to **VirtioFS** |
| `vsim` fails to start in the container | The `sed … linux_rh60` line in the `Dockerfile` must have run. Rebuild the image |
| Cursor won't move past the last character of a line | ModelSim editor bug. Use **Fn+→** / **Ctrl+E**, or edit in an external editor |
| Project created on Windows shows missing files | The `.mpf` stores Windows paths. Re‑add the files from `/work` and recompile |

## Limitations

- Simulation only: a USB‑Blaster can't be passed through Docker on macOS, so programming a board needs Windows/Linux.
- Version 20.1 is used because 21.1+ replaced ModelSim with Questa, which requires a node‑locked license.
