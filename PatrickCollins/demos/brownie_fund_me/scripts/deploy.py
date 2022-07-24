from brownie import FundMe, MockV3Aggregator, accounts, network, config
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_DEVELOPMENT,
)


def deploy_fund_me():
    account = get_account()
    print(network.show_active())
    # pass the priceFeed address to the FundMe contract

    # if we are on a persistent network like rinkeby, use the associated address "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e"
    # otherwise, deploy mocks
    if network.show_active() not in LOCAL_BLOCKCHAIN_DEVELOPMENT:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        # latest deployed mock comtract by using [-1]
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
