# Viridis Research

This is the public research record of Viridis LLC. Every night an AI research
agent works on one task from a project. It writes a full paper and a
reproducible package. An automated verifier then decides what that paper has
actually established. Each night leaves **one** record in this repository, and
the record is never edited.

| Where | What |
|---|---|
| `runs/<date>_<project>/` | One folder per night. It holds `paper.pdf` (certification page first), the sources, Lean proofs, `certification.json`, `provenance.json`, `REPRODUCE.md` and `MANIFEST.sha256` |
| `outcomes/<date>.json` | Exactly one per day: MERGED, IDLE or FAILED, with the reason |
| `projects/` | Research programs and their task ladders |
| `lean/ViridisStatements/` + `statements/registry.json` | Sealed formal targets, fixed before any proof attempt |
| `decisions/` | Requests and Justin Hart's recorded yes/no answers (the only source of authority) |
| `releases/` | Weekly publication records (GitHub Release, Zenodo, LinkedIn) |

## What the labels mean

| Label | Meaning |
|---|---|
| **ASSUMED** | Not verified. This is the default for every claim |
| **PROVEN** | A Lean 4 proof of a sealed statement. It compiles with the pinned toolchain, matches the statement definitionally, uses only `propext`, `Classical.choice` and `Quot.sound`, and is replayed through the kernel |
| **TESTED / REPLICATED** | Re-executed by the verifier. Not yet enabled, so empirical claims are ASSUMED for now |
| **ENDORSED / ADOPTED** | Given by people, by recorded decision |

Novelty is never a label. A sealed statement that one of the simple probe
tactics can already close is marked **TRIVIAL**. See `docs/CERTIFICATION.md`.

## Reproduce a run

```bash
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/<date>_<project>
```

## How it works

The research engine that runs the agent is private. The verifier kit in
`engine/` is public: the Lean checker, the sandbox, and the reproduce tool.
Anyone can re-check any run with it, and none of the labels depends on trusting
the private code. `docs/CERTIFICATION.md` defines the labels, and
`docs/PUBLICATION_POLICY.md` sets out when results go to Zenodo and LinkedIn.

Everything in `runs/`, `projects/` and `lean/` is open for others to build on,
with attribution, under CC BY 4.0.

## Credit and disclosure

The research program is directed by Justin Hart (Viridis LLC,
ORCID 0009-0008-3082-2482). Papers are drafted by an AI research agent (Claude,
by Anthropic). Formal proof search may use Aristotle (Harmonic). No AI system is
listed as an author.

Code is under the MIT license. Papers and data are under CC BY 4.0.
