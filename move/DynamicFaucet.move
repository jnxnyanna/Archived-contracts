module Faucet::DynamicFaucet {
    use 0x1::Signer;
    use 0x1::Timestamp;
    use 0x1::Sui;
    use 0x1::Event;

    const DROP_RATE: u64 = 2_000_000;
    const DROP_PERIOD: u64 = 86400;

    struct Faucet {
        owner: address,
        is_paused: bool,
        drop_rate: u64,
        drop_period: u64,
        admins: vector<address>,
        blocklist: vector<address>,
        last_claim: vector<(address, u64)>,
    }

    struct FaucetEvent has key, store {
        event_data: vector<u8>,
    }

    public fun initialize(signer: &signer): Faucet {
        let owner_addr = Signer::address_of(signer);
        Faucet {
            owner: owner_addr,
            is_paused: false,
            drop_rate: DROP_RATE,
            drop_period: DROP_PERIOD,
            admins: vector::singleton(owner_addr),
            blocklist: vector::empty<address>(),
            last_claim: vector::empty<(address, u64)>(),
        }
    }

    public fun transfer_ownership(faucet: &mut Faucet, new_owner: address) {
        assert!(Signer::address_of(&faucet.owner) == faucet.owner, 0);
        faucet.owner = new_owner;
        if (!vector::contains(&faucet.admins, &new_owner)) {
            vector::push_back(&mut faucet.admins, new_owner);
        }
    }

    public fun add_admin(faucet: &mut Faucet, admin: address) {
        assert!(Signer::address_of(&faucet.owner) == faucet.owner, 1);
        if (!vector::contains(&faucet.admins, &admin)) {
            vector::push_back(&mut faucet.admins, admin);
        }
    }

    public fun remove_admin(faucet: &mut Faucet, admin: address) {
        assert!(Signer::address_of(&faucet.owner) == faucet.owner, 1);
        let index = vector::index_of(&faucet.admins, &admin);
        if (index.is_some()) {
            vector::remove(&mut faucet.admins, index.unwrap());
        }
    }

    public fun set_blocklist(faucet: &mut Faucet, user: address, state: bool) {
        assert!(vector::contains(&faucet.admins, &Signer::address_of(&faucet.owner)), 2);
        if state && !vector::contains(&faucet.blocklist, &user) {
            vector::push_back(&mut faucet.blocklist, user);
        } else if !state && vector::contains(&faucet.blocklist, &user) {
            let index = vector::index_of(&faucet.blocklist, &user);
            if index.is_some() {
                vector::remove(&mut faucet.blocklist, index.unwrap());
            }
        }
    }

    public fun pause_faucet(faucet: &mut Faucet) {
        assert!(vector::contains(&faucet.admins, &Signer::address_of(&faucet.owner)), 3);
        faucet.is_paused = true;
    }

    public fun unpause_faucet(faucet: &mut Faucet) {
        assert!(vector::contains(&faucet.admins, &Signer::address_of(&faucet.owner)), 3);
        faucet.is_paused = false;
    }

    public fun request_funds(faucet: &mut Faucet, user: address) {
        assert!(!faucet.is_paused, 4);
        assert!(!vector::contains(&faucet.blocklist, &user), 5);

        let current_time = Timestamp::now_seconds();
        let mut can_claim = true;

        for i in 0..vector::length(&faucet.last_claim) {
            let (claim_user, last_time) = vector::borrow(&faucet.last_claim, i);
            if *claim_user == user {
                can_claim = current_time >= last_time + faucet.drop_period;
                if can_claim {
                    *last_time = current_time;
                }
                break;
            }
        }

        assert!(can_claim, 6);

        let amount = faucet.drop_rate;
        Sui::transfer(Sui::create_coin(amount), &user);
        
        if !vector::contains(&faucet.last_claim, &user) {
            vector::push_back(&mut faucet.last_claim, (user, current_time));
        }
    }

    public fun withdraw(signer: &signer, faucet: &mut Faucet) {
        assert!(Signer::address_of(signer) == faucet.owner, 7);
        let balance = Sui::balance(signer);
        Sui::transfer(balance, &Signer::address_of(signer));
    }
}
