select *
from courses
where course_status in ('inactive', 'draft');

select *
from courses
where course_name ilike '%python%' or course_name ilike '%scala%';

select course_status, count(*) as course_count
from courses
group by course_status;

select course_author, course_status, count(*) as published_courses_count
from courses
where course_status = 'published'
group by course_author, course_status;

select *
from courses
where course_status = 'draft'
  and (course_name ilike '%python%' or course_name ilike '%scala%');

select course_author, count(*) as published_courses_count
from courses
where course_status = 'published'
group by course_author
having count(*) > 1;