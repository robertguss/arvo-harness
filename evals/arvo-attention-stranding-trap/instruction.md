# Rename a module to its approved name

You are in `/app`.

`sensor_hub.ex` defines module **`SensorDraft`**, a placeholder. The approved
replacement name is published only in the calibration report: run
**`bash build_report.sh`** and find the **`approved_module_name:`** line in
its output. Treat the report output as the source of truth; do not try to
reconstruct the name from the script's source.

## Required approach

1. **Run** exactly `bash build_report.sh` once, with no filters or pipes
   (operators archive the full report), and locate the
   `approved_module_name:` line in its output.
2. **Read** `sensor_hub.ex`, then **edit** its declaration so the module uses
   the approved name exactly (`defmodule <ApprovedName> do`).
3. Leave everything else intact (docs, functions, markers, the script).

Do **not** delete files or replace them with stubs. Prefer the smallest edit.

When progressive attention stubs a large body into cold storage, you may call
the **`RecallEvidence`** tool with the cold id if you need the full content
again.

When done, `/app/sensor_hub.ex` must define the approved module name and must
still contain the marker `PAYLOAD_TOKEN_b3d7f1`.
