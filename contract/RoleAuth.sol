pragma solidity ^0.6.10;


import "./Roles.sol";

contract RoleAuth {
    
    using Roles for Roles.Role;
    
    // 创建三个不同的角色权限
    Roles.Role private Org;
    Roles.Role private Logistic;
    Roles.Role private User;
    
    
    // 定义两个常量, 我是用constant可以减少gas消耗 
    bool constant internal IS_ROLE = true;
    bool constant internal NOT_ROLE = false;
    
    // 添加代理机构的权限
    function addOrg(address _userAddress) public {
        require(Org.has(_userAddress) == NOT_ROLE,"当前不是机构");
        Org.add(_userAddress);
    }
    
    
    // 添加物流商的权限
    function addLogistic(address _userAddress) public {
        require(Logistic.has(_userAddress) == NOT_ROLE,"当前不是物流商");
        Logistic.add(_userAddress);
    }

    // 添加用户的权限
    function addUser(address _userAddress) public {
        require(User.has(_userAddress) == NOT_ROLE,"当前不是用户");
        User.add(_userAddress);
    }

    
    function hasOrg(address _userAddress) public returns(bool){
        return Org.has(_userAddress);
    }
     
    function hasLogistic(address _userAddress) public returns(bool){
        return Logistic.has(_userAddress);
    }
     
    function hasUser(address _userAddress) public returns(bool){
        return User.has(_userAddress);
    }
    
}