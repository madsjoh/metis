# Conventional Commits

Conventional Commits is the default convention for most repositories. It uses a
structured title with an optional body and footers. See the [Conventional
Commits specification][conventional-commits] for the authoritative rules.

## Format

```text
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

- `<type>` identifies the kind of change and is required.
- `<scope>` is optional and names the affected area, for example a module or component.
- `<description>` is the summary of the change.
- A `!` before the colon, or a `BREAKING CHANGE:` footer, marks a breaking change.

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
- Always use `type(scope):` when the scope is known.

## Examples

### Good Commit Titles

- `feat: add user authentication`
- `fix: resolve memory leak in parser`
- `docs: update installation guide`
- `refactor: simplify database queries`
- `perf: optimize image loading`
- `ci: add automated security scanning`

### Bad Commit Titles

- `feat: Add user authentication` because the description is capitalized.
- `fix: Resolve memory leak in parser` because the description is capitalized.
- `docs: Update installation guide` because the description is capitalized.
- `docs: update installation guide.` because the description ends with a period.
- `feat: This adds a new feature for user authentication` because the
  description is long and not imperative.
- `Fix bug` because the type prefix and colon are missing.

### Good Commit with a Body

```markdown
feat(api): add rate limiting middleware

Implement `express-rate-limit` middleware to prevent API abuse.
Configure a sliding window of 100 requests per 15 minute window per IP
address. Add custom error messages and logging for rate limit
violations.

Rate limiting applies to all `/api/*` endpoints except health checks.
```

### Good Commit with a Footer

```markdown
fix(auth): resolve token expiration edge case

Update token refresh logic to handle race conditions when multiple
requests attempt to refresh an expired token simultaneously. Add a
mutex lock to ensure only one refresh operation occurs at a time.

Fix https://github.com/org/repo/issues/456.
```

### Bad Commit Footers

```text
Fix https://github.com/org/repo/issues/123
```

Incorrect: the period at the end is missing.

```text
Fixes: https://github.com/org/repo/issues/123
```

Incorrect: `Fixes:` is used instead of `Fix` without a colon.

### Good Commit with a Breaking Change

```markdown
feat!: drop support for Node 14

Remove Node 14 from the supported runtime matrix and bump the minimum
required version to Node 16.

BREAKING CHANGE: Node 14 is no longer supported.
```

[conventional-commits]: https://www.conventionalcommits.org/
