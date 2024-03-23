local list = {}

list.match =  function(data, pattern)
  return data(pattern)
end

list.cons = function(value, alist)
  return function(pattern)
    return pattern.cons(value, alist);
  end
end

list.empty = function(_)
  return function(pattern)
    return pattern.empty();
  end
end


list.head = function(alist)
  return list.match(alist, {
    empty = function(_)
      return nil;
    end, 
    cons = function(head, tail)
      return head;
    end 
  });
end

list.tail = function(alist)
  return list.match(alist, {
    empty = function(_)
      return null;
    end,
    cons = function(head, tail)
      return tail;
    end 
  });
end  

list.foldr = function(alist)
  return function(accumulator)
    return function(callback)
      return list.match(alist,{
        empty = function(_)
          return accumulator;
        end,
        cons = function(head, tail)
          return callback(head)(list.foldr(tail)(accumulator)(callback));
        end 
      });
    end 
  end;
end;

list.append = function(xs)
  return function(ys)
    return list.match(xs,{
      -- /* emptyの場合は、終了条件 */
      empty = function(_)
        return ys; -- xsが空の場合は、ysを返す
      end,
      -- /* consの場合は、append関数を再帰的に呼び出す */
      cons = function(head, tail)
        -- /* xsとysを連結させる */
        return list.cons(head, list.append(tail,ys));
      end 
    });
  end
end 

list.find = function(alist)
  return function(predicate) -- 要素を判定する述語関数
    return list.foldr(alist)(null)(function(item) -- foldrを利用する
      return function(accumulator)
        -- /* 要素が見つかった場合、その要素を返す */
        if(predicate(item) == true) then
          return item;
        else
          return accumulator;
        end 
      end
    end);
  end 
end 

-- /* map:: LIST[T] -> FUNC[T -> T] -> LIST[T] */
list.map = function(alist)
  return function(transform)
    return list.match(alist,{
      empty = function(_)
        return list.empty();
      end,
      cons = function(head,tail)
        return list.cons(transform(head),list.map(tail)(transform));
      end
    });
  end
end

list.reverse = function(alist)
  local function reverseAux(alist, accumulator)
    return list.match(alist, {
      empty = function(_)
        return accumulator;  -- 空のリストの場合は終了
      end,
      cons = function(head, tail)
        return reverseAux(tail, list.cons(head, accumulator));
      end
    })
  end
  return reverseAux(alist, list.empty());
end

list.toArray = function(alist)
  local function toArrayAux(alist,accumulator)
    -- return list.match(alist, {
    return list.match(alist, {
      empty = function(_)
        return accumulator;  -- 空のリストの場合は終了
      end,
      cons = function(head, tail)
        accumulator[#accumulator+1] = head
        return toArrayAux(tail, accumulator);
        -- return toArrayAux(tail, accumulator.concat(head));
      end
    })
  end
  return toArrayAux(alist, {});
end

return list
