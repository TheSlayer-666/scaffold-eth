pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
    //ToDo: add constructor and mint tokens for deployer,
    constructor(string memory name, string memory symbol)
        public
        ERC20(name, symbol)
    {
        _mint(msg.sender, 3000 * (10**uint256(decimals())));
    }

    //you can use the above import for ERC20.sol. Read the docs ^^^
}
