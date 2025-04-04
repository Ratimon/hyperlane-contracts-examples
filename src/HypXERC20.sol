// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {HypERC20Collateral} from "@hyperlane-core/token/HypERC20Collateral.sol";
import {IXERC20} from "@xerc20-1_0_0/interfaces/IXERC20.sol";

/// @custom:security-contact Consult full code at https://github.com/defi-wonderland/xXERC20
contract HypXERC20 is HypERC20Collateral {
    constructor(address _xerc20, uint256 _scale, address _mailbox)
        HypERC20Collateral(_xerc20, _scale, _mailbox)
    {
        _disableInitializers();
    }

    function _transferFromSender(uint256 _amountOrId)
        internal
        override
        returns (bytes memory metadata)
    {
        IXERC20(address(wrappedToken)).burn(msg.sender, _amountOrId);
        return "";
    }

    function _transferTo(address _recipient, uint256 _amountOrId, bytes calldata )
        internal
        override 
    {
        IXERC20(address(wrappedToken)).mint(_recipient, _amountOrId);
    }
}
