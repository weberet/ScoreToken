pragma solidity >=0.4.21 <0.7.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/Roles.sol";

contract Schmeckle is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable, ERC20Pausable, Ownable {
    //Variables
    //Contract Definition
    uint256 public coinUnitMultiplier = 1000000000000000000; // = 1 coin
    uint256 deployerMintAmount = coinUnitMultiplier * 100000; //Amount deployer of contract mints for themselves.
    //
    //Identification
    uint256 public tokenInteractorCount = 1; //Default value should be 0; number of individuals who have interacted with or held token.
    mapping(uint256 => address) public tokenInteractors; //Store wallet addresses of those who interact with contract
    mapping(address => uint256) public tokenInteractorID; //Address to ID for reverse lookup
    mapping(address => string) public interactorAlias; //Store self set aliases for token interactors.

    using Roles for Roles.Role;

    Roles.Role private _minters;
    Roles.Role private _burners;
    Roles.Role private _pausers;

    constructor(string memory _name, string memory _symbol, uint8 _decimals)
        ERC20Detailed(_name, _symbol, _decimals)
        public
        {

            //Register original owner acount to account identification mappings
            tokenInteractors[0] = msg.sender; //Owner account is set to index 0
            tokenInteractorID[msg.sender] = 0; //Owner account ID is set to 0

            _mint(msg.sender, deployerMintAmount); //Mint initial supply to owner account

        }

    //Method for assigning default identification to interacting wallets (token holders)
    function addTokenInteractor(address _tInteractor) public{

        if(_tInteractor != owner()){ //Only register non-contract owner users
            if(tokenInteractorID[_tInteractor] == 0){ //If address ID is still set to default 0
                tokenInteractors[tokenInteractorCount] = _tInteractor; //Add wallets that have interacted to mapping.
                tokenInteractorID[_tInteractor] = tokenInteractorCount; //Add mapping for reverse lookup of ID
                tokenInteractorCount++;
            }
        }

    }

    function declareAlias(string memory _declaredAlias) public{
        interactorAlias[msg.sender] = _declaredAlias; //Declare wallet alias
    }

    /* Function overrides (inherrited from OpenZeppelin) */
    /* This section added to override OpenZeppelins native functions to track interacting wallet accounts for things
    such as high score listings and wallet aliases */

    function transfer(address recipient, uint256 amount) public returns (bool) {
        addTokenInteractor(recipient);
        super.transfer(recipient, amount); //Call inherited parent function from OpenZeppelin
    }

    //Function overrides (inherrited from OpenZeppelin)
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        addTokenInteractor(recipient);
        super.transferFrom(sender, recipient, amount); //Call inherited parent function from OpenZeppelin
    }

    //Function overrides (inherrited from OpenZeppelin)
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        addTokenInteractor(account);
        super.mint(account, amount); //Call inherited parent function from OpenZeppelin
    }

}