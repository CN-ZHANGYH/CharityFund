// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.10;

// 整个详细的溯源信息包括: 
//  1.用户捐款的金额和溯源信息
//  2.代理机构作为金额账户管理
//  3.提现的用户根据认证信息可以提现
contract DonationTrace {
    
    uint256 donationTraceId;    // 公益慈善溯源ID

    address donorAddress;       // 捐款人地址

    uint256 amount;             // 捐款金额

    uint256 transTime;          // 交易时间

    string  transType;          // 交易类型

    uint256 raiseId;            // 公益集资活动ID

    bool    isWithdraw;         // 交易状态

    string  source;             // 捐款来源：来源，可以是个人、组织、企业等。

    string  desc;               // 捐款描述：具体用途，例如救灾、扶贫、医疗救助等。

    address destAddress;        // 捐款接收方机构

    address withdrawAddress;    // 提现的用户地址

    uint8   status;             // 当前的公益慈善溯源状态：1 募资中 2 完成  3 提现

    address[] traceAddress;     // 溯源的地址

    uint256[] traceTime;        // 溯源的时间


    // 初始化公益慈善捐款的上链信息
    constructor(
        uint256 _donationTraceId,
        address _donorAddress,
        address _destAddress,
        uint256 _amount,
        string memory _transType,
        string memory _source,
        string memory _desc,
        uint256 _raiseId
    ) public {
        donationTraceId = _donationTraceId;
        donorAddress = _donorAddress;
        destAddress = _destAddress;
        amount = _amount;
        transType = _transType;
        source = _source;
        desc = _desc;
        raiseId = _raiseId;
        transTime = now;
        status = 1;
        isWithdraw = false;

        traceAddress.push(_donorAddress);
        traceAddress.push(_destAddress);
        traceTime.push(transTime);
    }


    // 更新当前的慈善捐赠的状态
    function updateTraceStatus(address _orgAddress,uint8 _status) public  returns(uint256) {
        // 判断当前是不是机构的地址
        uint256 res_code = 200;
        if (_orgAddress != destAddress) {
            res_code = 50001;
            return res_code;
        }
        status = _status;
        return res_code;
    }


    // 更新当前用户从代理机构提现之后的状态
    function verifyWithdraw(address _orgAddress,address _withdrawAddress) public returns(uint256) {
        uint256 res_code = 200;
        if (_orgAddress != destAddress) {
            res_code = 50001;
            return res_code;
        }
        status = 3;
        isWithdraw = true;
        traceTime.push(now);
        traceAddress.push(_withdrawAddress);
        return res_code;

    }

    // 查询当前的公益慈善捐款的溯源信息
    function selectTraceInfo() public returns(
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
        return(donationTraceId,donorAddress,destAddress,amount,transTime,transType,source,desc,isWithdraw,status,raiseId);
    }

    // 查询当前的公益捐款溯源地址和溯源时间
    function selectTraceAddressAndTime() public  returns(address[] memory,uint256[] memory) {
        return(traceAddress,traceTime);
    }
    
}