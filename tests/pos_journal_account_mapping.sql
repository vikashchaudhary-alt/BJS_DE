with expected as (
    select
        src.BusinessDate,
        src.SiteId,
        coalesce(jrn.JournalAccountId, -1) as JournalAccountId,
        src.Credit as CreditAmount,
        src.Debit as DebitAmount,
        src.LineageId as SourceLineageId
    from {{ source('src_posi', 'posi_journal') }} as src
    left join {{ source('dwr_reference', 'journal_account') }} as jrn
        on src.Acct_Posi = jrn.PositouchRecordedJournalAccountId
        and src.Acct_Name = jrn.JournalAccountName
    inner join {{ source('dwr_reference', 'site_business_date') }} as sb
        on src.BusinessDate = sb.BusinessDate
        and src.SiteId = sb.SiteId
    where src.CC_CODE = 'CC000'
        and (sb.IsOpenOnDayDate = 1 or src.SiteId = 589)
    {% if var('source_lineage_id', none) is not none %}
        and src.LineageId = {{ numeric_var('source_lineage_id', required=true) }}
    {% endif %}
),

actual as (
    select
        BusinessDate,
        SiteId,
        JournalAccountId,
        CreditAmount,
        DebitAmount,
        SourceLineageId
    from {{ ref('pos_journal') }}
    {% if var('source_lineage_id', none) is not none %}
        where SourceLineageId = {{ numeric_var('source_lineage_id', required=true) }}
    {% endif %}
),

missing_or_changed as (
    select * from expected
    minus
    select * from actual
),

unexpected as (
    select * from actual
    minus
    select * from expected
)

select * from missing_or_changed
union all
select * from unexpected
