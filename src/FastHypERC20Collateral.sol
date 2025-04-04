// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {FastTokenRouter} from "@hyperlane-core/token/libs/FastTokenRouter.sol";
import {HypERC20Collateral} from "@hyperlane-core/token/HypERC20Collateral.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TokenRouter} from "@hyperlane-core/token/libs/TokenRouter.sol";

/// @custom:security-contact Consult full code at https://github.com/hyperlane-xyz/hyperlane-monorepo/blob/main/solidity/contracts/token/extensions/FastHypERC20Collateral.sol
contract FastHypERC20Collateral is HypERC20Collateral, FastTokenRouter {
    using SafeERC20 for IERC20 ;
    constructor(address erc20, uint256 _scale, address _mailbox)
        HypERC20Collateral(erc20, _scale, _mailbox)
    {}

    function _handle(uint32 _origin, bytes32 _sender, bytes calldata _message)
        internal
        virtual override(FastTokenRouter, TokenRouter)
    {
        FastTokenRouter._handle(_origin, _sender, _message);
    }

    function _fastTransferTo(address _recipient, uint256 _amount)
        internal
        override
    {
        wrappedToken.safeTransfer(_recipient, _amount);
    }

    function _fastRecieveFrom(address _sender, uint256 _amount) internal override {
        wrappedToken.safeTransferFrom(_sender, address(this), _amount);
    }
}
