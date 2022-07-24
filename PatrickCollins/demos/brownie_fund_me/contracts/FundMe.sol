//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// importing safemath from chainlink or we can also use safemath from openzeppelin
// OR paste the interface code from the git repo (check remix for more details)

contract FundMe {
    using SafeMathChainlink for uint256;

    // create mapping to track addresses who is sending us(the contract) payment.
    mapping(address => uint256) public addressToAmountFunded;
    // we need to make balance of funder to 0 after withdrawal.
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeedAddress) public {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
        owner = msg.sender;
    }

    function fund() public payable {
        // we need to set a minimum spend of $50
        uint256 minimumUSD = 50 * 10**18; //to convert to wei
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "you need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        // Address from here: https://docs.chain.link/docs/ethereum-addresses/
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        // since we are not using a lot of the returned value we will keep ot blank
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer); // since answer is in int256 and we are returning uint256, hence type casting.
        //e.g. of uint256(answer) = 135827000000 price of ETH in GWEI
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethAmount * ethPrice); // / (10 ** 17);
        //134831964197000000000
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimum USD
        uint256 minimumUSD = 50 * 10**18; //to convert to wei
        uint256 price = getPrice(); // returns in wei STARTING_PRICE in helpful_scripts
        uint256 precision = 1 * 10**18;
        return ((minimumUSD * precision) / price);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        // we will have to loop through the funders araay to make the balance zero after withdrawal

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            addressToAmountFunded[funders[funderIndex]] = 0;
        }

        // reset funders array once the withdrawal is done
        funders = new address[](0);
    }
}
