--Top 10 highest paying Data Analyst roles that are avaliable remotly
--Focuses on salries without NULL values
--Why? Highlighting top paying jobs for Data Analyst, giving more in depth inside.

--Finding the exact name. Whether its under Czechia or Czech Republic.
SELECT
    job_location
FROM
    job_postings_fact
WHERE
    job_location LIKE '%Cze%'
ORDER BY
    job_location
--I wanted to check it for my country but there is only 1 job where the salary is not NULL so I decided to do remote jobs

SELECT
    job_id,
    company_dim.name AS company_name,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date
FROM 
    job_postings_fact
LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_location = 'Anywhere'
    AND salary_year_avg IS NOT NULL
    AND job_title_short = 'Data Analyst'
ORDER BY
    salary_year_avg DESC
LIMIT 10;

