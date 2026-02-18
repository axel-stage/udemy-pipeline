create schema if not exists bronze;

create or replace table bronze.course
as
select
    certificate_id,
    id,
    _class as type,
    title,
    published_title,
    url,
    visible_instructors[1].title as instructor_title,
    visible_instructors[1].name as instructor_name,
    visible_instructors[1].display_name as instructor_display,
    locale.locale as language,
    is_practice_test_course,
    is_paid,
    created as _created_at
from read_json("/tmp/api-*.json");
-- from read_json("src/etl_pipeline/data/api-*.json");

create or replace table bronze.certificate
as
select
    *
from read_json("/tmp/certificate-*.json");
-- from read_json("src/etl_pipeline/data/certificate-*.json");
