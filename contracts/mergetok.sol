// SPDX-License-Identifier: LYAA

// MERGETOK
// Create ERC20 tokens. Then merge them to create entirely new tokens!
// You can also merge any ERC20 token.
// The more merges, the higher the tier.

// v2

pragma solidity >=0.8.0;

import "./ERC20ApproveFactory.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";

interface MintERC20 {
    function mint(uint256 _amount) external;
}

contract Mergetok {

    // VARIABLES

    // Array of created tokens
    ERC20[] public createdTokensArray;
    mapping(string => address) public createdTokensSymbol;

    // Array of seeded tokens
    address[] public seededTokensArray;
    mapping(address => uint) public seededTokensAmount;

    // Tier of a given token
    mapping(address => uint) public mergedTier;

    // Owner gets all the (fake) ETH
    address payable owner;

    // CONSTRUCTOR

    constructor () {
        owner = payable(msg.sender);
    }

    // EXTERNAL

    // ** createToken **
    // @notice Creates a new base token if symbol doesn't exist yet
    // @notice Else, mint more of the existing token
    // @notice 1M tokens minted per ether, sent to the sender
    function createToken (string memory _name, string memory _symbol) public payable {
        owner.transfer(msg.value);
        if(createdTokensSymbol[_symbol] == address(0)){
            _buildToken(_name, _symbol, msg.value * 1_000_000);
        } else {
            _mintToken(createdTokensSymbol[_symbol], msg.value * 1_000_000);
        }
    }

    // ** mergeToken **
    // @notice Merges two tokens to create a new token
    // @notice Sender must provide X tokens from both contracts
    // @notice X tokens of the new token will be minted
    function mergeToken (address _tokenA, address _tokenB, uint256 _amount) public {
        require(_tokenA != _tokenB, "MERGETOK: can't merge a token with itself!");

        // @dev tokens created from this factory don't need approval
        // @notice Spent tokens go to the contract for other users to claim and play with
        _seedToken(_tokenA, _amount);
        _seedToken(_tokenB, _amount);

        // Compute tier to form the name
        uint256 _tier = computeTier(_tokenA, _tokenB);
        string memory _name = string(abi.encodePacked("mergedToken Tier ", Strings.toString(_tier)));

        // Concatenate symbols
        string memory _symbol = string(abi.encodePacked(IERC20Metadata(_tokenA).symbol(), "_", IERC20Metadata(_tokenB).symbol()));

        // Create new merged token
        address newMergedToken = _buildToken(_name, _symbol, _amount);

        // Store the tier for future merges
        mergedTier[newMergedToken] = _tier;

    }

    // ** seedToken **
    // @notice Seed the contract with an ERC20 token
    function seedToken(address _token, uint256 _amount) public {
        _seedToken(_token, _amount);
    }

    // ** claimSpecificToken **
    // @notice Get a given token from the contract
    function claimSpecificToken(address _token) public {
        require(seededTokensAmount[_token] != 0, "MERGETOK: this token hasn't been seeded yet");

        _claimToken(_token);
    }

    // ** claimRandomToken **
    // @notice Get a random token from the contract
    function claimRandomToken() public {
        uint256 number = block.difficulty % seededTokensArray.length;

        _claimToken(seededTokensArray[number]);
    }

    // INTERNAL

    // ** _buildToken **
    // @notice Creates a new ERC20 token
    // @notice Tokens are minted to the sender
    function _buildToken (string memory _name, string memory _symbol, uint256 _amount) internal returns(address) {
        ERC20 createdToken = new ERC20(_name, _symbol, _amount);
        createdTokensArray.push(createdToken);
        createdTokensSymbol[_symbol] = address(createdToken);
        IERC20(address(createdToken)).transfer(msg.sender, _amount);
        return(address(createdToken));
    }

    // ** _mintToken **
    // @notice Mints more supply for an existing token
    function _mintToken (address _token, uint256 _amount) internal {
        MintERC20(_token).mint(_amount);
        IERC20(_token).transfer(msg.sender, _amount);
    }

    // ** _seedToken **
    // @notice Seed the contract with an ERC20 token
    function _seedToken(address _token, uint256 _amount) internal {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        // add token to array if it's not there yet
        if(seededTokensAmount[_token] == 0) {
            seededTokensArray.push(_token);
        }

        // increase contract balance
        seededTokensAmount[_token] += _amount;
    }

    // ** _claimToken **
    // @notice Get a given token from the contract
    function _claimToken(address _token) internal {
        uint256 amount = seededTokensAmount[_token] / 2;
        seededTokensAmount[_token] -= amount;
        IERC20(_token).transfer(msg.sender, amount);
    }

    // VIEW ONLY

    // ** computeTier **
    // @notice Computes the tier of a new merged token
    // @notice Two tokens of the same tier produce a tier+1 token
    // @notice In any other case, the tier remains the same
    function computeTier (address _tokenA, address _tokenB) internal view returns(uint256) {
        uint _result;
        if(mergedTier[_tokenA] == mergedTier[_tokenB]) { 
            _result = mergedTier[_tokenA] + 1;
        } else if(mergedTier[_tokenA] > mergedTier[_tokenB]) {
            _result = mergedTier[_tokenA];
        } else {
            _result = mergedTier[_tokenB];
        }
        return _result;
    }

}
