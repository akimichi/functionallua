
--[[
--newtype Reader e a = Reader { runReader :: e -> a }

class MonadReader e m | m -> e where 
    ask   :: m e
    local :: (e -> e) -> m a -> m a 
instance MonadReader (Reader e) where 
    ask       = Reader id 
    local f c = Reader $ \e -> runReader c (f e) 
instance Monad (Reader env) where
    return a = Reader $ \_ -> a
    m >>= f  = Reader $ \env -> runReader (f (runReader m env)) env


Reader#ask

ask :: Reader r r
ask = Reader id

local f c = Reader $ \e -> runReader c (f e)
--]]

local function new(a)
  return {
    run = function(_)
      return a;
    end
  }
end

local function flatMap(reader)
  return function(f)
    return {
      run = function(env)
        return f(reader.run(env)).run(env);
      end
    };
  end 
end

local ask = {
  run = function(env)
    return env;
  end 
}

-- 一時的に環境を書き換えた状態で処理をすることができます。
local temporal function(f)
  return function(reader)
    return {
      run = function(env)
        return reader.run(f(env))
      end 
    };
  end 
end 

return {
  unit = unit, 
  flatMap = flatMap, 
  ask = ask, 
  temporal = temporal
}


