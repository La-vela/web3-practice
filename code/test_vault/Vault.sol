// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Vault {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // ETH 입금 (직접 전송 시 자동 실행)
    receive() external payable {}

    // 현재 컨트랙트 잔액 확인
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 출금 (오너만 가능)
    function withdraw() public {
        require(msg.sender == owner, "Only owner can withdraw");

        payable(owner).transfer(address(this).balance);
    }
}