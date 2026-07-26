{% macro create_audit_schema() %}
    create schema if not exists
        {{ env_var('DBT_ENVIRONMENT') | upper }}_SILVER.
        AUDIT
{% endmacro %}

{% macro create_model_run_audit_table() %}
    create table if not exists {{ audit_relation() }} (
        DBT_INVOCATION_ID varchar not null,
        DBT_RUN_STARTED_AT timestamp_tz not null,
        AUDIT_INSERTED_AT timestamp_tz not null,
        COMMAND_NAME varchar,
        SOURCE_LINEAGE_ID number(38, 0),
        LINEAGE_ID number(38, 0),
        LOAD_ID number(38, 0),
        LOOP_ID number(38, 0),
        RUN_ID number(38, 0),
        PROCEDURE_ID number(38, 0),
        NODE_UNIQUE_ID varchar not null,
        RESOURCE_TYPE varchar,
        DATABASE_NAME varchar,
        SCHEMA_NAME varchar,
        RELATION_NAME varchar,
        STATUS varchar,
        EXECUTION_TIME_SECONDS number(18, 6),
        ROWS_AFFECTED number(38, 0),
        ADAPTER_MESSAGE varchar
    )
{% endmacro %}
