# Conventional Commits

Conventional Commits is the default convention for most repositories. A
pull request title follows the same shape as a commit title. See the
[Conventional Commits specification][conventional-commits] for the
authoritative rules.

## Title Format

```text
<type>(<scope>): <description>
```

- `<type>` identifies the kind of change and is required.
- `<scope>` is optional and names the affected area.
- `<description>` is the summary of the change.

## Types

- `feat`: A new feature.
- `fix`: A bug fix.
- `docs`: Documentation only changes.
- `style`: Changes that do not affect the meaning of the code.
- `refactor`: A code change that neither fixes a bug nor adds a feature.
- `perf`: A code change that improves performance.
- `test`: Adding missing tests or correcting existing tests.
- `build`: Changes that affect the build system or external dependencies.
- `ci`: Changes to CI configuration files and scripts.
- `chore`: Other changes that do not modify source or test files.
- `revert`: Reverts a previous commit.

## Title Rules

- Use the imperative mood in the description, for example "add" not "added".
- Keep the description entirely lowercase, including product names.
- Do not capitalize any words in the description.
- Do not end the description with a period.
- Use `type(scope):` when the scope is known.

## Description Format

Use these sections unless a repository pull request template is present.

```text
## Summary

- <high-level change 1>
- <high-level change 2>

## Commit Groups

- <logical group 1 from feature branch commits>
- <logical group 2 from feature branch commits>

## Notes

- <tests, migration notes, or follow-up information>
```

## Example

A pull request titled `feat(api): add rate limiting middleware`:

```markdown
feat(api): add rate limiting middleware

## Summary

- Add `express-rate-limit` middleware to prevent API abuse.
- Configure a sliding window of 100 requests per 15 minute window.

## Commit Groups

- feat(api): add rate limiting middleware
- docs(api): document rate limit responses

## Notes

- Rate limiting applies to all `/api/*` endpoints except health checks.
```

[conventional-commits]: https://www.conventionalcommits.org/
