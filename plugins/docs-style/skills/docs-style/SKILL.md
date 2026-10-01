---
name: docs-style
description: House style for a project's prose — design documents, the README, CLAUDE.md, commit messages and pull request bodies, and user-facing copy. Google's developer documentation style guide, adapted to British English. Use it before writing or editing any of that prose, and when reviewing a pull request that changes it.
---

# House style

A project's own instructions — its CLAUDE.md, or whatever plays that part — say **what** goes in
each document and where. This says **how the sentences read**. Where the two disagree, the
project wins: keeping its record true and out of the way of concurrent work matters more than
any sentence.

The base is [Google's developer documentation style guide](https://developers.google.com/style).
It is a guide for exactly this kind of writing, it is opinionated in useful places, and
disagreeing with it is cheaper than inventing a style from nothing. **This style is British
English**, so some of it is inverted in _Where this style departs from Google_, and the
inversions are marked as such rather than quietly dropped.

## Provenance, and how much to trust it

`developers.google.com` was blocked by the egress proxy of the environment this was written in,
so it was not built by reading the guide. It was built from [`errata-ai/Google`](https://github.com/errata-ai/Google),
the Vale ruleset that encodes the guide rule by rule and links each one back to the page it comes
from, corroborated against model knowledge of the guide. The rules here are well attested; exact
wording of Google's own examples is not guaranteed. **If you can reach the guide, check it rather
than this file**, and correct anything here that turns out to be wrong.

## The rules that earn their place

Apply these to every document, every time.

- **Second person, and the imperative for instructions.** "Run the tests", not "You should run
  the tests" and not "The developer runs the tests". Reserve "we" for a decision this project
  made — a design record is allowed to say who decided what.
- **Present tense.** "The reducer clamps the delta at zero", not "will clamp". Future tense only
  for something that genuinely happens later.
- **Active voice, with the actor named.** "The relay refuses the claim", not "the claim is
  refused". Passive is fine when the actor is irrelevant or genuinely unknown.
- **Condition before instruction.** "To resume a match, press Resume", not "Press Resume to
  resume a match". The reader who does not need the instruction stops at the comma.
- **Say required, recommended and optional in those words.** Required is "must" or a bare
  imperative; recommended is "we recommend"; optional is "can"; possible is "might". Avoid
  "should" in a rule — it leaves the reader unsure whether they have to.
- **Cut `easy`, `easily`, `simple`, `simply` and `just`.** If it were easy the reader would not
  be reading. Say how many steps it takes instead.
- **Write so it stays true.** No `currently`, `now`, `soon`, `latest`, `new`, `at present`. If
  newness is the point, anchor it: "since the move to Workers", "measured on 2026-09-17". (This
  one does **not** apply to commit messages and pull request bodies — see _Commit messages and
  pull request bodies_.)
- **Don't claim what you cannot show.** No "best", "fastest", "always", "never", no unqualified
  security claims. Quote a measured number instead.
- **One idea per paragraph, and the same term for the same thing every time.** Synonyms read as
  new concepts to anybody who did not write the sentence.
- **No directional language.** Not "the table above", "the section below", "on the right". Use
  "preceding" and "following", or name the section. It is an accessibility rule, and it is also
  why a reordered document does not quietly start lying.
- **Link text describes its destination.** "See [_Deploying_](docs/deploying.md)",
  never "click [here]" or "read [this]".
- **Spell out an abbreviation on first use** unless everyone knows it (API, CSS, HTML, HTTP,
  JSON, SDK, SQL, URL). No `e.g.` or `i.e.` — write "for example" and "that is". No full stops
  in initialisms: "US", not "U.S.".
- **Numbers: spell out zero to nine in prose, numerals from 10**, and numerals always for
  versions, sizes, percentages, steps and measurements. A space between a number and its unit:
  `10 MB`, not `10MB`.
- **Code font for code things** — filenames, paths, identifiers, flags, commands, types, literal
  values. CSS lengths and durations stay closed up, because they are values rather than
  measurements: `11px` and `130ms`, but `10 MB` of memory. Product and project names stay in
  ordinary font. **Never inflect a code item**: write "the `paths` map's route", not
  "`paths`'s route".
- **Bold for a visible UI label**, matching its capitalisation: "press **Resume**". Don't make a
  verb of it ("**Resume** the match").

## Headings and lists

- **Sentence case, no full stop, no gerund opener.** "Keep the board hidden", not "Keeping the
  board hidden" and not "Keep The Board Hidden".
- **A task heading is an imperative; a concept heading is a noun phrase.** "Pause a match" is a
  task heading; "Pausing" is a concept heading and correct as it stands.
- **Don't skip levels, don't leave a heading with nothing under it, and don't repeat the page
  title as the first heading.**
- **Introduce every list, table and code block with a full sentence**, ending in a colon when it
  runs straight into the list.
- **Numbered for a sequence, bulleted for a set.** Keep items grammatically parallel. Never write
  a one-item list. Don't end a list with "etc." — say what it leaves out, or finish it.

## Where this style departs from Google

Each of these is a deliberate override, not an oversight.

| Google says                                    | Here                                                                                                         |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| American spelling                              | **British**: behaviour, colour, grey, centre, licence (noun), recognise                                      |
| Commas and full stops inside quotation marks   | **Outside**, unless they belong to the quoted matter: `Click "Save".`                                        |
| `January 19, 2017`                             | **`19 January 2017`** in prose. Keep ISO 8601 (`2026-09-17`) for a numeric date, and never `04/05/09`        |
| `3 PM`, 12-hour                                | **24-hour** (`15:45`). Keep the substance: minimise time zones, and give a UTC offset when you must name one |
| Em dash closed up (`word—word`)                | **Spaced** (`word — word`), which is British practice                                                        |
| Serial comma always                            | **When it removes an ambiguity**, and consistently within a document                                         |
| Expand `CLI`, prefer Google product vocabulary | Ignore all of it — it is house vocabulary for Google's products                                              |

Google's dash rules that are **not** about spacing still hold: don't use a dash where a colon or
a list would do the job, and don't put two of them in one sentence.

## Words

| Don't                                     | Do                                                  |
| ----------------------------------------- | --------------------------------------------------- |
| `allows you to`                           | `lets you`                                          |
| `in order to`                             | `to`                                                |
| `execute` (a program)                     | `run`                                               |
| `leverage`, `utilise`                     | `use`                                               |
| `ingest`                                  | `import`, `load`                                    |
| `once` (meaning after)                    | `after`                                             |
| `e.g.`, `i.e.`, `etc.`, `vs.`             | `for example`, `that is`, finish the list, `versus` |
| `click on`, `hit`                         | `click`, `press`                                    |
| `uncheck`, `deselect`                     | `clear`                                             |
| `kill`, `abort`, `terminate`              | `stop`, `exit`, `cancel`, `end`                     |
| `whitelist`, `blacklist`                  | `allowlist`, `blocklist`                            |
| `master`/`slave`                          | `primary`/`replica`, `main`                         |
| `sanity check`                            | say what is being checked                           |
| `dummy value`                             | `placeholder`                                       |
| `crazy`, `insane`, `blind to`, `cripples` | `baffling`, `unexpected`, `ignores`, `slows down`   |
| `he/she`, `s/he`                          | singular `they`, or second person                   |
| `regex`                                   | `regular expression`                                |
| `file name`, `check box`, `e-mail`        | `filename`, `checkbox`, `email`                     |
| `please`, `note that`, `simply`, `just`   | delete                                              |
| `data are`                                | `data is`                                           |
| `above`/`below` for a version             | `later`/`earlier`                                   |
| `the file(s)`                             | pick a number, or rewrite                           |
| `1st`, `5th`                              | `first`, `fifth`                                    |

`deprecated` means recommended against, not removed. `can` is ability, `might` is possibility,
`must` is requirement, `may` is for policy. `publicly available` takes no hyphen — no `-ly` adverb
does.

## Commit messages and pull request bodies

The same voice, with one exception and two additions.

- **The timeless rule is off.** A commit message is a dated record, like a release note. "This was
  red on main until #33 landed" is exactly what belongs there.
- **Imperative subject line, sentence case, no full stop**: "Split the design record into four
  documents". The git convention and the heading rule agree.
- **Past tense is right for what was wrong** — "the save ran with the new code and the old game" —
  and present tense for what the code does. A fix says what the cause was, not only the symptom,
  and the cause is a past-tense sentence.

## What to ignore in the guide

Google's guide is written for a documentation site with API references. Skip, and do not import
by association: the API reference comment conventions (method descriptions opening with a
third-person verb, parameter and return phrasings, per-class samples); the verbs-in-reference
page; figure numbering, `srcset` and image-scaling machinery; the `Note:`/`Caution:`/`Warning:`
notice taxonomy, which is a platform feature — though its substance holds, in that required
information does not belong in a callout; and the `th`/`scope` table markup rules, of which only
"introduce it with a sentence" and "sentence case column heads" survive into Markdown.

Command-line placeholder conventions (`UPPER_SNAKE_CASE`, explained after the command) are worth
having whenever a document shows a command with a value to substitute.
