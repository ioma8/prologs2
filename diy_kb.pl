:- module(diy_kb, [
    active_project/1,
    blocked_project/2,
    project_missing_tools/2,
    project_missing_skills/2,
    next_project/1,
    ideas_by_tag/2,
    knowledge_for_skill/2,
    repair_candidate/1,
    kb_consistent/0
]).

:- set_prolog_flag(double_quotes, chars).

% === Entity declarations ===
project(workbench_rebuild).
project(fix_table_lamp_switch).
project(garage_shelf_upgrade).

idea(solar_powered_vent).
idea(portable_solder_station).

skill(soldering).
skill(woodworking).
skill(electrical_diagnostics).
skill(d3_printing).

knowledge(lamp_switch_wiring_basics).
knowledge(pegboard_weight_distribution).
knowledge(li_ion_safety_notes).

tool(multimeter).
tool(soldering_iron).
tool(drill).
tool(hand_saw).
tool(clamps).

material(plywood).
material(wood_screws).
material(heat_shrink_tube).
material(replacement_switch).

issue(table_lamp_intermittent_power).
issue(workbench_surface_warping).

% === Core properties ===
title(workbench_rebuild, "Rebuild workbench top").
title(fix_table_lamp_switch, "Repair table lamp switch").
title(garage_shelf_upgrade, "Reinforce garage shelf").
title(solar_powered_vent, "Window vent with solar fan").
title(portable_solder_station, "Battery-powered solder station").

status(workbench_rebuild, active).
status(fix_table_lamp_switch, planned).
status(garage_shelf_upgrade, blocked).
status(solar_powered_vent, idea).
status(portable_solder_station, idea).

priority(workbench_rebuild, high).
priority(fix_table_lamp_switch, high).
priority(garage_shelf_upgrade, medium).
priority(solar_powered_vent, low).
priority(portable_solder_station, medium).

tag(workbench_rebuild, woodworking).
tag(workbench_rebuild, workshop).
tag(fix_table_lamp_switch, repair).
tag(fix_table_lamp_switch, electrical).
tag(garage_shelf_upgrade, storage).
tag(solar_powered_vent, energy).
tag(portable_solder_station, electronics).

requires_tool(workbench_rebuild, drill).
requires_tool(workbench_rebuild, clamps).
requires_tool(fix_table_lamp_switch, soldering_iron).
requires_tool(fix_table_lamp_switch, multimeter).
requires_tool(garage_shelf_upgrade, drill).
requires_tool(garage_shelf_upgrade, clamps).

requires_skill(workbench_rebuild, woodworking).
requires_skill(fix_table_lamp_switch, soldering).
requires_skill(fix_table_lamp_switch, electrical_diagnostics).
requires_skill(garage_shelf_upgrade, woodworking).

uses_material(workbench_rebuild, plywood).
uses_material(workbench_rebuild, wood_screws).
uses_material(fix_table_lamp_switch, replacement_switch).
uses_material(fix_table_lamp_switch, heat_shrink_tube).
uses_material(garage_shelf_upgrade, plywood).
uses_material(garage_shelf_upgrade, wood_screws).

learned_from(lamp_switch_wiring_basics, "Old desk lamp teardown").
learned_from(pegboard_weight_distribution, "Garage retrofit notes").
learned_from(li_ion_safety_notes, "Battery safety handbook").

note(workbench_rebuild, "Need to seal top after sanding").
note(fix_table_lamp_switch, "Verify continuity before reassembly").
note(garage_shelf_upgrade, "Current anchors feel loose").

blocked_by(garage_shelf_upgrade, missing_heavy_duty_anchors).

has_issue(fix_table_lamp_switch, table_lamp_intermittent_power).
has_issue(workbench_rebuild, workbench_surface_warping).

fix_path(table_lamp_intermittent_power, lamp_switch_wiring_basics).

owned_tool(multimeter).
owned_tool(drill).
owned_tool(clamps).

owned_skill(woodworking).
owned_skill(electrical_diagnostics).

% === Validation domains ===
valid_status(idea).
valid_status(planned).
valid_status(active).
valid_status(blocked).
valid_status(done).

valid_priority(low).
valid_priority(medium).
valid_priority(high).

% === Query helpers ===
active_project(Project) :-
    project(Project),
    status(Project, active).

blocked_project(Project, Reason) :-
    project(Project),
    status(Project, blocked),
    blocked_by(Project, Reason).

project_missing_tools(Project, MissingTools) :-
    project(Project),
    findall(
        Tool,
        (requires_tool(Project, Tool), \+ owned_tool(Tool)),
        Tools0
    ),
    sort(Tools0, MissingTools).

project_missing_skills(Project, MissingSkills) :-
    project(Project),
    findall(
        Skill,
        (requires_skill(Project, Skill), \+ owned_skill(Skill)),
        Skills0
    ),
    sort(Skills0, MissingSkills).

actionable_project(Project) :-
    project(Project),
    status(Project, Status),
    (Status = active ; Status = planned),
    project_missing_tools(Project, []),
    project_missing_skills(Project, []).

priority_rank(high, 3).
priority_rank(medium, 2).
priority_rank(low, 1).

next_project(Project) :-
    actionable_project(Project),
    priority(Project, Priority),
    priority_rank(Priority, Rank),
    \+ (
        actionable_project(Other),
        Other \= Project,
        priority(Other, OtherPriority),
        priority_rank(OtherPriority, OtherRank),
        OtherRank > Rank
    ).

ideas_by_tag(Tag, Idea) :-
    idea(Idea),
    tag(Idea, Tag).

knowledge_for_skill(Skill, KnowledgeItem) :-
    requires_skill(Project, Skill),
    has_issue(Project, Issue),
    fix_path(Issue, KnowledgeItem),
    knowledge(KnowledgeItem).

repair_candidate(Project) :-
    project(Project),
    has_issue(Project, Issue),
    fix_path(Issue, _).

% === Integrity checks ===
invalid_status(Item, Status) :-
    status(Item, Status),
    \+ valid_status(Status).

invalid_priority(Item, Priority) :-
    priority(Item, Priority),
    \+ valid_priority(Priority).

missing_tool_reference(Project, Tool) :-
    requires_tool(Project, Tool),
    \+ tool(Tool).

missing_skill_reference(Project, Skill) :-
    requires_skill(Project, Skill),
    \+ skill(Skill).

missing_material_reference(Project, Material) :-
    uses_material(Project, Material),
    \+ material(Material).

kb_consistent :-
    \+ invalid_status(_, _),
    \+ invalid_priority(_, _),
    \+ missing_tool_reference(_, _),
    \+ missing_skill_reference(_, _),
    \+ missing_material_reference(_, _).
