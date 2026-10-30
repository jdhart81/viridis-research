# Review draft: record text for the 2026-W44 weekly publication

Status: **draft for Justin Hart to edit and approve.** This file is not read by the
engine. It holds proposed wording for the Zenodo records, the GitHub Release
notes and the LinkedIn post that the weekly workflow is scheduled to create on
Monday 2 November 2026 from 01:00 America/New_York, checked against the Viridis
science release standard (S2, S5 to S8).

Do **not** paste any of this into `runs/<date>_<project>/`. Those folders are
covered by `MANIFEST.sha256` and the outcome hash. Editing `announcement.md` or
`run.json` there triggers the integrity hold in `docs/PUBLICATION_POLICY.md` and
blocks the whole week. The fixes below have to be applied where the private
engine (`jdhart81/viridis-engine`) builds the record text, or by hand after
publication as a metadata edit or a new version.

## What the public repository shows, and what it does not

- The engine builds the Zenodo description, the release notes and the LinkedIn
  post text in private code. The public repository holds only their inputs:
  `run.json` (title, abstract, claims), `announcement.md`, the paper PDF (whose
  first page is the certification page), `config/channels.json` (creators,
  license, keywords) and `projects/<id>/project.json` (record title and related
  identifiers).
- So the exact Monday text cannot be reviewed from here. The drafts below say
  what each record must contain; the engine-side template has to be checked
  against them before Monday.
- Monday publishes the whole week, Monday 26 October to Sunday 1 November. Any
  run merged on 30 or 31 October or 1 November will also be published, and
  Zenodo takes **each project's latest run with a compiled paper**. If P1 or P2
  merges again before Sunday, that later run replaces the text reviewed here.

## Findings

| # | Item | Standard | Finding |
|---|---|---|---|
| 1 | P1 and P2 Zenodo descriptions | S7 | No "Working paper, not peer reviewed" line exists in any input (`run.json` abstract, paper, certification page). The certification page says what PROVEN means but not the review status. |
| 2 | P1 Zenodo description and post | S2, novelty | The paper says "make no claim of novelty", but the `run.json` abstract and `announcement.md` do not say that the bit-quad formula is Gray's 1971 result and that this is a formalization. A reader of the post alone could take it as a new theorem. |
| 3 | P2 Zenodo description and post | S2, novelty | The paper says the result is "a two-dimensional instance of classical theory" and claims no novelty. The abstract and `announcement.md` do not. |
| 4 | P1 record title | S2 | `projects/P1/project.json` titles the living record "A machine-checked raster bridge for Trees Cannot Cut" (approved in D-003). Version 1 proves only rung L1 of three; the bridge (L3) is open. The title should not read as if the bridge is done. |
| 5 | AI disclosure | S6 | Present on the PDF certification page and promised for the description by the policy. It must also be in the Zenodo description text itself, naming the tools and Justin D. Hart as the accountable author. Draft below. |
| 6 | Creator name | S8 | `config/channels.json` uses `Hart, Justin`. Every other Viridis record, CITATION.cff and `.zenodo.json` uses `Hart, Justin D.`. Fixed on this branch. |
| 7 | Exact source link | S8, S9 | `project.json` related identifiers link only to the earlier papers. The policy does not require the Zenodo record to link the GitHub Release tag or commit it was built from. Added to the policy on this branch; the engine must add an `isSupplementTo` link to `https://github.com/jdhart81/viridis-research/tree/week-2026-W44` (or the run commit). |
| 8 | P2 related identifier | S8 | P2 cites and links Carbon Continuity as `10.5281/zenodo.21855690`. That is a superseded version (v0.2.0-formal); Zenodo shows a newer version (record 23329732). Linking the version is defensible because the proof was ported from that exact version, but the description should say so. Note that the newer Carbon Continuity record 23329732 itself has no status line, no AI disclosure and no GitHub link. |
| 9 | P2 "retired checker" wording | S7, cross-repo | The P2 paper says the earlier certificate "came from tooling that can no longer be re-run", and `projects/P2/README.md` calls the Comparator "retired". The canon front door (README, RESPONSIBLE_RELEASE.md, hub record 23442570 of 17 October) presents Comparator certificates as the current evidence and offers a bounty on them. Both cannot stand as written. Carbon Continuity itself has a Comparator receipt but no published certificate bundle (`formalization.yaml`: `certificate: null`). Proposed wording below. |
| 10 | References | S5 | All seven DOIs in the two bibliographies resolve to the cited works with correct titles, authors, venues and pages (checked against Crossref and Zenodo on 29 October; see the audit report). No action needed. |
| 11 | Agent's reference claim | S6, provenance | The P1 agent's final message says its five references "were each confirmed online", but `provenance.json` records 0 web searches, 0 web fetches and one doi.org request. The verifier's DOI resolution (`certification.json`) and the audit's own check are the real evidence. Do not repeat the agent's claim in any record text. |
| 12 | Assumptions | S2 | Both papers state their limits well (P1: combinatorial V−E+F only, 8-connected only, L2/L3 open; P2: linear one-cycle model, no coefficient values, no code conformance). The Zenodo description must carry these, not only the PDF. |

## Draft Zenodo description: P1

Suggested record title (instead of the project title alone):
**Toward a machine-checked raster bridge for *Trees Cannot Cut* (living paper)**,
with this version titled *The 8-connected bit-quad Euler formula for finite
rasters: a Lean proof by vertex double counting*.

> Working paper, not peer reviewed. Nothing in this record is field-validated.
>
> This version contains one machine-checked result, and it is a formalization of a
> known formula, not a new result: Gray's 1971 bit-quad formula for the Euler
> characteristic of an 8-connected binary image, 4·χ(K(B)) = Q1 − Q3 − 2·QD, stated for
> every finite raster B in Z² (S. B. Gray, IEEE Transactions on Computers C-20(5):
> 551–561, 1971, doi:10.1109/T-C.1971.223289). We are not aware of an earlier
> machine-checked proof, but we have not searched exhaustively and claim no novelty.
>
> What is checked. The sealed statement P1.BitQuad (sha256 cd3cdeba…8e23, sealed by
> decision D-001 before any proof attempt) is proved in Lean 4 (v4.28.0) against
> Mathlib commit 8f9d9cff. The automated Viridis verifier compiled it, matched it to
> the sealed statement, found only the axioms propext, Classical.choice and
> Quot.sound, and replayed it through the kernel. None of the simple probe tactics
> closes the statement, so it is not marked TRIVIAL.
>
> Limits. The theorem is about V − E + F as the sealed module defines these counts;
> it does not prove that this equals the topological Euler characteristic of
> K(B) ⊂ R². Only the 8-connected weighting is covered. A brute-force check of all
> 65,536 subsets of a 4×4 box found no counterexample; it is labelled ASSUMED because
> the verifier does not yet re-execute code.
>
> Why it is here. This is rung L1 of three in project P1, whose goal is to replace the
> assumed topological step (FaceCount) in *Trees Cannot Cut*
> (doi:10.5281/zenodo.21686446) with a theorem about rasters. Rungs L2 and L3 are
> open, so that assumption is not yet discharged.
>
> AI use. The paper and the Lean proof were drafted by an AI research agent (Claude,
> by Anthropic, run through Claude Code) inside the Viridis research engine. The
> Aristotle prover (Harmonic) was available but not used in this run. Labels were
> assigned by the automated verifier, not by the agent. Justin D. Hart (Viridis LLC,
> ORCID 0009-0008-3082-2482) directs the project, approved the sealed statement and
> is the accountable author. No AI system is listed as an author.
>
> Source and reproduction: github.com/jdhart81/viridis-research, folder
> runs/2026-10-28_P1, release week-2026-W44. Run `python3 -m engine.reproduce
> runs/2026-10-28_P1` (see REPRODUCE.md in the folder).

## Draft Zenodo description: P2

> Working paper, not peer reviewed. Nothing in this record is field-validated.
>
> This version re-proves a classical, elementary result; it is not a new theorem. For
> the linear two-pool cycle (L, D) ↦ (aL + rD, pL + dD), with retention fractions
> a, d in [0, 1) and transfer rates r, p > 0, a strictly positive portfolio that one
> cycle does not shrink in either pool exists exactly when (1 − a)(1 − d) ≤ rp. This
> is the 2×2 case of the Collatz–Wielandt characterisation of the Perron root of a
> nonnegative matrix (A. Berman and R. J. Plemmons, *Nonnegative Matrices in the
> Mathematical Sciences*, SIAM 1994, doi:10.1137/1.9781611971262). The contribution is
> a proof anyone can re-check with the current public toolchain, tied to the Carbon
> Continuity decision kernel in Viridis OS.
>
> What is checked. The sealed statement P2.CarbonContinuity (sha256 a5a6e8c6…ffded,
> sealed by decision D-004) is proved in Lean 4 (v4.28.0) against Mathlib commit
> 8f9d9cff, using only propext, Classical.choice and Quot.sound, with a kernel replay.
> It is not marked TRIVIAL. The proof was ported from version 0.2.0-formal of *Carbon
> Continuity After Wildfire* (doi:10.5281/zenodo.21855690), whose Lean development was
> checked by Viridis's earlier Comparator service and has no published certificate
> bundle.
>
> Assumptions and limits. The result holds only inside the stated linear,
> time-invariant model, for one cycle. It says nothing about coefficient values for
> any site, stochastic disturbance, behaviour over many cycles, whether the deployed
> TypeScript kernel implements the rule faithfully, or any carbon-credit or treatment
> outcome. The observation that the proof does not use 0 ≤ a, 0 ≤ d or p > 0 is
> recorded as an unproved conjecture (ASSUMED).
>
> AI use. The paper and the Lean proof were drafted by an AI research agent (Claude,
> by Anthropic, run through Claude Code) inside the Viridis research engine. The
> Aristotle prover (Harmonic) was not used in this run. Labels were assigned by the
> automated verifier. Justin D. Hart (Viridis LLC, ORCID 0009-0008-3082-2482) directs
> the project, approved the sealed statement and is the accountable author. No AI
> system is listed as an author.
>
> Source and reproduction: github.com/jdhart81/viridis-research, folder
> runs/2026-10-29_P2, release week-2026-W44.

Wording choice for item 9 (pick one and use it in canon and here alike):

- (a) "checked by Viridis's earlier Comparator service, which Viridis no longer runs;
  its published certificates can still be re-checked for axioms with
  `certificates/rerun.sh` in viridis-canon", or
- (b) if the Comparator is still in use for canon, drop "retired" from P2 and say
  "re-proved under the research engine's own verifier so that the kernel's
  assurance does not depend on a private service".

## Draft LinkedIn post text (one post at most; both fit the 600-character limit)

P1 (493 characters):

> Viridis Research, project P1, rung L1: a Lean 4 proof of Gray's 1971 bit-quad formula,
> 4·χ = Q1 − Q3 − 2·QD, for every finite raster. The formula is classical; this is a
> machine-checked formalization, not a new result. It is the first of three lemmas
> toward replacing the topological assumption in "Trees Cannot Cut" with a theorem
> about rasters, and the other two are still open. An automated verifier checked the
> proof against a statement sealed in advance. Working paper, not peer reviewed.

P2 (511 characters):

> Viridis Research, project P2: we re-proved in Lean 4, under a pinned toolchain, the
> threshold rule behind the Viridis OS Carbon Continuity kernel. A positive two-pool
> carbon portfolio can be kept from shrinking over one disturbance-recovery cycle
> exactly when (1-a)(1-d) <= rp. The mathematics is classical, a 2x2 Perron-Frobenius
> case; the point is a proof anyone can re-check. It covers the threshold logic only,
> not coefficient values or whether the model fits real forests. Working paper, not
> peer reviewed.

Because `announcement.md` cannot be edited without holding the week, the choices
are: change the engine so the fixed lines it adds include the status and novelty
sentence; or pause LinkedIn for W44 (`config/engine.json` `pauses`, or
`linkedin.enabled: false` in `config/channels.json`) and post one of the texts
above by hand after review.

## Draft header for the GitHub Release notes (week-2026-W44)

> Working papers, not peer reviewed; nothing here is field-validated. PROVEN means a
> Lean 4 proof of a statement sealed in advance, checked by the automated verifier
> (see docs/CERTIFICATION.md); it does not mean the result is new or that the model
> describes nature. Both PROVEN results this week are formalizations of known
> mathematics (Gray 1971; a 2×2 Perron–Frobenius case). Papers are drafted by an AI
> research agent (Claude, by Anthropic); Justin D. Hart is the accountable author.

## Cannot be fixed from this public repository

- The Zenodo description template, the release-notes template and the fixed lines of
  the LinkedIn post are in `jdhart81/viridis-engine` (private).
- Whether the engine titles the Zenodo record with the project title or the run title.
- Whether it adds a related identifier for the GitHub Release tag or commit.
- Which run the weekly job will pick for the single LinkedIn post.
