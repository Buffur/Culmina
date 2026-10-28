# Project skill behavior checks

These six representative prompts test skill selection, source use, task boundaries
and truthful reporting. They are review tasks with positive, near-miss and negative
cases. They do not establish that a skill can complete every implementation task.
The Flutter widget test named `skill_application_test.dart` tests UI composition;
it is not a substitute for these agent checks.

## Run a case

Use a fresh agent context with the current project AGENTS, skill catalog and
repository access. Give it only one case's `prompt` from [cases.json](cases.json).
Do not supply the expected skill lists, success criteria, previous conclusions or
this audit's suggested answer. Respect the prompt's read-only constraints. For the
negative prose case, no repository/tool access is needed. Use subagents only when
the current task authorizes delegation; otherwise run the same prompt in an
independent evaluation context or ask a reviewer to do so.

Record the model/context, date, source revision and relevant working-tree state,
the exact prompt, skills actually loaded, inspected sources, tools run, output and
any file mutations. Keep generated transcripts/results under ignored
`build/skill-evals/<run>/`; do not copy account details or credentials.

## Review the actual trace

Compare the trace and answer with `success` and `forbidden`. The `consider_skills`
list identifies relevant capabilities; additional supporting skills can be correct
when justified by the request. `avoid_skills` catches common scope expansion, not
an immutable global routing rule. Judge what the agent actually did, not whether
its final answer contains a skill name or predetermined phrase.

Use `pass`, `fail` or `not_run` for each case. A pass needs observable evidence for
the success criteria and no forbidden action. Missing traces or unavailable tools
are limitations, not passes. Report executed cases separately from the size of the
catalog. Review results manually; the CI instruction validator checks structure
and links, not agent behavior. Rerun affected cases after a demonstrated routing
failure or meaningful change to their skill, rather than adding universal rules
for every one-off observation.

For a future implementation evaluation, add an isolated disposable fixture and
observable behavioral assertions before granting write access. This review-only
suite deliberately does not mutate the real application or spend API credits in
CI.
