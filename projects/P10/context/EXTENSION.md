# Extension statement for P10 (rung: extension)

Queued behind P10.InventoryPartition and P10.FactorInterval. Proposed by P10-T004 only after both
are PROVEN.

## P10.SharedAllocation

A shared source emits E (a real number) and is reported by reporters in `r : Finset ρ`, reporter k
taking the share w k. Definition: allocated r w E := ∑ k ∈ r, w k * E.

Statement: for every E and w:

1. Conservation. If ∑ k ∈ r, w k = 1 then allocated r w E = E.
2. Double count. allocated r w E - E = (∑ k ∈ r, w k - 1) * E; so with 0 < E the reporters
   together claim more than the source emitted exactly when the shares sum to more than 1.
3. Inventory form. Allocating every activity of a P10 inventory by shares that sum to 1 over the
   reporters leaves the total unchanged (restate the inventory sum self-contained).

Check before proposing: part 1 is `Finset.sum_mul`; part 3 swaps the order of a double sum.

Sanity check: shares 1/2 and 1/2 of E = 10 allocate 10; shares 1 and 1/2 allocate 15, a double
count of 5. Negative control: with shares summing to 1 but E counted once per reporter (no shares),
two reporters claim 2E.

The rationale must say that the choice of shares is an accounting convention (operational
control, equity share or another rule) that the statement does not settle.
