CREATE OR REPLACE TABLE
    `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.aspera_logs_unique` AS
SELECT
    DISTINCT *
FROM
    `prj-int-dev-transfer-logs.ebi_transfer_logs.aspera_logs`
