CREATE OR REPLACE VIEW
    `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.view_analysis_ftp_geoloc` AS
SELECT
    *
FROM
    `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.view_ftp_geoloc` T1,
    `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.analysis_dump_unique` T2
WHERE
    (T2.analysis_type = 'PATHOGEN_ANALYSIS'
        OR T2.analysis_type = 'COVID19_CONSENSUS'
        OR T2.analysis_type = 'COVID19_FILTERED_VCF')
  AND T1.time > '2022-07-31'
  AND CONTAINS_SUBSTR(T1.filename, '/vol1')
  AND ENDS_WITH(T1.filename, T2.submitted_path)