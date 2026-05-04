// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GuardedWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // [핵심] 입구 컷을 담당하는 경비원 역할
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _; // 통과하면 함수 본문 실행
    }

    receive() external payable {}

    // 주인만 환불 가능하도록 modifier 적용
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}