# ERC20 - ERC777 bridge

A token bridge , inspired on the work of these projects :

- https://github.com/jacquesd/eip777
- https://github.com/paritytech/parity-bridge/

This bridge transfers any ERC20 token to an equivalent ERC777 token on another chain.

## Documentation

https://hackmd.io/s/rJDPfbZUG


# Status

## master branch

- Deposits and withdrawals work in the truffle test
- Basic verifications and contract audits have not been done

## conversion-reward branch 

- https://github.com/swarmcity/SCLabs-erc20-bridge/tree/conversion-reward
- Withdrawal transaction can be ececuted by anyone
- Withdrawer can set a fee in tokens for someone else to do the withdrawal

( This should be the preferred method to run the bridge )


# install / run / test

`npm i -g truffle`

`truffle test`

# How can you help ?

We use ZenHub as a project management tool for this project.

- Install the ZenHub chrome plugin ( https://chrome.google.com/webstore/detail/zenhub-for-github/ogcgkffhplmphkaahpmffcafajaocjbd )
- visit the project board : https://github.com/swarmcity/SCLabs-erc20-bridge#boards?repos=119867603
- check the `backlog` and `new issues` pipeline 

If you don't want to install this plugin , just check the issues on the project 

# Get in touch

- ScalingNOW! chat on Riot: https://riot.im/app/#/room/#ScalingEthereum:matrix.org

