# nixpkgs Commit Conventions

nixpkgs does **not** use Conventional Commits. Its commits are organized by
component, not by type. See the [nixpkgs commit conventions][nixpkgs-commit-conventions]
for the authoritative rules.

## Format

```text
<component>: <description>

[optional body]

[optional footer(s)]
```

**Key differences from Conventional Commits:**

- No type prefix such as `feat:` or `fix:`.
- The component or scope comes first, followed by a colon.
- The style guidelines otherwise match Conventional Commits, including the imperative mood and the 50/72 rule.

## Component Patterns

Common patterns for nixpkgs commits:

- `<package-name>: <old-version> -> <new-version>` for version updates.
- `<package-name>: init at <version>` for new packages.
- `nixos/<module-name>: <description>` for NixOS module changes.
- `lib/<function>: <description>` for library function changes.
- `doc: <description>` for documentation changes.
- `maintainers: add <handle>` when adding a maintainer.

## nixpkgs Specific Rules

1. **Create one commit per logical unit.** Keep changes focused and atomic.

2. **Squash interim commits.** Use `git rebase -i` to squash commits such as
   "oh, forgot to insert whitespace".

3. **No period at the end of the summary line.** The first line must not end
   with a period.

4. **Use a dedicated maintainer commit.** When adding yourself to
   `maintainer-list.nix`, use a separate commit with the message
   `maintainers: add <handle>`.

5. **Include relevant information.** For version updates, reference release
   notes or changelog URLs in the commit body.

6. **Consult area specific conventions.** Follow the conventions in the
   area README files:

   - `doc/README.md` for documentation changes.
   - `lib/README.md` for library changes.
   - `nixos/README.md` for NixOS changes.
   - `pkgs/README.md` for package changes.

## Examples

### Good Commit Titles

- `hello: 2.10 -> 2.12`
- `python311Packages.requests: 2.28.1 -> 2.31.0`
- `firefox: init at 121.0`
- `nixos/postgresql: add option for custom configuration`
- `lib/strings: fix off-by-one error in substring function`
- `doc: add guide for packaging python applications`
- `maintainers: add johndoe`

### Bad Commit Titles

- `feat: add hello package` because it uses the Conventional Commits format.
- `fix(python): update requests` because it uses the Conventional Commits format.
- `Hello: 2.10 -> 2.12` because the package name is capitalized.
- `hello: 2.10 -> 2.12.` because the title ends with a period.
- `Update hello to version 2.12` because it is not concise and omits the old version.

### Good Commit with a Body

```markdown
python311Packages.requests: 2.28.1 -> 2.31.0

This release includes several security fixes and bug fixes. Notable
changes include improved handling of redirect loops and better support
for international domain names.

Release notes: https://github.com/psf/requests/releases/tag/v2.31.0
```

### Good Maintainer Addition

```markdown
maintainers: add johndoe
```

### Good New Package

```markdown
hello: init at 2.12

GNU Hello is a program that prints "Hello, world!" when run. It
serves as an example of standard GNU coding practices.
```

[nixpkgs-commit-conventions]: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#commit-conventions
