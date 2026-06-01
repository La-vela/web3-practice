

// # Hamburger Recipe Contest 

// ## ERC1155 architecture

// ### enum status

// PENDING -> (approve) -> APPROVED - (mint) -> MINTED -> (reject) -> REJECTED

// 1. PENDING: 사용자가 무언가를 신청하거나 데이터가 시스템에 처음 들어온 대기 상태 (검토 전)
// -> approve (동작): 관리자 혹은 시스템이 해당 요청을 검토하고 승인하는 액션

// 2. APPROVED: 검토가 완료되어 승인이 확정된 상태 (준비 완료)

// -> Mint (동작): 승인된 데이터를 바탕으로 실제 블록체인 상에 기록을 생성하는 실행 액션 (온체인 작업)
// 3. MINTED: 최종적으로 발행이 완료된 결과 상태 (워크플로우 성공 종료)

// -> Reject (동작): PENDING 혹은 APPROVED 단계에서 부적합하다고 판단하여 거절하는 액션 (중단)
// 3. REJECTED: 요청이 거절되어 폐기된 최종 상태 (워크플로우 실패 종료)

// ### struct Recipe
// - address creator: 레시피 제출자 지갑
// - string name: 레시피 이름
// - string uri: IPFS 메타데이터 URI
// - uint8 status: 0=PENDING
// - uint8 status: 1=APPROVED
// - uint8 status: 2=REJECTED
// - uint256 tokenId: 민팅 후 부여되는 ERC1155 ID



```solidity
// SPDX-License-Identifier: MIT
prahma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC1155/ERC1155";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Hamburger Recipe Contest
 * @dev Enum과 Struct를 활용한 승인 기반 NFT 발행 시스템
 */
contract RecipeContest is ERC1155, Ownable {
    // 1. 상태 정의: PENDING(0), APPROVED(1), REJECTED(2), MINTED(3)
    enum status { PENDING, APPROVED, REJECTED, MINTED }
    struct Recipe { 
        address creator; 
        string name;
        string uri;
        Status status;
        uint256 tokenId; 
        } 

    uint256 private _recipeCounter;
    uint256 private _tokenCounter;

    mapping(uint256 => Recipe) public recipes;

    // 이벤트: 외부(프론트엔드)에서 트랜잭션을 추적하기 위해 사용
    event RecipeSubmitted(uint256 recipeId, address creator); 
    event RecipeApproved(uint256 recipeId);
    event RecipeRejected(uint256 recipeId); 
    event RecipeMinted(uint256 recipeId, uint256 tokenId); 

    // 상속받은 Ownable에 msg.sender를 관리자로 설정
 
    constructor() ERC1155("") Ownable(msg.sender) {}
    
    // [submit] 레시피 제출: 누구나 참여 가능
    function submitRecipe(string memory _name, string memory _uri) public {
        _recipeCounter++;
        recipes[_recipeCounter] = Recipe({
            creator: msg.sender,
            name: _name,
            uri: _uri,
            status: status.PENDING,
            tokenId: 0
        });
        emit RecipeSubmitted(_recipeCounter, msg.sender);
    }

    // [approve] 승인: 관리자(Owner)만 가능
    function approveRecipe(uint256 _recipeId) public onlyOwner {
        require(recipes[_recipeId].status == status.PENDING, "Not in PENDING status");
        recipes[_recipeId].status = status.APPROVED;
        emit RecipeApproved(_recipeId);
    }

    // [mint] 발행: 승인된 레시피만 발행 가능
    function mintRecipe(uint256 _recipeId, uint256 amount) public onlyOwner {
        Recipe storage recipe = recipes[_recipeId];
        require(recipe.status == Status.APPROVED, "Recipe must be approved first");
        
        _tokenCounter++;
        recipe.tokenId = _tokenCounter;
        recipe.status = Status.MINTED;

        // ERC1155 실제 발행 함수 실행
        _mint(recipe.creator, _tokenCounter, amount, "");
        
        emit RecipeMinted(_recipeId, _tokenCounter);
    }

        // [reject] 거절: 관리자(Owner)만 가능
    function rejectRecipe(uint256 _recipeId) public onlyOwner {
        require(recipes[_recipeId].status == status.PENDING, "Not in PENDING status");
        recipes[_recipeId].status = status.REJECTED;
        emit RecipeRejected(_recipeId);
    }
}
```

// ## Log / Trouble

// - 테스트 방법 (Remix IDE 기준)
// Submit: submitRecipe에 "Cheese Burger", "ipfs://..."를 넣고 실행합니다.
// Check: recipes 항목에 1을 넣어 상태가 0 (PENDING)인지 확인합니다.
// Approve: approveRecipe에 1을 넣고 실행합니다. (상태가 1로 변함)
// Mint: mintRecipe에 1과 발행 수량(예: 100)을 넣습니다.

// 이제 제출한 사람(creator)의 지갑에 실제 ERC1155 토큰이 들어왔는지 확인

// ## Next Step

// - 테스트 환경 구축