# Hypothesis Based On Data. 
One hypothesis we tested was: “Public transportation usage in NYC varies by income level, with lower-income households more likely to use it.”
To explore this, we created a SQL view called earnings_grouped that categorized income levels from the ACS data into four groups (1 = lowest income, 4 = highest income). We then aggregated estimates for total commuters, those driving alone, and those using public transportation:

```sql 
CREATE OR REPLACE VIEW earnings_grouped AS
SELECT
  CASE
    WHEN "earnings_in_past_12_months" IN (
      '$1 to $9,999 or loss',
      '$10,000 to $14,999',
      '$15,000 to $24,999'
    ) THEN 1
    WHEN "earnings_in_past_12_months" IN (
      '$25,000 to $34,999',
      '$35,000 to $49,999'
    ) THEN 2
    WHEN "earnings_in_past_12_months" IN (
      '$50,000 to $64,999',
      '$65,000 to $74,999'
    ) THEN 3
    WHEN "earnings_in_past_12_months" = '$75,000 or more' THEN 4
    ELSE NULL
  END AS earnings_group,

  SUM(CAST(REPLACE("total_estimate", ',', '') AS FLOAT)) AS total_estimate,
  SUM(CAST(REPLACE("public_transportation_estimate", ',', '') AS FLOAT)) AS public_transportation_estimate,
  SUM(CAST(REPLACE("driving_alone_estimate", ',', '') AS FLOAT)) AS driving_alone_estimate

FROM earnings
WHERE "earnings_in_past_12_months" IN (
  '$1 to $9,999 or loss',
  '$10,000 to $14,999',
  '$15,000 to $24,999',
  '$25,000 to $34,999',
  '$35,000 to $49,999',
  '$50,000 to $64,999',
  '$65,000 to $74,999',
  '$75,000 or more'
)
GROUP BY earnings_group;
```
We then joined this with NYC household data from tax returns by income group:

```sql
SELECT 
  z.borough,
  e.earnings_group,
  e.public_transportation_estimate,
  e.driving_alone_estimate
FROM NYC_Zips z
JOIN earnings_grouped e ON z.agi_stub = e.earnings_group;
```