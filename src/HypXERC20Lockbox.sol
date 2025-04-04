// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {HypERC20Collateral} from "@hyperlane-core/token/HypERC20Collateral.sol";
import {IXERC20, IERC20} from "@hyperlane-core/token/interfaces/IXERC20.sol";
import {IXERC20Lockbox} from "@hyperlane-core/token/interfaces/IXERC20Lockbox.sol";

/// @custom:security-contact Consult full code at https://github.com/defi-wonderland/xXERC20Lockbox
contract HypXERC20Lockbox is HypERC20Collateral {
    uint256 constant MAX_INT = 2 ** 256 - 1;
    IXERC20Lockbox public immutable lockbox;
    IXERC20 public immutable xERC20;

    constructor(address _lockbox, uint256 _scale, address _mailbox)
        HypERC20Collateral(address(IXERC20Lockbox(_lockbox).ERC20()), _scale, _mailbox)
    {
        lockbox = IXERC20Lockbox(_lockbox);
        xERC20 = lockbox.XERC20();
        approveLockbox();
        _disableInitializers();
    }

    function approveLockbox() public {
        require(
            IERC20(wrappedToken).approve(address(lockbox), MAX_INT),
            "erc20 lockbox approve failed"
        );
        require(
            xERC20.approve(address(lockbox), MAX_INT),
            "xerc20 lockbox approve failed"
        );
    }

    function initialize(address _hook, address _ism, address _owner)
        public
        override initializer
    {
        approveLockbox();
        _MailboxClient_initialize(_hook, _ism, _owner);
    }

    function _transferFromSender(uint256 _amount)
        internal
        override
        returns (bytes memory)
    {
        // transfer erc20 from sender
        super._transferFromSender(_amount);
        // convert erc20 to xERC20
        lockbox.deposit(_amount);
        // burn xERC20
        xERC20.burn(address(this), _amount);
        return bytes("");
    }

    function _transferTo(address _recipient, uint256 _amount, bytes calldata )
        internal
        override
    {
        // mint xERC20
        xERC20.mint(address(this), _amount);
        // convert xERC20 to erc20
        lockbox.withdrawTo(_recipient, _amount);
    }
}
