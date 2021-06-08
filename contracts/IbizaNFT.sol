// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract IbizaNFT is Context, AccessControlEnumerable, ERC721Enumerable, ERC721Burnable, ERC721Pausable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant URI_SETTER_ROLE = keccak256('URI_SETTER_ROLE');

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;

    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(URI_SETTER_ROLE, _msgSender());
    }

    /**
    * @dev internal function to get URI base
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
    * @dev set URI base (URI_SETTER_ROLE only)
    * @param _uriBase string for the URI base address
    */
    function setURIBase(string calldata _uriBase) public onlyRole(URI_SETTER_ROLE) {
        _baseTokenURI = _uriBase;
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
/*    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "IbizaNFT: URI set of nonexistent token");
        super.tokenURI[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "IbizaNFT: URI query for nonexistent token");
        return super.tokenURI(tokenId);
    }
*/
    /**
     * @dev See {IERC721Metadata-tokenURI}. Read tokenURI in a tokenID
     * @param tokenId token ID
     * @return token URI string
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "IbizaNFT: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
    * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
    * Requirements:
    * - `tokenId` must exist.
    * @param tokenId token ID
    * @param _tokenURI token URI string
    */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "IbizaNFT: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
    * @dev mint a token based on current enumeration and sends it to a recipient, with tokenURI formed by baseURI + counter
    * @param to recipient address
    */
    function mint(address to) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "IbizaNFT: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    /**
    * @dev mint a token based on a custom id and sends it to a recipient, with tokenURI formed by baseURI + counter
    * @param to recipient address
    * @param tokenId custom token id
    */
    function mintTokenID(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
        _tokenIdTracker.increment();
    }

    /**
    * @dev mint a token based on a custom id and sends it to a recipient, with tokenURI formed by baseURI + custo token URI
    * @param to recipient address
    * @param tokenId custom token id
    * @param _tokenURI custom token URI to add to baseURI
    */
    function mintComplete(address to, uint256 tokenId, string memory _tokenURI) public onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdTracker.increment();
    }

    /**
    * @dev pause the contract
    */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "IbizaNFT: must have pauser role to pause");
        _pause();
    }

    /**
    * @dev unpause the contract
    */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "IbizaNFT: must have pauser role to unpause");
        _unpause();
    }

    /**
    * @dev function called before any token transfer
    */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}