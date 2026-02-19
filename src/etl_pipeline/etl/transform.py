import duckdb
from pathlib import Path


def run_sql(con: duckdb.DuckDBPyConnection, path: str) -> None:
    """
    Execute a SQL file against an active DuckDB connection.

    This helper reads the entire SQL file from disk and executes it
    as a single statement batch.

    Args:
        con: Active DuckDB connection.
        path: Path to the SQL file.

    Returns:
        None

    Raises:
        FileNotFoundError: If the SQL file does not exist.
    """

    sql_file = Path(path)

    if not sql_file.exists():
        raise FileNotFoundError(f"SQL file not found: {sql_file}")

    con.execute(sql_file.read_text())


def transform_data(db_path: str, root_dir: str) -> None:
    """
    Execute the full medallion transformation pipeline.

    Runs Bronze → Silver → Gold SQL layers sequentially against
    the DuckDB warehouse.

    Args:
        db_path: Path to the DuckDB database file.

    Returns:
        None
    """
    with duckdb.connect(db_path) as con:
        for medallion in ("bronze", "silver", "gold"):
            run_sql(con, f"{root_dir}/sql/{medallion}.sql")
