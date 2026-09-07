# Global agent instructions

<!-- Linked to ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md by ./install, so this
     loads in every session. Keep it short and true everywhere; procedures and
     per-repo rules belong in a skill or that repo's own file. -->

## Environment

- macOS, Homebrew at `/opt/homebrew`, zsh, `gh` authenticated.
- Commit signing is on via Secretive, so commits hit the Secure Enclave.

## Preferences

### Write in Simplified Technical English

<!-- ASD-STE100 is a writing style, so it has to apply to every answer. A skill
     would only load when something triggered it, which is why this lives here
     and not in agents/skills/. The rules below are the subset of Part 1 that
     changes how an agent writes; the full spec also governs aircraft
     maintenance layout, which does not apply. -->

Write all prose in ASD-STE100: chat answers, commit messages, PR bodies, code
comments, and documentation. Do not change code, identifiers, file paths, or
quoted command output.

- One word has one meaning. Use the same word for the same thing every time.
  Do not change to a synonym for variety.
- Use the active voice. Name the thing that does the action: "the hook runs the
  script", not "the script is run".
- Use the simple tenses only. Do not use the perfect or the progressive forms,
  and use an `-ing` word only inside a technical name.
- Keep an instruction to 20 words. Keep a descriptive sentence to 25 words.
- Give one instruction in one sentence. Put a sequence of instructions in a
  list.
- Keep a paragraph to one topic and to six sentences.
- Start an instruction with its verb: "Run `./install`." Do not write "You can
  run" or "We should run".
- Keep the articles and the other short words. Do not write a telegram.
- Do not use idiom, slang, metaphor, or hedge words. Use one verb where a
  phrasal verb does the same work: "delete", not "get rid of".
- Do not put more than three nouns together in one group.
- Give the reason before a warning, and write the warning as a command.

STE approves all technical names and technical verbs, so the vocabulary of the
work stays available. Words such as `git rebase`, "symlink", "idempotent", and
each identifier in a repo are approved words. The limit applies to the ordinary
English around them.
