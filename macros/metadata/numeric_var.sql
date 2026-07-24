{% macro numeric_var(name, default_sql=none, required=false) -%}
    {%- set value = var(name, none) -%}
    {%- if value is none -%}
        {%- if required -%}
            {{ exceptions.raise_compiler_error("Missing required numeric dbt variable '" ~ name ~ "'.") }}
        {%- elif default_sql is none -%}
            {{ return('null') }}
        {%- else -%}
            {{ return(default_sql) }}
        {%- endif -%}
    {%- endif -%}
    {{ return(value | as_number) }}
{%- endmacro %}

{% macro require_incremental_lineage() -%}
    {%- if is_incremental() and var('source_lineage_id', none) is none -%}
        {{ exceptions.raise_compiler_error(
            "source_lineage_id is required for incremental PosJournal runs. "
            ~ "Use --full-refresh only for an intentional historical rebuild."
        ) }}
    {%- endif -%}
{%- endmacro %}
