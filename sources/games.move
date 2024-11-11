module stim_games::games {
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance}; 
    use sui::linked_table::{Self, LinkedTable};
    use std::string::String;

    // Error codes
    const ENotOwner: u64 = 0;
    const EGameNotFound: u64 = 1;
    const EUserNotFound: u64 = 2;
    const EInsufficientFunds: u64 = 3;
    const EGameAlreadyExists: u64 = 4;
    const EGameSoldOut: u64 = 5;
    const EInvalidPromoCode: u64 = 6;

    // Core structs
    public struct Platform has key {
        id: UID,
        owner: address,
        fee_percentage: u64,
        revenue: Balance<SUI>
    }

    public struct PlatformCap has key {
        id: UID,
        `for`: ID
    }

    public struct GameStore has key {
        id: UID,
        owner: address,
        games: LinkedTable<String, Game>,
        promo_codes: LinkedTable<String, Discount>
    }

    public struct GameStoreCap has key {
        id: UID,
        `for`: ID
    }

    public struct Game has key, store {
        id: UID,
        name: String,
        publisher: address,
        price: u64,
        licenses: vector<address>,
        revenue: Balance<SUI>,
        max_licenses: Option<u64>,
        description: String
    }

    public struct UserAccount has key {
        id: UID,
        user_address: address,
        balance: Balance<SUI>,
        licenses: LinkedTable<String, License>
    }

    public struct License has key, store {
        id: UID,
        game_name: String,
        owner: address,
        purchase_date: u64,
        gifted_by: Option<address>
    }

    public struct Discount has store {
        promo_code: String,
        discount_percentage: u64,
        expiry: u64,
        max_uses: u64,
        times_used: u64
    }

    // Initialize platform
    fun init (ctx: &mut TxContext) {
        let platform = Platform {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            fee_percentage: 0,
            revenue: balance::zero()
        };

        let cap = PlatformCap {
            id: object::new(ctx),
            `for`: object::id(&platform)
        };

        transfer::transfer(cap, ctx.sender());
        transfer::share_object(platform);
    }

    // Initialize the game store
    public fun create_store(ctx: &mut TxContext) {
        let store = GameStore {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            games: linked_table::new(ctx),
            promo_codes: linked_table::new(ctx)
        };

        let cap = GameStoreCap {
            id: object::new(ctx),
            `for`: object::id(&store)
        };
        transfer::transfer(cap, ctx.sender());
        transfer::share_object(store);
    }

    // Create user account
    public fun create_user_account(ctx: &mut TxContext) {
        let account = UserAccount {
            id: object::new(ctx),
            user_address: tx_context::sender(ctx),
            balance: balance::zero(),
            licenses: linked_table::new(ctx)
        };
        transfer::transfer(account, tx_context::sender(ctx));
    }

    // Add a new game to the store
    public fun add_game(
        cap: &GameStoreCap,
        store: &mut GameStore,
        name: String,
        price: u64,
        description: String,
        max_licenses: Option<u64>,
        ctx: &mut TxContext
    ) {
        assert!(cap.`for` == object::id(store), ENotOwner);
        assert!(!linked_table::contains(&store.games, name), EGameAlreadyExists);

        let game = Game {
            id: object::new(ctx),
            name,
            publisher: tx_context::sender(ctx),
            price,
            licenses: vector::empty(),
            revenue: balance::zero(),
            max_licenses,
            description
        };

        linked_table::push_back(&mut store.games, name, game);
    }

    // Add promo code
    public fun add_promo_code(
        cap: &GameStoreCap,
        store: &mut GameStore,
        code: String,
        discount_percentage: u64,
        expiry: u64,
        max_uses: u64,
    ) {
        assert!(cap.`for` == object::id(store), ENotOwner);
        
        let discount = Discount {
            promo_code: code,
            discount_percentage,
            expiry,
            max_uses,
            times_used: 0
        };
        linked_table::push_back(&mut store.promo_codes, code, discount);
    }

    // Purchase a game license
    public fun purchase_license(
        platform: &mut Platform,
        store: &mut GameStore,
        user: &mut UserAccount,
        game_name: String,
        mut promo_code: Option<String>,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert!(linked_table::contains(&store.games, game_name), EGameNotFound); // Check existence first
        let game = linked_table::borrow_mut(&mut store.games, game_name); // Then borrow mutably

        // Check if sold out
        if (option::is_some(&game.max_licenses)) {
            assert!(vector::length(&game.licenses) < *option::borrow(&game.max_licenses), EGameSoldOut);
        };

        let mut final_price = game.price;
        
        // Apply discount if promo code exists
        if (option::is_some(&promo_code)) {
            let code = option::extract(&mut promo_code);
            let discount = linked_table::borrow_mut(&mut store.promo_codes, code);
            assert!(discount.times_used < discount.max_uses && tx_context::epoch(ctx) < discount.expiry, EInvalidPromoCode);
            final_price = final_price * (100 - discount.discount_percentage) / 100;
            discount.times_used = discount.times_used + 1;
        };

        let payment_value = coin::value(&payment);
        assert!(payment_value >= final_price, EInsufficientFunds);

        // Process payment
        let mut coin_balance = coin::into_balance(payment);
        let platform_fee = balance::split(&mut coin_balance, final_price * platform.fee_percentage / 100);
        balance::join(&mut platform.revenue, platform_fee);
        balance::join(&mut game.revenue, coin_balance);

        // Create and transfer license
        let buyer = tx_context::sender(ctx);
        vector::push_back(&mut game.licenses, buyer);

        let license = License {
            id: object::new(ctx),
            game_name,
            owner: buyer,
            purchase_date: tx_context::epoch(ctx),
            gifted_by: option::none()
        };
        linked_table::push_back(&mut user.licenses, game_name, license);
    }

    // View user's licenses
    public fun view_user_licenses(user: &UserAccount, ctx: &TxContext): vector<String> {
        assert!(tx_context::sender(ctx) == user.user_address, EUserNotFound);
        let mut license_list = vector::empty();
        let mut key_i = linked_table::front(&user.licenses);
        while (option::is_some(key_i)) {
            let k = *option::borrow(key_i);
            vector::push_back(&mut license_list, k);
            key_i = linked_table::next(&user.licenses, k);
        };
        license_list
    }

    public fun view_license(user: &UserAccount, game_name: String, ctx: &TxContext): &License {
        assert!(tx_context::sender(ctx) == user.user_address, EUserNotFound);
        let license_ref = linked_table::borrow(&user.licenses, game_name);
        license_ref // Return a reference to the License
    }

    // View all available games
    public fun view_game_catalog(store: &GameStore): vector<String> {
        let mut catalog = vector::empty();
        let mut key_i = linked_table::front(&store.games); // Get the first key in the LinkedTable
        while (option::is_some(key_i)) {
            let k = *option::borrow(key_i); // Get the current key
            let game = linked_table::borrow(&store.games, k); // Borrow the game using the key
            if (!option::is_some(&game.max_licenses) || 
                vector::length(&game.licenses) < *option::borrow(&game.max_licenses)) {
                vector::push_back(&mut catalog, k);
            };
            key_i = linked_table::next(&store.games, k); // Move to the next key
        };
        catalog
    }

    // Verify game license
    public fun verify_license(
        cap: &GameStoreCap,
        store: &GameStore,
        game_name: String,
        license: &License,
        ctx: &TxContext
    ): bool {
        assert!(cap.`for` == object::id(store), ENotOwner);
        let game = linked_table::borrow(&store.games, game_name);
        let owner = tx_context::sender(ctx);
        
        license.game_name == game_name && 
        license.owner == owner && 
        vector::contains(&game.licenses, &owner)
    }

    // Withdraw revenue for publisher
    public fun withdraw_revenue(
        cap: &GameStoreCap,
        store: &mut GameStore,
        game_name: String,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(cap.`for` == object::id(store), ENotOwner);
        let game = linked_table::borrow_mut(&mut store.games, game_name);
        let amount = balance::value(&game.revenue);
        let revenue = balance::split(&mut game.revenue, amount);
        coin::from_balance(revenue, ctx)
    }

    public fun set_fee(
        cap: &PlatformCap,
        store: &mut Platform,
        fee: u64,
    ) {
        assert!(cap.`for` == object::id(store), ENotOwner);
        store.fee_percentage = fee;
    }

    public fun withdraw(
        cap: &PlatformCap,
        store: &mut Platform,
        ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(cap.`for` == object::id(store), ENotOwner);
        let balance = balance::withdraw_all(&mut store.revenue);
        let coin = coin::from_balance(balance, ctx);
        coin
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}
