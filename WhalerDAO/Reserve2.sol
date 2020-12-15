pragma solidity ^0.6.6;
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IUniswapRouterv2Router01 {
    function swapExactTokensForTokens(uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline) external returns (uint[] memory amounts);
}

contract Reserve2 {
    using SafeMath for uint256;

    event Pledge(uint256 _numCampaign, address _addr, uint256 _value);
    event Unpledge(uint256 _numCampaign, address _addr, uint256 _value);
    event Rebase(uint256 _id);
    event ReserveTransfer(address _to, uint256 _value);

    // https://github.com/dapphub/ds-dach/blob/49a3ccfd5d44415455441feeb2f5a39286b8de71/src/dach.sol
    IERC20 public constant dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IUniswapV2Router01 public router;
    address public gov;
    address public charity;

    struct Campaign {
        uint256 totalPledged;
        uint256 numPledgers;
        uint256 treeSold;
        mapping (uint256 => address) pledgers;
        mapping (address => uint256) valuesPledged;
    }

    uint256 private numCampaigns = 1;

    mapping(uint256 => Campaign) private campaigns;
 
    constructor(address _router, address _gov, address _charity) public {
        router = IUniswapV2Router01(_router);
        gov = _gov;
        charity = _charity;
    }

    
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external override returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        
        Campaign storage c = campaigns[numCampaigns];
        require(c.totalPledged >= amountIn, "Not enough DAI pledged. Rebase postponed.");
    
        // Calculate proportion of TREE to give to each address

        // Convert 

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

    function reserveTransfer(address _to) public {
        require(msg.sender == gov, "msg.sender is not gov");
        value = dai.balanceOf(address(this));
        dai.transferFrom(address(this), _to, value);
        emit ReserveTransfer(_to, value);
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