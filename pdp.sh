#!/usr/bin/env bash

dataset_name=${1:-'datahub_metadata_dump'}
project_id=${2:-'prj-int-dev-covid19-nf-gls'}
location=${3:-'europe-west2'}
analysis_dump=${4:-'/nfs/production/tburdett/ena/test/data_file_dump/analysis_dump.csv.gz'}
run_dump=${5:-'/nfs/production/tburdett/ena/test/data_file_dump/run_dump.csv.gz'}

# DIR where the current script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create bucket and dataset
gsutil ls -p "${project_id}" "gs://${dataset_name}" || gsutil mb -p "${project_id}" -l "${location}" "gs://${dataset_name}"
bq --project_id="${project_id}" show "${dataset_name}" || bq --location="${location}" mk --dataset "${project_id}:${dataset_name}"

# Unzip input from the Oracle dump
output_dir="${DIR}/results"; mkdir -p "${output_dir}"

# run_dump
echo "Creating run_dump..."
cp -f "${run_dump}" "${output_dir}/run_dump.csv.gz" && \
  gunzip -kf "${output_dir}/run_dump.csv.gz" && \
  gsutil -m cp "${output_dir}/run_dump.csv" "gs://${dataset_name}/run_dump.csv" && \
  bq --project_id="${project_id}" load --source_format=CSV --replace=true --skip_leading_rows=1 --field_delimiter=',' \
  --autodetect --max_bad_records=100 "${dataset_name}.run_dump" "gs://${dataset_name}/run_dump.csv"

# analysis_dump
echo "Creating analysis_dump..."
cp -f "${analysis_dump}" "${output_dir}/analysis_dump.csv.gz" && \
  gunzip -kf "${output_dir}/analysis_dump.csv.gz" && \
  gsutil -m cp "${output_dir}/analysis_dump.csv" "gs://${dataset_name}/analysis_dump.csv" && \
  bq --project_id="${project_id}" load --source_format=CSV --replace=true --skip_leading_rows=1 --field_delimiter=',' \
  --autodetect --max_bad_records=10 "${dataset_name}.analysis_dump" "gs://${dataset_name}/analysis_dump.csv"
