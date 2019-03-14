# Referral Program

Earn `WHALE` tokens by referring crypto whales or proving your own crypto wealth!

## How it woks

1. If you refer WhaleChat app to your crypto-whale friend and he/she submits asset proofs, both you and your friend will `WHALE` when the referral program ends.
2. If you refer WhaleChat to your friend who in turns refer a crypto-whale, everybody in the chain will get some `WHALE`!
3. The Referral Program ends when the Goal for each asset has been reached.

## Scheme Details

### Reward Formula

The `WHALE` that you obtain from an asset proof is basically calculated by:

`asset_proved * exchange_rate * coefficient`

- `asset_proved` is the amount of cryptocurrency being proved. For example, if someone submitted asset proof of 50 BTC, this would be `50`
- `exchange_rate` is the "Full Reward Rate" in the table below. For example, if someone submitted asset proof of 50 BTC, this would be `50 * 350 = 17500`
- `coefficient` is where you are at in the "referral chain":
  - For example, if your own referral code is a "genesis" / "level 0" referral code, and you submits an asset proof yourself, then your `coefficient` is `1`
  - If your own referral code is "level 0", and you refer to a friend (so your friend is "level 1"), and your friend submits an asset proof, then your `coefficient` is `0.5` and your friend's `coefficient` is also `0.5`
  - If your own referral code is "level 1" (i.e. your referrer is a "level 0"), and you submit an asset proof yourself, then your `coefficient` is `0.5`
  - If your own referral code is "level 1", and you refer to a friend (so your friend is "level 2"), and your friend submits an asset proof, then your `coefficient` is `0.25` and your friend's `coefficient` is also `0.25`
  - ... and so on

### Rates

Currently Referral Programs are open for the following currencies with the following rates:

|Currency|Target|Full Reward Rate|
|-|-|-|
|BTC|3500 BTC|1 BTC = 350 WHALE|
|ETH|42500 ETH|1 ETH = 15 WHALE|


## FAQ

**1. What if the asset Goal is never reached? Will I ever get my WHALE tokens?**

If after enough time (about a year or so) the target still couldn't be reached, the referral program could end and the `WHALE` reward will be given pro-rata to the target.

**2. When will other currencies be included?**

We are working to support other crypto-currencies as soon as possible. An update on that will follow soon.

**3. What is the token total supply?**

There will be 360,000,000 `WHALE` tokens issued. No more tokens can ever be created.

**4. How many `WHALE` tokens from the total supply will be used for referrals?**

The total number of `WHALE` tokens used for referrals depends on the total amount of crypto associated to the submitted asset proofs and in which level in the referral chain the asset proof was submitted.

Example: Say the goal for BTC is reached (that is, all the asset proofs submited account for a total of 3500 BTC), and all the asset proofs were submitted by "level 1" referrees, then the total number of `WHALE` tokens granted would be `3500 BTC * 350 WHALE/BTC * (0.5 + 0.5) = 1225000 WHALE`.
