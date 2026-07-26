with expected as (
    select
        count(*) as RowCount,
        coalesce(sum(src.Credit), 0) as CreditAmount,
        coalesce(sum(src.Debit), 0) as DebitAmount
    from {{ source('src_posi', 'posi_journal') }} as src
    inner join {{ source('dwr_reference', 'site_business_date') }} as sb
        on src.BusinessDate = sb.BusinessDate
        and src.SiteId = sb.SiteId
    where src.CC_CODE = 'CC000'
        and (sb.IsOpenOnDayDate = 1 or src.SiteId = 589)
    {% if has_numeric_var('source_lineage_id') %}
        and src.LineageId = {{ numeric_var('source_lineage_id', required=true) }}
    {% endif %}
),

actual as (
    select
        count(*) as RowCount,
        coalesce(sum(CreditAmount), 0) as CreditAmount,
        coalesce(sum(DebitAmount), 0) as DebitAmount
    from {{ ref('pos_journal') }}
    {% if has_numeric_var('source_lineage_id') %}
        where SourceLineageId = {{ numeric_var('source_lineage_id', required=true) }}
    {% endif %}
)

select
    expected.RowCount as ExpectedRowCount,
    actual.RowCount as ActualRowCount,
    expected.CreditAmount as ExpectedCreditAmount,
    actual.CreditAmount as ActualCreditAmount,
    expected.DebitAmount as ExpectedDebitAmount,
    actual.DebitAmount as ActualDebitAmount
from expected
cross join actual
where expected.RowCount != actual.RowCount
    or expected.CreditAmount != actual.CreditAmount
    or expected.DebitAmount != actual.DebitAmount
