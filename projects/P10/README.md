# P10 · Carbon accounting: inventory arithmetic and emission-factor uncertainty

P10 builds the formal core for the arithmetic the Viridis GHG Ledger applies when it turns activity
data into a Scope 1, 2 and 3 inventory. The Ledger already returns a total per scope and an audit
hash; P10 makes the identities those totals rest on machine-checked, and states how far a total can
move when each emission factor is known only within bounds.

Planned statements (drafted by P10-T001, sealed under the standing sealing policy, D-018):

1. **P10.InventoryPartition.** An inventory is the sum over activities of amount × emission factor.
   Its total equals the sum of its scope totals for any assignment of activities to scopes; it is
   additive over disjoint sets of activities; with non-negative amounts it is non-negative and does
   not fall when any factor rises; and rescaling every factor by a unit conversion rescales the
   total by the same number.
2. **P10.FactorInterval.** If every factor lies in a known interval and every amount is
   non-negative, the total lies between the totals at the lower and upper factors, both ends are
   attained, and the width of the interval is the amount-weighted sum of the factor widths.

These are arithmetic (the accounting identity of the GHG Protocol and interval arithmetic), not new
theorems. They are the known rung of this project. The queued extension (P10-T004) states when an
allocation of shared emissions among several reporters conserves the total and how large the
double count is when it does not.

A PROVEN label here certifies the arithmetic. It never certifies an emission factor, an activity
datum, a scope assignment, a factor pack or any reported inventory. The factor bounds are inputs;
the interval is a worst case, not a confidence interval, and correlated factor errors are not
modelled.

## Tasks

- **P10-T001** (known) proposes the two statements, exactly as specified in `context/STATEMENT_PROPOSAL.md`.
- **P10-T002** (known) proves `P10.InventoryPartition`.
- **P10-T003** (known) proves `P10.FactorInterval`.
- **P10-T004** (extension) proposes `P10.SharedAllocation`, as specified in `context/EXTENSION.md`.
- **P10-T005** (extension) proves it.
