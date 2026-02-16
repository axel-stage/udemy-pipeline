from decimal import Decimal

CONFIG_PATH = "src/etl_pipeline/config.yaml"
DATA_PATH = "src/etl_pipeline/data"
WAREHOUSE_PATH = "src/etl_pipeline/warehouse.duckdb"
OWNER_STATS_MAPPING = {
    "PartitionKey": lambda item: f"owner#{item['owner']}",
    "SortKey": lambda item: f"year#{item['year']}",
    "TotalCourses": lambda item: int(item["total_courses"]),
    "TotalCourseLength": lambda item: Decimal(str(item["total_course_length"])),
    "TotalPaidCourses": lambda item: int(item["total_paid_courses"]),
    "TotalPracticeTests": lambda item: int(item["total_practice_tests"]),
}
OWNER_STATS_QUERY = "select * from gold.owner_stats;"
