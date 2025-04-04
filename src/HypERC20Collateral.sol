// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {FungibleTokenRouter} from "@hyperlane-core/token/libs/FungibleTokenRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TokenMessage} from "@hyperlane-core/token/libs/TokenMessage.sol";
import {TokenRouter} from "@hyperlane-core/token/libs/TokenRouter.sol";

/// @custom:security-contact Consult full code at https://github.com/defi-wonderland/xERC20
contract HypERC20Collateral is FungibleTokenRouter {
    using SafeERC20 for IERC20 ;
    IERC20 public immutable wrappedToken;

    constructor(address erc20, uint256 _scale, address _mailbox)
        FungibleTokenRouter(_scale, _mailbox)
    {
        require(Address.isContract(erc20), "HypERC20Collateral: invalid token");
        wrappedToken = IERC20(erc20);
    }

    function initialize(address _hook, address _interchainSecurityModule, address _owner)
        public
        virtual initializer 
    {
        _MailboxClient_initialize(_hook, _interchainSecurityModule, _owner);
    }

    function balanceOf(address _account) external view override returns (uint256) {
        return wrappedToken.balanceOf(_account);
    }

    function _transferFromSender(uint256 _amount)
        internal
        virtual override
        returns (bytes memory)
    {
         wrappedToken.safeTransferFrom(msg.sender, address(this), _amount);
        return bytes(""); // no metadata
    }

    function _transferTo(address _recipient, uint256 _amount, bytes calldata _metadata)
        internal
        virtual override
    {
        wrappedToken.safeTransfer(_recipient, _amount);
    }
}
