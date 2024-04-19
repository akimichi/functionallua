local List = require("lib/list")

-- /* 先頭文字を取得する */
local head = function(str)
  return string.sub(str, 1, 1);
end,
-- /* 後尾文字列を取得する */
local tail = function(str)
  return string.sub(str, 2);
end,
-- /* 空の文字列かどうかを判定する */
local isEmpty = function(str)
  return #str == 0;
end,
-- /* 文字列を文字のリストに変換する */
local toList = function(chars)
  if(isEmpty(str)) then
    return List.empty();
  else
    return List.cons(head(chars), 
                    toList(tail(chars)));
  end 
end 

return {
  head = head, 
  tail = tail, 
  isEmpty = isEmpty, 
  toList = toList
}
