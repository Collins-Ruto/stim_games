#[test_only]
module stim_games::test_games {
    use sui::test_scenario::{Self as ts, next_tx};
    use sui::coin::{mint_for_testing};
    use sui::sui::{SUI};

    use std::string::{Self};

    use stim_games::helpers::init_test_helper;
    use stim_games::games::{Self as games, Platform, GameStore, PlatformCap, GameStoreCap, UserAccount};

    const ADMIN: address = @0xe;
    const TEST_ADDRESS1: address = @0xee;
    const TEST_ADDRESS2: address = @0xbb;

    #[test]
    #[expected_failure(abort_code = 0x2::dynamic_field::EFieldAlreadyExists)]
    public fun test1() {
        let mut scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        // create the voting shared object 
        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = ts::take_from_sender<PlatformCap>(scenario);
            let mut shared = ts::take_shared<Platform>(scenario);

            let fee: u64 = 100;
            games::set_fee(&cap, &mut shared, fee);

            ts::return_to_sender(scenario, cap);
            ts::return_shared(shared);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            games::create_store(ts::ctx(scenario));
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = ts::take_from_sender<GameStoreCap>(scenario);
            let mut shared = ts::take_shared<GameStore>(scenario);

            let name = string::utf8(b"a");
            let description = string::utf8(b"a");
            let max_licenses = option::some(100);
            let price: u64 = 1_000_000_000;

            games::add_game(&cap, &mut shared, name, price, description, max_licenses, ts::ctx(scenario));


            ts::return_to_sender(scenario, cap);
            ts::return_shared(shared);
        };

        next_tx(scenario, TEST_ADDRESS2);
        {
            games::create_user_account(ts::ctx(scenario));
        };
        // scenario 1 > we do not have promo code. 
        next_tx(scenario, TEST_ADDRESS2);
        {
            let mut account = ts::take_from_sender<UserAccount>(scenario);
            let mut platform = ts::take_shared<Platform>(scenario);
            let mut gamestore = ts::take_shared<GameStore>(scenario);

            let game_name = string::utf8(b"a");
            let promo_code = option::none();
            let coin = mint_for_testing<SUI>(1_000_000_000, ts::ctx(scenario));
       

            games::purchase_license(&mut platform, &mut gamestore, &mut account, game_name, promo_code, coin, ts::ctx(scenario));

            ts::return_to_sender(scenario, account);
            ts::return_shared(platform);
            ts::return_shared(gamestore);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = ts::take_from_sender<GameStoreCap>(scenario);
            let mut shared = ts::take_shared<GameStore>(scenario);

            let code = string::utf8(b"bb");
            let discount_percentage: u64 = 10;
            let expiry: u64 = 1_000_000_000;
            let max_uses: u64 = 1_000_000_000;

            games::add_promo_code(&cap, &mut shared, code, discount_percentage, expiry, max_uses);

            ts::return_to_sender(scenario, cap);
            ts::return_shared(shared);
        };

        // scenario 2 > we do have promo code 
        next_tx(scenario, TEST_ADDRESS2);
        {
            let mut account = ts::take_from_sender<UserAccount>(scenario);
            let mut platform = ts::take_shared<Platform>(scenario);
            let mut gamestore = ts::take_shared<GameStore>(scenario);

            let game_name = string::utf8(b"a");
            let promo_code = option::some(string::utf8(b"bb"));
            let coin = mint_for_testing<SUI>(1_000_000_000, ts::ctx(scenario));
       
            games::purchase_license(&mut platform, &mut gamestore, &mut account, game_name, promo_code, coin, ts::ctx(scenario));

            ts::return_to_sender(scenario, account);
            ts::return_shared(platform);
            ts::return_shared(gamestore);
        };

        ts::end(scenario_test);
    }

    #[test]
    public fun test2() {
        let mut scenario_test = init_test_helper();
        let scenario = &mut scenario_test;

        // create the voting shared object 
        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = ts::take_from_sender<PlatformCap>(scenario);
            let mut shared = ts::take_shared<Platform>(scenario);

            let fee: u64 = 100;
            games::set_fee(&cap, &mut shared, fee);

            ts::return_to_sender(scenario, cap);
            ts::return_shared(shared);
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            games::create_store(ts::ctx(scenario));
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = ts::take_from_sender<GameStoreCap>(scenario);
            let mut shared = ts::take_shared<GameStore>(scenario);

            let name = string::utf8(b"a");
            let description = string::utf8(b"a");
            let max_licenses = option::some(100);
            let price: u64 = 1_000_000_000;

            games::add_game(&cap, &mut shared, name, price, description, max_licenses, ts::ctx(scenario));


            ts::return_to_sender(scenario, cap);
            ts::return_shared(shared);
        };

        next_tx(scenario, TEST_ADDRESS2);
        {
            games::create_user_account(ts::ctx(scenario));
        };

        next_tx(scenario, TEST_ADDRESS1);
        {
            let cap = ts::take_from_sender<GameStoreCap>(scenario);
            let mut shared = ts::take_shared<GameStore>(scenario);

            let code = string::utf8(b"bb");
            let discount_percentage: u64 = 10;
            let expiry: u64 = 1_000_000_000;
            let max_uses: u64 = 1_000_000_000;

            games::add_promo_code(&cap, &mut shared, code, discount_percentage, expiry, max_uses);

            ts::return_to_sender(scenario, cap);
            ts::return_shared(shared);
        };

        // scenario 2 > we do have promo code 
        next_tx(scenario, TEST_ADDRESS2);
        {
            let mut account = ts::take_from_sender<UserAccount>(scenario);
            let mut platform = ts::take_shared<Platform>(scenario);
            let mut gamestore = ts::take_shared<GameStore>(scenario);

            let game_name = string::utf8(b"a");
            let promo_code = option::some(string::utf8(b"bb"));
            let coin = mint_for_testing<SUI>(1_000_000_000, ts::ctx(scenario));
       
            games::purchase_license(&mut platform, &mut gamestore, &mut account, game_name, promo_code, coin, ts::ctx(scenario));

            ts::return_to_sender(scenario, account);
            ts::return_shared(platform);
            ts::return_shared(gamestore);
        };
        
        ts::end(scenario_test);
    }
}
