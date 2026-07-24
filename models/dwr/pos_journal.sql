{{
    config(
        alias='POSJOURNAL',
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key=['BusinessDate', 'SiteId'],
        tmp_relation_type='table',
        on_schema_change='fail'
    )
}}

{{ require_incremental_lineage() }}

with source_journal as (
    select
        src.BusinessDate,
        src.SiteId,
        src.Acct_Posi,
        src.Acct_Name,
        src.Credit,
        src.Debit,
        src.LineageId as SourceLineageId,
        src.LoadId as SourceLoadId
    from {{ source('src_posi', 'posi_journal') }} as src
    where src.CC_CODE = 'CC000'
    {% if var('source_lineage_id', none) is not none %}
        and src.LineageId = {{ numeric_var('source_lineage_id', required=true) }}
    {% endif %}
),

transformed as (
    select
        src.BusinessDate,
        src.SiteId,
        coalesce(jrn.JournalAccountId, -1) as JournalAccountId,
        src.Credit as CreditAmount,
        src.Debit as DebitAmount,
        src.SourceLineageId,
        {{ numeric_var('lineage_id', 'src.SourceLineageId') }} as LineageId,
        {{ numeric_var('load_id', 'src.SourceLoadId') }} as LoadId,
        {{ numeric_var('loop_id', '-1') }} as LoopId,
        {{ numeric_var('run_id', '-1') }} as RunId,
        {{ numeric_var('procedure_id', '-1') }} as ProcedureId,
        '{{ invocation_id }}' as DbtInvocationId,
        to_timestamp_tz('{{ run_started_at.isoformat() }}') as DbtRunStartedAt,
        to_timestamp_ntz('{{ run_started_at.isoformat() }}') as InsertDateTime,
        to_timestamp_ntz('{{ run_started_at.isoformat() }}') as UpdateDateTime
    from source_journal as src
    left join {{ source('dwr_reference', 'journal_account') }} as jrn
        on src.Acct_Posi = jrn.PositouchRecordedJournalAccountId
        and src.Acct_Name = jrn.JournalAccountName
    inner join {{ source('dwr_reference', 'site_business_date') }} as sb
        on src.BusinessDate = sb.BusinessDate
        and src.SiteId = sb.SiteId
    where sb.IsOpenOnDayDate = 1
        or src.SiteId = 589
)

select *
from transformed
