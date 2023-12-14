// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.10;

// 整个详细的溯源信息包括: 
//  1.用户捐赠物资的溯源信息
//  2.物流商添加物流信息的溯源信息
//  3.代理机构签收物资的溯源信息

contract CharityTrace {

    uint256 charityTraceId;     // 公益活动溯源ID
        
    uint8   materialType;       // 种类：记录需要派送的物资种类，例如食品、饮用水、医疗用品、衣物等。

    string  materialName;       // 物资的名称
        
    uint256 materialCount;      // 物资的数量
        
    address sourceAddress;      // 源地址

    address logisticAddress;    // 物流商地址
        
    address destAddress;        // 目标地址
       
    uint256 transTime;          // 交易时间
        
    bool    isSign;             // 是否签收
        
    uint256 activitId;          // 公益活动ID

    uint8   status;             // 溯源状态： 1 开始 2 运输 3 签收 


    address[] public traceAddress;    // 溯源的地址
    uint256[] public traceTime;       // 溯源的时间

    // 初始化当前的公益活动捐赠物资溯源上链信息
    constructor(
        uint256 _charityTraceId,
        uint8 _materialType,
        string memory _materialName,
        uint256 _materialCount,
        address _sourceAddress,
        address _logisticAddress,
        address _destAddress,
        uint256 _activitId
    ) public {
        charityTraceId = _charityTraceId;
        materialType = _materialType;
        materialName = _materialName;
        materialCount = _materialCount;
        sourceAddress = _sourceAddress;
        logisticAddress = _logisticAddress;
        destAddress = _destAddress;
        transTime = now;
        isSign = false;
        activitId = _activitId;
        status = 1;

        traceAddress.push(_sourceAddress);
        traceAddress.push(_logisticAddress);
        traceAddress.push(_destAddress);

        traceTime.push(transTime);
        
    }

    // 更新当前的物流信息
    function updateLogisticInfo(address _logisticAddress) public returns(uint256) {
        uint256 res_code = 200;
        if (status != 1) {
            res_code = 50001;   // 50001: 订单状态异常
            return res_code;
        }
        if (_logisticAddress != logisticAddress) {
            res_code = 70001;   // 70001: 当前的物流商地址不符合
            return res_code;
        }
        uint256 time = now;
        traceTime.push(time);
        status = 2;
        return res_code;
    }

    // 更新当前的物流签收状态
    function verifySign(address _signAddress) public returns (uint256) {
        uint256 res_code = 200;
        if (status != 2) {
            res_code = 50001;   // 50001: 订单状态异常
            return res_code;
        }
        if (_signAddress != destAddress) {
            res_code = 70002;   // 70002: 当前的签收人地址不符合
            return res_code;
        }
        // 更新当前的签收状态 和添加签收的物流商地址和签收人地址
        isSign = true;
        uint256 time = now;
        traceTime.push(time);
        status = 3;
        return res_code;
    }

    // 查询当前的溯源信息
    function selectCharityTrace() public view  returns(
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
        return(charityTraceId,materialType,materialName,materialCount,transTime,isSign,status,activitId,traceAddress,traceTime);
    }

}


