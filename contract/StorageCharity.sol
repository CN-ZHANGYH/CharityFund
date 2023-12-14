pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;

import "./StorageData.sol";
import "./SafeMath.sol";
contract StorageCharity is StorageData {

    using SafeMath for uint256;

    // 发起公益活动
    function InitiateWelfareActivitie(
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
        _charityRaiseFund.evaluations = new uint256[](0);
        _charityRaiseFund.peoples = new address[](0);
    }




    // 发起公益集资
    function InitiateFundRaising(
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
        _charityActivitie.evaluations = new uint256[](0);
        _charityActivitie.peoples = new address[](0);

    }



    // 进行募资捐款
    function Donate(
        address _donorAddress,
        uint256 _amount,
        string memory _transType,
        string memory _source,
        string memory _desc,
        address _destAddress,
        uint256 _raiseId
    ) public  returns(uint256) {  
        uint256 res_code = 200;
        // 判断当前的用户和捐款接收方机构是否存在
        if (userMap[_donorAddress].userAddress != address(0) || orgMap[_destAddress].orgAddress != address(0)) {
            res_code = 600001;
            return res_code;
        }

        // 查询用户信息
        User storage _donorUser = userMap[_donorAddress];
        // 查询公益集资活动信息
        CharityRaiseFund storage _charityRaiseFund = charityRaiseFundMap[_raiseId];
        _charityRaiseFund.totalAmount = _charityRaiseFund.totalAmount.add(_amount);
        _charityRaiseFund.totalPeople = _charityRaiseFund.totalPeople.add(1);
        _charityRaiseFund.peoples.push(_donorAddress);


        _donorUser.amount = _donorUser.amount.sub(_amount);

        
        return res_code;
        
    }
    



    // 进行物资捐赠


    // 更新当前的公益募资活动的票选结果
    function updateVoteResults(uint256 _raiseId,bool _isFlag) public returns(bool){
        CharityRaiseFund storage _charityRaiseFund = charityRaiseFundMap[_raiseId];
        uint256 isYes = _charityRaiseFund.isYes;
        uint256 isNo = _charityRaiseFund.isNo;

        // 如果同意则票数+1
        if (_isFlag) {
            _charityRaiseFund.isYes = isYes.add(1);
        }else {
            if (isNo != 0) {
                _charityRaiseFund.isNo = isNo.sub(1);
            }
            _charityRaiseFund.isNo = 0;
        }

        // 校验当前的票数
        if (_charityRaiseFund.isYes > _charityRaiseFund.isNo) {
            return true;
        }
        return false;

    }


    function getWelfareActivitieInfo(uint256 _activitieId) public view returns(CharityActivitie memory){
        return charityActivitieMap[_activitieId];
    }

    function getFundRaisingInfo(uint256 _raiseId) public view returns(CharityRaiseFund memory){
        return charityRaiseFundMap[_raiseId];
    }

}