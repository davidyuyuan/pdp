CREATE VIEW prj-int-dev-covid19-nf-gls.datahub_metadata.pathogen_analysis_storage
AS SELECT
  * EXCEPT(submitted_bytes),
  (
  SELECT
    SUM(PARSE_BIGNUMERIC(val))
  FROM
    UNNEST(SPLIT(submitted_bytes, ';')) AS val) AS storagge_size
FROM
  `prj-int-dev-covid19-nf-gls.datahub_metadata.pathogen_analysis`