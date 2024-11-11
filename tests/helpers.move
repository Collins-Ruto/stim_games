#[test_only]
module stim_games::helpers {
    use sui::test_scenario::{Self as ts};

    const TEST_ADDRESS1: address = @0xee;

    use stim_games::games::test_init;

    public fun init_test_helper() : ts::Scenario{

       let  mut scenario_val = ts::begin(TEST_ADDRESS1);
       test_init(ts::ctx(&mut scenario_val));
       scenario_val
    }

}