// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicPayable {
    // 1. 돈을 받을 수 있게 해주는 특별한 함수 (Receive)
    // 이 함수가 있어야 Remix의 'Value'를 통해 이더를 보낼 수 있습니다.
    receive() external payable {}

    // 2. 컨트랙트의 현재 잔액을 확인하는 함수
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // 3. 특정 주소로 돈을 직접 보내는 함수
    // _to: 받는 사람 주소, _amount: 보낼 금액 (Wei 단위)
    function transferTo(address payable _to, uint _amount) public {
        require(address(this).balance >= _amount, "Insufficient balance");
        
        // _to 주소로 _amount만큼의 이더를 전송합니다.
        _to.transfer(_amount);
    }
}