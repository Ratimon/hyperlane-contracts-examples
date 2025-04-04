// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {HypERC20Collateral} from "@hyperlane-core/token/HypERC20Collateral.sol";

/// @custom:security-contact Consult full code at https://github.com/hyperlane-xyz/hyperlane-monorepo/blob/main/solidity/contracts/token/extensions/HypERC4626OwnerCollateral.sol
contract HypERC4626OwnerCollateral is HypERC20Collateral {
    ERC4626 public immutable vault;
    uint256 public constant PRECISION = 1e10;
    uint256 public assetDeposited;
    uint32 public rateUpdateNonce;
     event ExcessSharesSwept(uint256 amount, uint256 assetsRedeemed);

    constructor(ERC4626 _vault, uint256 _scale, address _mailbox)
        HypERC20Collateral(_vault.asset(), _scale, _mailbox)
    {
        vault = _vault;
    }

    function initialize(address _hook, address _interchainSecurityModule, address _owner)
        public
        override initializer
    {
        wrappedToken.approve(address(vault), type(uint256).max);
        _MailboxClient_initialize(_hook, _interchainSecurityModule, _owner);
    }

    function _transferFromSender(uint256 _amount)
        internal
        override
        returns (bytes memory metadata)
    {
        super._transferFromSender(_amount);
        _depositIntoVault(_amount);
        rateUpdateNonce++;

        return abi.encode(PRECISION, rateUpdateNonce);
    }

    function _depositIntoVault(uint256 _amount) internal {
        assetDeposited += _amount;
        vault.deposit(_amount, address(this));
    }

    function _transferTo(address _recipient, uint256 _amount, bytes calldata )
        internal
        virtual override
    {
        _withdrawFromVault(_amount, _recipient);
    }

    function _withdrawFromVault(uint256 _amount, address _recipient) internal {
        assetDeposited -= _amount;
        vault.withdraw(_amount, _recipient, address(this));
    }

    function sweep() external onlyOwner {
        uint256 excessShares = vault.maxRedeem(address(this)) -
            vault.convertToShares(assetDeposited);
        uint256 assetsRedeemed = vault.redeem(
            excessShares,
            owner(),
            address(this)
        );
        emit ExcessSharesSwept(excessShares, assetsRedeemed);
    }
}
