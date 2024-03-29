local negate = function(predicate)
  return function(arg)
    return not predicate(arg);
  end 
end 

local stream = {}

stream.match = function(data, pattern)
  return data(pattern);
end
stream.empty = function(_)
  return function(pattern)
    return pattern.empty();
  end 
end

stream.cons = function(head,tailThunk)
  return function(pattern)
    return pattern.cons(head,tailThunk);
  end
end

stream.toArray = function(lazyList)
  return stream.match(lazyList,{
    empty = function(_)
      return {}
    end,
    cons = function(head,tailThunk)
      return stream.match(tailThunk(),{
        empty = function(_)
          return {head}
        end,
        cons = function(head_,tailThunk_)
          return {head,  table.unpack(stream.toArray(tailThunk()))}
          -- return {head}.concat(stream.toArray(tailThunk()));
        end 
      });
    end 
  });
end

stream.take = function(lazyList)
  return function(number)
    return stream.match(lazyList,{
      empty = function(_)
        return stream.empty();
      end,
      cons = function(head,tailThunk)
        if(number == 0) then
          return stream.empty();
        else
          return stream.cons(head, function(_)
            return stream.take(tailThunk())(number -1);
          end);
        end 
      end 
    });
  end;
end

-- **リスト7.35** ストリームのfilter関数
-- #@@range_begin(stream_filter)
-- /* filter:: FUN[T => BOOL] => STREAM[T] => STREAM[T] */
stream.filter = function(predicate)
  return function(aStream)
    return stream.match(aStream,{
      empty = function(_)
        return stream.empty()
      end,
      cons = function(head,tailThunk)
        if(predicate(head)) then -- 条件に合致する場合
          return stream.cons(head, function(_)
            return stream.filter(predicate)(tailThunk());
          end);
        else -- 条件に合致しない場合
          return stream.filter(predicate)(tailThunk());
        end 
      end 
    });
  end 
end
-- #@@range_end(stream_filter)

-- **リスト7.36** ストリームのremove関数
-- #@@range_begin(stream_remove)
-- /* remove:: FUN[T => BOOL] => STREAM[T] => STREAM[T] */
stream.remove = function(predicate)
  return function(aStream)
    return stream.filter(negate(predicate))(aStream);
  end
end
-- #@@range_end(stream_remove)

stream.enumFrom = function(from)
  return stream.cons(from, function(_)
    return stream.enumFrom(from + 1);
  end);
end

return stream
