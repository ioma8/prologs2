:- module(diy_kb, [
    active_project/1,
    blocked_project/2,
    project_missing_tools/2,
    project_missing_skills/2,
    next_project/1,
    top_project/1,
    quick_win/1,
    unlocked_by_tool/2,
    purchase_unlock_count/2,
    issue_hypothesis/3,
    symptom_matches/2,
    next_diagnostic_check/2,
    skill_gap/2,
    best_skill_to_learn/1,
    projects_for_skill_growth/2,
    victory_chain/2,
    minimal_buy_list/1,
    learning_path/2,
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

estimate_hours(workbench_rebuild, 8).
estimate_hours(fix_table_lamp_switch, 1).
estimate_hours(garage_shelf_upgrade, 4).

impact(workbench_rebuild, high).
impact(fix_table_lamp_switch, high).
impact(garage_shelf_upgrade, medium).

risk(workbench_rebuild, medium).
risk(fix_table_lamp_switch, low).
risk(garage_shelf_upgrade, medium).

depends_on(garage_shelf_upgrade, workbench_rebuild).
unlocks(workbench_rebuild, garage_shelf_upgrade).

symptom(table_lamp_intermittent_power, flickers_when_toggled).
check_step(table_lamp_intermittent_power, continuity_test_switch).
check_step(table_lamp_intermittent_power, inspect_loose_terminals).
cause(table_lamp_intermittent_power, worn_switch_contacts, high).
cause(table_lamp_intermittent_power, loose_wire_joint, medium).

buy_option(soldering_iron, medium_cost, next_day).
buy_option(replacement_switch, low_cost, in_stock).

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

impact_rank(high, 3).
impact_rank(medium, 2).
impact_rank(low, 1).

risk_rank(low, 3).
risk_rank(medium, 2).
risk_rank(high, 1).

project_score(Project, Score) :-
    project(Project),
    status(Project, Status),
    (Status = active ; Status = planned),
    \+ blocked_by(Project, _),
    priority(Project, Priority),
    impact(Project, Impact),
    risk(Project, Risk),
    estimate_hours(Project, Hours),
    project_missing_tools(Project, MissingTools),
    project_missing_skills(Project, MissingSkills),
    priority_rank(Priority, P),
    impact_rank(Impact, I),
    risk_rank(Risk, R),
    list_length(MissingTools, MT),
    list_length(MissingSkills, MS),
    Score is P + I + R - Hours - MT - MS.

top_project(Project) :-
    project_score(Project, Score),
    \+ (
        project_score(Other, OtherScore),
        Other \= Project,
        OtherScore > Score
    ).

quick_win(Project) :-
    project(Project),
    status(Project, Status),
    (Status = active ; Status = planned),
    \+ blocked_by(Project, _),
    estimate_hours(Project, Hours),
    Hours =< 2,
    impact(Project, high).

unlocked_by_tool(Tool, Project) :-
    project(Project),
    requires_tool(Project, Tool),
    \+ owned_tool(Tool),
    findall(T, (requires_tool(Project, T), \+ owned_tool(T)), Missing),
    sort(Missing, [Tool]).

purchase_unlock_count(Item, Count) :-
    findall(Project, unlocked_by_tool(Item, Project), Projects),
    sort(Projects, Unique),
    list_length(Unique, Count).

issue_hypothesis(Issue, Cause, Confidence) :-
    cause(Issue, Cause, Confidence).

symptom_matches(Symptom, Issue) :-
    symptom(Issue, Symptom).

next_diagnostic_check(Issue, Step) :-
    check_step(Issue, Step).

skill_gap(Project, Skill) :-
    requires_skill(Project, Skill),
    \+ owned_skill(Skill).

skill_unlocks(Skill, Count) :-
    findall(Project, skill_gap(Project, Skill), Ps),
    sort(Ps, Unique),
    list_length(Unique, Count).

best_skill_to_learn(Skill) :-
    skill_unlocks(Skill, Count),
    Count > 0,
    \+ (
        skill_unlocks(Other, OtherCount),
        Other \= Skill,
        OtherCount > Count
    ).

projects_for_skill_growth(Skill, Project) :-
    skill_gap(Project, Skill).

victory_chain(Start, Chain) :-
    project(Start),
    victory_chain_(Start, [Start], RevChain),
    reverse_list(RevChain, Chain).

victory_chain_(Current, Acc, Acc) :-
    \+ unlocks(Current, _).
victory_chain_(Current, Acc, Chain) :-
    unlocks(Current, Next),
    \+ member_of(Next, Acc),
    victory_chain_(Next, [Next|Acc], Chain).

minimal_buy_list(Items) :-
    findall(
        Tool,
        (
            requires_tool(Project, Tool),
            status(Project, Status),
            (Status = active ; Status = planned),
            \+ owned_tool(Tool)
        ),
        Tools0
    ),
    sort(Tools0, Items).

learning_path(Skill, Projects) :-
    findall(Project, skill_gap(Project, Skill), Ps0),
    sort_projects_by_effort(Ps0, Projects).

sort_projects_by_effort([], []).
sort_projects_by_effort([P|Ps], Sorted) :-
    sort_projects_by_effort(Ps, SortedPs),
    insert_project_by_effort(P, SortedPs, Sorted).

insert_project_by_effort(P, [], [P]).
insert_project_by_effort(P, [H|T], [P,H|T]) :-
    estimate_hours(P, PH),
    estimate_hours(H, HH),
    PH =< HH.
insert_project_by_effort(P, [H|T], [H|R]) :-
    estimate_hours(P, PH),
    estimate_hours(H, HH),
    PH > HH,
    insert_project_by_effort(P, T, R).

list_length([], 0).
list_length([_|T], N) :-
    list_length(T, N0),
    N is N0 + 1.

member_of(X, [X|_]).
member_of(X, [_|T]) :-
    member_of(X, T).

reverse_list(List, Reversed) :-
    reverse_list_(List, [], Reversed).

reverse_list_([], Acc, Acc).
reverse_list_([H|T], Acc, Reversed) :-
    reverse_list_(T, [H|Acc], Reversed).

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
