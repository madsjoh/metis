# nixpkgs Commit Conventions

nixpkgs does **not** use Conventional Commits. A pull request title
follows the component based format. See the [nixpkgs commit
conventions][nixpkgs-commit-conventions] for the authoritative rules.

## Title Format

```text
<component>: <description>
```

**Key differences from Conventional Commits:**

- No type prefix such as `feat:` or `fix:`.
- The component or scope comes first, followed by a colon.
- The style guidelines otherwise match Conventional Commits, including the imperative mood and the 50/72 rule.

## Component Patterns

Common patterns for nixpkgs titles:

- `<package-name>: <old-version> -> <new-version>` for version updates.
- `<package-name>: init at <version>` for new packages.
- `nixos/<module-name>: <description>` for NixOS module changes.
- `lib/<function>: <description>` for library function changes.
- `doc: <description>` for documentation changes.
- `maintainers: add <handle>` when adding a maintainer.

## Description

Use a plain body unless a repository pull request template is present.
Explain what changed and why, and reference release notes or changelog URLs
for version updates.

## Example

A pull request titled `python311Packages.requests: 2.28.1 -> 2.31.0`:

```markdown
python311Packages.requests: 2.28.1 -> 2.31.0

This release includes several security fixes and bug fixes. Notable
changes include improved handling of redirect loops and better support
for international domain names.

Release notes: https://github.com/psf/requests/releases/tag/v2.31.0
```

[nixpkgs-commit-conventions]: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#commit-conventions
