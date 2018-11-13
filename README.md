# Concourse Tasks

Common utility tasks for [Concourse CI](https://concourse-ci.org).

## Tasks

### Fly

#### `fly/support/fetch.sh`

Download `fly` from a target Concourse instance.

##### Usage

```bash
fly/support/fetch.sh [options] <base_url> [fly_path]
```

Options:
* `--insecure`: Don't validate TLS certificates.

Arguments:
* `base_url`: The URL to the Concourse instance.
* `fly_path`: The directory in which to install `fly`. Default: `/usr/local/bin`.

#### `fly/support/login_4x.sh`

Log into Concourse version `4.x` using `fly`.

##### Usage

```bash
echo <password> | fly/support/login_4x.sh <base_url> <username> <fly_target> [team]
```

Arguments:
* `base_url`: The URL to the Concourse instance.
* `username`: The local username with which to login.
* `fly_target`: The name of the target (the `-t` option) with which to login.
* `team`: The name of the team (the `-n` option) with which to login.

### Git

#### `git/support/configure.sh`

Configure the container for git use. Sets the `user.name` and `user.email` properties,
globally, and installs an SSH private key.

##### Usage

```bash
git/support/configure.sh
```

Variables:

* `GIT_USER`: Required. The `user.name` property value.
* `GIT_EMAIL`: Required. The `user.email` property value.
* `GIT_PRIVATE_KEY`: Optional. The SSH private key contents with which to populate the `~/.ssh/id_rsa` file.
* `STRICT_HOST_KEY_CHECKING`: Optional. Default: `no`. The value of the `StrictHostKeyChecking` ssh_config entry to apply for all hosts.

### GitFlow

### Semver

### Utility

#### `util/command.yml`

Run a command, supplied through the `COMMAND` parameter, and output the resulting volume.

##### Parameters

* `COMMAND`: The command to execute.
* `DIR`: The directory in which to run the `COMMAND`, relative to the input `volume`.

#### `util/list.yml`

Recursively list the contents of a volume.

##### Parameters

* `DIR`: The directory to list. Defaults to the input `volume`.

## License

MIT © Troy Kinsella
