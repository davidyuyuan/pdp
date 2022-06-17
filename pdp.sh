#!/usr/bin/env bash

dataset_name=${1:-'datahub_metadata'}
project_id=${2:-'prj-int-dev-covid19-nf-gls'}
location=${3:-'europe-west4'}

# DIR where the current script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

output_dir="${DIR}/results"; mkdir -p "${output_dir}"

# Create bucket and dataset
gsutil ls -p "${project_id}" "gs://${dataset_name}" || gsutil mb -p "${project_id}" -l "${location}" "gs://${dataset_name}"
bq --project_id="${project_id}" show "${dataset_name}" || bq --location="${location}" mk --dataset "${project_id}:${dataset_name}"

echo ""
echo "** Updating ${dataset_name}.all_analyses table. **"

# https://www.ebi.ac.uk/ena/portal/api/search?fields=all&result=analysis&limit=10&fields=all
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'result=analysis&fields=all&format=tsv&limit=10' \
  "https://www.ebi.ac.uk/ena/portal/api/search" > "${output_dir}/all_fields.tsv"
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d 'result=analysis&fields=analysis_accession%2Cstudy_accession%2Csubmitted_bytes%2Canalysis_type%2Csample_accession%2Crun_ref%2Cscientific_name%2Clast_updated%2Canalysis_date&format=tsv&limit=0' \
  "https://www.ebi.ac.uk/ena/portal/api/search" > "${output_dir}/all_analyses.tsv"
gsutil -m cp "${output_dir}/all_analyses.tsv" "gs://${dataset_name}/all_analyses.tsv" && \
  bq --project_id="${project_id}" load --source_format=CSV --replace=true --skip_leading_rows=1 --field_delimiter=tab \
  --autodetect --max_bad_records=0 "${dataset_name}.all_analyses" "gs://${dataset_name}/all_analyses.tsv" \
  "analysis_accession:STRING,study_accession:STRING,submitted_bytes:STRING,analysis_type:STRING,sample_accession:STRING,run_ref:STRING,scientific_name:STRING,last_updated:DATE,analysis_date:DATE"
