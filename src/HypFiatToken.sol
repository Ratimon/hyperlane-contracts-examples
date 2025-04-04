// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {HypERC20Collateral} from "@hyperlane-core/token/HypERC20Collateral.sol";
import {IFiatToken} from "@hyperlane-core/token/interfaces/IFiatToken.sol";

/// @custom:security-contact Consult full code at https://github.com/defi-wonderland/xFiatToken
contract HypFiatToken is HypERC20Collateral {
    constructor(address _fiatToken, uint256 _scale, address _mailbox)
        HypERC20Collateral(_fiatToken, _scale, _mailbox)
    {}

    function _transferFromSender(uint256 _amount)
        internal
        override
        returns (bytes memory metadata)
    {
        // transfer amount to address(this)
        metadata = super._transferFromSender(_amount);
        // burn amount of address(this) balance
        IFiatToken(address(wrappedToken)).burn(_amount);
    }

    function _transferTo(address _recipient, uint256 _amount, bytes calldata )
        internal
        override
    {
        // transfer amount to address(this)
        require(
            IFiatToken(address(wrappedToken)).mint(_recipient, _amount),
            "FiatToken mint failed"
        );
    }
}
