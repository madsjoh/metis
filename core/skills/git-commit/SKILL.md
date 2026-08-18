---
name: git-commit
description: Create conventional commit messages from staged changes, with automatic nixpkgs convention detection. Use whenever the user wants to commit, stage, or write a commit message, including phrases like "commit this", "write a commit message", or after finishing a logical change, to generate correctly formatted, signed-off commits following Conventional Commits or nixpkgs conventions.
---

# Git Commit

## What This Skill Does

- Run `git diff --staged` first to inspect what will be committed.
- Always use `git commit --signoff` to include a `Signed-off-by:` trailer.
- Analyze staged changes to generate commit messages.
- Separate staged changes into separate logical commits.
- Detect the repository type and apply the matching convention.
- Follow the [Conventional Commits specification][conventional-commits] for most repositories.
- For nixpkgs or its forks, follow the [nixpkgs commit conventions][nixpkgs-commit-conventions].
- For Linux kernel style repositories, follow the [kernel commit conventions][kernel-commit-conventions].

## Attribution

Do not add `Co-Authored-By` or any LLM attribution trailer by default.

Only add attribution when the user explicitly asks, for example "add attribution",
"include co-authored-by", or "credit the LLM". When asked, append this trailer
after `Signed-off-by:`, substituting the actual tool name and model in use:

- Claude Code: `Co-Authored-By: Claude Code (<model>) <noreply@anthropic.com>`
- OpenCode: Use the value of the `$LLM_COAUTHOR` environment variable.

## Repository Detection

**Critical:** Always detect the repository type before creating commits.

1. Check whether the repository is nixpkgs or a nixpkgs fork by examining:
   - Remote URLs containing `NixOS/nixpkgs` or similar.
   - The presence of `pkgs/top-level/all-packages.nix` or a similar nixpkgs structure.
2. If it is nixpkgs, follow the [nixpkgs commit conventions][nixpkgs-commit-conventions].
3. Check whether the repository follows the Linux kernel style by examining:
   - Remote URLs containing `kernel.org` or `torvalds/linux`.
   - The presence of a `MAINTAINERS` file and a `Documentation/process/` directory.
4. If it follows the kernel style, follow the [kernel commit conventions][kernel-commit-conventions].
5. Otherwise, follow the [Conventional Commits specification][conventional-commits].

## General Rules for All Repositories

These rules apply to every commit regardless of convention.

### The 50/72 Rule

- The title must be 50 characters or fewer, including type, scope, colon, and spaces.
- Body lines must wrap at 72 characters maximum per line.
- Verify the character count before committing with `echo --no-newline "title" | wc --chars`.
- Do not use an em dash, en dash, or hyphen anywhere in the message, except within standard hyphenated words and technical tokens such as `Signed-off-by`.
- If the title or message contains backticks, use a heredoc with a quoted delimiter such as `<<'EOF'`, which suppresses all shell expansion inside the heredoc. Use this pattern for all commits.

The Linux kernel convention is the exception: it allows a subject up to 75
characters and wraps the body at 75 columns. See [Linux Kernel Commit
Conventions][kernel-commits-reference].

### Title Formatting

- Use the imperative mood in the description, for example "add" not "added".
- Keep the description entirely lowercase, including product names.
- Do not capitalize any words in the description.
- Do not end the description with a period.
- The entire title, including the convention prefix, counts toward the 50 character limit.

### Body Formatting

- Explain what changed and why, wrapped to 72 characters.
- Leave one blank line between the title and the body.
- Use proper grammar and punctuation following the Chicago Manual of Style.
- Start sentences with capital letters and end them with proper punctuation.
- Wrap technical identifiers, resource names, and code elements in backticks.
- Trailer lines such as `Signed-off-by` and `Co-Authored-By` are exempt from the 72 character limit.

### Footer

- Add a `BREAKING CHANGE:` footer for breaking changes.
- When referencing issues, pull requests, or URLs, use the format `Fix <url>.` with a trailing period.
- Do not use `Fixes:` or `Closes:` prefixes.

## Convention References

Read the matching reference file for the full convention details, types, and examples:

- [Conventional Commits][conventional-commits-reference] for most repositories.
- [nixpkgs Commit Conventions][nixpkgs-commits-reference] for nixpkgs and its forks.
- [Linux Kernel Commit Conventions][kernel-commits-reference] for kernel style repositories.

## References

- [Conventional Commits specification][conventional-commits]
- [nixpkgs commit conventions][nixpkgs-commit-conventions]
- [Linux kernel commit conventions][kernel-commit-conventions]

[conventional-commits]: https://www.conventionalcommits.org/
[conventional-commits-reference]: ./conventional-commits.md
[kernel-commit-conventions]: https://docs.kernel.org/process/submitting-patches.html
[kernel-commits-reference]: ./kernel-commits.md
[nixpkgs-commit-conventions]: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#commit-conventions
[nixpkgs-commits-reference]: ./nixpkgs-commits.md
