#!/bin/bash

TZ=Asia/Israel && sudo docker compose up -d
echo "wating for containers will be ready"
sleep 60

echo "run step1"
step1="$(curl -sS -X PUT 'http://localhost:9200/signatures/' > tmp.html)"

echo "run step2"
step2="$(curl -sS -d "@elastic/signature-mapping.json" -H 'Content-Type: application/json' -X PUT 'http://localhost:9200/signatures/_mapping/' > tmp.html)"

echo "run step3"
step3="$(sudo python3 signatures/upload-signatures.py signatures/signatures-report.json localhost)" 
wait

echo "run step4"
step4="$(curl -sS -d "@elastic/template-mapping.json" -H 'Content-Type: application/json' -X PUT 'http://localhost:9200/_template/waf_template?include_type_name' > tmp.html)"

echo "run step5"
step5="$(curl -sS -d "@elastic/enrich-policy.json" -H 'Content-Type: application/json' -X PUT 'http://localhost:9200/_enrich/policy/signatures-policy' > tmp.html)"

echo "run step6"
step6="$(curl -sS -X POST 'http://localhost:9200/_enrich/policy/signatures-policy/_execute' > tmp.html)"

echo "run step7"
step7="$(curl -sS -d "@elastic/sig-lookup.json" -H 'Content-Type: application/json' -X PUT 'http://localhost:9200/_ingest/pipeline/sig_lookup' > tmp.html)"

echo "run step8"
step8="$(curl -sS -d "@grafana/DS-waf-index.json" -H 'Content-Type: application/json' -u 'admin:admin' -X POST 'http://localhost:3000/api/datasources/' > /dev/null)"

echo "run step9"
step9="$(curl -sS -d "@grafana/DS-waf-decoded-index.json" -H 'Content-Type: application/json' -u 'admin:admin' -X POST 'http://localhost:3000/api/datasources/' > /dev/null )"
