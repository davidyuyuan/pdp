CREATE VIEW prj-int-dev-covid19-nf-gls.datahub_metadata.all_analyses_storage
AS SELECT
  * EXCEPT(submitted_bytes,
    scientific_name),
  IFNULL(scientific_name, 'TBD') AS scientific_name,
  (
  SELECT
    SUM(PARSE_BIGNUMERIC(val))
  FROM
    UNNEST(SPLIT(submitted_bytes, ';')) AS val) AS storage_size
FROM
  `prj-int-dev-covid19-nf-gls.datahub_metadata.all_analyses`