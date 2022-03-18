//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract StakingPairToken is ERC1155Receiver, Ownable {
  event Staking(
    address indexed stakeholder,
    address indexed tokenAddress0,
    address indexed tokenAddress1,
    uint96 timestamp,
    uint256 tokenId0,
    uint256 tokenId1,
    uint256 amount0,
    uint256 amount1,
    bool stake
  );

  /**
   * A stake struct is used to represent the way we store stakes,
   */
  struct Stake {
    uint256 tokenId0;
    uint256 tokenId1;
    uint256 amount0;
    uint256 amount1;
    address tokenAddress0;
    address tokenAddress1;
    uint96 timestamp;
  }

  /**
   * The stakes for each stakeholder.
   */
  mapping(address => Stake) public stakes;

  function stake(
    address stackholder,
    address tokenAddress0,
    address tokenAddress1,
    uint256 tokenId0,
    uint256 tokenId1,
    uint256 amount0,
    uint256 amount1
  ) public {
    require(stakes[stackholder].tokenId0 == 0, "You already have a staked token");

    stakes[stackholder] = Stake({
      tokenId0: tokenId0,
      tokenId1: tokenId1,
      amount0: amount0,
      amount1: amount1,
      tokenAddress0: tokenAddress0,
      tokenAddress1: tokenAddress1,
      timestamp: uint96(block.timestamp)
    });
    IERC1155(tokenAddress0).safeTransferFrom(stackholder, address(this), tokenId0, amount0, "0x00");
    IERC1155(tokenAddress1).safeTransferFrom(stackholder, address(this), tokenId1, amount1, "0x00");

    emit Staking(
      stackholder,
      tokenAddress0,
      tokenAddress1,
      uint96(block.timestamp),
      tokenId0,
      tokenId1,
      amount0,
      amount1,
      true
    );
  }

  /**
   * A method for a stakeholder to unstake a token.
   */
  function unstake() public {
    Stake memory userStake = stakes[msg.sender];

    require(
      block.timestamp >= (userStake.timestamp + 1 days),
      "You need to wait 24 hours before unstake"
    );

    IERC1155(userStake.tokenAddress0).safeTransferFrom(
      address(this),
      msg.sender,
      userStake.tokenId0,
      userStake.amount0,
      "0x00"
    );
    IERC1155(userStake.tokenAddress1).safeTransferFrom(
      address(this),
      msg.sender,
      userStake.tokenId1,
      userStake.amount1,
      "0x00"
    );

    emit Staking(
      msg.sender,
      userStake.tokenAddress0,
      userStake.tokenAddress1,
      uint96(block.timestamp),
      userStake.tokenId0,
      userStake.tokenId1,
      userStake.amount0,
      userStake.amount1,
      false
    );
    delete stakes[msg.sender];
  }

  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
  }

  function onERC1155BatchReceived(
    address,
    address,
    uint256[] calldata,
    uint256[] calldata,
    bytes calldata
  ) external pure override returns (bytes4) {
    revert("Batch transfer does not support");
  }
}
