# Introduction
### Welcome to My SQL Portfolio! 🐍💻
**This project is my hands-on journey into the world of SQL and the data analyst job market.** Throughout this course with Luke Barousse, I explored:

    💰 Highest-paying data analyst roles

    📈 Most in-demand skills

    🎯 The sweet spot where high demand meets high salary

    🛠️ Practical SQL problems and exercises I solved along the way

Everything here is a reflection of my learning process, from analyzing job trends to writing SQL queries to uncover insights. Whether you’re here to peek at my queries, get inspired, or just curious about the data analyst landscape, there’s something for you!

Check out my SQL work here: [project_sql folder](/project_sql/)
# Background
The motivation behind this project came from **my goal to learn SQL by analyzing real-world datasets 📊💻.** I used the data provided in **Luke Barousse’s SQL Course** ([link to course](https://www.lukebarousse.com/products/sql-for-data-analytics)) to explore trends in the data analyst job market. The datasets include information on job titles 🏷️, salaries 💰, locations 📍, and required skills 🛠️.

Through my SQL queries, I wanted to answer the following questions:

    💸 What are the top-paying data analyst jobs?

    🛠️ What skills are required for these top-paying jobs?

    📈 What skills are most in demand for data analysts?

    💡 Which skills are associated with higher salaries?

    🎯 What are the most optimal skills to learn for a data analyst looking to maximize job market value?
# Tools I used
In this project, I utilized a variety of tools to conduct my analysis:

- **SQL (Structured Query Language) 📝:** Enabled me to interact with the database, extract insights, and answer my key questions through queries.

- **PostgreSQL 🗄️:** As the database management system, PostgreSQL allowed me to store, query, and manipulate the job posting data.

- **Visual Studio Code 💻:** This open-source administration and development platform helped me manage the database and execute SQL queries.
# The Analysis
Each query for this project aimed at investigating specific aspects of the data analyst job market. Here’s how I approached each question:

### 1. Top Paying Data Analyst Jobs 💰📊

To identify the highest-paying roles, I filtered data analyst positions by average yearly salary and location, focusing on remote jobs 🌐. This query highlights the high paying opportunities in the field.

```sql
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
```

### 2. Skills for Top Paying Jobs 🛠️💼

To understand what skills are required for the top-paying jobs, I joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.

```sql
-- Gets the top 10 paying Data Analyst jobs
WITH top_paying_jobs AS (
    SELECT
        jpf.job_id,
        cd.name AS company_name,
        job_title,
        salary_year_avg
    FROM 
        job_postings_fact as jpf
    LEFT JOIN company_dim AS cd
        ON jpf.company_id = cd.company_id
    WHERE
        job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
        AND job_title_short = 'Data Analyst'
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)
SELECT
    tpj.*,
    sd.skills AS skill_name
    FROM 
    top_paying_jobs AS tpj
INNER JOIN skills_job_dim AS sjd
    ON tpj.job_id = sjd.job_id
INNER JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id
ORDER BY
    tpj.salary_year_avg DESC
```

### 3. In-Demand Skills for Data Analysts 📈🔥

This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.

```sql
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
```
**💡 Insight:** In Czechia, top in-demand skills differ slightly from global trends. SQL still leads 🏆, with Power BI coming in second 📊.
### 4. Skills Based on Salary 💵🛠️

Exploring the average salaries associated with different skills revealed which skills are the highest paying.

```sql
SELECT
    skills,
    ROUND (AVG (jpf.salary_year_avg),0) AS average_salary
FROM
    skills_dim AS sd
INNER JOIN skills_job_dim sjd
    ON sd.skill_id = sjd.skill_id
INNER JOIN job_postings_fact jpf
    ON sjd.job_id = jpf.job_id
WHERE
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY
    skills
ORDER BY
    average_salary DESC
LIMIT 25;
```

### 5. Most Optimal Skills to Learn 🎯🚀

Combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries, offering a strategic focus for skill development.

```sql
-- First we did it with CTEs from previous tables
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
-- Later we modified it to fit 1 query and save time
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
```

Each query not only served to answer a specific question but also to **improve my understanding of SQL and database analysis 🧠💻.** Through this project, I learned to leverage SQL's powerful data manipulation capabilities to derive meaningful insights from complex datasets. 

While working through the course, I discovered that **using aliases makes queries much easier to manage ✨📝** and saved me time from troubleshooting.
# What I Learned
Throughout this course, I honed several key SQL techniques and skills 💻✨:

- **Complex Query Construction🏗️:** Learning to build advanced SQL queries that combine multiple tables and employ functions like **`WITH`** clauses for temporary tables.
- **Data Aggregation 📊:** Utilizing **`GROUP BY`** and aggregate functions like **`COUNT()`** and **`AVG()`** to summarize data effectively.
- **Analytical Thinking 🧠🔍:** Developing the ability to translate real-world questions into actionable SQL queries that got insightful answers.
# Conclusions
From the analysis, several general insights emerged 📊💡:

1. **Top-Paying Data Analyst Jobs 💰🌐:** The highest-paying jobs for data analysts that allow remote work offer a wide range of salaries, the highest at $650,000!
2. **Skills for Top-Paying Jobs 🛠️🔥:** High-paying data analyst jobs require advanced proficiency in SQL, suggesting it’s a critical skill for earning a top salary.
3. **Most In-Demand Skills 📈⭐:** SQL is also the most demanded skill in the data analyst job market, thus making it essential for job seekers.
4. **Skills with Higher Salaries 💵🧠:** Specialized skills, such as SVN and Solidity, are associated with the highest average salaries, indicating a premium on niche expertise.
5. **Optimal Skills for Job Market Value 🎯🚀:** SQL leads in demand and offers for a high average salary, positioning it as one of the most optimal skills for data analysts to learn to maximize their market value.
### **Conclusion**
I started this journey by watching the course for free on YouTube 🎥. **I have to give a huge thanks to Luke Barousse for uploading all this amazing content for free on his channel** 🔴▶️ ([here](https://www.youtube.com/@LukeBarousse))!

Afterwards, I decided to purchase the course and support Luke’s work 💸. **Honestly, it’s been my best investment to date.** I learned SQL from scratch 🐍, even though I had very little programming experience before.

During the course, I realized that ChatGPT is an incredibly useful tool 🤖✨— **not only for coding help but also for learning faster and writing more precise SQL queries.** Troubleshooting became a piece of cake 🍰 thanks to it!

Rather than just describing data insights, I decided to focus on my personal growth in SQL 📈. I will definitely continue learning with:

- **[Intermediate SQL for Data Analytics](https://www.lukebarousse.com/int-sql)**
 📚

- **[Advanced SQL for Data Analytics](https://www.lukebarousse.com/courses)**
 🚀 (coming soon!)

**Meanwhile, I plan to work on Excel 🧮 and Power BI 📊 to be able to visualize data effectively.**

**I’m open to data analyst opportunities 💼,** but I’m still at the beginning of my career and eager to learn more. If anyone is interested, feel free to contact me via my [LinkedIn](https://www.linkedin.com/in/ond-boc/)🔗.

