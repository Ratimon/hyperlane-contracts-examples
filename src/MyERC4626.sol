// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin-5_2_0/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin-5_2_0/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/utils/SafeERC20.sol";

/// @custom:security-contact Consult full code at https://github.com/OpenZeppelin/openzeppelin-contracts
contract MyERC4626 is ERC4626, Ownable {
    using SafeERC20 for IERC20 ;
    constructor(IERC20 asset, address initialOwner)
        ERC4626(asset)
        ERC20("MyERC4626", "ME")
        Ownable(initialOwner)
    {}
}
