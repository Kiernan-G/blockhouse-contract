// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract Bond_v2 is ERC20Snapshot, Ownable, ReentrancyGuard{

    uint256 public maturityDate;
    uint256 public supplyCap;
    IERC20 public acceptedToken;

    uint256 public totalYieldDeposited;
    mapping(address => uint256) public lastYieldClaimed;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);
    event YieldDeposited(address indexed from, uint256 amount);
    event YieldClaimed(address indexed to, uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maturityDate,
        uint256 _supplyCap,
        IERC20 _acceptedToken
    ) ERC20(name, symbol) {
        require(_maturityDate > block.timestamp, "Maturity date must be in the future.");
        maturityDate = _maturityDate;
        supplyCap = _supplyCap;
        acceptedToken = _acceptedToken;
    }

    function deposit(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than zero.");
        require(block.timestamp < maturityDate, "Bond has reached maturity.");
        require(totalSupply() + _amount <= supplyCap, "Supply cap exceeded.");

        uint256 totalBalance = acceptedToken.balanceOf(address(this));
        uint256 totalSupplyBeforeDeposit = totalSupply();

        acceptedToken.transferFrom(msg.sender, address(this), _amount);
        emit Deposit(msg.sender, _amount);

        if (totalSupplyBeforeDeposit == 0) {
            _mint(msg.sender, _amount);
        } else {
            uint256 newTokens = (_amount * totalSupplyBeforeDeposit) / totalBalance;
            _mint(msg.sender, newTokens);
        }
    }

    function withdraw(uint256 _amount) external nonReentrant {
        require(block.timestamp >= maturityDate, "Bond has not reached maturity.");
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance.");

        uint256 totalBalance = acceptedToken.balanceOf(address(this));
        uint256 withdrawAmount = (totalBalance * _amount) / totalSupply();

        _burn(msg.sender, _amount);
        acceptedToken.transfer(msg.sender, withdrawAmount);
        emit Withdraw(msg.sender, withdrawAmount);
    }

    function depositYield(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than zero.");
        acceptedToken.transferFrom(msg.sender, address(this), _amount);
        totalYieldDeposited += _amount;
        emit YieldDeposited(msg.sender, _amount);
    }

    function getClaimableYield(address _holder) public view returns (uint256) {
        uint256 holderBalance = balanceOf(_holder);
        uint256 totalClaimed = lastYieldClaimed[_holder];
        uint256 yieldToClaim = ((totalYieldDeposited - totalClaimed) * holderBalance) / totalSupply();
        return yieldToClaim;
    }

    function claimYield() external nonReentrant {
        require(balanceOf(msg.sender) > 0, "No bond tokens held.");
        uint256 yieldToClaim = getClaimableYield(msg.sender);
        lastYieldClaimed[msg.sender] = totalYieldDeposited;
        acceptedToken.transfer(msg.sender, yieldToClaim);
        emit YieldClaimed(msg.sender, yieldToClaim);
    }

}