// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract NeoToken is Initializable, ERC20Upgradeable, Ownable2StepUpgradeable, UUPSUpgradeable {
    address constant OWNER = 0x0F378b9433c674Bc5021908b7a4150C6B0C3704E;
    string constant NAME = "NeoToken";
    string constant SYMBOL = "NEO";
    uint256 constant MAX_SUPPLY = 1e26;
    
    address public minter;

    error MaxSupplyExceeded();
    event MinterChanged(address indexed minter);

    modifier onlyMinter() {
        require(msg.sender == minter, "NeoToken: caller is not the minter");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init(NAME, SYMBOL);
        __Ownable_init(OWNER);
        __UUPSUpgradeable_init();
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
        emit MinterChanged(_minter);
    }

    function mint(address account,uint256 amount) public onlyMinter {
        if (totalSupply() + amount > MAX_SUPPLY) {
            revert MaxSupplyExceeded();
        }
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyMinter {
        _burn(account, amount);
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}