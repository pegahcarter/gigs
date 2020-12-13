pragma solidity ^0.6.6;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface TokenLike {
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
  function approve(address to, uint256 amount) external returns (bool);
  function balanceOf(address to) external returns (uint);
  function join(address to, uint256 amount) external;
  function exit(address from, uint256 amount) external;
}

contract Reserve2 {
    using SafeMath for uint256;
    using Address for address;

    event Pledge(uint256 _numCampaign, address addr, uint256 _value);
    event Unpledge(uint256 _numCampaign, address addr, uint256 _value);
    event Rebase(uint256 _id);

    // https://github.com/dapphub/ds-dach/blob/49a3ccfd5d44415455441feeb2f5a39286b8de71/src/dach.sol
    TokenLike public constant DAI = TokenLike(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    struct Campaign {
        uint256 totalPledged;
        uint256 numPledgers;
        uint256 treeSold;
        mapping (uint256 => address) pledgers;
        mapping (address => uint256) valuesPledged;
    }

    uint256 private numCampaigns = 1;

    mapping(uint256 => Campaign) private campaigns;

    constructor() {
        
    }

    // TODO: override
    function rebase(uint256 _treeSold) public payable {
        Campaign storage c = campaigns[numCampaigns];
        require(c.totalPledged >= _treeSold, "Not enough DAI pledged. Rebase postponed.");
    
        // Calculate proportion of TREE to give to each address

        // Send TREE to each pledger

        // increment numCampaigns
        numCampaigns++;
    }



    function pledge(uint256 _value) public payable returns (bool) {
        Campaign storage c = campaigns[numCampaigns];

        // add value to total pledged
        c.totalPledged = c.totalPledged + _value;

        uint256 pledgerId = getPledgerId(numCampaigns, msg.sender);
        if (pledgerId == 0) {
            // user has not pledged before
            pledgerId = c.numPledgers++;
            c.pledgers[pledgerId] = msg.sender;
            c.valuesPledged[msg.sender] = _value;
        } else {
            // user has pledged before
            c.valuesPledged[msg.sender] = c.valuesPledged[msg.sender].add(_value);
        }

        // TODO: handle plege token

        emit Pledge(numCampaigns, msg.sender, _value);

    }

    function unpledge(uint256 _value) public payable {
        Campaign storage c = campaigns[numCampaigns];

        uint256 pledgerId = getPledgerId(numCampaigns, msg.sender);
        require(pledgerId != 0, "User has not pledged.");
        require(_value <= c.valuesPledged[msg.sender], "Cannot unpledge more than already pledged.");

        c.totalPledged = c.totalPledged.sub(_value);
        c.valuesPledged[msg.sender] = c.valuesPledged.sub(_value);

        // TODO: handle unpledge token

        emit Unpledge(numCampaigns, msg.sender, _value);
    }

    function getPledgerId(uint256 _numCampaign, address _addr) public returns (uint256) {
        Campaign storage c = campaigns[_numCampaign];

        uint256 pledgerId;
        for (uint i=1; i < c.numPledgers+1; i++) {
            address pledger = c.pledgers[i];
            if (pledger == _addr) {
                pledgerId = i;
                break;
            }
        }
        return pledgerId;
    }

    function calculateRewardRatio(uint256 _numCampaign) public returns (uint256) {
        Campaign storage c = campaigns[_numCampaign];
        require(c.treeSold != 0, "Rebase has not occured.");
        // TODO
    }

    function getCampaignTotalPledged(uint256 _numCampaign) public view returns (uint256) {
        Campaign storage c = campaigns[_numCampaign];
        return c.totalPledged;
    }

    function getNumCampaigns() public view returns (uint256) {
        return numCampaigns;
    }
}