//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

contract StakingToken is Ownable {

  event Received(address sender, uint256 amount);
  event Staked(address indexed stakeholder, uint256 tokenId, uint256 amount, uint256 timestamp);

  /**
   * A stake struct is used to represent the way we store stakes, 
   */
  struct Stake {
    uint256 tokenId;
    uint256 amount;
    uint256 timestamp;
  }

  /**
   * The stakes for each stakeholder.
   */
  mapping(address => Stake) public stakes;

  /**
   * A method for a stakeholder to create a stake.
   *
   * @param tokenAddress The token contract address.
   * @param tokenId The token which will be stacked.
   * @param amount The amount of token.
   */
  function stake(IERC1155 tokenAddress, uint256 tokenId, uint256 amount) public
  {
    require(stakes[msg.sender].tokenId == 0, "You already have a staked token");

    stakes[msg.sender] = Stake(tokenId, amount, block.timestamp);
    IERC1155(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId, amount, "0x00");

    emit Staked(msg.sender, tokenId, amount, block.timestamp);
  }

  /**
   * A method for a stakeholder to unstake a token.
   *
   * @param tokenAddress The token contract address.
   */
  function unstake(IERC1155 tokenAddress) public
  {
    require(
      block.timestamp >= (stakes[msg.sender].timestamp + 1 days),
      "You need to wait 24 hours before unstake"
    );

    IERC1155(tokenAddress).safeTransferFrom(
      address(this),
      msg.sender,
      stakes[msg.sender].tokenId,
      stakes[msg.sender].amount,
      "0x00"
    );

    delete stakes[msg.sender];
  }

  /**
   * Handles the receipt of a single ERC1155 token type. This function is
   * called at the end of a `safeTransferFrom` after the balance has been updated.
   *
   * NOTE: To accept the transfer, this must return
   * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
   * (i.e. 0xf23a6e61, or its own function selector).
   *
   * @param operator The address which initiated the transfer (i.e. msg.sender)
   * @param from The address which previously owned the token
   * @param id The ID of the token being transferred
   * @param value The amount of tokens being transferred
   * @param data Additional data with no specified format
   * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
   */
  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external returns (bytes4)
  {
    return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }

  receive() external payable
  {
    emit Received(msg.sender, msg.value);
  }
}
