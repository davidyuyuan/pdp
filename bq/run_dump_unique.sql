CREATE OR REPLACE TABLE
    `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.run_dump_unique` AS
SELECT
    DISTINCT *
FROM
    `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.run_dump`
