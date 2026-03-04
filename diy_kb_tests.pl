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
    assert_true(quick_win(fix_table_lamp_switch)),
    assert_true(top_project(fix_table_lamp_switch)),
    assert_true(unlocked_by_tool(soldering_iron, fix_table_lamp_switch)),
    assert_true(purchase_unlock_count(soldering_iron, 1)),
    assert_true(issue_hypothesis(table_lamp_intermittent_power, worn_switch_contacts, high)),
    assert_true(symptom_matches(flickers_when_toggled, table_lamp_intermittent_power)),
    assert_true(next_diagnostic_check(table_lamp_intermittent_power, continuity_test_switch)),
    assert_true(skill_gap(fix_table_lamp_switch, soldering)),
    assert_true(best_skill_to_learn(soldering)),
    assert_true(projects_for_skill_growth(soldering, fix_table_lamp_switch)),
    assert_true(victory_chain(workbench_rebuild, [workbench_rebuild, garage_shelf_upgrade])),
    assert_true(minimal_buy_list([soldering_iron])),
    assert_true(learning_path(soldering, [fix_table_lamp_switch])),
    assert_true(kb_consistent),
    write('All tests passed.'), nl.
