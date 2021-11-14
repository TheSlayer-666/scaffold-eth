pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    YourToken yourToken;

    constructor(address tokenAddress) public {
        yourToken = YourToken(tokenAddress);
    }

    uint256 public constant tokensPerEth = 100; // Fixed price
    event BuyTokens(address buyer, uint256 amountOfTokens, uint256 amountOfEth);
    event SellTokens(
        address seller,
        uint256 amountOfEth,
        uint256 amountOfTokens
    );

    function buyTokens() public payable {
        uint256 tokenAmount = msg.value * tokensPerEth;
        yourToken.approve(msg.sender, tokenAmount);
        yourToken.transfer(msg.sender, tokenAmount);
        emit BuyTokens(msg.sender, msg.value, tokenAmount);
    }

    //ToDo: create a sellTokens() function:
    function sellTokens(uint256 amount) public returns (uint256 ethAmount) {
        require(amount > 0, "The amount must be greater than 0");
        uint256 EthAmount = amount / tokensPerEth;
        uint256 vendorETHBalance = address(this).balance;
        require(
            vendorETHBalance >= EthAmount,
            "Vendor hasn't enough funds to complete the request"
        );
        bool tokenSent = yourToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        require(tokenSent, "Failed to transfer the tokens to the vendor");
        (bool ok, ) = payable(msg.sender).call{value: EthAmount}("");
        require(ok, "Failed to send the ETH to the user");

        emit SellTokens(msg.sender, amount, EthAmount);

        return EthAmount;
    }

    //ToDo: create a withdraw() function that lets the owner, you can
    //use the Ownable.sol import above:
}
