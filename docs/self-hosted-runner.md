# Self-hosted runner (CachyOS)

Runs the `editor-image` and `release` workflows on your own machine. Both workflows have a `runner` input, choose `self-hosted` when starting them.

The `release` job that publishes the GitHub release always runs on a GitHub-hosted runner. Only the builds run locally.

## Security

The repo is public. Never let a self-hosted runner run code from pull requests of other people, it executes on your machine.

- Keep the workflows on `workflow_dispatch` only, do not add `pull_request` triggers.
- In the repo under Settings, Actions, General, require approval for workflows from outside collaborators.
- Run the runner as a dedicated user without sudo rights.

## Install dependencies

```sh
sudo pacman -S --needed docker docker-buildx git zip icu
sudo systemctl enable --now docker.service
```

`icu` is needed by the runner itself.

## Create the runner user

```sh
sudo useradd -m -s /bin/bash -G docker runner
```

Members of the `docker` group have root-equivalent access through Docker. This is acceptable for a dedicated build machine, otherwise use rootless Docker.

## Install the runner

1. Open the repo on GitHub, Settings, Actions, Runners, New self-hosted runner, select Linux x64.
2. GitHub shows the download commands and a registration token. Run them as the `runner` user:

```sh
sudo -iu runner
mkdir actions-runner && cd actions-runner
# download and extract as shown on the GitHub page
./config.sh --url https://github.com/tinogoehlert/godot-voxel-editor --token <TOKEN>
exit
```

The default labels (`self-hosted`, `Linux`, `X64`) are enough. The token expires after one hour.

## Run as a service

```sh
cd /home/runner/actions-runner
sudo ./svc.sh install runner
sudo ./svc.sh start
sudo ./svc.sh status
```

The runner should now show as Idle in the repo settings.

## Use it

Start the workflow from the Actions tab and set `runner` to `self-hosted`, or from the CLI:

```sh
gh workflow run release.yml -f runner=self-hosted
gh workflow run editor-image.yml -f runner=self-hosted
```

Notes:

- The four jobs of `release` run one after another on a single runner. Register more runners to run them in parallel, they then share the CPU cores.
- Docker layers stay on the machine, so repeated builds are faster than on GitHub-hosted runners.
- The disk cleanup step is skipped on self-hosted runners.

## Maintenance

The runner updates itself. Clean up Docker data now and then:

```sh
docker image prune -af
docker builder prune -af
```

To remove the runner:

```sh
cd /home/runner/actions-runner
sudo ./svc.sh stop && sudo ./svc.sh uninstall
sudo -u runner ./config.sh remove --token <TOKEN>
```
