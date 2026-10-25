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
2. **Zenodo.** Each project gets one new version per week of its living paper,
   built from that project's latest run with a compiled paper. Creating a
   project's first Zenodo record requires a recorded decision (effect
   `zenodo_concept`); after that, versions follow automatically. Justin Hart
   (ORCID 0009-0008-3082-2482) is the only creator. AI assistance is disclosed
   in the description.
3. **LinkedIn.** At most one post per week, under Justin's name. It goes out
   only when a run clears the announcement bar:
   - the run is MERGED and its paper compiled;
   - it has a non-trivial PROVEN (or stronger) claim;
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
