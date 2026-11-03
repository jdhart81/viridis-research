"""Brute-force check of the proposed P1.Bridge and P1.Insertion identities.

Independent of the Lean box model: pads the raster by a 2-pixel margin, flood-fills
the 4-connected complement from the padded corner (the unbounded component), labels
the remaining complement cells (enclosed components) and the 8-components of B,
and computes chi = V - E + F of the cubical complex directly.
"""
import itertools, json, random, sys

def euler(B):
    V, H, W = set(), set(), set()
    for (i, j) in B:
        V |= {(i, j), (i + 1, j), (i, j + 1), (i + 1, j + 1)}
        H |= {(i, j), (i, j + 1)}
        W |= {(i, j), (i + 1, j)}
    return len(V) - (len(H) + len(W)) + len(B)

N4 = [(1, 0), (-1, 0), (0, 1), (0, -1)]
N8 = [(a, b) for a in (-1, 0, 1) for b in (-1, 0, 1) if (a, b) != (0, 0)]

def components(cells, nbrs):
    cells, seen, comps = set(cells), set(), []
    for c in sorted(cells):
        if c in seen:
            continue
        stack, comp = [c], {c}
        seen.add(c)
        while stack:
            x, y = stack.pop()
            for a, b in nbrs:
                q = (x + a, y + b)
                if q in cells and q not in seen:
                    seen.add(q); comp.add(q); stack.append(q)
        comps.append(comp)
    return comps

def counts(B):
    B = set(B)
    if not B:
        return 0, 0, 0
    xs = [p[0] for p in B]; ys = [p[1] for p in B]
    box = {(x, y) for x in range(min(xs) - 2, max(xs) + 3) for y in range(min(ys) - 2, max(ys) + 3)}
    free = box - B
    comps = components(free, N4)
    corner = (min(xs) - 2, min(ys) - 2)
    enclosed = sum(1 for c in comps if corner not in c)
    return enclosed, len(components(B, N8)), euler(B)

def invariant(B):
    e, c, x = counts(B)
    return e - c + x

def main():
    out = {}
    # L3 on every subset of a 4x4 box
    cells = [(i, j) for i in range(4) for j in range(4)]
    fails = 0
    for mask in range(1 << 16):
        B = [cells[k] for k in range(16) if mask >> k & 1]
        if invariant(B) != 0:
            fails += 1
    out["bridge_all_subsets_4x4"] = {"rasters": 1 << 16, "failures": fails}
    # L2: all 256 configurations of the 8-neighbourhood of p=(0,0), alone and in random context
    rng = random.Random(20261103)
    fails = 0; trials = 0
    for mask in range(256):
        N = {N8[k] for k in range(8) if mask >> k & 1}
        contexts = [set()] + [{(x, y) for x in range(-5, 6) for y in range(-5, 6)
                               if max(abs(x), abs(y)) >= 2 and rng.random() < 0.45} for _ in range(40)]
        for ctx in contexts:
            B = N | ctx
            trials += 1
            if invariant(B | {(0, 0)}) != invariant(B):
                fails += 1
    out["insertion_256_configs_x41_contexts"] = {"insertions": trials, "failures": fails}
    # L3 on random rasters up to 12x12
    fails = 0
    for t in range(3000):
        n = rng.randint(1, 12); d = rng.random()
        B = {(x, y) for x in range(n) for y in range(n) if rng.random() < d}
        if invariant(B) != 0:
            fails += 1
    out["bridge_random_upto_12x12"] = {"rasters": 3000, "failures": fails, "seed": 20261103}
    # controls
    ring = {(0,0),(1,0),(2,0),(0,1),(2,1),(0,2),(1,2),(2,2)}
    block = {(0,0),(1,0),(0,1),(1,1)}
    diamond = {(1,0),(0,1),(2,1),(1,2)}
    out["controls"] = {k: dict(zip(["enclosed", "C8", "euler"], counts(v)))
                       for k, v in [("ring", ring), ("block", block), ("diamond", diamond)]}
    json.dump(out, sys.stdout, indent=2); print()

if __name__ == "__main__":
    main()
