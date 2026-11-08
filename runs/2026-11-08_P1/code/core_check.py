"""Brute-force check of the hypothesis `hJ` of `statement_of_halfplane_jordan`
(proofs/P1.Insertion.lean), and of the scan-order insertion identity.

For random rasters R and a pixel p = (x, y), let B be the pixels of R that come
before p in raster-scan order (earlier row, or same row and smaller x). Whenever
S = (x, y-1) is free, SE = (x+1, y-1) is in B and W = (x-1, y) or SW = (x-1, y-1)
is in B, check:
    (4-component of S in Z^2 minus (B with p) is finite)
      <->  (W or SW is 8-connected to SE inside B).
Also check enc - C8 + chi is unchanged by every scan-order insertion.
Usage: python3 -I core_check.py OUT.json
"""
import json
import random
import sys
from collections import deque

N4 = [(1, 0), (-1, 0), (0, 1), (0, -1)]
N8 = [(dx, dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1) if (dx, dy) != (0, 0)]


def bbox(B):
    xs = [q[0] for q in B] + [0]
    ys = [q[1] for q in B] + [0]
    return min(xs) - 1, max(xs) + 1, min(ys) - 1, max(ys) + 1


def comp4_finite(B, s):
    """Is the 4-component of s in Z^2 \\ B finite? (BFS in the padded box.)"""
    x0, x1, y0, y1 = bbox(B | {s})
    seen = {s}
    dq = deque([s])
    while dq:
        a, b = dq.popleft()
        if a in (x0, x1) or b in (y0, y1):
            return False
        for dx, dy in N4:
            q = (a + dx, b + dy)
            if q not in B and q not in seen:
                seen.add(q)
                dq.append(q)
    return True


def reach8(B, s):
    seen = {s}
    dq = deque([s])
    while dq:
        a, b = dq.popleft()
        for dx, dy in N8:
            q = (a + dx, b + dy)
            if q in B and q not in seen:
                seen.add(q)
                dq.append(q)
    return seen


def invariant(B):
    x0, x1, y0, y1 = bbox(B)
    free = {(a, b) for a in range(x0, x1 + 1) for b in range(y0, y1 + 1)} - B
    enc, seen = 0, set()
    for v in free:
        if v in seen:
            continue
        comp = {v}
        dq = deque([v])
        border = False
        while dq:
            a, b = dq.popleft()
            if a in (x0, x1) or b in (y0, y1):
                border = True
            for dx, dy in N4:
                q = (a + dx, b + dy)
                if q in free and q not in comp:
                    comp.add(q)
                    dq.append(q)
        seen |= comp
        enc += 0 if border else 1
    c8, seen = 0, set()
    for v in B:
        if v not in seen:
            seen |= reach8(B, v)
            c8 += 1
    V = {(a + i, b + j) for a, b in B for i in (0, 1) for j in (0, 1)}
    H = {(a, b + j) for a, b in B for j in (0, 1)}
    Ve = {(a + i, b) for a, b in B for i in (0, 1)}
    return enc - c8 + (len(V) - len(H) - len(Ve) + len(B))


def main(out):
    rng = random.Random(20261108)
    core_cases = core_true = core_false = 0
    core_fail = 0
    scan_ins = scan_fail = 0
    for trial in range(4000):
        n = rng.randint(3, 9)
        dens = rng.uniform(0.2, 0.75)
        R = {(a, b) for a in range(n) for b in range(n) if rng.random() < dens}
        order = sorted(R, key=lambda q: (q[1], q[0]))
        # scan-order insertions
        B = set()
        for q in order:
            if trial < 800:
                before = invariant(B)
                after = invariant(B | {q})
                scan_ins += 1
                scan_fail += before != after
            B.add(q)
        # core configurations at every candidate p in the box
        for y in range(n + 1):
            for x in range(-1, n + 1):
                p = (x, y)
                Bp = {q for q in R if q[1] < y or (q[1] == y and q[0] < x)}
                S, SE, W, SW = (x, y - 1), (x + 1, y - 1), (x - 1, y), (x - 1, y - 1)
                if S in Bp or SE not in Bp or not (W in Bp or SW in Bp):
                    continue
                core_cases += 1
                lhs = comp4_finite(Bp | {p}, S)
                comp_se = reach8(Bp, SE)
                rhs = W in comp_se or SW in comp_se
                core_true += lhs
                core_false += not lhs
                core_fail += lhs != rhs
    res = {"seed": 20261108, "rasters": 4000,
           "core_cases": core_cases, "core_enclosed": core_true, "core_not_enclosed": core_false,
           "core_failures": core_fail,
           "scan_insertions_checked": scan_ins, "scan_insertion_failures": scan_fail}
    with open(out, "w") as f:
        json.dump(res, f, indent=1)
    print(res)


if __name__ == "__main__":
    main(sys.argv[1])
