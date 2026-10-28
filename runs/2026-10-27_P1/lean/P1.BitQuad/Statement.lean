import Mathlib

/-!
# P1 · L1: the bit-quad formula for an 8-connected raster

A raster is a finite set `B` of pixels in `ℤ × ℤ`. Pixel `(i, j)` stands for the
closed unit square `[i, i+1] × [j, j+1]`. `K B` is the union of the closed
squares of `B`. It is a cubical complex, and its vertices, edges and faces are
counted below. Two pixels that share only a corner meet in `K B`, which is the
8-connected reading of the foreground.

`Statement` says that for every finite raster,
`4 · χ(K B) = Q₁ − Q₃ − 2·Q_D`. Here `Q₁`, `Q₃` and `Q_D` count the 2×2 windows
that hold exactly one pixel of `B`, exactly three pixels of `B`, and exactly two
diagonally opposite pixels of `B` (Gray 1971).

This is the first rung (L1) of the P1 lemma ladder. See
`projects/P1/context/STATEMENT_PROPOSAL.md`.
-/

namespace ViridisStatements.P1.BitQuad

/-- A pixel, named by its lower-left lattice corner. -/
abbrev Pixel := ℤ × ℤ

/-- The four lattice corners of pixel `p`. -/
def corners (p : Pixel) : Finset (ℤ × ℤ) :=
  {(p.1, p.2), (p.1 + 1, p.2), (p.1, p.2 + 1), (p.1 + 1, p.2 + 1)}

/-- Vertices of `K B`: every corner of every pixel of `B`. -/
def vertices (B : Finset Pixel) : Finset (ℤ × ℤ) :=
  B.biUnion corners

/-- Horizontal unit edges `[(i, j), (i + 1, j)]` of `K B`, named by their left
end. These are the bottom edge `(i, j)` and the top edge `(i, j + 1)` of each
pixel `(i, j)` of `B`. -/
def hEdges (B : Finset Pixel) : Finset (ℤ × ℤ) :=
  B.biUnion fun p => {(p.1, p.2), (p.1, p.2 + 1)}

/-- Vertical unit edges `[(i, j), (i, j + 1)]` of `K B`, named by their lower
end. These are the left edge `(i, j)` and the right edge `(i + 1, j)` of each
pixel `(i, j)` of `B`. -/
def vEdges (B : Finset Pixel) : Finset (ℤ × ℤ) :=
  B.biUnion fun p => {(p.1, p.2), (p.1 + 1, p.2)}

/-- The Euler characteristic `V − E + F` of `K B`. -/
def euler (B : Finset Pixel) : ℤ :=
  ((vertices B).card : ℤ) - (((hEdges B).card : ℤ) + (vEdges B).card) + B.card

/-- The 2×2 window centred on the lattice point `v`, as four membership bits in
this order: lower-left, lower-right, upper-left, upper-right. -/
def bits (B : Finset Pixel) (v : ℤ × ℤ) : Bool × Bool × Bool × Bool :=
  (decide ((v.1 - 1, v.2 - 1) ∈ B), decide ((v.1, v.2 - 1) ∈ B),
   decide ((v.1 - 1, v.2) ∈ B), decide ((v.1, v.2) ∈ B))

/-- The number of pixels of `B` in the window centred on `v`. -/
def windowCount (B : Finset Pixel) (v : ℤ × ℤ) : ℕ :=
  match bits B v with
  | (a, b, c, d) => a.toNat + b.toNat + c.toNat + d.toNat

/-- True when the window centred on `v` holds exactly two diagonally opposite
pixels of `B`. -/
def isDiagonal (B : Finset Pixel) (v : ℤ × ℤ) : Bool :=
  match bits B v with
  | (a, b, c, d) => (a && d && !b && !c) || (b && c && !a && !d)

/-- Windows holding exactly one pixel of `B`. Every window that meets `B` is
centred on a vertex of `K B`, so counting over `vertices B` counts each such
window exactly once. -/
def Q1 (B : Finset Pixel) : ℕ :=
  ((vertices B).filter fun v => windowCount B v = 1).card

/-- Windows holding exactly three pixels of `B`. -/
def Q3 (B : Finset Pixel) : ℕ :=
  ((vertices B).filter fun v => windowCount B v = 3).card

/-- Windows holding exactly two diagonally opposite pixels of `B`. -/
def QD (B : Finset Pixel) : ℕ :=
  ((vertices B).filter fun v => isDiagonal B v = true).card

/-- **Sealed target `P1.BitQuad`.** For every finite raster `B`,
`4 · χ(K B) = Q₁ − Q₃ − 2·Q_D`. -/
def Statement : Prop :=
  ∀ B : Finset Pixel, 4 * euler B = (Q1 B : ℤ) - Q3 B - 2 * QD B

/-! ## Sanity checks

These checks are proved by computation inside the sealed module, so the
definitions above mean what their comments say. -/

/-- A single pixel: `V = 4`, `E = 4`, `F = 1`, so `χ = 1`, and its four windows
each hold one pixel. -/
example : euler {(0, 0)} = 1 ∧ Q1 {(0, 0)} = 4 ∧ Q3 {(0, 0)} = 0 ∧ QD {(0, 0)} = 0 := by
  decide

/-- Two pixels that touch only at a corner form one 8-connected piece: `χ = 1`,
and the shared corner is a diagonal window. -/
example : euler {(0, 0), (1, 1)} = 1 ∧ QD {(0, 0), (1, 1)} = 1 ∧ Q1 {(0, 0), (1, 1)} = 6 := by
  decide

/-- A 2×2 solid block is contractible: `χ = 1`. -/
example : euler {(0, 0), (1, 0), (0, 1), (1, 1)} = 1 := by
  decide

/-- The 3×3 ring (eight pixels around one hole) has `χ = 0`. -/
example : euler {(0, 0), (1, 0), (2, 0), (0, 1), (2, 1), (0, 2), (1, 2), (2, 2)} = 0 := by
  decide

end ViridisStatements.P1.BitQuad
