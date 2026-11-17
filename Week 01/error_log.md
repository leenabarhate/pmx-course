## Part B — Numerical Diagnostic

| Item | My answer | Correct | Root cause | Fix |
|---|---|---|---|---|
| D2 — Cmax | 1.547 mg/L | 3.097 mg/L | Formula application / calculation error (review working) | Practise Bateman equation and carefully substitute values |
| D3 — Loading dose | Not attempted | 750 mg | Formula recall | Revise LD = Target concentration × V |
| D4 — Css,avg | Not attempted | 1.667 mg/L | Formula recall | Revise Css,avg = Dose / (CL × τ) |
| D5 — Css,avg | Not attempted | Unchanged when regimen and CL remain constant | Concept recall | Understand why average steady-state concentration is independent of V |

**Score:** 19/23 = 82.6%

**Outcome:** Passed the 80% threshold.

**Revision priorities:**
1. Bateman equation and Cmax calculation.
2. Loading dose calculations.
3. Average steady-state concentration.
4. Relationship between V and steady-state concentration.

### Block 4: Oral absorption and flip-flop

1. Confused the direction of change in Tmax and Cmax when ka increased.
2. Initially treated absorption and elimination as interchangeable without considering flip-flop kinetics.
3. Original Bateman equation produced NaN when ka = k due to division by zero.
4. An extra assignment after the if-else block overwrote the limiting formula.

### Lessons learned

- Increasing ka decreases Tmax and increases Cmax.
- AUC remains constant when Fbio, dose and CL remain unchanged.
- The slower rate constant controls the terminal slope.
- IV administration bypasses absorption.
- When ka = k, use the limiting equation derived using L'Hôpital's rule.