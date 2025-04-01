// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/IERC20.sol";
import {IXERC20} from "@xerc20-1_0_0/interfaces/IXERC20.sol";
import {IXERC20Lockbox} from "@xerc20-1_0_0/interfaces/IXERC20Lockbox.sol";
import {SafeCast} from "@openzeppelin-5_2_0/contracts/utils/math/SafeCast.sol";
import {SafeERC20} from "@openzeppelin-5_2_0/contracts/token/ERC20/utils/SafeERC20.sol";

/// @custom:security-contact Consult full code at https://github.com/defi-wonderland/xERC20
contract MyXERC20Lockbox is IXERC20Lockbox {
    using SafeERC20 for IERC20 ;
    using SafeCast for uint256 ;
    IXERC20 public immutable XERC20;
    IERC20 public immutable ERC20;
    bool public immutable IS_NATIVE;

    constructor(address _xerc20, address _erc20, bool _isNative) {
        XERC20 = IXERC20(_xerc20);
    ERC20 = IERC20(_erc20);
    IS_NATIVE = _isNative;
    }

    receive() external payable {
        depositNative();
    }

    function depositNative() public payable {
        if (!IS_NATIVE) revert IXERC20Lockbox_NotNative();

    _deposit(msg.sender, msg.value);
    }

    function deposit(uint256 _amount) public {
        if (IS_NATIVE) revert IXERC20Lockbox_Native();

    _deposit(msg.sender, _amount);
    }

    function depositTo(address _to, uint256 _amount) external {
        if (IS_NATIVE) revert IXERC20Lockbox_Native();

    _deposit(_to, _amount);
    }

    function depositNativeTo(address _to) external payable {
        if (!IS_NATIVE) revert IXERC20Lockbox_NotNative();

    _deposit(_to, msg.value);
    }

    function withdraw(uint256 _amount) external {
        _withdraw(msg.sender, _amount);
    }

    function withdrawTo(address _to, uint256 _amount) external {
        _withdraw(_to, _amount);
    }

    function _withdraw(address _to, uint256 _amount) internal {
        emit Withdraw(_to, _amount);

    XERC20.burn(msg.sender, _amount);

    if (IS_NATIVE) {
      (bool _success,) = payable(_to).call{value: _amount}('');
      if (!_success) revert IXERC20Lockbox_WithdrawFailed();
    } else {
      ERC20.safeTransfer(_to, _amount);
    }
    }

    function _deposit(address _to, uint256 _amount) internal {
        if (!IS_NATIVE) {
      ERC20.safeTransferFrom(msg.sender, address(this), _amount);
    }

    XERC20.mint(_to, _amount);
    emit Deposit(_to, _amount);
    }
}
