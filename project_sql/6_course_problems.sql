/*
CASE STATEMENTS
Problem 1

From the job_postings_fact table, categorize the salaries from job postings that are data analyst jobs, 
and that have yearly salary information. Put salary into 3 different categories.

SELECT
  job_id,
  job_title,
  salary_year_avg,
  CASE 
    WHEN salary_year_avg >= 100000 THEN 'High salary'
    WHEN salary_year_avg >= 60000 THEN 'Standard salary'
    WHEN salary_year_avg < 60000 THEN 'Low salary'
  END AS salary_category
FROM 
	job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
    and job_title_short = 'Data Analyst'
ORDER BY
    salary_year_avg DESC;

Problem 2
Count the number of unique companies that offer work from home (WFH) versus those requiring work to be on-site. 
Use the job_postings_fact table to count and compare the distinct companies based on their WFH policy (job_work_from_home).

SELECT 
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) AS wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) AS non_wfh_companies
FROM job_postings_fact;

Problem 3

Write a SQL query using the job_postings_fact table that returns the following columns:
job_id
salary_year_avg
experience_level (derived using a CASE WHEN)
remote_option (derived using a CASE WHEN)
Only include rows where salary_year_avg is not null.
Experience Level
Create a new column called experience_level based on keywords in the job_title column:
Contains "Senior" → 'Senior'
Contains "Manager" or "Lead" → 'Lead/Manager'
Contains "Junior" or "Entry" → 'Junior/Entry'
Otherwise → 'Not Specified'
Use ILIKE instead of LIKE to perform case-insensitive matching (PostgreSQL-specific).
Remote Option
Create a new column called remote_option:
If job_work_from_home is true → 'Yes'
Otherwise → 'No'
Filter and Order
Filter out rows where salary_year_avg is NULL
Order the results by job_id

SELECT 
  job_id,
  salary_year_avg,
  CASE
      WHEN job_title ILIKE '%Senior%' THEN 'Senior'
      WHEN job_title ILIKE '%Manager%' OR job_title ILIKE '%Lead%' THEN 'Lead/Manager'
      WHEN job_title ILIKE '%Junior%' OR job_title ILIKE '%Entry%' THEN 'Junior/Entry'
      ELSE 'Not Specified'
  END AS experience_level,
  CASE
      WHEN job_work_from_home THEN 'Yes'
      ELSE 'No' 
  END AS remote_option
FROM 
  job_postings_fact
WHERE 
  salary_year_avg IS NOT NULL 
ORDER BY 
  job_id;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

SubQuery
Problem 1

Identify the top 5 skills that are most frequently mentioned in job postings. 
Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table and then join this result with the skills_dim table to get the skill names.

SELECT skills_dim.skills
FROM skills_dim
INNER JOIN (
    SELECT 
        skill_id,
        COUNT(job_id) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY COUNT(job_id) DESC
    LIMIT 5
) AS top_skills ON skills_dim.skill_id = top_skills.skill_id
ORDER BY top_skills.skill_count DESC;

Problem 2

Determine the size category ('Small', 'Medium', or 'Large') for each company by first identifying the number of job postings they have. 
Use a subquery to calculate the total job postings per company. 
A company is considered 'Small' if it has less than 10 job postings, 
'Medium' if the number of job postings is between 10 and 50, 
and 'Large' if it has more than 50 job postings. 
Implement a subquery to aggregate job counts per company before classifying them based on size.

SELECT
   company_id,
   name,
   -- Categorize companies
   CASE
       WHEN job_count < 10 THEN 'Small'
       WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
       ELSE 'Large'
   END AS company_size
FROM (
   -- Subquery to calculate number of job postings per company 
   SELECT
       company_dim.company_id,
       company_dim.name,
       COUNT(job_postings_fact.job_id) AS job_count
   FROM company_dim
   INNER JOIN job_postings_fact 
       ON company_dim.company_id = job_postings_fact.company_id
   GROUP BY
       company_dim.company_id,
       company_dim.name
) AS company_job_count;

Problem 3

Your goal is to find the names of companies that have an average salary greater than the overall average salary across all job postings.
You'll need to use two tables: company_dim (for company names) and job_postings_fact (for salary data). The solution requires using subqueries.

SELECT 
    company_dim.name
FROM 
    company_dim
INNER JOIN (
    -- Subquery to calculate average salary per company
    SELECT 
        company_id, 
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY company_id
    ) AS company_salaries ON company_dim.company_id = company_salaries.company_id
-- Filter for companies with an average salary greater than the overall average
WHERE company_salaries.avg_salary > (
    -- Subquery to calculate the overall average salary
    SELECT AVG(salary_year_avg)
    FROM job_postings_fact
);

------------------------------------------------------------------------------------------------------------------------------------------------

CTEs

Problem 1

Identify companies with the most diverse (unique) job titles. 
Use a CTE to count the number of unique job titles per company, then select companies with the highest diversity in job titles.

-- Define a CTE named title_diversity to calculate unique job titles per company
WITH title_diversity AS (
    SELECT
        company_id,
        COUNT(DISTINCT job_title) AS unique_titles  
    FROM job_postings_fact
    GROUP BY company_id  
)
-- Get company name and count of how many unique titles each company has
SELECT
    company_dim.name,  
    title_diversity.unique_titles  
FROM title_diversity
	INNER JOIN company_dim ON title_diversity.company_id = company_dim.company_id  
ORDER BY 
	unique_titles DESC  
LIMIT 10;  

Problem 2

Explore job postings by listing job id, job titles, company names, and their average salary rates, 
while categorizing these salaries relative to the average in their respective countries. 
Include the month of the job posted date. 
Use CTEs, conditional logic, and date functions, to compare individual salaries with national averages.

-- gets average job salary for each country
WITH avg_salaries AS (
    SELECT 
        job_country, 
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY job_country
)
SELECT
    -- Gets basic job info
    job_postings.job_id,
    job_postings.job_title,
    companies.name AS company_name,
    job_postings.salary_year_avg AS salary_rate,
    -- categorizes the salary as above or below average the average salary for the country
    CASE
        WHEN job_postings.salary_year_avg > avg_salaries.avg_salary
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS salary_category,
    -- gets the month and year of the job posting date
    EXTRACT(MONTH FROM job_postings.job_posted_date) AS posting_month
FROM
    job_postings_fact as job_postings
INNER JOIN
    company_dim as companies ON job_postings.company_id = companies.company_id
INNER JOIN
    avg_salaries ON job_postings.job_country = avg_salaries.job_country
ORDER BY
    -- Sorts it by the most recent job postings
    posting_month desc

Problem 3

Calculate the number of unique skills required by each company. 
Aim to quantify the unique skills required per company and identify which of these companies 
offer the highest average salary for positions necessitating at least one skill. 
For entities without skill-related job postings, list it as a zero skill requirement and a null salary. 
Use CTEs to separately assess the unique skill count and the maximum average salary offered by these companies.

--CTE that counts unique job postings for each company
WITH required_skills AS (
    SELECT 
        company_dim.company_id,
        COUNT (DISTINCT skills_job_dim.skill_id) AS unique_skill_count
    FROM
        company_dim
    LEFT JOIN job_postings_fact
        ON company_dim.company_id = job_postings_fact.company_id
    LEFT JOIN skills_job_dim
        ON job_postings_fact.job_id = skills_job_dim.job_id
    GROUP BY
        company_dim.company_id
),
--CTE that finds highest average salary offered by these companies
maximum_company_salary AS (
    SELECT
        job_postings_fact.company_id,
        MAX (job_postings_fact.salary_year_avg) AS maximum_salary
    FROM
        job_postings_fact
    WHERE
        job_postings_fact.job_id IN (SELECT job_id FROM skills_job_dim)
    GROUP BY
        job_postings_fact.company_id
)
SELECT 
    company_dim.name,
    required_skills.unique_skill_count,
    maximum_company_salary.maximum_salary
FROM
    company_dim
LEFT JOIN required_skills
    ON required_skills.company_id = company_dim.company_id
LEFT JOIN maximum_company_salary
    ON maximum_company_salary.company_id = company_dim.company_id
ORDER BY
    company_dim.name;

---------------------------------------------------------------------------------------------------------------------------------------------------------

UNIOIS

Problem 1

Create a unified query that categorizes job postings into two groups: those with salary information (salary_year_avg or salary_hour_avg is not null) and those without it. 
Each job posting should be listed with its job_id, job_title, and an indicator of whether salary information is provided.
(
SELECT
    job_id,
    job_title,
    'With Salary Info' AS salary_info
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
)
UNION ALL
(
SELECT
    job_id,
    job_title,
    'Without Salary Info' AS salary_info
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NULL AND salary_hour_avg IS NULL
)
ORDER BY
    salary_info DESC,
    job_id;

Problem 2

Retrieve the job id, job title short, job location, job via, skill and skill type for each 
job posting from the first quarter (January to March). 
Using a subquery to combine job postings from the first quarter (these tables were created in the Advanced Section - Practice Problem 6 Video) 
Only include postings with an average yearly salary greater than $70,000.

SELECT
    job_postings_q1.job_id,
    job_postings_q1.job_title_short,
    job_postings_q1.job_location,
    job_postings_q1.job_via,
    job_postings_q1.salary_year_avg,
    skills_dim.skills,
    skills_dim.type
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) as job_postings_q1

LEFT JOIN skills_job_dim
    ON job_postings_q1.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    salary_year_avg > 70000
ORDER BY
    job_postings_q1, job_id;

Problem 3

Analyze the monthly demand for skills by counting the number of job postings for each skill in the first quarter (January to March), 
utilizing data from separate tables for each month. Ensure to include skills from all job postings across these months. 
The tables for the first quarter job postings were created in Practice Problem 6.
*/

WITH first_quarter AS (
    SELECT job_id FROM january_jobs
    UNION ALL
    SELECT job_id FROM february_jobs
    UNION ALL
    SELECT job_id FROM march_jobs
)
SELECT
    s.skills,
    COUNT(fq.job_id) AS skill_count,
    EXTRACT(MONTH FROM jpf.job_posted_date) AS month,
    EXTRACT(YEAR FROM jpf.job_posted_date) AS year
FROM first_quarter fq
INNER JOIN job_postings_fact jpf
    ON fq.job_id = jpf.job_id
INNER JOIN skills_job_dim sjd
    ON fq.job_id = sjd.job_id
INNER JOIN skills_dim s
    ON sjd.skill_id = s.skill_id
GROUP BY s.skills, year, month
ORDER BY s.skills;