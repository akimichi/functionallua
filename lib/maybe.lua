local Maybe = {}

-- /* #@range_begin(maybe_monad) */
Maybe.match = function(exp, pattern)
  return exp(pattern);
end

Maybe.just = function(value)
  return function(pattern)
    return pattern.just(value);
  end;
end

Maybe.nothing = function(_)
  return function(pattern)
    return pattern.nothing(_);
  end
end 

-- /* #@range_begin(maybe_monad) */
-- /* unit:: T => MAYBE[T] */
Maybe.unit = function(value)
  return Maybe.just(value);
end

-- /* flatMap:: MAYBE[T] => FUN[T => MAYBE[U]] => MAYBE[U] */
Maybe.flatMap = function(instanceM)
  return function(transform)
    return Maybe.match(instanceM,{
      -- /* 正常な値の場合は、transform関数を計算する */
      just = function(value)
        return transform(value);
      end,
      -- /* エラーの場合は、何もしない */
      nothing = function(_)
        return Maybe.nothing();
      end 
    });
  end 
end

-- /* ヘルパー関数  */
Maybe.getOrElse = function(instanceM)
  return function(alternate)
    return Maybe.match(instanceM,{
      just = function(value)
        return value;
      end,
      nothing = function(_)
        return alternate;
      end 
    });
  end;
end
-- /* #@range_end(maybe_monad) */


return Maybe




