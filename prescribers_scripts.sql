-- PART ONE: PRESCRIBER, DRUG, AND REGIONAL ANALYSIS

-- 1a. Which prescriber had the highest total number of claims across all drugs?
SELECT npi, SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC;
-- Answer: 1881634483

-- 1b. What are the name, specialty, and total claim count of the prescriber with the highest claim volume?
SELECT
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description,
	SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY SUM(total_claim_count) DESC;
-- Answer: Bruce Pendley (Family Practice), 99707

-- 2a. Which specialty had the highest total number of claims across all drugs?
SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;
-- Answer: Family Practice

-- 2b. Which specialty had the highest total number of opioid claims?
SELECT specialty_description, SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;
-- Answer: Nurse Practioner

-- 2c. Which specialties have no associated prescriptions?
SELECT specialty_description
FROM prescriber
EXCEPT
SELECT specialty_description
FROM prescriber
	INNER JOIN prescription USING (npi);

-- 2d. What percentage of each specialty's total claims were for opioids, and which specialties had the highest percentages?
SELECT specialty_description,
	ROUND(SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) / SUM(total_claim_count) * 100, 2) AS opioid_percentage
FROM prescription
	INNER JOIN prescriber USING (npi)
	INNER JOIN drug USING (drug_name)
GROUP BY specialty_description
ORDER BY opioid_percentage DESC;

-- 3a. Which generic drug had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost)
FROM drug
	INNER JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC;
-- Answer: INSULIN GLARGINE, HUM.REC.ANLOG

-- 3b. Which generic drug had the highest total cost per day supplied?
SELECT generic_name, ROUND(SUM(total_drug_cost) / SUM(total_day_supply), 2) AS cost_per_day
FROM drug
	INNER JOIN prescription USING (drug_name)
GROUP BY generic_name
ORDER BY cost_per_day DESC;
-- Answer: C1 ESTERASE INHIBITOR

-- 4a. Which drugs were classified as opioids, antibiotics, or neither?
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiobiotic'
	ELSE 'neither' END AS drugtype
FROM drug;

-- 4b. Was more spent on opioids or antibiotics?
SELECT
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antiobiotic'
		ELSE 'neither' END AS drugtype,
	SUM(total_drug_cost::MONEY) AS total_spent
FROM drug
	INNER JOIN prescription USING (drug_name)
GROUP BY drugtype
ORDER BY total_spent DESC;
-- Answer: Opioid

-- 5a. How many Core-Based Statistical Areas (CBSAs) are in Tennessee?
SELECT COUNT(DISTINCT cbsa)
FROM cbsa
	INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';
-- Answer: 10

-- 5b. Which CBSAs had the largest and smallest combined populations?
SELECT cbsaname, SUM(population) as comb_pop
FROM cbsa
	INNER JOIN population USING (fipscounty)
GROUP BY cbsaname
ORDER BY comb_pop DESC;
-- Answer: Nashville-Davidson--Murfreesboro--Franklin, TN -> 1830410

-- 5c. What was the most populous county not included in a CBSA?
SELECT county, population
FROM fips_county
	INNER JOIN population USING (fipscounty)
	LEFT JOIN cbsa USING (fipscounty)
WHERE cbsa IS NULL
ORDER BY population DESC;
-- Answer: SEVIER

-- 6a. Which prescription records had at least 3,000 total claims?
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

-- 6b. Which drugs with at least 3,000 total claims were opioids?
SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
	INNER JOIN drug USING (drug_name)
WHERE total_claim_count >= 3000;

-- 6c. Which prescribers were associated with drugs having at least 3,000 total claims?
SELECT nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count, opioid_drug_flag
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE total_claim_count >= 3000;

-- 7a. What were all possible prescriber-drug combinations for Nashville pain-management specialists and opioid drugs?
SELECT npi, drug_name
FROM prescriber
	CROSS JOIN drug
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y';

-- 7b. How many claims did each Nashville pain-management specialist have for every opioid drug, including combinations with no claims?
SELECT npi, drug.drug_name, total_claim_count
FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y';

-- 7c. What was the claim count for every Nashville pain-management specialist and opioid combination when missing claims were reported as zero?
SELECT npi, drug_name, COALESCE(total_claim_count, 0)
FROM prescriber
	CROSS JOIN drug
	LEFT JOIN prescription USING (npi, drug_name)
WHERE specialty_description = 'Pain Management' AND
	nppes_provider_city = 'NASHVILLE' AND
	opioid_drug_flag = 'Y';


-- PART TWO: SPECIALTY, METROPOLITAN, AND POPULATION ANALYSIS

-- 1. Which NPIs appeared in the prescriber data but not in the prescription data?
SELECT npi
FROM prescriber
EXCEPT
SELECT npi
FROM prescriber
	INNER JOIN prescription USING (npi);
-- Answer: 4458

-- 2a. What were the five most-prescribed generic drugs among Family Practice prescribers?
SELECT generic_name, SUM(total_claim_count)
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE specialty_description LIKE 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- 2b. What were the five most-prescribed generic drugs among Cardiology prescribers?
SELECT generic_name, SUM(total_claim_count)
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE specialty_description LIKE 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- 2c. Which generic drugs ranked among the most prescribed by Family Practice and Cardiology prescribers?
SELECT generic_name, SUM(total_claim_count)
FROM prescription
	INNER JOIN drug USING (drug_name)
	INNER JOIN prescriber USING (npi)
WHERE specialty_description LIKE 'Family Practice' OR
	specialty_description LIKE 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- 3a. Who were the five highest-volume prescribers in Nashville by total claims?
SELECT npi,
	nppes_provider_city,
	SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE nppes_provider_city LIKE 'NASHVILLE'
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- 3b. Who were the five highest-volume prescribers in Memphis by total claims?
SELECT npi,
	nppes_provider_city,
	SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE nppes_provider_city LIKE 'MEMPHIS'
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- 3c. Who were the highest-volume prescribers across Nashville, Memphis, Knoxville, and Chattanooga?
SELECT npi,
	nppes_provider_city,
	SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE nppes_provider_city IN ('NASHVILLE', 'MEMPHIS', 'KNOXVILLE', 'CHATTANOOGA')
GROUP BY npi, nppes_provider_city
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

-- 4. Which Tennessee counties had an above-average number of overdose deaths?
SELECT county, SUM(overdose_deaths)
FROM fips_county
	INNER JOIN overdose_deaths ON overdose_deaths.fipscounty = fips_county.fipscounty::numeric
GROUP BY county
HAVING SUM(overdose_deaths) > (SELECT AVG(overdose_deaths) FROM overdose_deaths)
ORDER BY SUM(overdose_deaths) DESC;

-- 5a. What was the total population of Tennessee?
SELECT SUM(population)
FROM population
	INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';

-- 5b. What percentage of Tennessee's population lived in each county?
SELECT county,
	population,
	ROUND(population / (SELECT SUM(population)
	FROM population INNER JOIN fips_county USING (fipscounty)
	WHERE state = 'TN'), 3) AS pop_percentage
FROM population
	INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN'
GROUP BY county, population
ORDER BY pop_percentage DESC;


-- PART THREE: MULTIDIMENSIONAL CLAIM ANALYSIS

-- 1a. How many total claims were associated with Interventional Pain Management and Pain Management specialists?
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY specialty_description;

-- 1b. What were the individual and combined total claims for Interventional Pain Management and Pain Management specialists?
SELECT '' AS specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
UNION
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY specialty_description;

-- 2a. What were the specialty-level and combined claim totals for Interventional Pain Management and Pain Management specialists?
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY GROUPING SETS ((),(specialty_description));

-- 2b. How did opioid and non-opioid claims compare across the two pain-management specialties, including category and overall totals?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY GROUPING SETS ((),(opioid_drug_flag),(specialty_description));

-- 3a. How did claim totals break down by opioid status and then by pain-management specialty?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY ROLLUP(opioid_drug_flag,specialty_description);

-- 3b. How did claim totals break down by pain-management specialty and then by opioid status?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY ROLLUP(specialty_description, opioid_drug_flag);

-- 3c. What were the claim totals across every combination of pain-management specialty and opioid status?
SELECT specialty_description, opioid_drug_flag, SUM(total_claim_count) AS total_claims
FROM prescriber
	INNER JOIN prescription USING (npi)
	INNER JOIN drug USING (drug_name)
WHERE specialty_description = 'Interventional Pain Management' OR
	specialty_description = 'Pain Management'
GROUP BY CUBE(specialty_description, opioid_drug_flag);

-- 3d. How many claims were recorded for six common opioid categories across Nashville, Memphis, Knoxville, and Chattanooga?
CREATE EXTENSION tablefunc;

SELECT *
FROM crosstab(
	'SELECT nppes_provider_city AS city,
		CASE
			WHEN drug_name ILIKE ''%hydrocodone%'' THEN ''hydrocodone''
			WHEN drug_name ILIKE ''%oxycodone%'' THEN ''oxycodone''
			WHEN drug_name ILIKE ''%oxymorphone%'' THEN ''oxymorphone''
			WHEN drug_name ILIKE ''%morphine%'' THEN ''morphine''
			WHEN drug_name ILIKE ''%codeine%'' THEN ''codeine''
			WHEN drug_name ILIKE ''%fentanyl%'' THEN ''fentanyl''
		END AS drug_category,
		SUM(total_claim_count)
	FROM prescription
		INNER JOIN prescriber USING (npi)
	WHERE nppes_provider_city IN (''NASHVILLE'',''MEMPHIS'',''KNOXVILLE'',''CHATTANOOGA'')
	GROUP BY nppes_provider_city, drug_category
	ORDER BY city')
AS ct(city text, codeine numeric, fentanyl numeric, hydrocodone numeric, morphine numeric, oxycodone numeric, oxymorphone numeric)
