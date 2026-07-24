# BJS data engineering dbt project

This Snowflake project ports the POS Journal modernisation pilot into the
`bjs_de` dbt project. It is designed to run both from dbt Core and dbt Cloud.

## What it builds

`models/dwr/pos_journal.sql` reads the existing POSI journal and DWR reference
tables and writes `POSJOURNAL` to the configured target database and schema.
The first full refresh processes source history. Each later incremental run
requires a `source_lineage_id` and replaces the affected `BusinessDate + SiteId`
partitions with dbt's Snowflake `delete+insert` strategy.

The project also includes:

- source and model documentation with data tests;
- reconciliation, account-mapping, and valid-site-day tests;
- numeric lineage validation; and
- run hooks that write node results to `<target database>.AUDIT.MODEL_RUN_AUDIT`.

## Local setup

Use an isolated virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
```

Set credentials outside the repository:

```bash
export SNOWFLAKE_ACCOUNT='<account>'
export SNOWFLAKE_USER='<user>'
export SNOWFLAKE_PASSWORD='<password>'
export SNOWFLAKE_ROLE='<role>'
export SNOWFLAKE_WAREHOUSE='<warehouse>'
```

Optional project settings use dbt Cloud-compatible `DBT_` names:

```bash
export DBT_TARGET_DATABASE='DBT_DEV'
export DBT_AUDIT_SCHEMA='AUDIT'
export DBT_SRC_POSI_DATABASE='SRCPOSIDB_DEV'
export DBT_DWR_REFERENCE_DATABASE='DWRDB_DEV'
```

Validate configuration without running warehouse SQL:

```bash
dbt parse
```

Validate the Snowflake connection, then run the initial historical build:

```bash
dbt debug
dbt build --select pos_journal --full-refresh
```

For a small connection and table-creation smoke test, run the retained starter
model by itself:

```bash
dbt run --select my_first_dbt_model
```

The starter model intentionally contains one null `id`. Its `not_null` data test
will therefore fail if you use `dbt build` or `dbt test`; uncomment the final
filter in the model when you want that demonstration test to pass.

Run one incremental lineage:

```bash
dbt build --select pos_journal --vars \
  '{source_lineage_id: 129128, lineage_id: 229128, load_id: 329128, loop_id: 1, run_id: 429128, procedure_id: 529128}'
```

Only `source_lineage_id` is required for an incremental run. The other numeric
IDs inherit source values or default to `-1` as described in the model docs.

## dbt Cloud and orchestration

Follow [DBT_CLOUD_SETUP.md](docs/DBT_CLOUD_SETUP.md) to connect this repository
to dbt Cloud, configure development/CI/production environments, enable GitHub
pull-request checks, and trigger the production job from Astronomer Airflow.
