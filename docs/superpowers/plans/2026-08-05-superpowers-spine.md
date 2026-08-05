# Superpowers Spine With Two Metis Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the superpowers plugin and skills the mandatory workflow spine, keep only the metis `commit` and `pull-request` commands with the `builder` agent and their two supporting skills, and expose anthropic, vercel, and matt-pocock as individually optional leaf skill sources.

**Architecture:** Delete the competing first-party workflow agents, commands, and skills. Rewire the surviving `builder` agent and two git/PR skills off the deleted `apply-writing-style` skill, relying on the global `context.md` for style. Simplify the Nix layer so the spine and core assets always ship, model configuration collapses to a single `primary` field, and each leaf source gets its own enable flag.

**Tech Stack:** Nix flakes, home-manager module, Markdown agent, command, and skill definitions.

## Global Constraints

- Adhere to Chicago Manual of Style in all prose, comments, and documentation.
- Never use em dashes, en dashes, or decorative hyphens. Allow hyphens only in standard hyphenated words and literal technical tokens.
- Use GNU-style explicit long options in commands, except where the platform tool lacks them (darwin BSD `mkdir` has no `--parents`; use `-p` there).
- Use "configuration" not "config", "utility" not "util".
- Use reference-style links in Markdown.
- Every file ends in a single trailing newline with no trailing whitespace.
- Keep lists alphanumerically sorted in ascending order where a list is sorted.
- Leaf sources default to off. Zero leaf sources is a valid configuration. The superpowers spine is always installed when `metis.opencode.enable = true`.
- Verify with `nix flake check` (or `scripts/test.sh`) and `nix fmt` after Nix changes.

---

### Task 1: Delete the superseded agents, commands, and skills

**Files:**
- Delete: `core/agents/planner.md`
- Delete: `core/agents/code-reviewer.md`
- Delete: `core/agents/security-auditor.md`
- Delete: `core/agents/technical-writer.md`
- Delete: `core/agents/explorer.md`
- Delete: `core/agents/chicken.md`
- Delete: `core/commands/plan.md`
- Delete: `core/commands/implement.md`
- Delete: `core/commands/research.md`
- Delete: `core/commands/fix-issue.md`
- Delete: `core/commands/changelog.md`
- Delete: `core/skills/apply-writing-style/` (directory)
- Delete: `core/skills/apply-owasp-security/` (directory)
- Delete: `core/skills/fix-github-issue/` (directory)
- Delete: `core/skills/upsert-github-release/` (directory)

**Interfaces:**
- Produces: a `core/` tree containing exactly `agents/builder.md`, `commands/commit.md`, `commands/pull-request.md`, `skills/upsert-git-commit/`, and `skills/upsert-github-pull-request/`.

- [ ] **Step 1: Delete the six superseded agents and five commands**

```bash
cd /Users/mads/repo/metis
git rm core/agents/planner.md core/agents/code-reviewer.md \
  core/agents/security-auditor.md core/agents/technical-writer.md \
  core/agents/explorer.md core/agents/chicken.md \
  core/commands/plan.md core/commands/implement.md \
  core/commands/research.md core/commands/fix-issue.md \
  core/commands/changelog.md
```

- [ ] **Step 2: Delete the four superseded skill directories**

```bash
cd /Users/mads/repo/metis
git rm --recursive core/skills/apply-writing-style \
  core/skills/apply-owasp-security core/skills/fix-github-issue \
  core/skills/upsert-github-release
```

- [ ] **Step 3: Verify the surviving core tree**

```bash
cd /Users/mads/repo/metis
find core -type f | sort
```

Expected: exactly these entries appear.

```text
core/agents/builder.md
core/commands/commit.md
core/commands/pull-request.md
core/skills/upsert-git-commit/LICENSE-APACHE
core/skills/upsert-git-commit/LICENSE-MIT
core/skills/upsert-git-commit/SKILL.md
core/skills/upsert-github-pull-request/LICENSE-APACHE
core/skills/upsert-github-pull-request/LICENSE-MIT
core/skills/upsert-github-pull-request/SKILL.md
```

- [ ] **Step 4: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "refactor: remove first-party workflow superseded by superpowers spine"
```

---

### Task 2: Rewire the builder agent off deleted references

**Files:**
- Modify: `core/agents/builder.md`

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: a `builder.md` whose only model placeholder is `__PRIMARY_MODEL__` and which contains no references to `apply-writing-style`, `planner`, `security-auditor`, or `technical-writer`.

- [ ] **Step 1: Remove the "Before Starting Any Task" block**

Delete these lines from `core/agents/builder.md` (currently lines 20 through 25, including the surrounding blank line so no double blank line remains):

```markdown
## Before Starting Any Task

Load and use the `apply-writing-style` skill before writing or editing text.
Follow its Chicago Manual of Style, capitalization, grammar, and command formatting
rules for all output.

```

Style now comes from the global `context.md`, so the agent no longer loads a per-agent style skill.

- [ ] **Step 2: Replace the "When to Hand Off" section**

The current section references deleted agents. Replace the whole section:

```markdown
## When to Hand Off

- Need research or planning: use planner first.
- Security review needed: escalate to security-auditor.
- Need documentation: coordinate with technical-writer.
- Complex architecture decisions: consult planner first.
```

with this superpowers-oriented version:

```markdown
## When to Hand Off

- Need research or planning: use the superpowers writing-plans skill first.
- Need a code review: use the superpowers requesting-code-review skill.
- Hit a bug or unexpected behavior: use the superpowers systematic-debugging skill.
- Before claiming work is complete: use the superpowers verification-before-completion skill.
```

- [ ] **Step 3: Verify no stale references remain**

```bash
cd /Users/mads/repo/metis
rg -n "apply-writing-style|planner|security-auditor|technical-writer" core/agents/builder.md
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "refactor(builder): rewire handoffs onto superpowers skills"
```

---

### Task 3: Strip apply-writing-style loads from the two kept skills

**Files:**
- Modify: `core/skills/upsert-git-commit/SKILL.md:11`
- Modify: `core/skills/upsert-github-pull-request/SKILL.md:11`

**Interfaces:**
- Produces: two `SKILL.md` files with no `apply-writing-style` load line.

- [ ] **Step 1: Remove the load line from upsert-git-commit**

Delete this exact bullet (line 11) from `core/skills/upsert-git-commit/SKILL.md`:

```markdown
- Load the `apply-writing-style` skill for writing style guidelines before continuing.
```

- [ ] **Step 2: Remove the load line from upsert-github-pull-request**

Delete this exact bullet (line 11) from `core/skills/upsert-github-pull-request/SKILL.md`:

```markdown
- Load the `apply-writing-style` skill for writing style guidelines before continuing.
```

- [ ] **Step 3: Verify no stale references remain**

```bash
cd /Users/mads/repo/metis
rg -n "apply-writing-style" core/skills
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "refactor(skills): drop apply-writing-style load from git and pr skills"
```

---

### Task 4: Add leaf skill source discovery in default.nix

**Files:**
- Modify: `default.nix`

**Interfaces:**
- Consumes: `sources.anthropic-skills`, `sources.vercel-skills`, `sources.matt-pocock-skills`, already threaded in through `flake.nix`.
- Produces: the returned attribute set gains `anthropicSkills`, `vercelSkills`, and `mattPocockSkills`, each an attribute set of discovered directory skills. The `models` argument is reduced to a single `primary` field.

- [ ] **Step 1: Reduce the models default in default.nix**

Replace the `models` argument default (currently lines 5 through 9):

```nix
  models ? {
    primary = "opencode/gpt-5.1-codex";
    review = "opencode/gpt-5.1-codex";
    lightweight = "opencode/gpt-5.1-codex";
  },
```

with a single-field default:

```nix
  models ? {
    primary = "opencode/gpt-5.1-codex";
  },
```

- [ ] **Step 2: Add the matt-pocock source binding**

In the `let` block, after the `vercelSkillsSrc = sources.vercel-skills;` binding, add:

```nix

  # mattpocock/skills: Skills for real software engineering.
  # https://github.com/mattpocock/skills
  mattPocockSkillsSrc = sources.matt-pocock-skills;
```

- [ ] **Step 3: Add leaf skill discovery to the returned set**

After the `superpowersSkills = discoverDirectorySkills (superpowersSrc + "/skills");` line, add the three leaf discoveries. Confirm each source's skill directory path first (see Step 4).

```nix

  # Optional leaf skill sources. Each is gated by its own enable flag in the
  # home-manager module and layered on top of the superpowers spine.
  anthropicSkills = discoverDirectorySkills anthropicSkillsSrc;
  vercelSkills = discoverDirectorySkills vercelSkillsSrc;
  mattPocockSkills = discoverDirectorySkills mattPocockSkillsSrc;
```

- [ ] **Step 4: Verify the leaf source skill directory layout**

The `discoverDirectorySkills` function expects a directory containing `<name>/SKILL.md` subdirectories. Confirm the actual layout of each source before trusting the paths above.

```bash
cd /Users/mads/repo/metis
nix --extra-experimental-features "nix-command flakes" eval --raw --expr '
  let f = builtins.getFlake (toString ./.);
  in builtins.concatStringsSep "\n" (builtins.attrNames (builtins.readDir f.inputs.anthropic-skills))
'
```

Expected: a list of entries. If the skills live under a subdirectory (for example `skills/` or `document-skills/`) rather than the repository root, adjust the corresponding `discoverDirectorySkills` argument to append that subpath. Repeat for `vercel-skills` and `matt-pocock-skills`. Record the correct paths before proceeding.

- [ ] **Step 5: Confirm default.nix evaluates**

```bash
cd /Users/mads/repo/metis
nix --extra-experimental-features "nix-command flakes" eval --raw --expr '
  let f = builtins.getFlake (toString ./.);
      p = f.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
      s = f.lib.build { pkgs = p; };
  in builtins.concatStringsSep "," [
    (toString (builtins.length (builtins.attrNames s.anthropicSkills)))
    (toString (builtins.length (builtins.attrNames s.vercelSkills)))
    (toString (builtins.length (builtins.attrNames s.mattPocockSkills)))
  ]
'
```

Expected: three comma-separated non-negative integers, no evaluation error.

- [ ] **Step 6: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "feat(nix): discover anthropic, vercel, and matt-pocock leaf skills"
```

---

### Task 5: Simplify the model placeholder substitution in dump.nix

**Files:**
- Modify: `dump.nix`

**Interfaces:**
- Consumes: `settings.models.primary` only.
- Produces: `substituteModelPlaceholders` replaces only `__PRIMARY_MODEL__`. The `includeSuperpowers` and `includeCore` gates are replaced by always rendering the spine and core, plus three leaf-source flags `includeAnthropicSkills`, `includeVercelSkills`, and `includeMattPocockSkills`.

- [ ] **Step 1: Reduce the placeholder substitution**

Replace the `substituteModelPlaceholders` body (currently lines 12 through 19):

```nix
    builtins.replaceStrings
      [ "__PRIMARY_MODEL__" "__REVIEW_MODEL__" "__LIGHTWEIGHT_MODEL__" ]
      [
        settings.models.primary
        settings.models.review
        settings.models.lightweight
      ]
      content;
```

with:

```nix
    builtins.replaceStrings
      [ "__PRIMARY_MODEL__" ]
      [ settings.models.primary ]
      content;
```

- [ ] **Step 2: Replace the argument flags**

Replace the argument header (currently lines 1 through 6):

```nix
{
  pkgs,
  settings,
  includeSuperpowers ? true,
  includeCore ? true,
}:
```

with leaf-source flags, spine and core always on:

```nix
{
  pkgs,
  settings,
  includeAnthropicSkills ? false,
  includeMattPocockSkills ? false,
  includeVercelSkills ? false,
}:
```

- [ ] **Step 3: Always render spine and core, add leaf skill commands**

Replace the command bindings (currently lines 47 through 60):

```nix
  superpowersSkillCommands = lib.optionals includeSuperpowers (
    lib.mapAttrsToList renderSkill settings.superpowersSkills
  );
  coreSkillCommands = lib.optionals includeCore (lib.mapAttrsToList renderSkill settings.coreSkills);
  agentCommands = lib.optionals includeCore (
    lib.mapAttrsToList (renderFile "agents") settings.agents
  );
  commandCommands = lib.optionals includeCore (
    lib.mapAttrsToList (renderFile "commands") settings.commands
  );

  contextCommand = lib.optionalString includeCore ''cp ${builtins.toString settings.context} "$out/context.md"'';

  pluginCommand = lib.optionalString includeSuperpowers ''cp ${builtins.toString settings.superpowersPlugin} "$out/plugins/superpowers.js"'';
```

with:

```nix
  superpowersSkillCommands = lib.mapAttrsToList renderSkill settings.superpowersSkills;
  coreSkillCommands = lib.mapAttrsToList renderSkill settings.coreSkills;
  anthropicSkillCommands = lib.optionals includeAnthropicSkills (
    lib.mapAttrsToList renderSkill settings.anthropicSkills
  );
  vercelSkillCommands = lib.optionals includeVercelSkills (
    lib.mapAttrsToList renderSkill settings.vercelSkills
  );
  mattPocockSkillCommands = lib.optionals includeMattPocockSkills (
    lib.mapAttrsToList renderSkill settings.mattPocockSkills
  );
  agentCommands = lib.mapAttrsToList (renderFile "agents") settings.agents;
  commandCommands = lib.mapAttrsToList (renderFile "commands") settings.commands;

  contextCommand = ''cp ${builtins.toString settings.context} "$out/context.md"'';

  pluginCommand = ''cp ${builtins.toString settings.superpowersPlugin} "$out/plugins/superpowers.js"'';
```

- [ ] **Step 4: Emit the leaf skill commands in the runCommand body**

Replace the skill command concatenation block (currently lines 67 through 70):

```nix
  ${lib.concatStringsSep "\n" superpowersSkillCommands}
  ${lib.concatStringsSep "\n" coreSkillCommands}
  ${lib.concatStringsSep "\n" agentCommands}
  ${lib.concatStringsSep "\n" commandCommands}
```

with:

```nix
  ${lib.concatStringsSep "\n" superpowersSkillCommands}
  ${lib.concatStringsSep "\n" coreSkillCommands}
  ${lib.concatStringsSep "\n" anthropicSkillCommands}
  ${lib.concatStringsSep "\n" vercelSkillCommands}
  ${lib.concatStringsSep "\n" mattPocockSkillCommands}
  ${lib.concatStringsSep "\n" agentCommands}
  ${lib.concatStringsSep "\n" commandCommands}
```

- [ ] **Step 5: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "refactor(nix): render spine and core always, gate leaf skills"
```

---

### Task 6: Rework the home-manager module and flake models

**Files:**
- Modify: `flake.nix`

**Interfaces:**
- Consumes: `dump.nix` with the new flag names and the reduced `models` shape.
- Produces: options `metis.opencode.enable`, `metis.opencode.core.models.primary`, and three leaf-source enable options `metis.opencode.anthropicSkills.enable`, `metis.opencode.vercelSkills.enable`, `metis.opencode.mattPocockSkills.enable`. The superpowers plugin and core assets always render when opencode is enabled.

- [ ] **Step 1: Reduce the build models default**

Replace the `build` model default (currently lines 61 through 65):

```nix
          models ? {
            primary = "opencode/gpt-5.1-codex";
            review = "opencode/gpt-5.1-codex";
            lightweight = "opencode/gpt-5.1-codex";
          },
```

with:

```nix
          models ? {
            primary = "opencode/gpt-5.1-codex";
          },
```

- [ ] **Step 2: Reduce the module defaultModels and models merge**

Replace the module `defaultModels` block (currently lines 84 through 89):

```nix
          defaultModels = {
            primary = "opencode/gpt-5.1-codex";
            review = "opencode/gpt-5.1-codex";
            lightweight = "opencode/gpt-5.1-codex";
          };
          models = defaultModels // (cfg.opencode.core.models or { });
```

with:

```nix
          defaultModels = {
            primary = "opencode/gpt-5.1-codex";
          };
          models = defaultModels // (cfg.opencode.core.models or { });
```

- [ ] **Step 3: Rework the rendered call to use leaf flags**

Replace the `rendered` binding (currently lines 90 through 95):

```nix
          rendered = pkgs.callPackage ./dump.nix {
            inherit pkgs;
            settings = build { inherit pkgs models; };
            includeSuperpowers = cfg.opencode.superpowers.enable;
            includeCore = cfg.opencode.core.enable;
          };
```

with:

```nix
          rendered = pkgs.callPackage ./dump.nix {
            inherit pkgs;
            settings = build { inherit pkgs models; };
            includeAnthropicSkills = cfg.opencode.anthropicSkills.enable;
            includeMattPocockSkills = cfg.opencode.mattPocockSkills.enable;
            includeVercelSkills = cfg.opencode.vercelSkills.enable;
          };
```

- [ ] **Step 4: Replace the opencode options**

Replace the superpowers and core option declarations plus the models submodule (currently lines 99 through 127) with the mandatory-spine and leaf-source options. Delete the old `superpowers.enable`, `core.enable`, and the three-field `core.models` submodule, and add:

```nix
          options.metis.opencode.anthropicSkills.enable =
            lib.mkEnableOption "install the anthropic leaf skills on top of the superpowers spine";
          options.metis.opencode.mattPocockSkills.enable =
            lib.mkEnableOption "install the matt-pocock leaf skills on top of the superpowers spine";
          options.metis.opencode.vercelSkills.enable =
            lib.mkEnableOption "install the vercel leaf skills on top of the superpowers spine";
          options.metis.opencode.core.models = lib.mkOption {
            type =
              with lib.types;
              submodule {
                options = {
                  primary = lib.mkOption {
                    type = str;
                    default = "opencode/gpt-5.1-codex";
                    description = "Model for the builder agent.";
                  };
                };
              };
            default = { };
            description = "Model configuration for the builder agent.";
          };
```

Keep the existing `options.metis.opencode.enable` line above these. The `metis.claude.enable` and `metis.codex.enable` options stay unchanged.

- [ ] **Step 5: Always render spine and core for opencode**

Replace the opencode `home.file` merge (currently lines 133 through 145):

```nix
              home.file = lib.mkMerge [
                {
                  ".config/opencode/skills".source = "${rendered}/skills";
                }
                (lib.mkIf cfg.opencode.core.enable {
                  ".config/opencode/AGENTS.md".source = "${rendered}/context.md";
                  ".config/opencode/agents".source = "${rendered}/agents";
                  ".config/opencode/commands".source = "${rendered}/commands";
                })
                (lib.mkIf cfg.opencode.superpowers.enable {
                  ".config/opencode/plugins".source = "${rendered}/plugins";
                })
              ];
```

with an unconditional set, since the spine and core always ship:

```nix
              home.file = {
                ".config/opencode/AGENTS.md".source = "${rendered}/context.md";
                ".config/opencode/agents".source = "${rendered}/agents";
                ".config/opencode/commands".source = "${rendered}/commands";
                ".config/opencode/plugins".source = "${rendered}/plugins";
                ".config/opencode/skills".source = "${rendered}/skills";
              };
```

- [ ] **Step 6: Format the flake**

```bash
cd /Users/mads/repo/metis
nix --extra-experimental-features "nix-command flakes" fmt
```

Expected: no errors; files reformatted in place if needed.

- [ ] **Step 7: Run the flake check**

```bash
cd /Users/mads/repo/metis
nix --extra-experimental-features "nix-command flakes" flake check
```

Expected: `all checks passed` equivalent, no evaluation errors.

- [ ] **Step 8: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "feat(nix): make superpowers spine mandatory, add leaf source flags"
```

---

### Task 7: Update the dump script attribute categories

**Files:**
- Modify: `scripts/dump.sh:32`, `scripts/dump.sh:41`

**Interfaces:**
- Consumes: the settings attributes `agents`, `commands`, `coreSkills`, `superpowersSkills`, `anthropicSkills`, `vercelSkills`, `mattPocockSkills`.
- Produces: a dump listing that includes the leaf skill categories.

- [ ] **Step 1: Extend the attribute-name category loop**

In `scripts/dump.sh`, replace both occurrences of the category list:

```bash
    for CATEGORY in agents commands coreSkills superpowersSkills; do
```

with:

```bash
    for CATEGORY in agents anthropicSkills commands coreSkills mattPocockSkills superpowersSkills vercelSkills; do
```

There are two occurrences (the attribute-name loop and the resolved-store-paths loop). Update both.

- [ ] **Step 2: Verify the dump script parses**

```bash
cd /Users/mads/repo/metis
bash -n scripts/dump.sh
```

Expected: no output, exit status 0.

- [ ] **Step 3: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "chore(scripts): list leaf skill categories in dump"
```

---

### Task 8: Materialize and verify the rendered tree

**Files:**
- No source changes. This task verifies the end-to-end render.

**Interfaces:**
- Consumes: all prior tasks.
- Produces: a verified `generated/` tree.

- [ ] **Step 1: Run the dump with the default build (no leaf sources)**

```bash
cd /Users/mads/repo/metis
scripts/dump.sh
```

Expected: completes and writes the rendered tree to `generated/`. Note that `scripts/dump.sh` calls `import ${FLAKE_SOURCE}/dump.nix { inherit pkgs settings; }` with no leaf flags, so all three leaf flags default to false.

- [ ] **Step 2: Verify the rendered agents, commands, and core skills**

```bash
cd /Users/mads/repo/metis
find generated/agents generated/commands -type f | sort
ls generated/skills | sort
```

Expected: `generated/agents/builder.md`, `generated/commands/commit.md`, and `generated/commands/pull-request.md` are present and are the only agent and command files. The `generated/skills` listing contains the superpowers skills plus `upsert-git-commit` and `upsert-github-pull-request`, and does not contain any anthropic, vercel, or matt-pocock skill (leaf flags are off).

- [ ] **Step 3: Verify the plugin and model substitution**

```bash
cd /Users/mads/repo/metis
test -f generated/plugins/superpowers.js && echo "plugin present"
rg -n "__PRIMARY_MODEL__|__REVIEW_MODEL__|__LIGHTWEIGHT_MODEL__" generated/agents/builder.md
```

Expected: `plugin present` prints, and the `rg` command produces no output (all placeholders substituted, no stray review or lightweight placeholders).

- [ ] **Step 4: Confirm no commit needed**

The `generated/` directory is materialized output. Check whether it is tracked.

```bash
cd /Users/mads/repo/metis
git status --short generated
```

If `generated/` is tracked and changed, commit it:

```bash
cd /Users/mads/repo/metis
git add generated
git commit --message "chore(generated): refresh rendered tree for superpowers spine"
```

If `generated/` is ignored (no output), do nothing.

---

### Task 9: Update the README for the new source model

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: the final option and attribute names from Tasks 4 through 7.
- Produces: a README whose Quick Start, feature-group description, function reference, and contents table match the superpowers-spine model.

- [ ] **Step 1: Update the Quick Start home.nix example**

Replace the `metis.opencode` block (currently README lines 24 through 37):

```nix
  metis.opencode = {
    enable = true;
    superpowers.enable = true;
    core = {
      enable = true;
      models = {
        primary = "opencode/gpt-5.1-codex";
        review = "opencode/gpt-5.1-codex";
        lightweight = "opencode/gpt-5.1-codex";
      };
    };
  };
```

with the mandatory-spine model plus optional leaf flags:

```nix
  metis.opencode = {
    enable = true;
    anthropicSkills.enable = false;
    mattPocockSkills.enable = false;
    vercelSkills.enable = false;
    core.models.primary = "opencode/gpt-5.1-codex";
  };
```

- [ ] **Step 2: Rewrite the feature-group paragraph**

Replace the paragraph after the Quick Start example (currently README line 40):

```markdown
The opencode module exposes two independent feature groups. Enable `superpowers` to install the upstream superpowers skills and plugin. Enable `core` to install the first-party metis agents, commands, skills, and context. Model configuration lives under `core.models`.
```

with:

```markdown
The opencode module installs the superpowers spine and the first-party metis assets whenever `enable` is true. The spine provides the superpowers plugin and skills that drive the whole workflow. The first-party assets are the `builder` agent, the `commit` and `pull-request` commands, their two supporting skills, and the shared context. Each leaf skill source, anthropic, vercel, and matt-pocock, is an optional add-on gated by its own enable flag and defaulting to off. Model configuration for the builder agent lives under `core.models.primary`.
```

- [ ] **Step 3: Update the low-level builder example skills line**

The builder example merges skills. Replace the skills assignment (currently README line 56):

```nix
    skills = settings.superpowersSkills // settings.coreSkills;
```

with a version that shows leaf sources are available to merge:

```nix
    skills = settings.superpowersSkills // settings.coreSkills;
    # Optional: layer in leaf sources, for example:
    # // settings.anthropicSkills // settings.vercelSkills // settings.mattPocockSkills;
```

- [ ] **Step 4: Update the Contents table**

Replace the Contents table body (currently README lines 71 through 74) to reflect the reduced core:

```markdown
| `core/skills/` | First-party directory skills in `SKILL.md` format. |
| `core/commands/` | First-party slash command definitions. |
| `core/agents/` | First-party agent definitions. |
| `context.md` | Shared global instructions rendered to `AGENTS.md` or `CLAUDE.md`. |
```

with:

```markdown
| `core/agents/` | The first-party `builder` agent. |
| `core/commands/` | The `commit` and `pull-request` slash commands. |
| `core/skills/` | The `upsert-git-commit` and `upsert-github-pull-request` skills. |
| `context.md` | Shared global instructions rendered to `AGENTS.md` or `CLAUDE.md`. |
```

- [ ] **Step 5: Update the returned members table**

In the Function Reference returned-members table (currently README lines 87 through 98), keep the existing rows and add three rows for the leaf skill attributes, keeping the table alphanumerically consistent with its neighbors:

```markdown
| `anthropicSkills` | The discovered Anthropic leaf skills. |
| `vercelSkills` | The discovered Vercel leaf skills. |
```

The `mattPocockSkills` row already exists in the table. Confirm all three leaf attributes (`anthropicSkills`, `mattPocockSkills`, `vercelSkills`) appear.

- [ ] **Step 6: Verify no stale option names remain in the README**

```bash
cd /Users/mads/repo/metis
rg -n "superpowers\.enable|core\.enable|models\.review|models\.lightweight|__REVIEW_MODEL__|__LIGHTWEIGHT_MODEL__" README.md
```

Expected: no output.

- [ ] **Step 7: Commit**

```bash
cd /Users/mads/repo/metis
git commit --message "docs(readme): document superpowers spine and leaf sources"
```

---

### Task 10: Final full verification

**Files:**
- No source changes.

**Interfaces:**
- Consumes: all prior tasks.

- [ ] **Step 1: Run the flake check**

```bash
cd /Users/mads/repo/metis
scripts/test.sh
```

Expected: `all checks passed`.

- [ ] **Step 2: Confirm formatting is clean**

```bash
cd /Users/mads/repo/metis
nix --extra-experimental-features "nix-command flakes" fmt
git status --short
```

Expected: no unstaged formatting changes after the run.

- [ ] **Step 3: Confirm the whole-repo has no stale references**

```bash
cd /Users/mads/repo/metis
rg -n "includeSuperpowers|includeCore|apply-writing-style|__REVIEW_MODEL__|__LIGHTWEIGHT_MODEL__|models\.review|models\.lightweight" \
  --glob '!docs/**' --glob '!RELEASE-NOTES.md'
```

Expected: no output.
