// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {HypERC20Collateral} from "@hyperlane-core/token/HypERC20Collateral.sol";
import {TokenMessage} from "@hyperlane-core/token/libs/TokenMessage.sol";
import {TypeCasts} from "@hyperlane-core/libs/TypeCasts.sol";

/// @custom:security-contact Consult full code at https://github.com/hyperlane-xyz/hyperlane-monorepo/blob/main/solidity/contracts/token/extensions/HypERC4626Collateral.sol
contract HypERC4626Collateral is HypERC20Collateral {
    using TypeCasts for address ;
    using TokenMessage for bytes ;
    ERC4626 public immutable vault;
    uint256 public constant PRECISION = 1e10;
    bytes32 public constant NULL_RECIPIENT =
        0x0000000000000000000000000000000000000000000000000000000000000001;
    uint32 public rateUpdateNonce;

    constructor(ERC4626 _vault, uint256 _scale, address _mailbox)
        HypERC20Collateral(_vault.asset(), _scale, _mailbox)
    {
        vault = _vault;
    }

    function initialize(address _hook, address _interchainSecurityModule, address _owner)
        public
        override initializer
    {
        _MailboxClient_initialize(_hook, _interchainSecurityModule, _owner);
    }

    function _transferRemote(uint32 _destination, bytes32 _recipient, uint256 _amount, uint256 _value, bytes memory _hookMetadata, address _hook)
        internal
        virtual override
        returns (bytes32 messageId)
    {
         // Can't override _transferFromSender only because we need to pass shares in the token message
        _transferFromSender(_amount);
        uint256 _shares = _depositIntoVault(_amount);
        uint256 _exchangeRate = vault.convertToAssets(PRECISION);

        rateUpdateNonce++;
        bytes memory _tokenMetadata = abi.encode(
            _exchangeRate,
            rateUpdateNonce
        );

        bytes memory _tokenMessage = TokenMessage.format(
            _recipient,
            _shares,
            _tokenMetadata
        );

        messageId = _Router_dispatch(
            _destination,
            _value,
            _tokenMessage,
            _hookMetadata,
            _hook
        );

        emit SentTransferRemote(_destination, _recipient, _shares);
    }

    function _depositIntoVault(uint256 _amount) internal returns (uint256) {
        wrappedToken.approve(address(vault), _amount);
        return vault.deposit(_amount, address(this));
    }

    function _transferTo(address _recipient, uint256 _amount, bytes calldata )
        internal
        virtual override
    {
         // withdraw with the specified amount of shares
        vault.redeem(_amount, _recipient, address(this));
    }

    function rebase(uint32 _destinationDomain, bytes calldata _hookMetadata, address _hook)
        public
        payable
    {
        // force a rebase with an empty transfer to 0x1
        _transferRemote(
            _destinationDomain,
            NULL_RECIPIENT,
            0,
            msg.value,
            _hookMetadata,
            _hook
        );
    }
}
