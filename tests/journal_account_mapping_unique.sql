select
    PositouchRecordedJournalAccountId,
    JournalAccountName,
    count(*) as MatchCount
from {{ source('dwr_reference', 'journal_account') }}
group by
    PositouchRecordedJournalAccountId,
    JournalAccountName
having count(*) > 1
