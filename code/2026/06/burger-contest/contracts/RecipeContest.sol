// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Hamburger Recipe Contest
 * @dev Enum과 Struct를 활용한 승인 기반 NFT 발행 시스템
 * 0=PENDING, 1=APPROVED, 2=REJECTED, 3=MINTED
 */
contract RecipeContest is ERC1155, Ownable {
    
    // 1. 상태 정의 (enum 이름은 관례에 따라 대문자로 시작하는 것이 좋습니다)
    enum Status { PENDING, APPROVED, REJECTED, MINTED }

    struct Recipe { 
        address creator; 
        string name;
        string uri;
        Status status;   // 상태 변수
        uint256 tokenId; // 민팅 후 부여되는 ID
    } 

    uint256 private _recipeCounter;
    uint256 private _tokenCounter;

    // 레시피 ID => 레시피 정보 매핑
    mapping(uint256 => Recipe) public recipes;

    // 이벤트 정의
    event RecipeSubmitted(uint256 indexed recipeId, address indexed creator); 
    event RecipeApproved(uint256 indexed recipeId);
    event RecipeRejected(uint256 indexed recipeId); 
    event RecipeMinted(uint256 indexed recipeId, uint256 indexed tokenId); 

    // 상속받은 Ownable의 생성자에 msg.sender를 전달하여 관리자 설정
    constructor() ERC1155("") Ownable(msg.sender) {}
    
    // [submit] 누구나 레시피를 제출할 수 있음
    function submitRecipe(string memory _name, string memory _uri) public {
        _recipeCounter++;
        recipes[_recipeCounter] = Recipe({
            creator: msg.sender,
            name: _name,
            uri: _uri,
            status: Status.PENDING,
            tokenId: 0
        });
        emit RecipeSubmitted(_recipeCounter, msg.sender);
    }

    // [approve] 관리자만 승인 가능 (PENDING 상태일 때만)
    function approveRecipe(uint256 _recipeId) public onlyOwner {
        require(recipes[_recipeId].status == Status.PENDING, "Not in PENDING status");
        recipes[_recipeId].status = Status.APPROVED;
        emit RecipeApproved(_recipeId);
    }

    // [mint] 관리자만 실제 NFT 발행 가능 (APPROVED 상태일 때만)
    function mintRecipe(uint256 _recipeId, uint256 amount) public onlyOwner {
        Recipe storage recipe = recipes[_recipeId];
        require(recipe.status == Status.APPROVED, "Recipe must be approved first");
        
        _tokenCounter++;
        recipe.tokenId = _tokenCounter;
        recipe.status = Status.MINTED;

        // ERC1155의 내부 민팅 함수 호출 (제출자에게 토큰 전송)
        _mint(recipe.creator, _tokenCounter, amount, "");
        
        emit RecipeMinted(_recipeId, _tokenCounter);
    }

    // [reject] 관리자만 거절 가능 (PENDING 상태일 때만)
    function rejectRecipe(uint256 _recipeId) public onlyOwner {
        require(recipes[_recipeId].status == Status.PENDING, "Not in PENDING status");
        recipes[_recipeId].status = Status.REJECTED;
        emit RecipeRejected(_recipeId);
    }
}