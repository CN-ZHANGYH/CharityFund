pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;

import "./RoleAuth.sol";

// 用户管理合约
contract UserService {
    
    // 用户结构体信息
    struct User {
        uint256 userId;              // 用户ID
        string  userName;            // 用户名称
        address userAddress;         // 用户地址
        uint256 amount;              // 用户账户
        uint256 credit;              // 用户积分
        string  cardId;              // 身份证ID
        string  designation;         // 用户称号
        uint256[] donateList;        // 捐款记录ID
        uint256[] raiseList;         // 募资记录ID
        uint256[] welfareList;       // 公益活动捐赠记录ID
        uint256   voteCount;         // 参与投票的次数
    }

    // 机构结构体信息
    struct Org {
        uint256 orgId;              // 用户ID
        string  orgName;            // 用户名称
        address orgAddress;         // 用户地址
        uint256 amount;             // 用户账户
        uint256[] activitiesList;   // 灾区活动发起记录ID

    }

    // 物流商结构体信息
    struct Logistic {
        uint256 logisticId;              // 用户ID
        string  logisticName;            // 用户名称
        address logisticAddress;         // 用户地址
    }
    
    
    // 配置用户的权限
    RoleAuth public rolesAuth = new RoleAuth();
    

    uint256 public userCount;
    uint256 public orgCount;
    uint256 public logisticCount;
    
    mapping (address=>User) public userMap;
    mapping (address=>Org) public orgMap;
    mapping (address=>Logistic) public logisticMap;

    event Registered(address indexed user,uint256 indexed time);

    

    function init_user(
        address _userAddress,
        string memory _userName,
        string memory _cardId
    ) public returns(uint256) {
        // 初始化返回值
        uint256 res_code = 200;
        // 判断当前的用户是否存在
        if (userMap[_userAddress].userAddress != address(0)) {
            // 用户已经存在返回600001
            res_code = 600001;
            return res_code;
        }

        // 用户注册
        userCount++;
        User storage _user = userMap[_userAddress];
        _user.userId = userCount;
        _user.userName = _userName;
        _user.userAddress = _userAddress;
        _user.cardId = _cardId;
        _user.amount = 0;
        _user.credit = 0;
        _user.donateList = new uint256[](0);
        _user.raiseList = new uint256[](0);
        _user.welfareList = new uint256[](0);
        _user.voteCount = 0;
        
        // 添加用户的权限
        rolesAuth.addUser(_userAddress);
        emit Registered(_userAddress,now);
        return res_code;
    }


    function init_org(
        address _orgAddress,
        string memory _orgName
    ) public returns(uint256) {
        // 初始化返回值
        uint256 res_code = 200;
        // 判断当前的用户是否存在
        if (orgMap[_orgAddress].orgAddress != address(0)) {
            // 用户已经存在返回600001
            res_code = 600001;
            return res_code;
        }
        
        orgCount++;
        Org storage _org = orgMap[_orgAddress];
        _org.orgId = orgCount;
        _org.orgName = _orgName;
        _org.orgAddress = _orgAddress;
        _org.amount = 0;
        _org.activitiesList = new uint256[](0);
        
        // 添加架构的权限
        rolesAuth.addOrg(_orgAddress);
        emit Registered(_orgAddress,now);
        return res_code;
        
    }


    function init_logistic(
        address _logistcAddress,
        string memory _logisticName
    ) public returns(uint256) {
        // 初始化返回值
        uint256 res_code = 200;
        // 判断当前的用户是否存在
        if (logisticMap[_logistcAddress].logisticAddress != address(0)) {
            // 用户已经存在返回600001
            res_code = 600001;
            return res_code;
        }
        
        logisticCount++;
        Logistic storage _logistic = logisticMap[_logistcAddress];
        _logistic.logisticId = logisticCount;
        _logistic.logisticName = _logisticName;
        _logistic.logisticAddress = _logistcAddress;
        
        // 添加物流商的权限
        rolesAuth.addLogistic(_logistcAddress);
        emit Registered(_logistcAddress,now);
        return res_code;
    }
    
    
    function getUserInfo(address _userAddress) public view returns(User memory) {
        return userMap[_userAddress];
    }
    
    function getOrgInfo(address _orgAddress) public view returns(Org memory) {
        return orgMap[_orgAddress];
    }
    
    function getLogisticInfo(address _logisticAddress) public view returns(Logistic memory) {
        return logisticMap[_logisticAddress];
    }
    
    
    
    function updateUserBalance(address _userAddress,uint256 _balance) public {
        userMap[_userAddress].amount += _balance;
    }
    
}
