from decimal import Decimal
from pathlib import Path

ROOT_DIR = Path(__file__).parent.parent.parent
MODULE_DIR = Path(__file__).parent
STORAGE_DIR = "/tmp"
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
INSTRUCTOR_TOP_5_QUERY = "select * from gold.instructor limit 5;"
INSTRUCTOR_TOP_5_MAPPING = {
    "PartitionKey": lambda item: f"owner#{item['owner']}",
    "SortKey": lambda item: f"instructor#{item['instructor']}",
    "TotalCourses": lambda item: int(item["total_courses"]),
    "TotalCourseLength": lambda item: Decimal(str(item["total_course_length"])),
}
