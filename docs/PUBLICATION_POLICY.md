# Publication policy

## Schedule

| When | What |
|---|---|
| Every night, 07:17 UTC | One run, one outcome, one run folder committed to `main` |
| Monday from 01:00 America/New_York (two crons, one window guard) | The week that just ended is published once, as below |
| Tuesday, if Monday's publication did not complete | The watchdog dispatches the weekly workflow once |

## Weekly channels

1. **GitHub Release `week-YYYY-Www`.** It contains every MERGED run of the
   week: the reproduce zip (rebuilt from the committed folder and checked
   against the outcome's hash) and the paper PDF. The notes list every night
   of the week, including IDLE and FAILED.
2. **Zenodo (Z5, decided by Justin D. Hart on 2026-11-02).** Every run of the
   week that has a compiled paper **and** a non-trivial PROVEN claim or a TESTED claim gets its
   own Zenodo record and DOI, containing that run's paper and reproduce zip.
   Separate results are separate records, not versions of one record. A run
   that does not pass this gate gets no Zenodo record, and the reason is
   recorded; it still ships in the GitHub Release. A run is deposited at most
   once, ever: the ledger `zenodo.runs` in `config/channels.json` records
   each deposit (Z6). Depositing for a project requires a recorded approval
   (effect `zenodo_concept`) and the project's record note. A week published
   before Z5 can be completed with `engine.weekly --week YYYY-Www
   --zenodo-catchup --force`, which deposits only the missing qualifying runs
   and never touches GitHub or LinkedIn. Justin D. Hart (ORCID
   0009-0008-3082-2482) is the only creator.
   Every description:
   - opens with "Working paper, not peer reviewed. Nothing in this record is
     field-validated." (for a run with a TESTED claim: "... Its empirical results
     are analyses of existing records that the verifier re-ran; nothing in this
     record has been validated by a field trial.");
   - then gives the project's scope and novelty note (`zenodo.projects.<id>.record_note`
     in `config/channels.json`), saying plainly when a result formalizes known
     work. A project without a note is skipped, not published without one;
   - ends with the AI-use line: drafted by Claude (Anthropic) running the
     engine, formal claims checked by the Lean 4 kernel and empirical claims by
     re-execution, Justin D. Hart accountable, no AI
     author.
3. **LinkedIn.** At most one post per week, under Justin's name. It goes out
   only when a run clears the announcement bar:
   - the run is MERGED and its paper compiled;
   - it has a non-trivial PROVEN, TESTED or stronger claim;
   - every DOI resolved;
   - the project is announceable;
   - the result has not been announced before;
   - the agent's `announcement.md` is at most 600 characters, with no links,
     no handles and no hype words ("breakthrough", "first ever", "proves that", …).

   The post text is the agent's summary plus a fixed verification line, the
   link (DOI first, then the GitHub folder), and the AI disclosure. If nothing
   clears the bar, nothing is posted, and the reason is recorded in
   `releases/<week>.json`.

## Integrity holds

If any committed run folder no longer matches its manifest or its outcome
hash, the whole week is held. No channel publishes, the record is marked
`blocked`, and an issue is opened. After the cause is fixed, re-run the weekly
workflow for that week.

## Never

- Publishing from the research job.
- Listing an AI system as an author.
- Announcing an ASSUMED or TRIVIAL result.
- Reposting after an unconfirmed post.
