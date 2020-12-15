pragma solidity ^0.6.6;
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// TODO: will need to update uniswapPair in TREEReserve to reflect TREE/DAI


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedAmount) public virtual returns (bool)
}

interface IUniswapRouterv2Router01 {
    function swapExactTokensForTokens(uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline) external returns (uint[] memory amounts);
}

contract Reserve2 {
    using SafeMath for uint256;

    event Pledge(uint256 _numCampaign, address _addr, uint256 _amount);
    event Unpledge(uint256 _numCampaign, address _addr, uint256 _amount);
    event Rebase(uint256 _id);
    event ReserveTransfer(address _token, address _to, uint256 _amount);

    // https://github.com/dapphub/ds-dach/blob/49a3ccfd5d44415455441feeb2f5a39286b8de71/src/dach.sol
    address constant public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    // https://github.com/Uniswap/uniswap-v2-core/blob/4dd59067c76dea4a0e8e4bfdda41877a6b16dedc/contracts/UniswapV2Pair.sol#L16
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));


    IUniswapV2Router01 public router;
    address public tree;
    address public gov;
    address public charity;

    struct Campaign {
        uint256 totalPledged;
        uint256 numPledgers;
        uint256 treeSold;
        mapping (uint256 => address) pledgers;
        mapping (address => uint256) amountsPledged;
    }

    uint256 private numCampaigns = 1;

    mapping(uint256 => Campaign) private campaigns;
 
    constructor(address _router, address _tree, address _gov, address _charity) public {
        router = IUniswapV2Router01(_router);
        gov = _gov;
        charity = _charity;
    }

    
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external override returns (uint256[] memory amounts) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');

        Campaign storage c = campaigns[numCampaigns];
        require(c.totalPledged >= amountIn, "Not enough DAI pledged. Rebase postponed.");

        IERC20(DAI).increaseAllowance(address(this), c.totalPledged);

        // https://github.com/WhalerDAO/tree-contracts/blob/4525d20def8fce41985f0711e9b742a0f3c0d30b/contracts/TREEReserve.sol#L230
        tree = address(path[0])
    
        // Send TREE to each pledger
        for (uint i=1; i< c.numPledgers+1; i++) {
            
            // Calculate proportion of TREE to give to each address
            address pledger = c.pledgers[i];
            uint256 valuePledged = c.amountsPledged[pledger];

            // treeToReceive = value pledged * (amountIn / totalPledged)
            // For example, if 100 DAI is pledged and there's only 50 TREE available
            // an address that pledged 5 DAI would receive 5 * (50/100) = 2.5 TREE
            uint256 treeToReceive = valuePledged.mul(amountIn).div(c.totalPledged);

            // TREE is already approved to transfer
            // https://github.com/WhalerDAO/tree-contracts/blob/4525d20def8fce41985f0711e9b742a0f3c0d30b/contracts/TREEReserve.sol#L228
            IERC20(tree).transfer(pledger, treeToReceive);
        }

        numCampaigns++;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amountIn;
        amounts[1] = c.totalPledged;
    }


    function pledge(uint256 _amount) public payable returns (bool) {
        Campaign storage c = campaigns[numCampaigns];

        // add value to total pledged
        // TODO: handle incoming DAI
        c.totalPledged = c.totalPledged + _amount;

        uint256 pledgerId = getPledgerId(numCampaigns, msg.sender);
        if (pledgerId == 0) {
            // user has not pledged before
            pledgerId = c.numPledgers++;
            c.pledgers[pledgerId] = msg.sender;
            c.amountsPledged[msg.sender] = _amount;
        } else {
            // user has pledged before, add to their total pledged
            c.amountsPledged[msg.sender] = c.amountsPledged[msg.sender].add(_amount);
        }

        // TODO: handle pledge token

        emit Pledge(numCampaigns, msg.sender, _amount);

    }

    function unpledge(uint256 _amount) public payable {
        Campaign storage c = campaigns[numCampaigns];

        uint256 pledgerId = getPledgerId(numCampaigns, msg.sender);
        require(pledgerId != 0, "User has not pledged.");
        require(_amount <= c.amountsPledged[msg.sender], "Cannot unpledge more than already pledged.");

        c.totalPledged = c.totalPledged.sub(_amount);
        c.amountsPledged[msg.sender] = c.amountsPledged.sub(_amount);

        // TODO: handle unpledge token

        emit Unpledge(numCampaigns, msg.sender, _amount);
    }

    function reserveTransfer(address _token, address _to) public {
        require(msg.sender == gov, "msg.sender is not gov");
        amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, amount);
        emit ReserveTransfer(_token, _to, amount);
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

    function getCampaignTotalPledged(uint256 _numCampaign) public view returns (uint256) {
        Campaign storage c = campaigns[_numCampaign];
        return c.totalPledged;
    }

    function getNumCampaigns() public view returns (uint256) {
        return numCampaigns;
    }
}