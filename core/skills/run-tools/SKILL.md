---
name: run-tools
description: Use when a required command or tool is missing, or when you need to determine how to obtain and run a command. Prefers commands already on the system, then uses Nix shell when Nix is available, then falls back to Podman or Docker.
---

# Run Tools

## What This Skill Does

- Determines the best way to run a command or tool that may not be installed.
- Prefers commands that are already present on the system.
- Uses Nix shell when Nix is available and the command is missing.
- Falls back to Podman or Docker when neither the command nor Nix is available.

## Resolution Order

Resolve the tool in this order.

1. Check whether the command is already present.
2. If it is not, check whether Nix is present and use Nix shell.
3. If Nix is not present, use Podman or Docker.

## Step 1: Use the Command When Present

Check whether the command is already on the PATH before obtaining it.

```console
command -v <command>
```

If the command is present, run it directly. Do not wrap it in Nix shell or a container when it already works.

## Step 2: Run Through Nix Shell

When the command is missing and Nix is present, run it through Nix shell.

First confirm that Nix is available.

```console
command -v nix
```

Then run the command through a temporary Nix shell. Replace `<package>` with the nixpkgs attribute name that provides the command, and replace `<command>` and `<arguments>` with the command to run.

```console
nix shell nixpkgs#<package> --command <command> <arguments>
```

If the package attribute name is unknown, search nixpkgs for it.

```console
nix search nixpkgs <command>
```

If `nix shell` reports that flakes are disabled, enable the required experimental features for the single invocation.

```console
nix --extra-experimental-features nix-command --extra-experimental-features flakes shell nixpkgs#<package> --command <command> <arguments>
```

## Step 3: Run Through Podman or Docker

When the command is missing and Nix is not present, run it in a container. Check for Podman first, then Docker.

```console
command -v podman
command -v docker
```

Run the command in a container with either `podman run` or `docker run`. Replace `<image>` with an image that provides the command, and replace `<command>` and `<arguments>` with the command to run.

```console
podman run --rm <image> <command> <arguments>
docker run --rm <image> <command> <arguments>
```

When the command needs access to the current working directory, mount it into the container.

```console
podman run --rm --volume "$PWD:$PWD" --workdir "$PWD" <image> <command> <arguments>
docker run --rm --volume "$PWD:$PWD" --workdir "$PWD" <image> <command> <arguments>
```
