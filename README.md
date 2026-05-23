# R-for-VSCode

Repository for testing R and Quarto scripts in VS Code.

## Attaching an R session

This workspace uses the VS Code R extension to attach terminals to the editor.
Do not call `.vsc.attach()` manually; that helper is not available in a plain
R session.

Use one of these instead:

- Run `R: Create R Terminal` from the Command Palette.
- Click the `R: (not attached)` status bar item and choose `Attach Active Terminal`.
- If you already have a terminal open, use the R extension command `R: Attach Active Terminal`.

## R scripts

- `r-scripts/01-basic-math.R`
- `r-scripts/02-data-frame.R`
- `r-scripts/03-plot.R`

## Quarto scripts

- `quarto-scripts/01-intro.qmd`
- `quarto-scripts/02-summary.qmd`
- `quarto-scripts/03-visualization.qmd`
