import duckdb
import pandas as pd
import boto3
from decimal import Decimal


dynamodb = boto3.resource("dynamodb")


def query_to_df(db_path: str, query: str) -> pd.DataFrame:
    """
    Pull owner_stats from DuckDB gold layer.
    """
    con = duckdb.connect(db_path)
    df = con.execute(query).df()
    con.close()
    return df


def load_into_dynamodb(table_name: str, df: pd.DataFrame) -> None:

    table = dynamodb.Table(table_name)
    records = df.to_dict("records")
    with table.batch_writer() as batch:
        for record in records:
            batch.put_item(
                Item={
                    "PartitionKey": f"owner#{record['owner']}",
                    "SortKey": f"year#{record['year']}",
                    "TotalCourses": int(record["total_courses"]),
                    "TotalCourseLength": Decimal(record["total_course_length"]),
                    "TotalPaidCourses": int(record["total_paid_courses"]),
                    "TotalPracticeTests": int(record["total_practice_tests"]),
                }
            )


def load_data(db_path: str, table_name: str, query: str):
    df = query_to_df(db_path, query)
    load_into_dynamodb(table_name, df)
