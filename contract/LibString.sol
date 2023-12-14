
/**
 * @file: LibString
 * @author: fisco-dev
 * 
 * @date: 2018
 */

pragma solidity >=0.4.24 <0.6.10;

library LibString {
    
    using LibString for *;
    
    function bytesToString(bytes memory _bytes) internal pure returns (string memory){
        bytes memory bytesArray = new bytes(_bytes.length);
        for (uint256 i; i < _bytes.length; i++) {
            bytesArray[i] = _bytes[i];
        }
        return string(_bytes);
    }

    function stringToBytes(string memory _string) internal pure returns (bytes memory){
        bytes memory _bytes = bytes(_string);
        return _bytes;
    }
    
 
    function bytes32ToString(bytes32 _bytes32) internal pure returns(string memory){
        bytes memory bytesString = new bytes(32);
        uint charCount = 0 ;
        for(uint i = 0 ; i<32;i++){
            byte char = byte(bytes32(uint(_bytes32) *2 **(8*i)));
            if(char !=0){
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for(uint j=0;j<charCount;j++){
            bytesStringTrimmed[j]=bytesString[j];
        }
        return string(bytesStringTrimmed);
    }


    function stringToBytes32(string memory source) internal pure returns(bytes32 result){
        assembly{
            result := mload(add(source,32))
        }
    }


    function memcpy(uint dest, uint src, uint len) private {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
    
    
    function compare(string memory _self, string memory _str) internal pure returns (int8 _ret) {
        for (uint i=0; i<bytes(_self).length && i<bytes(_str).length; ++i) {
            if (bytes(_self)[i] > bytes(_str)[i]) {
                return 1;
            } else if (bytes(_self)[i] < bytes(_str)[i]) {
                return -1;
            }
        }
        
        if (bytes(_self).length > bytes(_str).length) {
            return 1;
        } if (bytes(_self).length < bytes(_str).length) {
            return -1;
        } else {
            return 0;
        }
    }

    function compareNoCase(string memory _self, string memory _str) internal pure returns (int8 _ret) {
        for (uint i=0; i<bytes(_self).length && i<bytes(_str).length; ++i) {
            byte ch1 = bytes(_self)[i]|0x20;
            byte ch2 = bytes(_str)[i]|0x20;
            if (ch1 >= 'a' && ch1 <='z' && ch2 >= 'a' && ch2 <='z') {
                if (ch1 > ch2) {
                    return 1;
                } else if (ch1 < ch2) {
                    return -1;
                }
            } else {
                if (bytes(_self)[i] > bytes(_str)[i]) {
                    return 1;
                } else if (bytes(_self)[i] < bytes(_str)[i]) {
                    return -1;
                }
            }
        }
        
        if (bytes(_self).length > bytes(_str).length) {
            return 1;
        } if (bytes(_self).length < bytes(_str).length) {
            return -1;
        } else {
            return 0;
        }
    }

    function equals(string memory _self, string memory _str) internal pure returns (bool _ret) {
        if (bytes(_self).length != bytes(_str).length) {
            return false;
        }

        for (uint i=0; i<bytes(_self).length; ++i) {
            if (bytes(_self)[i] != bytes(_str)[i]) {
                return false;
            }
        }
        
        return true;
    }

    function equalsNoCase(string memory _self, string memory _str) internal pure returns (bool _ret) {
        if (bytes(_self).length != bytes(_str).length) {
            return false;
        }

        for (uint i=0; i<bytes(_self).length; ++i) {
            byte ch1 = bytes(_self)[i]|0x20;
            byte ch2 = bytes(_str)[i]|0x20;
            if (ch1 >= 'a' && ch1 <='z' && ch2 >= 'a' && ch2 <='z') {
                if (ch1 != ch2) {
                    return false;
                }
            } else {
                if (bytes(_self)[i] != bytes(_str)[i]) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    function substr(string memory _self, uint _start, uint _len) internal returns (string memory _ret) {
        if (_len > bytes(_self).length-_start) {
            _len = bytes(_self).length-_start;
        }

        if (_len <= 0) {
            _ret = "";
            return _ret;
        }
        
        _ret = new string(_len);

        uint selfptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        memcpy(retptr, selfptr+_start, _len);
    }
    
    function concat(string memory _self, string memory _str) internal returns (string memory _ret) {
        _ret = new string(bytes(_self).length + bytes(_str).length);

        uint selfptr;
        uint strptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            strptr := add(_str, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        memcpy(retptr, selfptr, bytes(_self).length);
        memcpy(retptr+bytes(_self).length, strptr, bytes(_str).length);
    }
    
    function concat(string memory _self, string memory _str1, string memory _str2)
        internal returns (string memory _ret) {
        _ret = new string(bytes(_self).length + bytes(_str1).length + bytes(_str2).length);

        uint selfptr;
        uint str1ptr;
        uint str2ptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            str1ptr := add(_str1, 0x20)
            str2ptr := add(_str2, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        uint pos = 0;
        memcpy(retptr+pos, selfptr, bytes(_self).length);
        pos += bytes(_self).length;
        memcpy(retptr+pos, str1ptr, bytes(_str1).length);
        pos += bytes(_str1).length;
        memcpy(retptr+pos, str2ptr, bytes(_str2).length);
        pos += bytes(_str2).length;
    }
    
    function concat(string memory _self, string memory _str1, string memory _str2, string memory _str3)
        internal returns (string memory _ret) {
        _ret = new string(bytes(_self).length + bytes(_str1).length + bytes(_str2).length
            + bytes(_str3).length);

        uint selfptr;
        uint str1ptr;
        uint str2ptr;
        uint str3ptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            str1ptr := add(_str1, 0x20)
            str2ptr := add(_str2, 0x20)
            str3ptr := add(_str3, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        uint pos = 0;
        memcpy(retptr+pos, selfptr, bytes(_self).length);
        pos += bytes(_self).length;
        memcpy(retptr+pos, str1ptr, bytes(_str1).length);
        pos += bytes(_str1).length;
        memcpy(retptr+pos, str2ptr, bytes(_str2).length);
        pos += bytes(_str2).length;
        memcpy(retptr+pos, str3ptr, bytes(_str3).length);
        pos += bytes(_str3).length;
    }
    
    function trim(string memory _self) internal returns (string memory _ret) {
        uint i;
        uint8 ch;
        for (i=0; i<bytes(_self).length; ++i) {
            ch = uint8(bytes(_self)[i]);
            if (!(ch == 0x20 || ch == 0x09 || ch == 0x0D || ch == 0x0A)) {
                break;
            }
        }
        uint start = i;
        
        for (i=bytes(_self).length; i>0; --i) {
            ch = uint8(bytes(_self)[i-1]);
            if (!(ch == 0x20 || ch == 0x09 || ch == 0x0D || ch == 0x0A)) {
                break;
            }
        }
        uint end = i;
        
        _ret = new string(end-start);
        
        uint selfptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        memcpy(retptr, selfptr+start, end-start);
    }
    
    function trim(string memory _self, string memory _chars) internal returns (string memory _ret) {
        uint16 i;
        uint16 j;
        bool matched;
        for (i=0; i<bytes(_self).length; ++i) {
            matched = false;
            for (j=0; j<bytes(_chars).length; ++j) {
                if (bytes(_self)[i] == bytes(_chars)[j]) {
                    matched = true;
                    break;
                }
            }
            if (!matched) {
                break;
            }
        }
        uint16 start = i;
        
        for (i=uint16(bytes(_self).length); i>0; --i) {
            matched = false;
            for (j=0; j<bytes(_chars).length; ++j) {
                if (bytes(_self)[i-1] == bytes(_chars)[j]) {
                    matched = true;
                    break;
                }
            }
            if (!matched) {
                break;
            }
        }
        uint16 end = i;

        if (end <= start) {
		    _ret = "";
            return _ret;
        }
        
        _ret = new string(end-start);
        
        uint selfptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        memcpy(retptr, selfptr+start, end-start);
    }
    
    function indexOf(string memory src, string memory value)
        internal
        pure
        returns (int) {
        return indexOf(src, value, 0);
    }
    
    function indexOf(string  memory src, string memory value, uint offset)
        internal
        pure
        returns (int) {
        bytes memory srcBytes = bytes(src);
        bytes memory valueBytes = bytes(value);

        assert(valueBytes.length == 1);

        for (uint i = offset; i < srcBytes.length; i++) {
            if (srcBytes[i] == valueBytes[0]) {
                return int(i);
            }
        }

        return -1;
    }

    function split(string memory src, string memory separator) internal pure returns (string[] memory splitArr) {
        bytes memory srcBytes = bytes(src);

        uint offset = 0;
        uint splitsCount = 1;
        int limit = -1;
        while (offset < srcBytes.length - 1) {
            limit = indexOf(src, separator, offset);
            if (limit == -1)
                break;
            else {
                splitsCount++;
                offset = uint(limit) + 1;
            }
        }

        splitArr = new string[](splitsCount);

        offset = 0;
        splitsCount = 0;
        while (offset < srcBytes.length - 1) {

            limit = indexOf(src, separator, offset);
            if (limit == - 1) {
                limit = int(srcBytes.length);
            }

            string memory tmp = new string(uint(limit) - offset);
            bytes memory tmpBytes = bytes(tmp);

            uint j = 0;
            for (uint i = offset; i < uint(limit); i++) {
                tmpBytes[j++] = srcBytes[i];
            }
            offset = uint(limit) + 1;
            splitArr[splitsCount++] = string(tmpBytes);
        }
        return splitArr;
    }
    

    
    function toInt(string memory _self) internal returns (int _ret) {
        _ret = 0;
        if (bytes(_self).length == 0) {
            return _ret;
        }
        
        uint16 i;
        uint8 digit;
        for (i=0; i<bytes(_self).length; ++i) {
            digit = uint8(bytes(_self)[i]);
            if (!(digit == 0x20 || digit == 0x09 || digit == 0x0D || digit == 0x0A)) {
                break;
            }
        }
        
        bool positive = true;
        if (bytes(_self)[i] == '+') {
            positive = true;
            i++;
        } else if(bytes(_self)[i] == '-') {
            positive = false;
            i++;
        }

        for (; i<bytes(_self).length; ++i) {
            digit = uint8(bytes(_self)[i]);
            if (!(digit >= 0x30 && digit <= 0x39)) {
                return _ret;
            }
            _ret = _ret*10 + int(digit-0x30);
        }        
        
        if (!positive) {
            _ret = -_ret;
        }
    }

    function toAddress(string memory _self) internal returns (address _ret) {
        uint16 i;
        uint8 digit;
        for (i=0; i<bytes(_self).length; ++i) {
            digit = uint8(bytes(_self)[i]);
            if (!(digit == 0x20 || digit == 0x09 || digit == 0x0D || digit == 0x0A)) {
                break;
            }
        }
        
        if (bytes(_self).length-i < 2) {
            return address(0);
        }

        //must start with 0x
        if (!(bytes(_self)[i] == '0' && bytes(_self)[i+1]|0x20 == 'x')) {
            return address(0);
        }

        uint addr = 0;
        
        for (i+=2; i<bytes(_self).length; ++i) {
            digit = uint8(bytes(_self)[i]);
            if (digit >= 0x30 && digit <= 0x39) //'0'-'9'
                digit -= 0x30;
            else if (digit|0x20 >= 0x61 && digit|0x20 <= 0x66) //'a'-'f'
                digit = digit-0x61+10;
            else 
                return address(0); 
            
            addr = addr*16+digit;
        }
        
        return address(addr);
    }
    
    function toKeyValue(string memory _self, string memory _key) internal returns (string memory _ret) {
        _ret = new string(bytes(_self).length + bytes(_key).length + 5);
        
        uint selfptr;
        uint keyptr;
        uint retptr;
        assembly {
            selfptr := add(_self, 0x20)
            keyptr := add(_key, 0x20)
            retptr := add(_ret, 0x20)
        }
        
        uint pos = 0;

        bytes(_ret)[pos++] = '"';
        memcpy(retptr+pos, keyptr, bytes(_key).length);
        pos += bytes(_key).length;
        bytes(_ret)[pos++] = '"';
        
        bytes(_ret)[pos++] = ':';
        
        bytes(_ret)[pos++] = '"';
        memcpy(retptr+pos, selfptr, bytes(_self).length);
        pos += bytes(_self).length;
        bytes(_ret)[pos++] = '"';
    }
    
    function getStringValueByKey(string memory _self, string memory _key) internal returns (string memory _ret) {
		_ret = "";
        int pos = -1;
        uint searchStart = 0;
        while (true) {
            pos = _self.indexOf("\"".concat(_key, "\""), searchStart);
            if (pos == -1) {
                pos = _self.indexOf("'".concat(_key, "'"), searchStart);
                if (pos == -1) {
                    return _ret;
                }
            }

            pos += int(bytes(_key).length+2);

            bool colon = false;
            while (uint(pos) < bytes(_self).length) {
                if (bytes(_self)[uint(pos)] == ' ' || bytes(_self)[uint(pos)] == '\t' 
                    || bytes(_self)[uint(pos)] == '\r' || bytes(_self)[uint(pos)] == '\n') {
                    pos++;
                } else if (bytes(_self)[uint(pos)] == ':') {
                    pos++;
                    colon = true;
                    break;
                } else {
                    break;
                }
            }

            if(uint(pos) == bytes(_self).length) {
                return _ret;
            }

            if (colon) {
                break;
            } else {
                searchStart = uint(pos);
            }
        }
        
        bool doubleQuotes = true;
        int start = _self.indexOf("\"", uint(pos));
        if (start == -1) {
            doubleQuotes = false;
            start = _self.indexOf("'", uint(pos));
            if (start == -1) {
                return _ret;
            }
        }
        start += 1;
        
        int end;
        if (doubleQuotes) {
            end = _self.indexOf("\"", uint(start));
        } else {
            end = _self.indexOf("'", uint(start));
        }
        if (end == -1) {
            return _ret;
        }
        
        _ret = _self.substr(uint(start), uint(end-start));
    }
    
    function getIntValueByKey(string memory _self, string memory _key) internal returns (int _ret) {
        _ret = 0;
        int pos = -1;
        uint searchStart = 0;
        while (true) {
            pos = _self.indexOf("\"".concat(_key, "\""), searchStart);
            if (pos == -1) {
                pos = _self.indexOf("'".concat(_key, "'"), searchStart);
                if (pos == -1) {
                    return _ret;
                }
            }

            pos += int(bytes(_key).length+2);

            bool colon = false;
            while (uint(pos) < bytes(_self).length) {
                if (bytes(_self)[uint(pos)] == ' ' || bytes(_self)[uint(pos)] == '\t' 
                    || bytes(_self)[uint(pos)] == '\r' || bytes(_self)[uint(pos)] == '\n') {
                    pos++;
                } else if (bytes(_self)[uint(pos)] == ':') {
                    pos++;
                    colon = true;
                    break;
                } else {
                    break;
                }
            }

            if(uint(pos) == bytes(_self).length) {
                return _ret;
            }

            if (colon) {
                break;
            } else {
                searchStart = uint(pos);
            }
        }

        uint i = uint(pos);
        uint8 digit;
        for (; i<bytes(_self).length; ++i) {
            digit = uint8(bytes(_self)[i]);
            if (!(digit == 0x20 || digit == 0x09 || digit == 0x0D || digit == 0x0A 
            || digit == 0x3A /*:*/ || digit == 0x22 /*"*/ || digit == 0x27 /*'*/)) {
                break;
            }
        }
        
        bool positive = true;
        if (bytes(_self)[i] == '+') {
            positive = true;
            i++;
        } else if(bytes(_self)[i] == '-') {
            positive = false;
            i++;
        }

        for (; i<bytes(_self).length; ++i) {
            digit = uint8(bytes(_self)[i]);
            if (!(digit >= 0x30 && digit <= 0x39)) {
                if (!positive) {
                    _ret = -_ret;
                }
                return _ret;
            }
            _ret = _ret*10 + int(digit-0x30);
        }        
        
        if (!positive) {
            _ret = -_ret;
        }
    }
    
    function toUppercase(string memory src) internal pure returns(string memory){
        bytes memory srcb = bytes(src);
        for(uint i=0;i<srcb.length;i++){
            byte b = srcb[i];
            if(b >= 'a' && b <= 'z'){
                b &= byte(0xDF);// -32
                srcb[i] = b ;
            }
        }
        return src;
    }
    
    function toLowercase(string memory src) internal pure returns(string memory){
        bytes memory srcb = bytes(src);
        for(uint i=0;i<srcb.length;i++){
            byte b = srcb[i];
            if(b >= 'A' && b <= 'Z'){
                b |= 0x20;
                srcb[i] = b;
            }
        }
        return src;
    }

	
    function keyExists(string memory _self, string memory _key) internal returns (bool _ret) {
        int pos = _self.indexOf("\"".concat(_key, "\""));
        if (pos == -1) {
            pos = _self.indexOf("'".concat(_key, "'"));
            if (pos == -1) {
                return false;
            }
        }

        return true;
    }

    function inArray(string memory _self, string[] storage _array) internal returns (bool _ret) {
        for (uint i=0; i<_array.length; ++i) {
            if (_self.equals(_array[i])) {
                return true;
            }
        }

        return false;
    }
 
    function inArrayNoCase(string memory _self, string[] storage _array) internal returns (bool _ret) {
        for (uint i=0; i<_array.length; ++i) {
            if (_self.equalsNoCase(_array[i])) {
                return true;
            }
        }

        return false;
    }

  }