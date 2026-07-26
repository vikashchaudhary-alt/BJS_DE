{% macro has_numeric_var(name) -%}
    {%- set value = var(name, none) -%}
    {%- set normalized = value | string | trim | lower -%}
    {{ return(value is not none and normalized not in ['', 'none', 'null']) }}
{%- endmacro %}

{% macro numeric_var(name, default_sql=none, required=false) -%}
    {%- set value = var(name, none) -%}
    {%- if not has_numeric_var(name) -%}
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
    {%- if is_incremental() and not has_numeric_var('source_lineage_id') -%}
        {{ exceptions.raise_compiler_error(
            "source_lineage_id is required for incremental PosJournal runs. "
            ~ "Use --full-refresh only for an intentional historical rebuild."
        ) }}
    {%- endif -%}
{%- endmacro %}
