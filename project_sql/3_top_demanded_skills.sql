/*
What are the most in-demand skills for data anylyst?
*/

SELECT
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
    job_location = 'Czechia'
GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5;

-- Top in demand skills in Czechia are little bit different compare to rest of the world. 
-- SQL is still winning but Power BI took the scond place.


