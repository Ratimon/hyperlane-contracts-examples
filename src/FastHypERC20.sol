// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {FastTokenRouter} from "@hyperlane-core/token/libs/FastTokenRouter.sol";
import {HypERC20} from "@hyperlane-core/token/HypERC20.sol";
import {TokenRouter} from "@hyperlane-core/token/libs/TokenRouter.sol";

/// @custom:security-contact Consult full code at https://github.com/hyperlane-xyz/hyperlane-monorepo/blob/main/solidity/contracts/token/extensions/FastHypERC20.sol
contract FastHypERC20 is HypERC20, FastTokenRouter {
    constructor(uint8 __decimals, uint256 _scale, address _mailbox)
        HypERC20(__decimals, _scale, _mailbox)
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
        _mint(_recipient, _amount);
    }

    function _fastRecieveFrom(address _sender, uint256 _amount) internal override {
        _burn(_sender, _amount);
    }

    function balanceOf(address _account)
        public
        view
        virtual override(HypERC20, TokenRouter)
        returns (uint256)
    {
        return ERC20Upgradeable.balanceOf(_account);
    }
}
