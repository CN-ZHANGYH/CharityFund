pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;


import "./SafeMath.sol";
import "./UserService.sol";

contract CharityService is UserService {
    
    using SafeMath for uint256;
    
    // 公益活动结构体信息
    // RaiseId => CharityRaiseFund
    struct CharityRaiseFund {
        uint256 raiseId;            // 活动ID
        string  title;              // 活动名称
        string  desc;               // 活动描述
        uint256 createTime;         // 活动创建时间
        address promoterAddress;    // 活动组织者
        uint8   status;             // 活动状态
        uint256 startTime;          // 开始时间
        uint256 endTime;            // 结束时间
        uint256 totalPeople;        // 总参与人数
        uint256 totalAmount;        // 总需金额
        uint256 overAmount;         // 已经完成集资金额
    }
    
    mapping(uint256 => uint256) isYesMap;          // 募资支持的票选结果
    mapping(uint256 => uint256) isNoMap;           // 募资不支持的票选结果
    mapping (uint256 => bool) isApply;             // 募资活动是否支持举行

    mapping(uint256 => uint256[]) raiseEvaluationsMap;      // 活动评估 [4,5,4,2,1]
    mapping(uint256 => address[]) raisePeoplesMap;          // 参与人的溯源地址
    mapping(uint256 => uint256[]) raiseDonationTransIdsMap; // 所有参与人的交易溯源ID

    // 公益捐赠灾区结构体信息
    struct CharityActivitie {
        uint256 activitId;          // 活动ID
        string  title;              // 活动名称
        uint256 createTime;         // 创建时间
        uint256 startTime;          // 开始时间
        uint256 endTime;            // 结束时间
        string  logisticType;       // 物流方式
        address logisticAddress;    // 物流商地址
        address lncomeAddress;      // 代理人地址
        uint8   status;             // 状态
        uint256 totalPeople;        // 总参与人数
        uint256 totalMaterias;      // 总物资数量
    }
    
    mapping(uint256 => uint256[]) activiteEvaluationsMap;      // 活动评估 [4,5,4,2,1]
    mapping(uint256 => address[]) activitePeoplesMap;          // 参与人的溯源地址
    mapping(uint256 => uint256[]) activiteCharityTransIdsMap;  // 所有参与人的交易溯源ID

    uint256 public raiseCount;
    uint256 public activiteCount;


    mapping (uint256=>CharityRaiseFund) public charityRaiseFundMap;
    mapping (uint256=>CharityActivitie) public charityActivitieMap;



    // 物流运输状态
    enum Logistic_Status {STARTING, LOGISTICING,SIGNING,ENDING}

    // 活动状态
    enum Charity_Status {STARTING, CHARITYING,ENDING }

    // 交易状态
    enum Transaction_Status {STARTING, TRANSACTIONING,ENDING }
    
    // 发起公益活动
    function InitiateFundRaising(
        string memory _title,
        string memory _desc,
        address _promoterAddress,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _totalAmount
    ) public {
        // 判断当前的公益活动是否存在

        raiseCount++;
        CharityRaiseFund storage _charityRaiseFund = charityRaiseFundMap[raiseCount];
        _charityRaiseFund.raiseId = raiseCount;
        _charityRaiseFund.title = _title;
        _charityRaiseFund.desc = _desc;
        _charityRaiseFund.createTime = now;
        _charityRaiseFund.promoterAddress = _promoterAddress;
        _charityRaiseFund.status = 1;
        _charityRaiseFund.startTime = _startTime;
        _charityRaiseFund.endTime = _endTime;
        _charityRaiseFund.totalAmount = _totalAmount;
        _charityRaiseFund.totalPeople = 0;
    }


    // 发起公益集资
    function InitiateWelfareActivitie(
        string memory _title,
        uint256 _startTime,
        uint256 _endTime,
        string memory _logisticType,
        address _logisticAddress,
        address _lncomeAddress
    ) public {

        activiteCount++;
        CharityActivitie storage _charityActivitie = charityActivitieMap[activiteCount];
        _charityActivitie.activitId =  activiteCount;
        _charityActivitie.title = _title;
        _charityActivitie.createTime = now;
        _charityActivitie.startTime = _startTime;
        _charityActivitie.endTime = _endTime;
        _charityActivitie.logisticType = _logisticType;
        _charityActivitie.logisticAddress = _logisticAddress;
        _charityActivitie.lncomeAddress = _lncomeAddress;
        _charityActivitie.status = 1;
        _charityActivitie.totalPeople = 0;
        _charityActivitie.totalMaterias = 0;
    }
    
    
    // 对当前的公益募资活动进行反馈以及评分
    function scoringOfRaiseFund(uint256 _raiseId,uint256 _score) public returns(uint256){
        raiseEvaluationsMap[_raiseId].push(_score);
        uint sum = 0; // 初始化总和为 0

        for (uint i = 0; i < raiseEvaluationsMap[_raiseId].length; i++) {
            sum += raiseEvaluationsMap[_raiseId][i]; // 将当前元素的值加到总和中
        }

        uint average = sum / raiseEvaluationsMap[_raiseId].length; // 计算平均值
        return average;
    }
    
    
    // 对当前的公益资产物资捐赠活动进行反馈以及评分
    function scoringOfActivite(uint256 _activitieId,uint256 _score) public returns(uint256) {
        activiteEvaluationsMap[_activitieId].push(_score);
        activiteEvaluationsMap[_activitieId].push(_score);
        uint sum = 0; // 初始化总和为 0

        for (uint i = 0; i < activiteEvaluationsMap[_activitieId].length; i++) {
            sum += activiteEvaluationsMap[_activitieId][i]; // 将当前元素的值加到总和中
        }

        uint average = sum / activiteEvaluationsMap[_activitieId].length; // 计算平均值
        return average;
    }
    
 
    // 查询所有的慈善公益物资捐赠的活动信息
    function getWelfareActivitieInfo(uint256 _activitieId) public view returns(CharityActivitie memory,uint256[] memory,address[] memory,uint256[] memory){
        return (charityActivitieMap[_activitieId],activiteEvaluationsMap[_activitieId],activitePeoplesMap[_activitieId],activiteCharityTransIdsMap[_activitieId]);
    }

    // 查看所有的公益募资的活动信息
    function getFundRaisingInfo(uint256 _raiseId) public view returns(CharityRaiseFund memory,uint256[] memory,address[] memory,uint256[] memory){
        return (charityRaiseFundMap[_raiseId],raiseEvaluationsMap[_raiseId],raisePeoplesMap[_raiseId],raiseDonationTransIdsMap[_raiseId]);
    }
    
    // 对公益募资进行投票管理
    function voteOfRaiseFund(uint256 _raiseId,bool _flag) public returns(bool) {

        // 对当前的公益活动时间内的投票是否有效
        uint256 createTime = charityRaiseFundMap[_raiseId].createTime;
        if (block.timestamp <= createTime + (3 days * 1000)) {
            // 对用户的是否支持票选的结果进行计算
            if (_flag) {
                isYesMap[_raiseId] = isYesMap[_raiseId].add(1);
            }else {
                if (isNoMap[_raiseId] != 0) {
                    isNoMap[_raiseId] = isNoMap[_raiseId].add(1);
                }else {
                    isNoMap[_raiseId] = 0;
                }
            }
            
            if (isYesMap[_raiseId] > isNoMap[_raiseId]) {
                return  true;
            }else {
                return false;
            }
        }else  {
            // 如果当前的时间范围内过期则直接返回false
            return false;
        }
        
    }
    
    // 查询公益活募资的投票情况
    function getVoteInfo(uint256 _raiseId) public view returns(uint256,uint256) {
        return(isYesMap[_raiseId],isNoMap[_raiseId]);
    }
    
    // 查看当前的公益募资是否票举通过
    function getFundRaisingApplyStatus(uint256 _raiseId) public view  returns(bool) {
        return isApply[_raiseId];
    }
}