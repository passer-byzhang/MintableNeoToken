// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract NeoToken is Initializable, ERC20Upgradeable, Ownable2StepUpgradeable, UUPSUpgradeable {
    address constant OWNER = 0x0F378b9433c674Bc5021908b7a4150C6B0C3704E;
    address constant BRIDGE_PROXY = 0x1212000000000000000000000000000000000004;
    string constant NAME = "NeoToken";
    string constant SYMBOL = "NEO";
    uint256 constant MAX_SUPPLY = 1e26;
    
    uint256 public mintQuota;

    error MaxSupplyExceeded();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init(NAME, SYMBOL);
        __Ownable_init(OWNER);
        __UUPSUpgradeable_init();
    }

    function updateMintQuota(uint256 delta) external onlyOwner {
        mintQuota += delta;
    }

    function mint(address account,uint256 amount) public onlyOwner {
        if (totalSupply() + amount > MAX_SUPPLY) {
            revert MaxSupplyExceeded();
        }
        if(account != BRIDGE_PROXY) {
            require(mintQuota >= amount, "NeoToken: mint quota exceeded");
            mintQuota -= amount;
        }
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}