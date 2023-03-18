// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract Bond is ReentrancyGuard{

    address[] public owners;
    mapping(address => uint256) public shares;
    uint256 public totalShares;

    IERC20 public acceptedToken;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    constructor(address[] memory _owners, IERC20 _acceptedToken){
        require(_owners.length > 0, "Need at least one owner.");
            for(uint256 i = 0; i < _owners.length; i++){
                require(_owners[i] != address(0), "Owner address can't be 0.");
                owners.push(_owners[i]);
                shares[_owners[i]] = 1;
                totalShares = totalShares + 1;
            }

            acceptedToken = _acceptedToken;
    }

    function deposit(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than 0.");
        acceptedToken.transferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw() external nonReentrant {
        require(shares[msg.sender] > 0, "This address has no shares.");
        uint256 balance = acceptedToken.balanceOf(address(this));
        uint256 amount = (balance * shares[msg.sender]) / totalShares;
        acceptedToken.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

}
