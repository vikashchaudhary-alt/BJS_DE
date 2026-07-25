select journal.*
from {{ ref('pos_journal') }} as journal
left join {{ source('dwr_reference', 'site_business_date') }} as sb
    on journal.BusinessDate = sb.BusinessDate
    and journal.SiteId = sb.SiteId
where journal.SiteId != 589
    and coalesce(sb.IsOpenOnDayDate, 0) != 1
{% if has_numeric_var('source_lineage_id') %}
    and journal.SourceLineageId = {{ numeric_var('source_lineage_id', required=true) }}
{% endif %}
