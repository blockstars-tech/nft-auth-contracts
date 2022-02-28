//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract StakingToken is ERC1155Receiver, Ownable {
  event Staking(
    address indexed stakeholder,
    uint256 indexed tokenId,
    uint256 amount,
    uint256 timestamp,
    bool indexed stake
  );

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
  function stake(
    IERC1155 tokenAddress,
    uint256 tokenId,
    uint256 amount
  ) public {
    require(stakes[msg.sender].tokenId == 0, "You already have a staked token");

    stakes[msg.sender] = Stake({ tokenId: tokenId, amount: amount, timestamp: block.timestamp });
    IERC1155(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId, amount, "0x00");

    emit Staking(msg.sender, tokenId, amount, block.timestamp, true);
  }

  /**
   * A method for a stakeholder to unstake a token.
   *
   * @param tokenAddress The token contract address.
   */
  function unstake(IERC1155 tokenAddress) public {
    IERC1155(tokenAddress).safeTransferFrom(
      address(this),
      msg.sender,
      stakes[msg.sender].tokenId,
      stakes[msg.sender].amount,
      "0x00"
    );

    emit Staking(
      msg.sender,
      stakes[msg.sender].tokenId,
      stakes[msg.sender].amount,
      block.timestamp,
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
    return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
  }
}
