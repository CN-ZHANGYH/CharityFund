pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;


import "./CharityService.sol";
import "./CharityTrace.sol";
import "./DonationTrace.sol";

contract CharityController is CharityService {
    
    
    
    constructor() public {
        init_user(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,"zhangsan","441622200305132857");
        updateUserBalance(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,10000);
        InitiateFundRaising("医药费","没有钱购买医药费了",0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,1728173123,1728179999,10000);
        donatedFunds(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,100,"微信","个人","用于捐款提供帮助",1);
        InitiateWelfareActivitie("灾区捐赠",17232323,17943093,"顺丰快递",0x617F2E2fD72FD9D5503197092aC168c91465E7f2,0x17F6AD8Ef982297579C203069C1DbfFE4348c372);
        donatedMaterials(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,1,"衣服",10,0x617F2E2fD72FD9D5503197092aC168c91465E7f2,0x17F6AD8Ef982297579C203069C1DbfFE4348c372,1);
        addLogisticsTrace(0x617F2E2fD72FD9D5503197092aC168c91465E7f2,1);
        addSignTrace(0x17F6AD8Ef982297579C203069C1DbfFE4348c372, 1);
    }
    
    // 1.加载用户的业务
    
    
    // 2.加载慈善公益的业务
    
    
    // 3.用户的业务操作
    
    uint256 charityIndex;
    uint256 donationIndex;
    
    
    // ID映射用户捐赠物资交易上链 => mapping
    mapping(uint256 => address) public charityTraceAddressMap;
    
    // ID映射用户捐款交易上链 => mapping
    mapping(uint256 => address) public donationTraceAddressMap;
    
    // 存放用户捐赠物资的所有ID
    uint256[] charityTraceIds;
    
    // 存放用户捐款的所有ID
    uint256[] donationTraceIds;
    
    
    // 用户捐款
    function donatedFunds(
        address _donorAddress,
        address _destAddress,
        uint256 _amount,
        string memory _transType,
        string memory _source,
        string memory _desc,
        uint256 _raiseId
    ) public returns(uint256) {
        uint256 res_code = 200;
        // 查询当前用户的信息
        if (_donorAddress == address(0) || _destAddress == address(0)) {
            res_code = 50000; // 参数无效
            return res_code;
        }
        
        User storage _user = userMap[_donorAddress];
        CharityRaiseFund storage _charityRaiseFund = charityRaiseFundMap[_raiseId];
        
        // 查询当前的公益募资活动的信息
        if (_charityRaiseFund.promoterAddress == address(0)) {
            res_code = 50002;   // 公益活动不存在
            return res_code;
        }        
        
        // 创建交易信息上链
        donationIndex++;
        DonationTrace donationTransaction = new DonationTrace(donationIndex,_donorAddress,_destAddress,_amount,_transType,_source,_desc,_raiseId);
        donationTraceAddressMap[donationIndex] = address(donationTransaction);
        donationTraceIds.push(donationIndex);
        
        // 完成公益募资活动的业务操作
        _user.donateList.push(donationIndex);
        _user.amount = _user.amount.sub(_amount);
        _user.credit = _user.credit.add(50);
        raisePeoplesMap[_raiseId].push(_donorAddress);
        raiseDonationTransIdsMap[_raiseId].push(donationIndex);
        
        // 更新当前的公益活动的状态信息
        _charityRaiseFund.totalPeople = _charityRaiseFund.totalPeople.add(1);
        _charityRaiseFund.overAmount = _charityRaiseFund.overAmount.add(_amount);
        
    }

    function selectDonationTraceInfo(uint256 _dontaionTransId) public returns(
        uint256,
        address,
        address,
        uint256,
        uint256,
        string memory,
        string memory,
        string memory,
        bool,
        uint8,
        uint256
    ) {
        address _donationAddress = donationTraceAddressMap[_dontaionTransId];
        DonationTrace donationTransaction = DonationTrace(_donationAddress);
        return donationTransaction.selectTraceInfo();
    }

    // 查询当前的公益捐款溯源地址和溯源时间
    function selectDonationTraceAddressAndTime(uint256 _dontaionTransId) public returns(address[] memory,uint256[] memory) {
        address _donationAddress = donationTraceAddressMap[_dontaionTransId];
        DonationTrace donationTransaction = DonationTrace(_donationAddress);
        return donationTransaction.selectTraceAddressAndTime();
    }
    
    // 用户的捐赠物资
    function donatedMaterials(
        address _userAddress,
        uint8 _materialType,
        string memory _materialName,
        uint256 _materialCount,
        address _logisticAddress,
        address _destAddress,
        uint256 _activiteId
    ) public returns(uint256) {
        uint256 res_code = 200;

        // 查询当前用户的信息
        User storage _user = userMap[_userAddress];
        CharityActivitie storage _charityActivite = charityActivitieMap[_activiteId];
        // 查询当前的公益物资捐赠活动的信息
        
        
        // 创建交易信息上链
        charityIndex++;
        CharityTrace charityTransaction = new CharityTrace(charityIndex,_materialType,_materialName,_materialCount,_userAddress,_logisticAddress,_destAddress,_activiteId);
        charityTraceAddressMap[charityIndex] = address(charityTransaction);
        charityTraceIds.push(charityIndex);


        // 完成公益募资活动的业务操作
        _user.welfareList.push(charityIndex);
        _user.credit  = _user.credit.add(100);
        _charityActivite.totalPeople = _charityActivite.totalPeople.add(1);
        _charityActivite.totalMaterias = _charityActivite.totalMaterias.add(_materialCount);

        activitePeoplesMap[_activiteId].push(_userAddress);
        activiteCharityTransIdsMap[_activiteId].push(charityIndex);
        return res_code;
    }

    // 查询当前的溯源信息
    function selectCharityTraceInfo(uint256 _activiteId) public view returns(
        uint256,
        uint8,
        string memory,
        uint256,
        uint256,
        bool,
        uint8,
        uint256,
        address[] memory,
        uint256[] memory
    ) {
        address _charityAddress = charityTraceAddressMap[_activiteId];
        CharityTrace charityTrace = CharityTrace(_charityAddress);
        return charityTrace.selectCharityTrace();
    }


    // 物流商进行添加物资物流溯源信息
    function addLogisticsTrace(
        address _logisticAddress,
        uint256 _activiteId
    ) public {
        address _charityAddress = charityTraceAddressMap[_activiteId];
        CharityTrace charityTrace = CharityTrace(_charityAddress);
        charityTrace.updateLogisticInfo(_logisticAddress);
    }
    


    // 代理机构对物资进行签收处理
    function addSignTrace(
        address _signAddress,
        uint256 _activiteId
    ) public  {
        address _charityAddress = charityTraceAddressMap[_activiteId];
        CharityTrace charityTrace = CharityTrace(_charityAddress);
        charityTrace.verifySign(_signAddress);
    }
}