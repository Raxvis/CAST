<!-- TEMPLATE INSTRUCTIONS
  FILE: docs/BACKEND.md
  PURPOSE: Backend-specific reference material for AI coding assistants. Covers
  patterns, pitfalls, and conventions for API servers, gRPC services, background
  workers, scheduled job runners, and data pipelines.

  RELEVANCE:
  - Keep this file for projects that expose an HTTP/gRPC API, run background
    workers, process message queues, or move data between systems.
  - Delete this file for pure frontend projects (use docs/FRONTEND.md instead).
  - Delete this file for pure CLI tools (use docs/CLI.md instead).
  - If your project spans both a user interface and a backend, keep this file
    alongside docs/FRONTEND.md.

  HOW TO CUSTOMIZE:
  - Replace every [PLACEHOLDER] token with project-specific values.
  - See README.md for the full placeholder reference table.
  - Delete sections that do not apply (e.g., Background Work for a pure
    request/response service with no async jobs).
  - Add your own backend patterns under the relevant section as they emerge.
  - This comment block is stripped automatically by /cast-init at install.
-->

<!-- Placeholders — see README.md → Placeholder Reference -->

# [PROJECT_NAME] — Backend Patterns

## Scope

"Backend" here means any code that runs without a direct user interface: HTTP
and gRPC API servers, message-queue workers, scheduled jobs, background job
runners, and data pipelines. This document covers conventions that apply to
all of them. If [PROJECT_NAME] has a user-facing interface, read
`docs/FRONTEND.md` as well — frontend and backend concerns overlap at the
request boundary and both documents apply.

Universal conventions (naming, module layout, style) live in
`docs/CODE_PATTERNS.md`. This file only covers backend-specific guidance.

---

## Request / Response Boundaries

Validate every input at the process boundary. Never trust a request payload,
queue message, or pipeline record until it has been parsed into a typed value.

- Use a schema validator or type guard at the entry point of each handler.
- Reject invalid input with a structured error before any business logic runs.
- Serialize outputs through a typed response shape — never return raw database
  rows or internal objects directly.
- Keep the validated request type distinct from the internal domain type.
  Transform once at the boundary; downstream code sees only domain types.

```[LANGUAGE]
// [CreateItemHandler].[ext]
interface [CreateItemRequest] {
  [name]: string;
  [quantity]: number;
}

interface [CreateItemResponse] {
  [id]: string;
  [createdAt]: string;
}

export async function [handleCreateItem](
  [rawInput]: unknown,
  [ctx]: [RequestContext]
): Promise<[CreateItemResponse]> {
  const [input] = [parseCreateItemRequest]([rawInput]);  // throws on invalid
  const [item] = await [itemService].[create]([input], [ctx].[userId]);
  return { [id]: [item].[id], [createdAt]: [item].[createdAt].toISOString() };
}
```

---

## Database and Persistence

Data access goes through [PERSISTENCE_LAYER]. The following rules apply
regardless of which specific library or driver wraps it.

- **Connection pooling.** One pool per process. Never open a connection per
  request. Size the pool based on expected concurrency, not peak load.
- **Transaction boundaries.** A transaction wraps one logical unit of work.
  Open, commit, or roll back in the same function that started it. Do not
  pass open transactions across service boundaries.
- **N+1 queries.** Load related data in a single query or an explicit batch.
  If you see a loop with a query inside it, that is a bug.
- **Migrations.** Every schema change is a numbered, reviewed migration.
  Migrations must be idempotent and reversible where possible. Never mutate
  the schema from application code at runtime.
- **Reads vs writes.** If the project uses read replicas, route read-only
  queries to the replica and writes to the primary. Mixing them in one
  request causes replication-lag bugs that only show up under load.
- **Prepared statements / parameterized queries.** Always. String
  interpolation into SQL is forbidden.

```[LANGUAGE]
// [ItemRepository].[ext]
export async function [findItemsByOwner](
  [db]: [DbHandle],
  [ownerId]: string,
  [limit]: number
): Promise<[Item][]> {
  const [rows] = await [db].[query](
    'SELECT [id], [name], [owner_id], [created_at] ' +
    'FROM [items] WHERE [owner_id] = $1 ORDER BY [created_at] DESC LIMIT $2',
    [[ownerId], [limit]]
  );
  return [rows].map([toItem]);
}
```

---

## Error Handling and HTTP Status Codes

Every backend response, error or success, has a predictable shape. Clients
must be able to distinguish categories without parsing error messages.

Standard status code semantics:

| Code | Meaning |
|------|---------|
| 200  | Success — resource returned or action completed |
| 201  | Created — new resource; response includes its identifier |
| 400  | Bad request — malformed input, fails schema validation |
| 401  | Unauthenticated — no valid credentials provided |
| 403  | Forbidden — authenticated but not allowed to perform this action |
| 404  | Not found — resource does not exist or caller cannot see it |
| 409  | Conflict — request collides with current state (e.g., duplicate key) |
| 422  | Unprocessable — syntactically valid but semantically rejected |
| 500  | Server error — unhandled failure; always logged with a correlation ID |

Rules:

- Error responses use a consistent shape: `{ error: { code, message } }` or
  the project equivalent. Pick one and enforce it in a single serializer.
- Never leak stack traces, SQL, or internal paths to clients. Those belong
  in the internal log only, keyed by correlation ID.
- Catch unexpected errors at one outer boundary (middleware or the framework
  error handler). Do not sprinkle try/catch throughout business logic.
- Distinguish expected errors (validation, auth, not found) from unexpected
  errors (a panic, a broken dependency). Only the latter should page anyone.

See `docs/ERROR_HANDLING.md` for the project-wide error category taxonomy.

---

## Authentication and Authorization

Authentication answers "who are you?" Authorization answers "are you allowed
to do this?" They are different checks and they live in different places.

- **Authenticate at the edge.** Parse the token, session, or API key in
  middleware. By the time a handler runs, the caller's identity is already
  attached to the request context or the request is rejected.
- **Authorize inside the handler** — or in a thin layer just above it.
  Ownership and permission checks need the resource in hand, so they cannot
  always run as pure middleware.
- **Never trust client-supplied identifiers for ownership.** A request that
  says "update item X" must verify the authenticated caller owns item X
  before the update runs. Missing this check is a common critical bug.
- **Token validation** happens on every request. Do not cache validation
  results across requests in a way that outlives token revocation.
- **Sessions** (if used) must be server-validated, not just client-presented.
  A signed cookie is not enough — revocation needs a server-side check.

Do not hard-code the auth scheme into business logic. Handlers receive an
already-authenticated `[RequestContext]` and call `[ctx].[authorize]([resource], [action])`.

---

## Middleware and Pipelines

Middleware order is load-bearing. The canonical order for a request-handling
pipeline:

1. **Request ID / correlation ID** — assign before anything else can log
2. **Authentication** — reject unknown callers early
3. **Rate limiting** — after auth so limits are per-identity
4. **Input validation / parsing** — reject malformed payloads
5. **Handler** — the actual business logic
6. **Response serialization** — enforce the output schema
7. **Logging / metrics** — record outcome and duration

Rules:

- Middleware must be free of side effects on external systems. Logging and
  metrics are fine; writing to the database from middleware is not.
- An idempotent request must remain idempotent under retries. If middleware
  generates identifiers or timestamps, it must do so deterministically per
  request, not per middleware invocation.
- Do not swallow errors in middleware. Propagate to the outer error handler.

---

## Observability

Every running backend process emits three streams: **logs**, **metrics**, and
(optionally) **traces**. All three are keyed by a correlation ID so a single
request can be reconstructed across services.

- **Structured logging.** Every log line is a key/value record, not a
  free-form string. At minimum: timestamp, level, correlation ID, event name.
- **Correlation IDs** flow from the edge through every downstream call,
  including database queries, queue messages, and outbound HTTP. Pass them
  explicitly in the request context.
- **Metrics** cover request rate, error rate, and latency percentiles per
  endpoint. Watch p95 and p99, not averages.
- **Startup and memory budgets.** Cold start time stays under `[STARTUP_METRIC]`
  and resident memory stays under `[MEMORY_METRIC]`. Regressions are reviewed
  before merge.
- **Traces** (if enabled) span the full request including database and
  downstream calls, with one span per logical unit of work.

---

## Background Work and Jobs

Not every unit of work belongs in a request handler. Use an async job when:

- The work takes longer than the request budget allows
- The work must survive the caller disconnecting
- The work needs to be retried on failure
- The work is triggered by a schedule rather than a user action

Rules for job handlers:

- **Idempotent by construction.** Running a job twice must produce the same
  result as running it once. Use a deduplication key or check-then-act with
  a unique constraint.
- **Bounded retries with backoff.** Exponential backoff with a ceiling.
  Never retry forever.
- **Dead-letter queue.** After the retry budget is exhausted, move the job
  to a DLQ for inspection, not silent drop.
- **Enqueue after commit.** If a job is enqueued inside a database
  transaction, enqueue it only after the transaction commits successfully,
  otherwise a rolled-back transaction leaves a ghost job.
- **No hidden dependencies on request context.** Jobs run in a separate
  process with a separate context. Everything the job needs is in the
  job payload or loaded from persistent storage.

---

## Common Pitfalls

Backend-specific traps that recur across projects:

- **String concatenation into SQL.** Any query built by concatenating user
  input is a SQL injection. Always use parameterized queries.
- **Connection and cursor leaks.** An unclosed transaction or cursor holds a
  connection until the pool is exhausted. Use `finally` or a scoped helper
  so cleanup runs on every code path, including error paths.
- **Catching errors and returning 200.** Swallowing an exception to avoid a
  500 hides real failures from monitoring. Let errors propagate to the
  outer handler, which logs and returns the correct status.
- **Read-then-write races.** Reading a value, computing a new one, and
  writing it back in two statements is a race. Use `UPDATE ... WHERE` with
  the old value, a transaction with proper isolation, or a database-level
  atomic operation.
- **Trusting request-supplied IDs.** A request that says "delete order 42"
  must verify the authenticated caller owns order 42 before deleting.
  Missing ownership checks are one of the most common critical bugs.
- **N+1 queries hidden behind helpers.** A `getItemsForUsers` function that
  loops over users calling `getItem` once each is an N+1. Batch at the
  repository layer.
- **Timezone-naive timestamps.** Store UTC. Convert to local time only at
  the presentation boundary. A `DATETIME` column without a timezone is a
  latent bug.
- **Logging request bodies wholesale.** Request bodies contain passwords,
  tokens, and personal data. Log the minimum structured fields needed to
  reconstruct a failure, never the raw payload.

---

## Cross-References

- `docs/CODE_PATTERNS.md` — universal naming, module layout, and style conventions
- `docs/ERROR_HANDLING.md` — project-wide error category taxonomy and logging rules
- `artifacts/architecture/` — active architecture documents, including per-milestone
  service and data-schema designs

---

_Last updated: [YYYY-MM-DD]_
