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
  -- return reverseAux(alist, list.empty());
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
