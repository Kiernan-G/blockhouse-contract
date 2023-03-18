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
                require(_owners[i] != address(0), "Owner address can't be 0");
                owners.push(_owners[i]);
                shares[_owners[i]] = 1;
                totalShares = totalShares + 1;
            }

            acceptedToken = _acceptedToken;
    }

    function deposit(uint256 _amount) external nonReentrant {

    }

    function withdraw() external nonReentrant {

    }

}
