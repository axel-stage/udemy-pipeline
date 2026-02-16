import duckdb
import pandas as pd
import boto3
from typing import Any, Callable, TypeAlias


Record: TypeAlias = dict[str, Any]
DataDict: TypeAlias = list[Record]
Mapping: TypeAlias = dict[str, Callable[[Record], Any]]


def query_to_df(db_path: str, query: str) -> pd.DataFrame:
    """
    Execute a SQL query against a DuckDB database and return the result
    as a Pandas DataFrame.

    This function represents the extraction phase of the ELT pipeline.

    Args:
        db_path: Path to the DuckDB database file.
        query: SQL query to execute.

    Returns:
        Pandas DataFrame containing the query results.
    """
    with duckdb.connect(db_path) as con:
        return con.execute(query).df()


def df_to_data_dict(df: pd.DataFrame) -> DataDict:
    """
    Convert a Pandas DataFrame into a list of record dictionaries.

    Each row becomes a dict keyed by column name.

    Args:
        df: Input DataFrame.

    Returns:
        List of records suitable for downstream transformation and loading.
    """
    return df.to_dict("records")


def build_item(record: Record, mapping: Mapping) -> Record:
    """
    Transform a single record into a DynamoDB-compatible item
    using a mapping configuration.

    The mapping defines how each target field is derived
    from the source record.

    Args:
        record: Source record (typically from DuckDB).
        mapping: Field mapping configuration.

    Returns:
        Transformed DynamoDB item.
    """
    return {
        target_field: transform(record)
        for target_field, transform in mapping.items()
    }


def load_into_dynamodb(table_name: str, data_dict: DataDict, mapping: Mapping) -> None:
    """
    Load transformed records into a DynamoDB table using batch writes.

    Uses DynamoDB batch_writer to handle retries and throughput automatically.

    Args:
        table_name: Target DynamoDB table name.
        data_dict: List of source records.
        mapping: Transformation mapping used to build DynamoDB items.

    Returns:
        None
    """
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(table_name)

    with table.batch_writer() as batch:
        for record in data_dict:
            item = build_item(record, mapping)
            batch.put_item(Item=item)


def load_data(db_path: str, table_name: str, query: str, mapping: Mapping) -> None:
    """
    Orchestrate the full load process:

    1. Extract data from DuckDB into a DataFrame
    2. Convert from DataFrame to dictionary records
    3. Transform via mapping into schema
    4. Load into DynamoDB

    Acts as the pipeline entry point.

    Args:
        db_path: Path to DuckDB warehouse.
        table_name: DynamoDB target table.
        query: SQL query used to extract data.
        mapping: Mapping configuration for DynamoDB items.

    Returns:
        None
    """
    df = query_to_df(db_path, query)

    if df.empty:
        print("No records found — skipping load.")
        return

    data_dict = df_to_data_dict(df)
    load_into_dynamodb(table_name, data_dict, mapping)
