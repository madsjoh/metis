# Linux Kernel Commit Conventions

The Linux kernel does not use Conventional Commits. Its commits are organized
by subsystem and explain the reasoning behind each change. See [submitting
patches][submitting-patches] for the authoritative rules.

## Format

```text
<subsystem>: <imperative summary>

<body explaining what changed and why>

[optional trailers]
```

- `<subsystem>` names the area of the tree, for example `net/core`, `drivers/gpu/drm`, or `mm`.
- `<imperative summary>` describes the change in the imperative mood.
- The body explains the change and its reasoning.
- Trailer lines record authorship, reporting, review, and the `Fixes:` tag.

## Key Differences from Conventional Commits

- No type prefix such as `feat:` or `fix:`; the subsystem prefix plays that role.
- The subject line may be up to 75 characters rather than 50.
- The body wraps at 75 columns rather than 72.
- A `Signed-off-by:` trailer is mandatory under the Developer Certificate of Origin.
- Bug fixes reference the offending commit with a `Fixes:` tag.

## Subject Line

- Use the imperative mood, for example "make xyzzy do frotz", not "made xyzzy do frotz".
- Do not end the subject with a period.
- Keep the subject below 75 characters.
- Prefix the subject with the subsystem, for example `net/core: fix ...`.

## Body

- Explain what changed and why.
- Describe the problem the change solves, why this approach was chosen, and any relevant alternatives.
- Wrap lines at 75 columns.
- Avoid phrases such as "this patch" in favor of the imperative mood.

## Trailers

- `Signed-off-by:` is mandatory for every commit.
- `Fixes: <commit-id> ("<subject>")` references the commit a bug fix corrects.
- `Reported-by:` and `Suggested-by:` credit the reporter or the author of the idea.
- `Reviewed-by:` and `Tested-by:` record review and testing.

## Examples

### Good Commit Titles

- `e1000e: remove workaround for erratum 7`
- `s390/boot: fix double accounting of addresses`
- `net/core: fix use-after-free in skb_release_data`
- `mm: fix page leak in migrate_pages`
- `drivers/gpu/drm/i915: avoid division by zero`

### Bad Commit Titles

- `feat: add support for foo` because it uses the Conventional Commits format.
- `e1000e: Remove workaround for erratum 7` because the summary is not in the imperative mood.
- `e1000e: fixed a bug` because the summary is not in the imperative mood.
- `e1000e: add workaround for erratum 7.` because the subject ends with a period.

### Good Commit with a Body

```text
net/core: fix use-after-free in skb_release_data

A reference to the shared info structure is dropped before the last
user of the buffer is done with it. When the final destructor runs,
the shared info has already been freed, so the buffer is released
twice and the second release dereferences freed memory.

Move the destructor call after the last reference is released and add
a reference count check so the shared info cannot be freed while a
user still holds a reference.

Reported-by: Jane Doe <jane.doe@example.com>
Fixes: 1234567890ab ("net/core: refactor skb destructor")
Signed-off-by: John Doe <john.doe@example.com>
```

[submitting-patches]: https://docs.kernel.org/process/submitting-patches.html
