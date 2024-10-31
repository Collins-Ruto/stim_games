# Stim Games Platform: Module Documentation

## Overview

This module, `stim_games::stim_games`, establishes a decentralized game store, enabling publishers to sell game licenses and users to buy, store, and view their purchased licenses. Additional features like promo codes, fee management, and a licensing verification mechanism are built in, providing a comprehensive structure for managing a blockchain-based game store.

### Components

#### Struct Definitions

1. **Platform**: Represents the game platform, with attributes for owner, fee percentage, and accumulated revenue.

2. **GameStore**: A container for games and promotional codes, with features for owner management.

3. **Game**: Contains details of a game, including name, publisher, price, revenue, and a list of issued licenses.

4. **UserAccount**: Manages user-specific information such as balance and owned licenses.

5. **License**: Represents ownership of a purchased game, with details like purchase date and gifting information.

6. **Discount**: Details for promotional codes, including discount rate, expiry, and usage tracking.

#### Error Codes

- **ENotOwner (0)**: Triggered when an action is attempted by a non-owner.
- **EGameNotFound (1)**: Raised if a game is not found in the store.
- **EUserNotFound (2)**: Raised when a user account is not found.
- **EInsufficientFunds (3)**: Raised if the user lacks enough funds to purchase a license.
- **EGameAlreadyExists (4)**: Raised when trying to add a game that already exists.
- **EGameSoldOut (5)**: Raised when a game reaches its maximum licenses.
- **EInvalidPromoCode (6)**: Raised if a promo code is invalid or expired.

---

### Functions

#### Platform and Store Management

- **initialize_platform**: Initializes the platform with a set fee percentage for transactions. Only the platform owner can use this.
  
- **create_store**: Creates a game store for managing games and promotional codes. The sender of the transaction becomes the store owner.

#### User Account Management

- **create_user_account**: Sets up a new user account for purchasing licenses.

#### Game Management

- **add_game**: Allows store owners to add new games, specifying name, price, description, and optional max licenses.

- **add_promo_code**: Enables store owners to add promotional codes with defined discounts and usage restrictions.

#### License Purchase and Payment

- **purchase_license**: Manages the purchase of a game license, including promo code application, fund deduction, platform fees, and license issuance. Licenses are only issued if sufficient funds are available, and the game is not sold out.

#### User Interaction

- **view_user_licenses**: Lists all licenses owned by the user.

- **view_license**: Provides details of a specific license owned by the user.

#### Game Catalog

- **view_game_catalog**: Displays all games available for purchase. Filters out sold-out games if `max_licenses` is defined.

#### License Verification and Revenue Withdrawal

- **verify_license**: Allows for the verification of a user’s license by the license holder.

- **withdraw_revenue**: Enables the game publisher to withdraw accumulated revenue for a particular game.

---

### How to Use

1. **Initialize Platform**: Set up the platform with a fee percentage, enabling revenue collection for game sales.

2. **Create Store**: Owners create a store, which will manage the available games and promotional codes.

3. **Add Games and Promo Codes**: Owners add games with prices and descriptions. Promo codes may be added to incentivize purchases.

4. **User Registration**: Users create accounts to track their purchases and manage licenses.

5. **Purchasing and Licensing**: Users purchase licenses, with promo codes if available. Platform fees are automatically deducted and transferred to the platform’s revenue.

6. **License Verification**: Purchased licenses can be verified by the owner and store, ensuring authenticity and preventing unauthorized transfers.

### Key Features

- **Decentralized Ownership**: Owners have full control over store creation, game additions, and revenue withdrawal.
- **Promotional Code System**: Promo codes offer users discounts, which store owners can configure with usage limits and expiration.
- **Revenue Collection and Fee Management**: Platform fees are automatically collected on each purchase, providing a steady revenue stream for the platform.
- **License Verification**: Verifiable licenses increase transparency and trust, ensuring that only legitimate users access purchased content.

**Dependencies:**

- This module requires the `sui` and `candid` crates for Sui blockchain interaction and data serialization.

get more info at [dacade](https://dacade.org/communities/sui/challenges/19885730-fb83-477a-b95b-4ab265b61438/learning-modules/fc2e67a1-520d-4fae-a318-38414babc803)
