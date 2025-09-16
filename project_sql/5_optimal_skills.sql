/*
What are the most optimal skills to learn?

Using CTEs with the queries from previous taks
*/

WITH skills_demand AS (
    SELECT
        sd.skill_id,
        skills,
        COUNT (jpf.job_id) AS demand_count
    FROM
        skills_dim AS sd
    INNER JOIN skills_job_dim sjd
        ON sd.skill_id = sjd.skill_id
    INNER JOIN job_postings_fact jpf
        ON sjd.job_id = jpf.job_id
    WHERE
        job_title_short = 'Data Analyst' AND
        job_work_from_home IS TRUE AND
        salary_year_avg IS NOT NULL
    GROUP BY
        sd.skill_id
), average_salary AS (
    SELECT
        sd.skill_id,
        skills,
        ROUND (AVG (salary_year_avg),0) AS average_salary
    FROM
        job_postings_fact AS jpf
    INNER JOIN skills_job_dim sjd
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim sd
        ON sjd.skill_id = sd.skill_id
    WHERE
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL
    GROUP BY
        sd.skill_id
)
SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    average_salary
FROM
    skills_demand
INNER JOIN average_salary
    ON average_salary.skill_id = skills_demand.skill_id
ORDER BY
    demand_count DESC,
    average_salary DESC
LIMIT 25;

/*
Now we are going to do it in 1 query
*/

SELECT
    sd.skill_id,
    sd.skills,
    COUNT (sjd.job_id) AS demand_count,
    ROUND (AVG (jpf.salary_year_avg), 0) AS average_salary
FROM job_postings_fact jpf
INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND job_work_from_home IS TRUE
    AND salary_year_avg IS NOT NULL
GROUP BY
    sd.skill_id
HAVING
    COUNT (sjd.job_id) > 10
ORDER BY
    average_salary DESC,
    demand_count DESC
LIMIT 25;

