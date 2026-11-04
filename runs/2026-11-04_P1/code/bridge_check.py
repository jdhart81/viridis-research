"""Independent brute-force check of the proposed P1.Bridge and P1.Insertion identities.

For a finite raster B (a set of integer pixels), compute
  enclosed(B): number of finite 4-components of Z^2 minus B (via a padded bounding box),
  C8(B): number of 8-components of B,
  chi(B) = V - E + F of the union of closed unit squares (direct count of corners and edges),
and test enclosed = C8 - chi (L3) and invariance of enclosed - C8 + chi under insertion (L2).

Usage: python3 bridge_check.py <output.json>
"""
import itertools
import json
import random
import sys

N4 = [(1, 0), (-1, 0), (0, 1), (0, -1)]
N8 = [(dx, dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (dx, dy) != (0, 0)]


def components(cells, nbrs):
    cells = set(cells)
    seen = set()
    comps = []
    for c in cells:
        if c in seen:
            continue
        stack = [c]
        seen.add(c)
        comp = [c]
        while stack:
            x, y = stack.pop()
            for dx, dy in nbrs:
                q = (x + dx, y + dy)
                if q in cells and q not in seen:
                    seen.add(q)
                    comp.append(q)
                    stack.append(q)
        comps.append(comp)
    return comps


def c8(B):
    return len(components(B, N8))


def enclosed(B):
    if not B:
        return 0
    xs = [p[0] for p in B]
    ys = [p[1] for p in B]
    x0, x1, y0, y1 = min(xs) - 1, max(xs) + 1, min(ys) - 1, max(ys) + 1
    free = {(x, y) for x in range(x0, x1 + 1) for y in range(y0, y1 + 1)} - set(B)
    comps = components(free, N4)
    # A component touching the box border is part of the unbounded component.
    return sum(1 for comp in comps
               if not any(x in (x0, x1) or y in (y0, y1) for x, y in comp))


def chi(B):
    V, H, Vt = set(), set(), set()
    for (i, j) in B:
        V |= {(i, j), (i + 1, j), (i, j + 1), (i + 1, j + 1)}
        H |= {(i, j), (i, j + 1)}
        Vt |= {(i, j), (i + 1, j)}
    return len(V) - (len(H) + len(Vt)) + len(B)


def inv(B):
    return enclosed(B) - c8(B) + chi(B)


def main(out):
    res = {"seed": 20261104}
    rng = random.Random(res["seed"])
    # Controls.
    ring = {(x, y) for x in range(3) for y in range(3)} - {(1, 1)}
    block = {(0, 0), (1, 0), (0, 1), (1, 1)}
    diamond = {(1, 0), (0, 1), (2, 1), (1, 2)}
    res["controls"] = {name: {"C8": c8(B), "chi": chi(B), "enclosed": enclosed(B)}
                       for name, B in [("ring", ring), ("block", block), ("diamond", diamond)]}
    # L3 exhaustively on a 4x4 box.
    box = [(x, y) for x in range(4) for y in range(4)]
    fails = 0
    count = 0
    for bits in range(1 << 16):
        B = {box[k] for k in range(16) if bits >> k & 1}
        count += 1
        if enclosed(B) != c8(B) - chi(B):
            fails += 1
    res["L3_4x4_exhaustive"] = {"rasters": count, "failures": fails}
    # L3 on random rasters.
    fails = 0
    n = 3000
    for _ in range(n):
        w, h = rng.randint(1, 12), rng.randint(1, 12)
        d = rng.random()
        B = {(x, y) for x in range(w) for y in range(h) if rng.random() < d}
        if enclosed(B) != c8(B) - chi(B):
            fails += 1
    res["L3_random"] = {"rasters": n, "max_side": 12, "failures": fails}
    # L2: every 8-neighbourhood configuration of p = (0, 0), alone and in random contexts.
    fails = 0
    count = 0
    contexts = 40
    for m in range(256):
        N = {N8[k] for k in range(8) if m >> k & 1}
        ctxs = [set()]
        for _ in range(contexts):
            r = rng.randint(2, 6)
            d = rng.random()
            ctxs.append({(x, y) for x in range(-r, r + 1) for y in range(-r, r + 1)
                         if max(abs(x), abs(y)) >= 2 and rng.random() < d})
        for ctx in ctxs:
            B = ctx | N
            count += 1
            if inv(B | {(0, 0)}) != inv(B):
                fails += 1
    res["L2_insertions"] = {"configurations": 256, "contexts_per_configuration": contexts + 1,
                            "insertions": count, "failures": fails}
    with open(out, "w") as f:
        json.dump(res, f, indent=2)
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    main(sys.argv[1])
