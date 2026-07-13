# openarmX

This repository is the meta repository for my openarmX project.

It is intended to store:
- top-level documentation
- workspace bootstrap scripts
- repository manifest files
- workspace layout templates

It is not intended to store ROS2 build artifacts or machine-local symlinks.

## Recommended Layout

```text
openarmx/
  README.md
  openarmx.repos
  setup_workspace.sh
  repos/
  workspaces/
    hw_ws/
      src/
    sim_ws/
      src/
    dev_ws/
      src/
```

Notes:
- `repos/` contains real source repositories cloned locally.
- `workspaces/*/src/` contains local symlinks to repositories in `repos/`.
- `workspaces/*/build`, `install`, and `log` are local-only and ignored by git.

## Typical Usage

Initialize the local directory layout:

```bash
./setup_workspace.sh init
```

Import repositories listed in `openarmx.repos` if `vcs` is installed:

```bash
./setup_workspace.sh import
```

Link a package into a workspace:

```bash
./setup_workspace.sh link hw_ws openarmx_teleop_bridge
```

Link all local repositories into a workspace:

```bash
./setup_workspace.sh link-all dev_ws
```

Build a workspace:

```bash
cd workspaces/hw_ws
source /opt/ros/humble/setup.bash
colcon build
source install/setup.bash
```

## Git Policy

Commit this repository with:
- documentation
- manifest files
- helper scripts
- empty workspace templates

Do not commit:
- `repos/`
- `workspaces/*/build`
- `workspaces/*/install`
- `workspaces/*/log`
- `workspaces/*/src/` symlinks

