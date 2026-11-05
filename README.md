<p align="center"><img src="assets/icon.png" width="128" alt="qPCR Studio icon"></p>

<h1 align="center">qPCR Studio</h1>

<p align="center">ΔΔCt relative quantification for <b>Roche LightCycler 480</b> exports — from raw Cp values to publication‑ready graphs.</p>

---

## Download

**macOS app:** grab `qPCR-Studio.dmg` from the [latest release](../../releases/latest), open it and drag **qPCR Studio** into **Applications**.
Works on Apple Silicon and Intel Macs (macOS 12+).

> The app is not notarized by Apple. On first launch, **right‑click → Open → Open**
> (or *System Settings → Privacy & Security → Open Anyway*). This is needed only once.

**Any OS:** download [`qpcr-studio.html`](qpcr-studio.html) and open it in a browser. It is a single self‑contained file and works offline.

## Workflow

1. **Upload**: drop the LightCycler 480 result `.txt` (Abs Quant / 2nd Derivative Max export with `Pos · Name · Cp` columns). Choose duplicates or triplicates.
2. **Plate map**:
   - **Drag** across 2–3 wells (e.g. B2 → D2) or click a well to define a replicate set, then name the **sample** and **gene**.
   - Mark housekeeping genes with ★. They are matched to targets by **sample name**.
   - Right‑click a well to exclude an outlier. Shift‑click builds non‑adjacent sets.
   - Plate layouts can be saved and loaded as JSON.
3. **Analysis**:
   - Pick the reference gene(s).
   - Normalize against **one calibrator** or set a **calibrator per sample**.
   - Choose which samples and targets to include and in what order, and group bars by gene or by sample.
4. **Results**:
   - Tables for raw Cp, ΔCt, ΔΔCt and fold change with min/max error, which you can copy to Excel/Prism or export as CSV.
   - Bar graphs in GraphPad Prism style.
   - Export as SVG (vector) or PNG (2–8×).

### Graph editor
In the graph editor you can change:
- fonts, sizes and bold/italic
- axis titles and X label angle
- bar width, gaps and edge padding
- border width and color, fill opacity
- per‑series colors and fills (solid, hollow, hatched) and palettes
- error bar width and cap width
- replicate dots: shape, size, fill and spread
- axis width, ticks and linear/log2/log10 scale
- manual Y range and the reference line
- legend position

Click any element in the figure to jump to its settings.

## Calculations (Livak 2^−ΔΔCt)

| Quantity | Formula |
|---|---|
| Mean Ct / SD | technical replicates pooled per sample × gene (excluded wells ignored) |
| Reference Ct | mean of the selected housekeeping genes (= geometric mean of expression) |
| ΔCt | Ct<sub>target</sub> − Ct<sub>reference</sub>,  SD = √(SD<sub>t</sub>² + SD<sub>r</sub>²) |
| ΔΔCt | ΔCt<sub>sample</sub> − ΔCt<sub>calibrator</sub> |
| Fold change | 2<sup>−ΔΔCt</sup>, min = 2<sup>−(ΔΔCt+SD)</sup>, max = 2<sup>−(ΔΔCt−SD)</sup> |

Optionally the calibrator's SD can be propagated into the ΔΔCt error. Replicate sets with SD > 0.5 are flagged.

## Building the Mac app from source

Requires the Xcode command line tools (`xcode-select --install`).

```bash
./mac/build.sh
```

This compiles a universal WebKit wrapper (`mac/main.swift`), renders the icon (`mac/icon.swift`), bundles `qpcr-studio.html` and writes `qPCR-Studio.dmg`.

## Project layout

```
qpcr-studio.html   the entire app (HTML/CSS/JS, no dependencies)
mac/main.swift     native macOS shell (window, menus, save/open panels, clipboard)
mac/icon.swift     app icon renderer
mac/build.sh       builds .app + .dmg
```
