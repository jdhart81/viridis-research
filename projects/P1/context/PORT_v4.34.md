# Porting the P1 raster proofs to Lean v4.34.0

The record moved from Lean v4.28.0 to v4.34.0 (Mathlib `5ed29652`) on 2026-11-13. The proofs of
`P1.Insertion` (run `2026-11-09_P1`) and `P1.Bridge` (run `2026-11-10_P1`) were certified at v4.28.0 and
stay certified there. Their files are not edited. They do not compile at the new Mathlib as written.

If a later task reuses that proof code, three places need changing. With these changes both proofs pass
every verifier stage at v4.34.0 (checked 2026-11-13 in the verifier's sandbox).

1. `exists_bound`: `simp only at h` now fails with "simp made no progress". Remove it, or write
   `try simp only at h`.
2. `invariant_zero_of_scan` and `invariant_nonneg` use
   `induction B using Finset.induction_on_max_value ... with`. The cases are now named `empty` and `insert`:

   ```lean
   | empty => ...
   | insert a s ha hmax ih => ...
   ```

   They were `h0` and `step`.

The sealed statements themselves compile unchanged at both versions.
