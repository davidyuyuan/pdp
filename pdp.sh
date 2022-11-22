#!/usr/bin/env bash

dataset_name=${1:-'datahub_metadata_dump'}
project_id=${2:-'prj-int-dev-covid19-nf-gls'}
location=${3:-'europe-west2'}
analysis_dump=${4:-'/nfs/production/tburdett/ena/test/data_file_dump/analysis_dump.tsv.gz'}
run_dump=${5:-'/nfs/production/tburdett/ena/test/data_file_dump/run_dump.tsv.gz'}

# DIR where the current script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create bucket and dataset
gsutil ls -p "${project_id}" "gs://${dataset_name}" || gsutil mb -p "${project_id}" -l "${location}" "gs://${dataset_name}"
bq --project_id="${project_id}" show "${dataset_name}" || bq --location="${location}" mk --dataset "${project_id}:${dataset_name}"

# Unzip input from the Oracle dump
output_dir="${DIR}/results"; mkdir -p "${output_dir}"

# run_dump
echo "Creating run_dump..."
cp -f "${run_dump}" "${output_dir}/run_dump.tsv.gz" && \
  gunzip -kf "${output_dir}/run_dump.tsv.gz" && \
  gsutil -m cp "${output_dir}/run_dump.tsv" "gs://${dataset_name}/run_dump.tsv" && \
  bq --project_id="${project_id}" load --source_format=CSV --replace=true --skip_leading_rows=1 --field_delimiter='\t' \
  --autodetect --max_bad_records=10 "${dataset_name}.run_dump" "gs://${dataset_name}/run_dump.tsv" \
  "run_accession:STRING,study_accession:STRING,submitted_bytes:INTEGER,scientific_name:STRING,last_updated:DATE,submitted_format:STRING,submitted_md5:STRING,submitted_path:STRING,data_file_role:STRING,submission_account_id:STRING,tax_id:STRING,run_first_created:DATE,fire_oid:STRING"

# analysis_dump
echo "Creating analysis_dump..."
cp -f "${analysis_dump}" "${output_dir}/analysis_dump.tsv.gz" && \
  gunzip -kf "${output_dir}/analysis_dump.tsv.gz" && \
  gsutil -m cp "${output_dir}/analysis_dump.tsv" "gs://${dataset_name}/analysis_dump.tsv" && \
  bq --project_id="${project_id}" load --source_format=CSV --replace=true --skip_leading_rows=1 --field_delimiter='\t' \
  --autodetect --max_bad_records=10 "${dataset_name}.analysis_dump" "gs://${dataset_name}/analysis_dump.tsv" \
  "analysis_accession:STRING,study_accession:STRING,submitted_bytes:INTEGER,analysis_type:STRING,scientific_name:STRING,last_updated:DATE,submitted_format:STRING,submitted_md5:STRING,submitted_path:STRING,data_file_role:STRING,submission_account_id:STRING,tax_id:STRING,analysis_sub_type:STRING,analysis_first_created:DATE,fire_oid:STRING"

# Unique?