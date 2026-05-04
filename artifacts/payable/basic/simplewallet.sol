// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleWallet {
    // 컨트랙트 잔액 확인
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // 입금: 이더를 받을 때 실행됨
    receive() external payable {}

    // 환불: 잔액 전액을 호출자에게 전송
    function withdrawAll() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}