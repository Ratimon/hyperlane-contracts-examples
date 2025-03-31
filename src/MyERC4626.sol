// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {SafeERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/utils/SafeERC20.sol";

import {IERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/IERC20.sol";

import {ERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin-5_2_0/contracts/token/ERC20/extensions/ERC4626.sol";

import {Ownable} from "@openzeppelin-5_2_0/contracts/access/Ownable.sol";


contract MyERC4626 is ERC4626, Ownable {

    using SafeERC20 for IERC20;

    constructor(
        IERC20 asset,
        address initialOwner
        )
        ERC4626(asset)
        ERC20('Mytoken', 'MT')
        Ownable(initialOwner) {

        }

}

