create schema if not exists gold;

create or replace table gold.fact_udemy_course
as
select
    cert.owner,
    cert.certificate_id,
    cour.title,
    cour.instructor,
    cert.course_length,
    cert.course_end,
    cour.language,
    cour.is_practice_test,
    cour.is_paid
from silver.certificate as cert
left outer join silver.course as cour on cert.certificate_id = cour.certificate_id;

create or replace table gold.owner_stats as
select
    owner,
    year(course_end) as year,
    count(*) as total_courses,
    sum(course_length) as total_course_length,
    sum(case when is_paid is true then 1 else 0 end)::int as total_paid_courses,
    sum(case when is_practice_test is true then 1 else 0 end)::int as total_practice_tests
from gold.fact_udemy_course
group by grouping sets ((owner),(owner, year))
order by year;

create or replace table gold.instructor_top_5 as
select
    instructor,
    count(*) as total_courses,
    sum(course_length) as total_course_length
from gold.fact_udemy_course
group by instructor
order by total_course_length desc
limit 5;
