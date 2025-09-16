/*
What are the top paying skills based on salary?
*/

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


/*
MLOps + AI frameworky
Skills jako TensorFlow, PyTorch, Keras, Hugging Face, MXNet, DataRobot se objevují hodně vysoko.
To ukazuje, že znalost strojového učení a AI pipeline je extrémně dobře placená.

Cloud & DevOps nástroje
Terraform, Ansible, Puppet, VMware, GitLab, Bitbucket, Atlassian, Airflow → hodně DevOps/automation skillů.
Znamená to, že data analysti, kteří ovládají cloudové nasazení a orchestraci, mají velkou konkurenční výhodu.

Databáze a distribuované systémy
Couchbase, Cassandra, Kafka, Scala → dobře placené big data a NoSQL technologie.
Trend ukazuje, že znalost distribuovaných databází a stream processingu je pro data analýzu klíčová.

Programovací jazyky mimo klasický Python/R
Go (Golang), Perl, Scala, Solidity – ukazuje se, že univerzální programátoři s přesahem do data analýzy si přijdou na hodně peněz.
Solidity navíc naznačuje trend propojení datové analytiky s blockchainem.

Nové nástroje produktivity & kolaborace
Notion, Atlassian, Twilio – i když nejsou typicky „data“ skills, objevují se, protože firmy oceňují efektivní spolupráci a integrace s daty.

JSON dataset rozdělený
{
  "AI_ML_Tools": [
    "datarobot",
    "mxnet",
    "keras",
    "pytorch",
    "hugging face",
    "tensorflow"
  ],
  "DevOps_Cloud_Automation": [
    "vmware",
    "terraform",
    "gitlab",
    "puppet",
    "ansible",
    "airflow",
    "bitbucket",
    "atlassian"
  ],
  "BigData_Databases": [
    "couchbase",
    "kafka",
    "cassandra",
    "scala"
  ],
  "Programming_Languages": [
    "golang",
    "perl",
    "solidity",
    "scala"
  ],
  "Productivity_Collaboration": [
    "notion",
    "twilio",
    "atlassian",
    "bitbucket"
  ]
}

JSON dataset podle zadání

[
  {
    "skills": "svn",
    "average_salary": "400000"
  },
  {
    "skills": "solidity",
    "average_salary": "179000"
  },
  {
    "skills": "couchbase",
    "average_salary": "160515"
  },
  {
    "skills": "datarobot",
    "average_salary": "155486"
  },
  {
    "skills": "golang",
    "average_salary": "155000"
  },
  {
    "skills": "mxnet",
    "average_salary": "149000"
  },
  {
    "skills": "dplyr",
    "average_salary": "147633"
  },
  {
    "skills": "vmware",
    "average_salary": "147500"
  },
  {
    "skills": "terraform",
    "average_salary": "146734"
  },
  {
    "skills": "twilio",
    "average_salary": "138500"
  },
  {
    "skills": "gitlab",
    "average_salary": "134126"
  },
  {
    "skills": "kafka",
    "average_salary": "129999"
  },
  {
    "skills": "puppet",
    "average_salary": "129820"
  },
  {
    "skills": "keras",
    "average_salary": "127013"
  },
  {
    "skills": "pytorch",
    "average_salary": "125226"
  },
  {
    "skills": "perl",
    "average_salary": "124686"
  },
  {
    "skills": "ansible",
    "average_salary": "124370"
  },
  {
    "skills": "hugging face",
    "average_salary": "123950"
  },
  {
    "skills": "tensorflow",
    "average_salary": "120647"
  },
  {
    "skills": "cassandra",
    "average_salary": "118407"
  },
  {
    "skills": "notion",
    "average_salary": "118092"
  },
  {
    "skills": "atlassian",
    "average_salary": "117966"
  },
  {
    "skills": "bitbucket",
    "average_salary": "116712"
  },
  {
    "skills": "airflow",
    "average_salary": "116387"
  },
  {
    "skills": "scala",
    "average_salary": "115480"
  }
]

