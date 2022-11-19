CREATE VIEW `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.view_run_aspera`
AS SELECT
    *
FROM
    `prj-int-dev-transfer-logs.ebi_transfer_logs.aspera_logs` T1,
    `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.run_dump` T2
WHERE
    ENDS_WITH(T1.filename, T2.submitted_path)