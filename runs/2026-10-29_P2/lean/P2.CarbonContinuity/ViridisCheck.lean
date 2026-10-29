import ViridisStatements.P2.CarbonContinuity
import Candidate
import Lean

open Lean Elab Command

elab "#viridis_axioms " id:ident : command => do
  let n := id.getId
  let axs ← liftCoreM (Lean.collectAxioms n)
  let names := axs.toList.map (fun a => a.toString)
  let s := ",".intercalate names
  logInfo m!"VIRIDIS_AXIOMS {s}"

theorem viridis_statement_match : ViridisStatements.P2.CarbonContinuity.Statement := Candidate.main

#viridis_axioms Candidate.main
#viridis_axioms viridis_statement_match
