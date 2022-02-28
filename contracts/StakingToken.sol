//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract StakingToken is ERC1155Receiver, Ownable {
  event Staking(
    address indexed stakeholder,
    address indexed tokenAddress,
    uint96 timestamp,
    uint256 tokenId,
    uint256 amount,
    bool indexed stake
  );

  /**
   * A stake struct is used to represent the way we store stakes,
   */
  struct Stake {
    uint256 tokenId;
    uint256 amount;
    address tokenAddress;
    uint96 timestamp;
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
  function stake(
    address tokenAddress,
    uint256 tokenId,
    uint256 amount
  ) public {
    require(stakes[msg.sender].tokenId == 0, "You already have a staked token");

    stakes[msg.sender] = Stake({
      tokenId: tokenId,
      amount: amount,
      tokenAddress: tokenAddress,
      timestamp: uint96(block.timestamp)
    });
    IERC1155(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId, amount, "0x00");

    emit Staking(msg.sender, tokenAddress, uint96(block.timestamp), tokenId, amount, true);
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

    IERC1155(userStake.tokenAddress).safeTransferFrom(
      address(this),
      msg.sender,
      userStake.tokenId,
      userStake.amount,
      "0x00"
    );

    emit Staking(
      msg.sender,
      userStake.tokenAddress,
      uint96(block.timestamp),
      userStake.tokenId,
      userStake.amount,
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
    revert("batch transfer does not supported");
  }
}
