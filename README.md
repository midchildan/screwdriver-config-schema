# Screwdriver.cd Configuration Schemas

## About

This repository contains schema files for
[screwdriver.yaml](https://docs.screwdriver.cd/user-guide/configuration/).
The schemas are available as [JSON Schema](https://json-schema.org) and
[Nickel](https://nickel-lang.org).

| Format      | Path                          |
| ----------- | ----------------------------- |
| JSON Schema | `src/screwdriver.schema.json` |
| Nickel      | `src/screwdriver.schema.ncl`  |

## Developing

Install the following requiments:

- [Devenv](https://devenv.sh)
- [Direnv](https://direnv.net)

After installation, open the terminal, cd into this repository, and run
`direnv allow`. This will drop you into a development shell.

Fetch the latest upstream Screwdriver.cd packages:

```bash
npm update
```

Fetch the latest test files:

```bash
./test.sh fetch
```

Generate the schema files:

```bash
generate
```

Run the tests:

```bash
./test.sh
```
