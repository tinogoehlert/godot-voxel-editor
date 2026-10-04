# godot-voxel-editor

Godot (mono) with the [Zylann voxel module](https://github.com/Zylann/godot_voxel), built in Docker. Produces the Linux editor, export templates for Linux and Windows and the Windows editor.

The versions are pinned in [engine.env](engine.env).

## Files

| File | Content |
| --- | --- |
| `Dockerfile.editor` | Base image with toolchain, sources and the Linux mono editor (`godot` on the PATH) |
| `Dockerfile.platforms` | Template and Windows editor builds on top of the base image |
| `build.sh` | Local build script |
| `engine.env` | Pinned `GODOT_TAG` and `VOXEL_COMMIT` |

## Prebuilt image

```sh
docker pull ghcr.io/tinogoehlert/godot-voxel-editor:4.7.2-stable
```

The tag is the `GODOT_TAG` from `engine.env`. The image is built by the `editor-image` workflow (manual trigger).

## Releases

The `release` workflow (manual trigger) builds on top of the prebuilt image and publishes a GitHub release tagged `<GODOT_TAG>-voxel-<short commit>`. It contains one zip each for `linux-editor`, `linux-templates`, `windows-editor` and `windows-templates`. Run `editor-image` first. Both workflows can run on your own machine, see [docs/self-hosted-runner.md](docs/self-hosted-runner.md).

## Local build

Requires Docker. The build runs as `linux/amd64`, so it is slow under emulation on Apple Silicon.

```sh
./build.sh [target...]
```

| Target | Output |
| --- | --- |
| `editor-image` | Base image only, nothing is exported |
| `editor` | Linux editor and `GodotSharp` |
| `linux-templates` | Linux release and debug templates |
| `windows-templates` | Windows release and debug templates |
| `windows-editor` | Windows editor and `GodotSharp` |
| `templates` | `linux-templates` and `windows-templates` (default) |
| `all` | Everything above |

Output goes to `builds/editor/`.

```sh
./build.sh                    # templates
./build.sh editor             # Linux editor
./build.sh all                # everything
JOBS=4 ./build.sh templates   # limit scons jobs
```

The base image is always built first and cached by Docker.

### Environment

| Variable | Default | Meaning |
| --- | --- | --- |
| `EDITOR_IMAGE` | `godot-voxel-editor:<GODOT_TAG>` | Name of the locally built base image |
| `JOBS` | `nproc` | Parallel scons jobs |

## Updating the engine

Change `GODOT_TAG` or `VOXEL_COMMIT` in `engine.env`, then run the `editor-image` workflow to publish the new tag.

## macOS

Not built here. Build it manually.
