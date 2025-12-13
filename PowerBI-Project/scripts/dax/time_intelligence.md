
---

### 🔹 `time_intelligence.md` (VERY IMPORTANT for Q2)

```md
# Time Intelligence DAX Measures

## This Year Sales
```DAX
This Year Sales =
CALCULATE(
    [Total Sales],
    YEAR(Sales[Order Date]) = YEAR(TODAY())
)
Last Year Sales =
CALCULATE(
    [Total Sales],
    YEAR(Sales[Order Date]) = YEAR(TODAY()) - 1
)
Sales Growth % =
DIVIDE(
    [This Year Sales] - [Last Year Sales],
    [Last Year Sales]
)
