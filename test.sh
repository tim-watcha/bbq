#!/usr/bin/env bash
set -euo pipefail

# test.sh: Automated tests for bbq
# Tests only the wrapper logic — never sends dangerous commands to real bq.

BBQ="./bbq"
PASS=0
FAIL=0

# Verify bbq does NOT print its own block message (command passes through to bq,
# even if bq itself returns non-zero).
assert_not_blocked() {
  local description="$1"
  shift
  local output
  output=$("$BBQ" "$@" 2>&1 || true)
  if echo "$output" | grep -q "bbq blocked"; then
    echo "FAIL (bbq blocked):  $description"
    FAIL=$((FAIL + 1))
  else
    echo "PASS (not blocked):  $description"
    PASS=$((PASS + 1))
  fi
}

assert_blocked() {
  local description="$1"
  shift
  if "$BBQ" "$@" >/dev/null 2>&1; then
    echo "FAIL (should block): $description"
    FAIL=$((FAIL + 1))
  else
    echo "PASS (blocked):      $description"
    PASS=$((PASS + 1))
  fi
}

assert_allowed() {
  local description="$1"
  shift
  if "$BBQ" "$@" >/dev/null 2>&1; then
    echo "PASS (allowed):      $description"
    PASS=$((PASS + 1))
  else
    echo "FAIL (should allow): $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== bbq test suite ==="
echo ""

# --- Blocked subcommands ---
echo "## Blocked subcommands"
assert_blocked "rm"                            rm test_dataset
assert_blocked "truncate"                      truncate test_dataset.table
assert_blocked "update"                        update test_dataset
assert_blocked "insert"                        insert test_dataset.table
assert_blocked "load"                          load test_dataset.table file.csv
assert_blocked "cp"                            cp src_table dst_table
assert_blocked "cancel"                        cancel job_id_123
assert_blocked "partition"                     partition src_table dst_table
assert_blocked "shell"                         shell
assert_blocked "undelete"                      undelete test_dataset.table
assert_blocked "add-iam-policy-binding"        add-iam-policy-binding --member=user:x --role=roles/y table1
assert_blocked "remove-iam-policy-binding"     remove-iam-policy-binding --member=user:x --role=roles/y table1
assert_blocked "set-iam-policy"                set-iam-policy table1 policy.json
echo ""

# --- Blocked SQL keywords ---
echo "## Blocked SQL in query"
assert_blocked "DROP TABLE"                    query 'DROP TABLE test'
assert_blocked "INSERT INTO"                   query 'INSERT INTO t VALUES (1)'
assert_blocked "DELETE FROM"                   query 'DELETE FROM t WHERE 1=1'
assert_blocked "UPDATE SET"                    query 'UPDATE t SET x=1'
assert_blocked "ALTER TABLE"                   query 'ALTER TABLE t ADD COLUMN x INT64'
assert_blocked "TRUNCATE TABLE"                query 'TRUNCATE TABLE t'
assert_blocked "MERGE INTO"                    query 'MERGE INTO t USING s ON t.id=s.id WHEN MATCHED THEN UPDATE SET x=1'
assert_blocked "CREATE TABLE"                  query 'CREATE TABLE t (x INT64)'
assert_blocked "CALL procedure"                query 'CALL my_procedure()'
assert_blocked "GRANT"                         query 'GRANT roles/bigquery.dataViewer ON TABLE t TO "user:x"'
assert_blocked "REVOKE"                        query 'REVOKE roles/bigquery.dataViewer ON TABLE t FROM "user:x"'
assert_blocked "EXECUTE IMMEDIATE"             query "EXECUTE IMMEDIATE 'DROP TABLE t'"
assert_blocked "leading whitespace + DROP"     query '  DROP TABLE test'
assert_blocked "semicolon multi-statement"     query 'SELECT 1; DROP TABLE t'
echo ""

# --- Blocked write flags ---
echo "## Blocked write-related query flags"
assert_blocked "--destination_table"           query --destination_table=d.t 'SELECT 1'
assert_blocked "--destination_table (space)"   query --destination_table d.t 'SELECT 1'
assert_blocked "--replace"                     query --replace 'SELECT 1'
assert_blocked "--append_table"                query --append_table 'SELECT 1'
assert_blocked "--schedule"                    query --schedule='every 24 hours' 'SELECT 1'
assert_blocked "--target_dataset"              query --target_dataset=my_ds 'SELECT 1'
assert_blocked "--destination_kms_key"         query --destination_kms_key=key 'SELECT 1'
assert_blocked "--clustering_fields"           query --clustering_fields=col1 'SELECT 1'
assert_blocked "--time_partitioning_field"     query --time_partitioning_field=ts 'SELECT 1'
assert_blocked "--time_partitioning_type"      query --time_partitioning_type=DAY 'SELECT 1'
assert_blocked "--time_partitioning_expiration" query --time_partitioning_expiration=86400 'SELECT 1'
echo ""

# --- Allowed subcommands ---
echo "## Allowed subcommands"
assert_not_blocked "ls"                        ls
assert_not_blocked "version"                   version
# bq help exits with code 1 (bq behavior, not bbq blocking), so we verify
# bbq does NOT print its own block message
assert_not_blocked "help"                      help
echo ""

# --- Allowed queries ---
echo "## Allowed queries"
assert_not_blocked "SELECT 1"                  query --nouse_legacy_sql 'SELECT 1'
assert_not_blocked "WITH CTE"                  query --nouse_legacy_sql 'WITH cte AS (SELECT 1 AS x) SELECT * FROM cte'
assert_not_blocked "select lowercase"          query --nouse_legacy_sql 'select 1'
# bq may fail with invalid project, but bbq should not block it
assert_not_blocked "SELECT with --project_id"  query --nouse_legacy_sql --project_id=my-project 'SELECT 1'
echo ""

# --- Summary ---
echo "=== Results ==="
echo "PASS: $PASS"
echo "FAIL: $FAIL"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
echo "All tests passed!"
