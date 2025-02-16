# ERC20 Tests
This repository contains a set of tests utilizing Anvil and more generally the [Foundry suite](https://github.com/foundry-rs/foundry) in order to implement an ERC20 test suite. To spool up a local Anvil node and run the tests:

```
./run_tests_anvil.sh
```

The tests are run against the contract defined in `src/ERC20Impl.sol`. By default it uses the OpenZeppelin reference implementation with a dummy name and symbol. To change it to any other ERC20 token, simply modify ERC20Impl such that its constructor takes in only an `initialSupply`, performs any specific pre-test setup setup, and deposits the `initialSupply` to `msg.sender`.

The basic set of tests only test against the ERC20 interfaces as specified in [EIP-20.](https://eips.ethereum.org/EIPS/eip-20). As EIP-20 is fairly minimal with many details left to implementation, some commonly expected ERC20 behaviors are not yet tested.

It attempts to generally follow the best practices from the [Foundry best practices](https://book.getfoundry.sh/guides/best-practices), with some exceptions as we are testing against an interface. 

Some obvious future improvements:
* All `transfer`, `transferFrom` and `approve` tests should be modified so that an invariant function is used to check the correct events are emitted. 
* A security test suite should test for common attacks like reentrancy, etc
* Many of these are assuming the receiver has a balance of zero and thus checking the balance is sufficient to check the transfer was successful. This isn't required by the ERC20 interface and shouldn't be assumed.