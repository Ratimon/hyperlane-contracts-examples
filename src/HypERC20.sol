// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {FungibleTokenRouter} from "@hyperlane-core/token/libs/FungibleTokenRouter.sol";
import {TokenRouter} from "@hyperlane-core/token/libs/TokenRouter.sol";

/// @custom:security-contact Consult full code at https://github.com/hyperlane-xyz/hyperlane-monorepo/blob/main/solidity/contracts/token/HypERC20.sol
contract HypERC20 is FungibleTokenRouter, ERC20Upgradeable {
    uint8 private immutable _decimals;

    constructor(uint8 __decimals, uint256 _scale, address _mailbox)
        FungibleTokenRouter(_scale, _mailbox)
    {
        _decimals = __decimals;
    }

    function initialize(uint256 _totalSupply, string memory _name, string memory _symbol, address _hook, address _interchainSecurityModule, address _owner)
        public
        virtual initializer
    {
        // Initialize ERC20 metadata
        __ERC20_init(_name, _symbol);
        _mint(msg.sender, _totalSupply);
        _MailboxClient_initialize(_hook, _interchainSecurityModule, _owner);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function balanceOf(address _account)
        public
        view
        virtual override(TokenRouter, ERC20Upgradeable)
        returns (uint256)
    {
        return ERC20Upgradeable.balanceOf(_account);
    }

    function _transferFromSender(uint256 _amount)
        internal
        override
        returns (bytes memory)
    {
        _burn(msg.sender, _amount);
        return bytes(""); // no metadata
    }

    function _transferTo(address _recipient, uint256 _amount, bytes calldata )
        internal
        virtual override
    {
        _mint(_recipient, _amount);
    }
}
