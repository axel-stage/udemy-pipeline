
# courses = (
#     https://www.udemy.com/course/mongodb-the-complete-developers-guide/
#     https://www.udemy.com/course/apache-kafka/
#     https://www.udemy.com/course/diveintokubernetes-introduction/
#     https://www.udemy.com/course/programming-in-snowflake/
#     https://www.udemy.com/course/the-bigtech-system-design-interview-bootcamp/
#     )

# courses = (
#     mongodb-the-complete-developers-guide
#     apache-kafka
#     diveintokubernetes-introduction
#     programming-in-snowflake
#     the-bigtech-system-design-interview-bootcamp
#     )

# certificates = (
#     UC-0a1bc19a-e326-4931-b1b3-459e1d87d859
#     UC-0db7b3f2-6944-4679-8492-df97a0db19a1
#     UC-0f533ce1-a75f-4696-8507-7a2a724f583b
#     UC-1f3033aa-2316-4387-b677-0df992a2f13e
#     UC-3d0dde11-15c7-4158-bb56-82f1079b275d
#     )


# invoke function
aws lambda invoke \
  --function-name=$(terraform output -raw api_function_name) \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "course_id": "'$1'",
    "certificate_id": "'$2'",
    "bucket": "'$(terraform output -raw bucket_id)'",
    "prefix": "api-upstream-zone/"
    }' \
  response.json && cat response.json && rm response.json
