---
name: github-pull-request
description: Create or update pull request titles and descriptions from feature branch commits, with automatic nixpkgs convention detection and pull request template support. Use whenever the user wants to open, create, or update a pull request, or asks to "make a PR", "update the PR description", or prepare a branch for review, especially after new local modifications. Previews the title and description and requires explicit confirmation before running gh pr create or gh pr edit.
---

# GitHub Pull Request

## What This Skill Does

- Analyze all existing commit messages in the feature branch.
- Skip when the current branch is the default branch.
- Combine logical commits into a single pull request title and description.
- Detect the repository type and apply the matching convention.
- Detect a repository pull request template and fill it when present.
- Show a preview of the pull request title and description before any pull request command runs.
- Ask for explicit user confirmation before running `gh pr create` or `gh pr edit`.
- Follow the [Conventional Commits specification][conventional-commits] for most repositories.
- For nixpkgs or its forks, follow the [nixpkgs commit conventions][nixpkgs-commit-conventions].

## Attribution

Do not add any AI attribution to the pull request description by default.

Only add attribution when the user explicitly asks, for example "add attribution",
"include generated-by footer", or "credit the AI". When asked, append this line
at the end of the pull request description, substituting the tool in use:

- Claude Code: `Generated with [Claude Code](https://code.claude.com).`
- OpenCode: `Generated with [OpenCode](https://opencode.ai).`

## Pull Request Update Workflow

1. Detect whether the current branch is a feature branch.
2. If the current branch is the default branch, skip this skill.
3. Read the current commits in the feature branch and group logical changes.
4. Check for new local modifications and include the resulting commits.
5. Detect the repository type and any pull request template.
6. Generate a pull request title and description draft.
7. Show a preview of the draft title and description to the user.
8. Ask for explicit confirmation before running any pull request command.
9. If no pull request exists for the branch, run `gh pr create` only after user confirmation.
10. If a pull request exists, run `gh pr edit` only after user confirmation.

## Confirmation Requirement

- Never run `gh pr create` or `gh pr edit` without explicit user confirmation.
- Always show a preview of the pull request title and description first.
- If the user requests edits to the preview, update the draft and ask again.

## Repository Detection

**Critical:** Always detect the repository type before creating pull request
titles and descriptions.

1. Check whether the repository is nixpkgs or a nixpkgs fork by examining:
   - Remote URLs containing `NixOS/nixpkgs` or similar.
   - The presence of `pkgs/top-level/all-packages.nix` or a similar nixpkgs structure.
2. If it is nixpkgs, follow the [nixpkgs commit conventions][nixpkgs-commit-conventions].
3. Otherwise, follow the [Conventional Commits specification][conventional-commits].

## Pull Request Template Detection

Before generating a description, check for a repository pull request template.

1. Look for `.github/PULL_REQUEST_TEMPLATE.md`.
2. Look for `.github/PULL_REQUEST_TEMPLATE/` and any `.md` files inside it.
3. When a template exists, read it and use its section headings as the
   description skeleton. Fill in each section with content derived from the
   branch commits, keeping the repository structure instead of the standard
   format.
4. When no template exists, use the format from the matching convention
   reference.
5. Show a preview and require confirmation regardless of the source.

## General Rules for All Repositories

These rules apply to every pull request regardless of convention.

### The 50/72 Rule

- The title must be 50 characters or fewer, including type, scope, colon, and spaces.
- Body lines must wrap at 72 characters maximum per line.
- Verify the character count before creating with `echo --no-newline "title" | wc --chars`.
- Do not use an em dash, en dash, or hyphen anywhere in the title or description, except within standard hyphenated words and technical tokens.

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
- When using lists, each item must be a complete sentence ending with a period.

### Footer

- Add a `BREAKING CHANGE:` footer for breaking changes.
- When referencing issues, pull requests, or URLs, use the format `Fix <url>.` with a trailing period.
- Do not use `Fixes:` or `Closes:` prefixes.

## Convention References

Read the matching reference file for the full convention details and examples:

- [Conventional Commits][conventional-commits-reference] for most repositories.
- [nixpkgs Commit Conventions][nixpkgs-commits-reference] for nixpkgs and its forks.

## References

- [Conventional Commits specification][conventional-commits]
- [nixpkgs commit conventions][nixpkgs-commit-conventions]
- [Markdown reference-style links][markdown-reference-links]

[conventional-commits]: https://www.conventionalcommits.org/
[conventional-commits-reference]: ./conventional-commits.md
[markdown-reference-links]: https://www.markdownguide.org/basic-syntax/#reference-style-links
[nixpkgs-commit-conventions]: https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md#commit-conventions
[nixpkgs-commits-reference]: ./nixpkgs-commits.md
