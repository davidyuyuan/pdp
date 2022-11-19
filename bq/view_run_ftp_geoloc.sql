CREATE VIEW `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.view_run_ftp_geoloc`
AS SELECT
    * EXCEPT(network_bin,
    mask),
FROM (
         SELECT
             *,
             NET.SAFE_IP_FROM_STRING(ip) & NET.IP_NET_MASK(4,
                                                           mask) AS network_bin
         FROM
             `prj-int-dev-covid19-nf-gls.datahub_metadata_dump.view_run_ftp` AS T1,
             UNNEST(GENERATE_ARRAY(9,32)) AS mask
         WHERE
             ip IS NOT NULL
           AND BYTE_LENGTH(NET.SAFE_IP_FROM_STRING(ip)) = 4 )
         JOIN
     `prj-int-dev-transfer-logs.geoip.201806_geolite2_city_ipv4_locs` AS T2
     USING
         (network_bin,
          mask)
WHERE
    city_name IS NOT null