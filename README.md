# DIY Knowledge Base (Scryer Prolog)

Personal, manually edited knowledge base for DIY projects, ideas, skills, tools, materials, and repair knowledge.

## Files

- `diy_kb.pl`: core facts, helper query predicates, integrity checks
- `diy_kb_tests.pl`: lightweight test runner

## Requirements

- [Scryer Prolog](https://github.com/mthom/scryer-prolog)

## Run

Load the knowledge base:

```bash
scryer-prolog diy_kb.pl
```

Run tests:

```bash
scryer-prolog diy_kb_tests.pl --goal "run_tests,halt"
```

Quick validity check:

```bash
scryer-prolog diy_kb.pl --goal halt
```

## Example Queries

In Scryer REPL:

```prolog
?- active_project(P).
?- blocked_project(P, Reason).
?- project_missing_tools(fix_table_lamp_switch, Missing).
?- project_missing_skills(fix_table_lamp_switch, Missing).
?- next_project(P).
?- ideas_by_tag(energy, Idea).
?- knowledge_for_skill(electrical_diagnostics, K).
?- repair_candidate(P).
?- kb_consistent.
```

## Editing the KB

Add or modify facts in `diy_kb.pl`:

- entities: `project/1`, `idea/1`, `skill/1`, `knowledge/1`, `tool/1`, `material/1`, `issue/1`
- properties: `title/2`, `status/2`, `priority/2`, `tag/2`
- relations: `requires_tool/2`, `requires_skill/2`, `uses_material/2`, `has_issue/2`, `fix_path/2`
- ownership: `owned_tool/1`, `owned_skill/1`

After editing, rerun tests to confirm consistency.
