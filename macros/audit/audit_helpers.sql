{% macro audit_relation() -%}
    {{ return(api.Relation.create(
        database=(env_var('DBT_ENVIRONMENT') | upper) ~ '_SILVER',
        schema='AUDIT',
        identifier='MODEL_RUN_AUDIT'
    )) }}
{%- endmacro %}

{% macro sql_literal(value) -%}
    {%- if value is none -%}
        {{ return('null') }}
    {%- endif -%}
    {{ return("'" ~ (value | string | replace("'", "''")) ~ "'") }}
{%- endmacro %}

{% macro audit_numeric_var(name) -%}
    {%- set value = var(name, none) -%}
    {%- if value is none -%}
        {{ return('null') }}
    {%- endif -%}
    {{ return(value | as_number) }}
{%- endmacro %}
