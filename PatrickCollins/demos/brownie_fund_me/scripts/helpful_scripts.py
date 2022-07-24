from fcntl import LOCK_SH
from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

# ganache-fundme was added as a new blockchain under Ethereum network
LOCAL_BLOCKCHAIN_DEVELOPMENT = ["developmemt", "ganache-fundme"]

DECIMALS = 18
STARTING_PRICE = 2000 * 10**18  # in Wei


def get_account():
    if network.show_active() in LOCAL_BLOCKCHAIN_DEVELOPMENT:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying Mocks...")

    if len(MockV3Aggregator) <= 0:  # only deploys the mock contract once
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})

    print("Mock Deployed!")
