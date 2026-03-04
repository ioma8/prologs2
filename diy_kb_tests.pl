:- use_module('diy_kb.pl').

assert_true(Goal) :-
    ( call(Goal) -> true
    ; write('FAIL expected true: '), writeq(Goal), nl, fail
    ).

assert_false(Goal) :-
    ( call(Goal) ->
        write('FAIL expected false: '), writeq(Goal), nl, fail
    ; true
    ).

run_tests :-
    assert_true(active_project(workbench_rebuild)),
    assert_true(project_missing_tools(fix_table_lamp_switch, [soldering_iron])),
    assert_true(project_missing_skills(fix_table_lamp_switch, [soldering])),
    assert_true(blocked_project(garage_shelf_upgrade, missing_heavy_duty_anchors)),
    assert_true(ideas_by_tag(energy, solar_powered_vent)),
    assert_true(knowledge_for_skill(electrical_diagnostics, lamp_switch_wiring_basics)),
    assert_true(repair_candidate(fix_table_lamp_switch)),
    assert_false(next_project(garage_shelf_upgrade)),
    assert_true(kb_consistent),
    write('All tests passed.'), nl.
