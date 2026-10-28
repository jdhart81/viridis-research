"""Brute-force check of 4*chi(K B) = Q1 - Q3 - 2*QD on every subset of a 4x4 box.

Mirrors the definitions in the sealed module ViridisStatements.P1.BitQuad.
Writes a JSON summary to the path given as the first argument."""
import itertools, json, sys

def stats(B):
    V = {(i + a, j + b) for (i, j) in B for a in (0, 1) for b in (0, 1)}
    H = {(i, j + b) for (i, j) in B for b in (0, 1)}
    E = {(i + a, j) for (i, j) in B for a in (0, 1)}
    chi = len(V) - (len(H) + len(E)) + len(B)
    q1 = q3 = qd = 0
    for (x, y) in V:
        a, b, c, d = ((x-1, y-1) in B, (x, y-1) in B, (x-1, y) in B, (x, y) in B)
        n = a + b + c + d
        q1 += n == 1; q3 += n == 3
        qd += (a and d and not b and not c) or (b and c and not a and not d)
    return chi, q1, q3, qd

cells = [(i, j) for i in range(4) for j in range(4)]
bad = 0; n = 0; hist = {}
for mask in range(1 << 16):
    B = {cells[k] for k in range(16) if mask >> k & 1}
    chi, q1, q3, qd = stats(B)
    n += 1; hist[chi] = hist.get(chi, 0) + 1
    if 4 * chi != q1 - q3 - 2 * qd:
        bad += 1
json.dump({"box": "4x4", "subsets": n, "failures": bad,
           "euler_histogram": {str(k): v for k, v in sorted(hist.items())}},
          open(sys.argv[1], "w"), indent=2)
