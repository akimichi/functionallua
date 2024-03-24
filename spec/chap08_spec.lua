-- 第8章 関数型言語を作る
-- ========

-- ## 小目次
-- <div class="toc">
-- <ul class="toc">
--   <li><a href="http:--akimichi.github.io/functionaljs/chap08.spec.html#abstract-syntax-tree">8.2 抽象構文木を作る</a></li>
--   <li><a href="http:--akimichi.github.io/functionaljs/chap08.spec.html#environment">8.3 環境を作る</a></li>
--   <li><a href="http:--akimichi.github.io/functionaljs/chap08.spec.html#evaluator">8.4 評価器を作る</a>
--      <ul>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap08.spec.html#identity-monad-evaluator">恒等モナドによる評価器</a></li>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap08.spec.html#logger-monad-evaluator">ログ出力評価器</a></li></ul>
--   </li>
-- </ul>
-- </div>



-- 以下のコードで利用されるpairモジュールとlistモジュールをあらかじめ定義しておく

-- **pairモジュール**
local Pair = require("lib/pair")

-- **listモジュール**
local List = require("lib/list")
--[[
local list  = {
  match = function(data, pattern) => {
    return data.call(list, pattern);
  },
  empty= function(_) => {
    return (pattern) => {
      return pattern.empty();
    };
  },
  cons= function(head, tail) => {
    return (pattern) => {
      return pattern.cons(head, tail);
    };
  },
  head= function(alist) => {
    return list.match(alist, {
      empty= function(_) => {
        return undefined;
      },
      cons= function(head, tail) => {
        return head;
      }
    });
  },
  tail= function(alist) => {
    return list.match(alist, {
      empty= function(_) => {
        return undefined;
      },
      cons= function(head, tail) => {
        return tail;
      }
    });
  },
  --/* append:: LIST[T] -> LIST[T] -> LIST[T] */
  append= function(xs) => {
    return (ys) => {
      return list.match(xs, {
        empty= function(_) => {
          return ys;
        },
        cons= function(head, tail) => {
          return list.cons(head, list.append(tail)(ys)); 
        }
      });
    };
  },
  --/* foldr:: LIST[T] -> T -> FUN[T -> LIST] -> T */
  foldr= function(alist) => {
    return (accumulator) => {
      return (glue) => {
        expect(glue).to.a('function');
        return list.match(alist,{
          empty= function(_) => {
            return accumulator;
          },
          cons= function(head, tail) => {
            return glue(head)(list.foldr(tail)(accumulator)(glue));
          }
        });
      };
    };
  },
  toArray= function(alist) => {
    return list.foldr(alist)([])((item) => {
      return (accumulator) => {
        return [item].concat(accumulator); 
      };
    });
  }
};
]]

-- ## 8.2 <section id='abstract-syntax-tree'>抽象構文木を作る</section>
-- > 参考資料: [Wikipediaの記事](https:--ja.wikipedia.org/wiki/%E6%8A%BD%E8%B1%A1%E6%A7%8B%E6%96%87%E6%9C%A8)
describe('抽象構文木を作る', function()
  -- **リスト8.2** 式の代数的データ構造
  describe('式の代数的データ構造', function()
    local exp = {
      --/* #@range_begin(expression_algebraic_datatype) */
      --/* 式のパターンマッチ関数 */
      match = function(data, pattern)
        return data(pattern);
      end, 
      --/* 数値の式 */
      num = function(value)
        return function(pattern)
          return pattern.num(value);
        end;
      end,
      --/* 変数の式 */
      variable = function(name)
        return function(pattern)
          return pattern.variable(name);
        end
      end,
      --/* 関数定義の式(λ式) */
      lambda = function(variable, body)
        return function(pattern)
          return pattern.lambda(variable, body);
        end 
      end,
      --/* 関数適用の式 */
      app = function(lambda, arg)
        return function(pattern)
          return pattern.app(lambda, arg);
        end;
      end,
      --/* #@range_end(expression_algebraic_datatype) */

      -- **リスト8.3** 演算の定義
      --/* #@range_begin(expression_arithmetic) */
      --/* 足し算の式 */
      add = function(expL,expR)
        return function(pattern)
          return pattern.add(expL, expR);
        end 
      end
      --/* #@range_end(expression_arithmetic) */
    };
    describe('式をテストする', function()
      it("\\x.\\y.x", function()
        --/* λx.λy.x */
        return exp.match(exp.lambda(exp.variable("x"),exp.lambda(exp.variable("y"),exp.variable("x"))),{
          lambda = function(variable, arg)
            assert.are.equal(
              type(variable)
            , 
              'function' 
            )
            -- expect(
            --   variable
            -- ).to.a('function');
          end 
        });
      end);
    end);
  end);
end) -- end of 抽象構文木を作る

-- -- ## 8.3 <section id='environment'>環境を作る</section>
describe('環境を作る', function()
  -- **リスト8.5** クロージャーによる「環境」の定義
  --/* #@range_begin(environment) */
  local Env = require("lib/env")
  local env = {
    --/* 空の環境を作る */
    --/* empty:: STRING => VALUE */
    empty = function(variable)
      return nil;
    end,
    --/* 変数名に対応する値を環境から取り出す */
    --/* lookup:= function(STRING, ENV) => VALUE */
    lookup = function(name, environment)
      return environment(name);
    end,
    --/* 環境を拡張する */
    --/* extend:= function(STRING, VALUE, ENV) => ENV */
    extend = function(identifier, value, environment)
      return function(queryIdentifier)
        if(identifier == queryIdentifier) then
          return value;
        else
          return env.lookup(queryIdentifier,environment);
        end 
      end
    end 
  };
  --/* #@range_end(environment) */
  -- **リスト8.7** 変数バインディングにおける環境のセマンティクス

  -- ~~~
  -- local a = 1;
  -- a;
  -- ~~~
  it('変数バインディングにおける環境のセマンティクス', function()
    --/* #@range_begin(environment_code_test) */
    local test =  function()
      --/* 空の環境からnewEnv環境を作る */
      local newEnv = env.extend("a", 1, env.empty); 
      --/* newEnv環境を利用して a の値を求める */
      return env.lookup("a", newEnv);            
    end
    assert.are.equal(
      test() 
    , 
      1 
    )
    -- expect(((_) => {
    --   --/* 空の環境からnewEnv環境を作る */
    --   local newEnv = env.extend("a", 1, env.empty); 
    --   --/* newEnv環境を利用して a の値を求める */
    --   return env.lookup("a", newEnv);            
    -- })()).to.eql(
    --   1
    -- );
    --/* #@range_end(environment_code_test) */
    --
    local test2 = function()
      local initEnv = env.empty;                      -- 空の辞書を作成する
      --/* local a = 1 を実行して、辞書を拡張する */  
      local firstEnv = env.extend("a", 1, initEnv);
      --/* local b = 3 を実行して、辞書を拡張する */
      local secondEnv = env.extend("b",3, firstEnv);
      --/* 辞書から b の値を参照する */
      return env.lookup("b",secondEnv);
    end
    assert.are.equal(
      test2()
    , 
      3
    )
    -- expect(((_) => {
    --   local initEnv = env.empty;                      -- 空の辞書を作成する
    --   --/* local a = 1 を実行して、辞書を拡張する */  
    --   local firstEnv = env.extend("a", 1, initEnv);
    --   --/* local b = 3 を実行して、辞書を拡張する */
    --   local secondEnv = env.extend("b",3, firstEnv);
    --   --/* 辞書から b の値を参照する */
    --   return env.lookup("b",secondEnv);
    -- })()).to.eql(
    --   3
    -- );
    -- ~~~js
    -- local x = 1;
    -- local y = 2;
    -- local closure = () => {
    --   local z = 3;
    --   return x + y + z;
    -- };
    -- closure() 
    -- ~~~
    -- **リスト8.9** クロージャーにおける環境のセマンティクス
    --/* #@range_begin(environment_extend_test) */
    local test3 = function()
      --/* 空の辞書を作成する */
      local initEnv = Env.empty;                   
      --/* 空の辞書から outerEnv環境を作る */
      local outerEnv = Env.extend("x", 1, initEnv);    

      --/* closureEnv環境を作る */
      local closureEnv = Env.extend("y", 2, outerEnv);  
      --/* closureEnv環境を利用してx+yを計算する */
      return Env.lookup("x",closureEnv) + Env.lookup("y",closureEnv);
    end
    assert.are.equal(
      test3()
    , 
      3
    )
    
    -- expect(((_) => {
    --   --/* 空の辞書を作成する */
    --   local initEnv = env.empty;                   
    --   --/* 空の辞書から outerEnv環境を作る */
    --   local outerEnv = env.extend("x", 1, initEnv);    
    --
    --   --/* closureEnv環境を作る */
    --   local closureEnv = env.extend("y", 2, outerEnv);  
    --   --/* closureEnv環境を利用してx+yを計算する */
    --   return env.lookup("x",closureEnv) + env.lookup("y",closureEnv);
    -- })()).to.eql(
    --   3
    -- );
    --/* #@range_end(environment_extend_test) */
   end)
end)
--
-- ## 8.4 <section id='evaluator'>評価器を作る</section>
-- > 参考資料: [The Essence of Functional Programming](https:--www.google.co.jp/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwiw25uwks7PAhVBF5QKHQjDBfEQFggcMAA&url=http%3A%2F%2Fwww.eliza.ch%2Fdoc%2Fwadler92essence_of_FP.pdf&usg=AFQjCNFX6YZ2kqhIuqGGysZCyMQwaWAAfQ&sig2=0GWjNVeqVkXjUCr6B20DLA&bvm=bv.135258522,d.dGo)
describe('評価器を作る', function()
  --/* 「環境」モジュール */
  local Env = require("lib.env")
  -- local env = {
  --   empty= function(variable) => {                        
  --     return undefined;
  --   },
  --   lookup = function(name, environment) => {       
  --     return environment(name);
  --   },
  --   extend= function(identifier, value, environment) => { 
  --     return (queryIdentifier) => {
  --       if(identifier === queryIdentifier) {
  --         return value;
  --       } else {
  --         return env.lookup(queryIdentifier,environment);
  --       }
  --     };
  --   }
  -- };
  local emptyEnv = Env.empty;

  -- ### <section id='identity-monad-evaluator'>恒等モナドによる評価器</section>
  describe('恒等モナドによる評価器', function()
    local exp = {
      match = function(data, pattern) -- 式のパターンマッチ関数
        return data(pattern);
      end,
      num = function(value)            -- 数値の式
        return function(pattern)
          return pattern.num(value);
        end;
      end,
      variable = function(name)        -- 変数の式
        return function(pattern)
          return pattern.variable(name);
        end;
      end,
      lambda = function(variable, body) -- 関数定義の式(λ式)
        return function(pattern)
          return pattern.lambda(variable, body);
        end;
      end,
      app = function(lambda, arg)       -- 関数適用の式
        return function(pattern)
          return pattern.app(lambda, arg);
        end;
      end,
      add = function(expL,expR)        -- 足し算の式
        return function(pattern)
          return pattern.add(expL, expR);
        end;
      end
    };
    -- ### 恒等モナド
    --/* #@range_begin(identity_monad) */
    local ID = require("lib/id")
    -- local ID = {
    --   unit = function(value) => {
    --     return value;
    --   },
    --   flatMap= function(instance) => {
    --     return (transform) => {
    --       expect(transform).to.a('function');
    --       return transform(instance);
    --     };
    --   }
    -- };
    --/* #@range_end(identity_monad) */

    -- **リスト8.10** 恒等モナド評価器の定義
    --/* #@range_begin(identity_monad_evaluator) */
    --/* evaluate:= function(EXP, ENV) => ID[VALUE] */
    local function evaluate(anExp, environment)
      return exp.match(anExp,{
        -- **リスト8.11** 数値の評価
        num = function(numericValue)
          return ID.unit(numericValue);
        end,
        -- **リスト8.13** 変数の評価
        variable = function(name)
          return ID.unit(Env.lookup(name, environment));
        end,
        --/* 関数定義（λ式）の評価  */
        lambda = function(variable, body)
          return exp.match(variable,{
            variable = function(name)
              return ID.unit(function(actualArg)
                return evaluate(body, 
                                Env.extend(name, actualArg, environment))
              end)
            end
            })
        end, 
        --/* 関数適用の評価 */
        app = function(lambda, arg)
          return ID.flatMap(evaluate(lambda, environment))(function(closure)
            return ID.flatMap(evaluate(arg, environment))(function(actualArg)
              return closure(actualArg); 
            end);
          end);
        end,
        -- **リスト8.15**  足し算の評価 
        add = function(expL, expR)
          return ID.flatMap(evaluate(expL, environment))(function(valueL)
            return ID.flatMap(evaluate(expR, environment))(function(valueR)
              return ID.unit(valueL + valueR); 
            end);
          end);
        end
      });
    end;
    --/* #@range_end(identity_monad_evaluator) */
    -- **リスト8.12** 数値の評価のテスト
    it('数値の評価のテスト', function()
      --/* #@range_begin(number_evaluation_test) */
      assert.are.equal(
        evaluate(exp.num(2), Env.empty) 
        ,
        ID.unit(2) 
      )
      -- expect(
      --   evaluate(exp.num(2), env.empty)
      -- ).to.eql(
      --   ID.unit(2)
      -- );
      --/* #@range_end(number_evaluation_test) */
     end);
    -- **リスト8.14** 変数の評価のテスト
    it('変数の評価のテスト', function()
      --/* #@range_begin(variable_evaluation_test) */
      --/* 変数xを1に対応させた環境を作る */
      local newEnv = Env.extend("x", 1, Env.empty); 
      --/* 拡張したnewEnv環境を用いて変数xを評価する */
      assert.are.equal(
        evaluate(exp.variable("x"), newEnv)
        ,
        ID.unit(1) 
      )
      -- expect(
      --   evaluate(exp.variable("x"), newEnv)
      -- ).to.eql(
      --   ID.unit(1)
      -- );
      --/* #@range_end(variable_evaluation_test) */
      assert.are.equal(
        evaluate(exp.variable("y"), newEnv)
        ,
        nil 
      )
      -- expect(
      --   evaluate(exp.variable("y"), newEnv)
      -- ).to.be(
      --   ID.unit(undefined)
      -- );
    end)
    -- **リスト8.16** 足し算の評価のテスト
    it('足し算の評価のテスト', function()
      --/* add(1,2) */
      --/* #@range_begin(add_evaluation_test) */
      local addition = exp.add(exp.num(1),exp.num(2));
      assert.are.equal(
        evaluate(addition, Env.empty) 
        ,
        ID.unit(3)
      )
      -- expect(
      --   evaluate(addition, Env.empty)
      -- ).to.eql(
      --   ID.unit(3)
      -- );
      --/* #@range_end(add_evaluation_test) */
    end);
    it('恒等モナド評価器で演算を評価する', function()
      assert.are.equal(
        evaluate(exp.add(exp.num(1),exp.num(2)), emptyEnv) 
        ,
        ID.unit(3)
      )
      -- expect(
      --   evaluate(exp.add(exp.num(1),exp.num(2)), emptyEnv)
      -- ).to.be(
      --   ID.unit(3)
      -- );
    end);
    -- #### 関数の評価
    it('ID評価器で関数を評価する', function()
      -- ~~~js
      -- ((x) => {
      --   return x; 
      -- })(1)
      -- ~~~
      local expression = exp.lambda(exp.variable("x"),
                                  exp.variable("x"));
      assert.are.equal(
        evaluate(expression, emptyEnv)(1)
        ,
        ID.unit(1)
      )
      -- expect(
      --   evaluate(expression, emptyEnv)(1)
      -- ).to.be(
      --   1
      -- );
    end)
    it('関数適用の評価のテスト', function()
      -- **リスト8.17** 関数適用の評価のテスト
      -- ~~~js
      -- ((n) => {
      --   return n + 1; 
      -- })(2)
      -- ~~~
      --/* #@range_begin(application_evaluation_test) */
      local expression = exp.app(         --/* 関数適用 */
        exp.lambda(exp.variable("n"),   --/* λ式 */
                   exp.add(exp.variable("n"),
                           exp.num(1))),
        exp.num(2));                    --/* 引数の数値2 */
      assert.are.equal(
        evaluate(expression, Env.empty) 
        ,
        ID.unit(3)
      )
      -- expect(
      --   evaluate(expression, env.empty)
      -- ).to.eql(
      --   ID.unit(3)
      -- );
      --/* #@range_end(application_evaluation_test) */
    end)
    it('ID評価器で関数適用 \\x.add(x,x)(2)を評価する', function()
      -- ~~~js
      -- ((x) => {
      --   return x + x; 
      -- })(2)
      -- ~~~
      local expression = exp.app(exp.lambda(exp.variable("x"),
                                          exp.add(exp.variable("x"),exp.variable("x"))),
                               exp.num(2));
      assert.are.equal(
        evaluate(expression, Env.empty)
        ,
        ID.unit(4)
      )
      -- expect(
      --   evaluate(expression, env.empty)
      -- ).to.eql(
      --   4
      -- );
    end)
    it('カリー化関数の評価', function()
      -- **リスト8.19**カリー化関数の評価
      -- ~~~js
      -- ((n) => {
      --    return (m) => {
      --       return n + m;
      --    };
      -- })(2)(3)
      -- ~~~
      --/* #@range_begin(curried_function_evaluation_test) */
      local expression = exp.app(
        exp.app(
          exp.lambda(exp.variable("n"),
                     exp.lambda(exp.variable("m"),
                                exp.add(
                                  exp.variable("n"),exp.variable("m")))),
          exp.num(2)),
        exp.num(3));
      assert.are.equal(
        evaluate(expression, Env.empty)
        ,
        ID.unit(5)
      )
      -- expect(
      --   evaluate(expression, env.empty)
      -- ).to.eql(
      --   ID.unit(5)
      -- );
      --/* #@range_end(curried_function_evaluation_test) */
    end);
  end)
  -- ### <section id='logger-monad-evaluator'>ログ出力評価器</section>
  describe('ログ出力評価器', function()
    local match = function(data, pattern)
      return data(pattern);
    end
    -- **リスト8.20** ログ出力評価器の式
    --/* #@range_begin(expression_logger_interpreter) */
    local exp = {
      log = function(anExp) -- ログ出力用の式
        return function(pattern)
          return pattern.log(anExp);
        end;
      end,
      --/* #@range_end(expression_logger_interpreter) */
      num = function(value)
        return function(pattern)
          return pattern.num(value);
        end 
      end,
      variable = function(name)
        -- expect(name).to.a('string');
        return function(pattern)
          return pattern.variable(name);
        end;
      end,
      lambda = function(variable, body)
        -- expect(variable).to.a('function');
        -- expect(body).to.a('function');
        return function(pattern)
          return pattern.lambda(variable, body);
        end
      end,
      app = function(variable, arg)
        return function(pattern)
          return pattern.app(variable, arg);
        end;
      end,
      add = function(exp1,exp2)
        return function(pattern)
          return pattern.add(exp1, exp2);
        end;
      end,
      mul = function(exp1,exp2)
        return function(pattern)
          return pattern.mul(exp1, exp2);
        end;
      end
    };
    -- **リスト8.21** LOGモナドの定義
    --/* #@range_begin(logger_monad) */
    --/* LOG[T] = PAIR[T, LIST[STRING]] */
    local LOG = {
      --/* unit:: VALUE => LOG[VALUE] */
      unit = function(value)
        --/* 値とログのPair型を作る */
        return Pair.cons(value, List.empty()); 
      end,
      --/* flatMap:: LOG[T] => FUN[T => LOG[T]] => LOG[T] */
      flatMap = function(instanceM)
        return function(transform)
          return Pair.match(instanceM,{
            --/* Pair型に格納されている値の対を取り出す */
            cons = function(value, log)
              --/* 取り出した値で計算する */
              local newInstance = transform(value); 
              --[[/* 計算の結果をPairの左側に格納し、
                 新しいログをPairの右側に格納する */
                 ]]
              return Pair.cons(Pair.left(newInstance),
                               List.append(log)(Pair.right(newInstance)));
                               -- List.append(log)(List.cons(Pair.right(newInstance), List.empty())));
            end 
          })
        end;
      end,
      --/* 引数 value をログに格納する */
      --/* output:: VALUE => LOG[()] */
      output = function(value)
        return Pair.cons(nil, 
                         List.cons(value, List.empty()));
      end 
    };
    --/* #@range_end(logger_monad) */
    -- **リスト8.22** LOGモナド評価器
    --/* #@range_begin(logger_monad_evaluator) */
    --/* evaluate:= function(EXP, ENV) => LOG[VALUE] */
    local function evaluate(anExp, environment)
      return match(anExp,{
        --/* log式の評価 */
        log = function(anExp)
          --/* 式を評価する */
          return LOG.flatMap(evaluate(anExp, environment))(function(value)
            --/* value をログに格納する */
            return LOG.flatMap(LOG.output(value))(function(_)
              return LOG.unit(value); 
            end)
          end)
        end,
        --/* #@range_end(logger_monad_evaluator) */
        --/* 数値の評価 */
        num = function(value)
          return LOG.unit(value);
        end,
        --/* 変数の評価 */
        variable = function(name)
          return LOG.unit(Env.lookup(name, environment));
        end,
        --/* λ式の評価 */
        lambda = function(variable, body) 
          return exp.match(variable,{
            variable = function(name)
              return LOG.unit(function(actualArg)
                return evaluate(body, Env.extend(name, actualArg, environment));
              end);
            end 
          });
        end,
        --/* 関数適用の評価 */
        app = function(lambda, arg)         -- 関数適用の評価
          return LOG.flatMap(evaluate(lambda, environment))(function(closure)
            return LOG.flatMap(evaluate(arg, environment))(function(actualArg)
              return closure(actualArg); 
            end);
          end);
        end,
        add = function(expL, expR)
          return LOG.flatMap(evaluate(expL, environment))(function(valueL)
            return LOG.flatMap(evaluate(expR, environment))(function(valueR)
              return LOG.unit(valueL + valueR); 
            end);
          end);
        end
      });
    end
    -- ### ログ出力評価器のテスト
    describe('ログ出力評価器のテスト', function()
      it('LOG評価器で数値を評価する', function()
        --/* #@range_begin(log_interpreter_number) */
        Pair.match(evaluate(exp.log(exp.num(2)), Env.empty),{
          cons = function(value, log)
            assert.are.equal(
              value 
            , 
             2 
            )
            -- expect( -- 結果の値をテストする
            --   value
            -- ).to.be(
            --   2
            -- );
            assert.are.equal(
              List.toArray(log) 
            , 
              {} 
            )
            -- expect( -- 保存されたログを見る
            --   list.toArray(log)
            -- ).to.eql(
            --   [2]
            -- );
          end
        });
        --/* #@range_end(log_interpreter_number) */
      end);
--       it('LOG評価器で変数を評価する', (next) => {
--         --/* #@range_begin(log_interpreter_variable) */
--         local newEnv = env.extend("x", 1, env.empty);
--         pair.match(evaluate(exp.log(exp.variable("x")), newEnv), {
--           cons= function(value, log) => {
--             expect( -- 結果の値をテストする
--               value
--             ).to.eql(
--               1
--             );
--             expect( -- 保存されたログを見る
--               list.toArray(log)
--             ).to.eql(
--               [1]
--             );
--           }
--         });
--         --/* #@range_end(log_interpreter_variable) */
--         next();
--       });
--       it('LOG評価器で演算を評価する', (next) => {
--         pair.match(evaluate(exp.log(exp.add(exp.num(1),exp.num(2))), env.empty),{
--           cons= function(value, log) => {
--             expect(
--               value
--             ).to.be(
--               3
--             );
--             expect(
--               list.toArray(log)
--             ).to.eql(
--               [3]
--             );
--           }
--         });
--         pair.match(evaluate(exp.log(exp.add(exp.log(exp.num(1)),exp.log(exp.num(2)))), env.empty),{
--           cons= function(value, log) => {
--             expect(
--               value
--             ).to.be(
--               3 -- 1 + 2 = 3
--             );
--             expect(
--               list.toArray(log)
--             ).to.eql(
--               [1,2,3]
--             );
--           }
--         });
--         -- **リスト8.25** ログ出力評価器による評価戦略の確認
--         --/* #@range_begin(log_interpreter_evaluation_strategy) */
--         -- ~~~js
--         -- ((n) => {
--         --    return add(1)(n)
--         -- })(2);
--         -- ~~~ 
--         local theExp = exp.log(exp.app(exp.lambda(exp.variable("n"),
--                                                 exp.add(exp.log(exp.num(1)), 
--                                                         exp.variable("n"))),
--                                      exp.log(exp.num(2))));
--         pair.match(evaluate(theExp, env.empty),{
--           --/* パターンマッチで結果を取り出す */
--           cons = function(value, log) => {
--             expect(
--               value
--             ).to.eql(
--               3
--             );
--             expect(
--               list.toArray(log)
--             ).to.eql(
--               [2,1,3]
--             );
--           }
--         });
--         --/* #@range_end(log_interpreter_evaluation_strategy) */
--         next();
--       });
--       it('LOG評価器で関数適用を評価する', (next) => {
--         -- ~~~js
--         -- ((x) => {
--         --    return add(x)(x)
--         -- })(2);
--         -- ~~~ 
--         local expression = exp.app(exp.lambda(exp.variable("x"),
--                                             exp.add(exp.variable("x"),exp.variable("x"))),
--                                  exp.num(2));
--         expect(
--           pair.left(evaluate(expression, env.empty))
--         ).to.eql(
--           4
--         );
--         expect(
--           list.toArray(pair.right(evaluate(expression, env.empty)))
--         ).to.eql(
--           []
--         );
--         next();
--       });
--       it('LOG評価器でカリー化関数を評価する', (next) => {
--         -- ~~~js
--         -- ((x) => {
--         --   return (y) => {
--         --       return add(x)(y)
--         --   };
--         -- })(2)(3);
--         -- ~~~ 
--         local expression = exp.app(
--           exp.app(exp.lambda(exp.variable("x"),
--                              exp.lambda(exp.variable("y"),
--                                         exp.add(exp.variable("x"),exp.variable("y")))),
--                   exp.num(2)),
--           exp.num(3));
--         expect(
--           pair.left(evaluate(expression, emptyEnv))
--         ).to.be(
--           5
--         );
--         next();
--       });
     end)
   end) 
end)
--
--
-- -- [目次に戻る](index.html) 


