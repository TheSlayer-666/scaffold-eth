pragma solidity >=0.6.0 <0.7.0;

import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
        deadline = block.timestamp + 2 hours;
    }

    event Stake(address indexed sender, uint256 amount);

    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;

    uint256 public immutable deadline;

    /**
     * @dev modifier used for checking if the staking process is done
     */
    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "staking process already complete");
        _;
    }
    /**
     * @dev modifier used for checking if the deadline has been reached
     */
    modifier deadlineReached(bool hasReached) {
        uint256 leftTime = timeLeft();
        if (hasReached) {
            require(leftTime == 0, "Didn't reach deadline yet");
        } else {
            require(leftTime > 0, "Deadline reached already");
        }
        _;
    }

    function execute() public deadlineReached(false) notCompleted {
        uint256 contractBalance = address(this).balance;

        // Prevent further exec if threshold isn't reached
        require(contractBalance >= threshold, "Threshold not reached yet");

        exampleExternalContract.complete{value: contractBalance}();
    }

    /**
     * @notice Transfer Ether to the contract
     */
    function stake() public payable deadlineReached(false) {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        emit Stake(msg.sender, msg.value);
    }

    /**
     * @notice Widthdraw Ether from the contract as long as `threshold` isn't met
     */
    function withdraw() external notCompleted deadlineReached(false) {
        require(address(this).balance < threshold, "Threshhold met");

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok);
    }

    /**
     * @notice Get time left before lock-up
     */
    function timeLeft() public view returns (uint256 timeleft) {
        if (block.timestamp < deadline) {
            return deadline - block.timestamp;
        }
        return 0;
    }
}
