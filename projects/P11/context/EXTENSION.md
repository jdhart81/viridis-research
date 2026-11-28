# Extension statement for P11 (rung: extension)

Queued behind P11.WaterBalance and P11.BudykoFu. Proposed by P11-T004 only after both are PROVEN.

## P11.BudykoMonotone

Use Fu's curve of P11.BudykoFu, restated self-contained.

Statement: for φ > 0:

1. In the parameter. For 1 ≤ w ≤ w': fu φ w ≤ fu φ w' (a larger w means more evaporation and
   less runoff for the same climate).
2. In aridity. For 1 ≤ w and 0 < φ ≤ φ': fu φ w ≤ fu φ' w (a drier climate evaporates a larger
   share of its precipitation) and fu φ' w / φ' ≤ fu φ w / φ (it meets a smaller share of its
   evaporative demand).
3. The limit. As w grows, fu φ w tends to min 1 φ (state it with `Filter.Tendsto`).

Check before proposing: part 1 is the monotonicity of (1 + φ^w)^(1/w) in w, which decreases (the
p-norm of the vector (1, φ) falls as p rises); part 3 is its limit max 1 φ. For part 2, the
derivative of fu in φ is 1 - (φ^w / (1 + φ^w))^((w - 1) / w) ≥ 0, and fu is concave in φ with
fu 0 w = 0, which gives the ratio. If a part as written is false or not provable over the
pinned Mathlib, propose the nearest correct statement and explain the change.

Sanity check: φ = 1 gives fu = 0 at w = 1, 2 - √2 at w = 2, and tends to 1. Negative control:
part 1 fails at φ = 0 only trivially (every value is 0), so take φ > 0.

The rationale must say that any link from forest cover to w is a field claim the statement does not
make.
