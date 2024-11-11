#[test_only]
module stim_games::test_games {
    use sui::test_scenario::{Self as ts, next_tx, ctx};
    use sui::test_utils::{assert_eq};
    use sui::coin::{Coin, mint_for_testing};
    use sui::clock::{Clock, Self};
    use sui::sui::{SUI};

    use std::string::{Self};
    use std::debug::print;

    use stim_games::helpers::init_test_helper;
    use stim_games::games::{Self as games, Platform, GameStore, Game, UserAccount, License};

    const ADMIN: address = @0xe;
    const TEST_ADDRESS1: address = @0xee;
    const TEST_ADDRESS2: address = @0xbb;

    #[test]
    public fun test_not_admin() {
        let mut scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        // create the voting shared object 
        next_tx(scenario, TEST_ADDRESS1);
        {
           

        };

        ts::end(scenario_test);
    }

}