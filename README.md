## Project Overview

This project analyzes a healthcare database derived from the Medicare Part D Prescriber Public Use File. The database contains eight interconnected tables covering prescribers, prescriptions, drugs, populations, counties, metropolitan areas, ZIP-to-county mappings, and overdose deaths.

The analysis examines prescribing volume, opioid utilization, drug costs, provider specialties, geographic trends, population distribution, and overdose mortality across Tennessee.

## Project Objective

Use SQL to investigate key healthcare and public-health questions, including:

- Which providers, specialties, and medications account for the highest prescription claim volumes
- Which specialties prescribe the greatest number and proportion of opioids
- Which medications have the highest total cost and cost per day supplied
- How opioid and antibiotic spending compare
- Which providers generate the most claims across Tennessee’s major metropolitan areas
- How population and overdose deaths vary between Tennessee counties
- How opioid claims differ by drug category across Nashville, Memphis, Knoxville, and Chattanooga
- How to preserve zero-claim combinations when reporting every opioid associated with Nashville pain-management specialists

## Technologies Used

- PostgreSQL

## Techniques and Methodology Used

- Advanced relational joins across healthcare and demographic datasets
- Subqueries for benchmark and above-average comparisons
- Set operations using `UNION` and `EXCEPT`
- Conditional aggregation for opioid-utilization metrics
- Cross joins and outer joins to construct complete prescriber–drug combinations
- Multidimensional aggregation with `GROUPING SETS`, `ROLLUP`, and `CUBE`
- Pivot-table generation with `crosstab` and the PostgreSQL `tablefunc` extension
- Top-N analysis across specialties, drugs, providers, and geographic areas
- Population-normalized and percentage-based analysis