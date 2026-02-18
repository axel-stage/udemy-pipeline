from decimal import Decimal

WAREHOUSE_PATH = "/tmp/warehouse.duckdb"
OWNER_STATS_QUERY = "select * from gold.owner_stats;"
OWNER_STATS_MAPPING = {
    "PartitionKey": lambda item: f"owner#{item['owner']}",
    "SortKey": lambda item: f"year#{item['year']}",
    "TotalCourses": lambda item: int(item["total_courses"]),
    "TotalCourseLength": lambda item: Decimal(str(item["total_course_length"])),
    "TotalPaidCourses": lambda item: int(item["total_paid_courses"]),
    "TotalPracticeTests": lambda item: int(item["total_practice_tests"]),
}
INSTRUCTOR_TOP_5_QUERY = "select * from gold.instructor_top_5;"
INSTRUCTOR_TOP_5_MAPPING = {
    "PartitionKey": lambda item: f"instructor#{item['instructor']}",
    "SortKey": lambda item: f"instructor#{item['instructor']}",
    "TotalCourses": lambda item: int(item["total_courses"]),
    "TotalCourseLength": lambda item: Decimal(str(item["total_course_length"])),
}
