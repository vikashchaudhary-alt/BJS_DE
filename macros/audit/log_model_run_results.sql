{% macro log_model_run_results(results) %}
    {%- if results | length == 0 -%}
        select 1
    {%- else -%}
        insert into {{ audit_relation() }} (
            DBT_INVOCATION_ID,
            DBT_RUN_STARTED_AT,
            AUDIT_INSERTED_AT,
            COMMAND_NAME,
            SOURCE_LINEAGE_ID,
            LINEAGE_ID,
            LOAD_ID,
            LOOP_ID,
            RUN_ID,
            PROCEDURE_ID,
            NODE_UNIQUE_ID,
            RESOURCE_TYPE,
            DATABASE_NAME,
            SCHEMA_NAME,
            RELATION_NAME,
            STATUS,
            EXECUTION_TIME_SECONDS,
            ROWS_AFFECTED,
            ADAPTER_MESSAGE
        )
        {% for result in results %}
            {%- set response = result.adapter_response if result.adapter_response is not none else {} -%}
            select
                {{ sql_literal(invocation_id) }},
                to_timestamp_tz({{ sql_literal(run_started_at.isoformat()) }}),
                current_timestamp(),
                {{ sql_literal(flags.WHICH) }},
                {{ audit_numeric_var('source_lineage_id') }},
                {{ audit_numeric_var('lineage_id') }},
                {{ audit_numeric_var('load_id') }},
                {{ audit_numeric_var('loop_id') }},
                {{ audit_numeric_var('run_id') }},
                {{ audit_numeric_var('procedure_id') }},
                {{ sql_literal(result.node.unique_id) }},
                {{ sql_literal(result.node.resource_type) }},
                {{ sql_literal(result.node.database) }},
                {{ sql_literal(result.node.schema) }},
                {{ sql_literal(result.node.alias) }},
                {{ sql_literal(result.status) }},
                {{ result.execution_time if result.execution_time is not none else 'null' }},
                {{ response.get('rows_affected', 'null') if response.get('rows_affected', none) is not none else 'null' }},
                {{ sql_literal(result.message) }}
            {% if not loop.last %}
            union all
            {% endif %}
        {% endfor %}
    {%- endif -%}
{% endmacro %}
