-- 第6章 関数を利用する
-- ========

-- ## 小目次
-- <div class="toc">
-- <ul class="toc">
--   <li><a href="http:--akimichi.github.io/functionaljs/chap06.spec.html#function-basics">6.1 関数の基本</a>
--     <ul>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap06.spec.html#function-definition">関数を定義する</a></li>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap06.spec.html#function-application">関数を適用する</a></li></ul>
--   </li>
--   <li><a href="http:--akimichi.github.io/functionaljs/chap06.spec.html#function-and-referential-transparency">6.2 関数と参照透過性</a>
--      <ul>
--         <li><a href="http:--akimichi.github.io/functionaljs/chap06.spec.html#purity-of-function">関数の純粋性</a></li>
--         <li><a href="http:--akimichi.github.io/functionaljs/chap06.spec.html#coping-sideeffect">副作用への対処</a></li>
--      </ul>
--   </li>
-- </ul>
-- </div>


-- ## 6.1 <section id='function-basics'>関数の基本</section>
describe('関数の基本', function()
  -- ### <section id='function-definition'>関数を定義する</section>
  describe('関数を定義する', function()
    -- **リスト6.1** 恒等関数
    it('恒等関数', function()
      -- /* #@range_begin(identity_function_definition) */
      local identity = function(any)
        return any;
      end
      -- /* #@range_end(identity_function_definition) */
      assert.are.equal(identity(1), 1)
      assert.are.equal(identity("a"), "a")
      -- expect(
      --   identity(1)
      -- ).to.eql(
      --   1
      -- );
      -- expect(
      --   identity("a")
      -- ).to.eql(
      --   "a"
      -- );
    end)
    -- **リスト6.2** succ関数
    it('succ関数', function()
      -- /* #@range_begin(succ_function_definition) */
      local succ = function(n)
        return n + 1;
      end
      -- /* #@range_end(succ_function_definition) */
      -- /* テスト */
      assert.are.equal(succ(0), 1)
      -- expect(
      --   succ(0)  -- 0 を引数にsucc関数を適用する
      -- ).to.eql(
      --   1
      -- );
      assert.are.equal(succ(1), 2)
      -- expect(
      --   succ(1)  -- 数値1にsucc関数を適用する
      -- ).to.eql(
      --   2
      -- );
      -- ~~~
      -- node> local succ = (n) => { return n + 1; }; 
      -- undefined
      -- node> succ("abc")
      -- abc1
      -- ~~~
      -- assert.are.equal(succ("abc"), 2)
      -- 
      -- expect(
      --   succ("abc")
      -- ).to.eql(
      --   "abc1"
      -- );
    end)
    -- **リスト6.3** add関数
    it('add関数', function()
      -- /* #@range_begin(add_function_definition) */
      -- /* add:: (NUM, NUM) => NUM */
      local add = function(n, m)
        return n + m;
      end 
      -- /* #@range_end(add_function_definition) */
      -- /* テスト */
      assert.are.equal(add(0, 1), 1)
      -- expect(
      --   add(0,1)
      -- ).to.eql(
      --   1
      -- );
    end)
    -- **リスト6.5** 関数の変数へのバインド
    it('関数の変数へのバインド', function()
      -- /* #@range_begin(function_bound_to_variable) */
      local succ = function(x)
        return x + 1;
      end 
      -- /* #@range_end(function_bound_to_variable) */
    end)
    it('引数を参照しない関数', function()
      -- **リスト6.6** 定数関数
      -- /* #@range_begin(constant_one_function) */
      local alwaysOne = function(x)
        return 1;
      end 
      -- /* #@range_end(constant_one_function) */
      assert.are.equal(alwaysOne(1), 1)
      assert.are.equal(alwaysOne("a"), 1)
      -- expect(
      --   alwaysOne(1)
      -- ).to.eql(
      --   1
      -- );
      -- expect(
      --   alwaysOne("a")
      -- ).to.eql(
      --   1
      -- );
      -- **リスト6.7** left関数
      -- /* #@range_begin(left_function) */
      local left = function(x,y)
        return x;
      end
      -- /* #@range_end(left_function) */
      assert.are.equal(left(1), 1)
      -- expect(
      --   left(1,2)
      -- ).to.eql(
      --   1
      -- );
    end)
  end)
  -- ### <section id='function-application'>関数を適用する</section>
  describe('関数を適用する', function()
    -- **リスト6.8** succ関数のテスト
    it('succ関数のテスト', function()
      -- /* #@range_begin(succ_function_test) */
      local succ = function(n) -- nは仮引数 
        return n + 1;
      end 
      assert.are.equal(succ(1), 2)
      -- expect(
      --   succ(1)  -- 数値1にsucc関数を適用する
      -- ).to.eql(
      --   2
      -- );
      -- /* #@range_end(succ_function_test) */
    end)
    -- #### 関数の評価戦略
    describe('関数の評価戦略', function()
      it('add(succ(0), succ(2))の簡約', function()
        local add = function(n, m)
          return n + m;
        end 
        local succ = function(n)
          return n + 1;
        end 
        assert.are.equal(add(succ(0), succ(2)), 4)
        -- expect(
        --   add(succ(0), succ(2))
        -- ).to.eql(
        --   4
        -- );
      end)
      -- **リスト6.9** JavaScriptにおける正格評価
      it('JavaScriptにおける正格評価', function()
        -- /* #@range_begin(strict_evaluation_in_javascript) */
        local left = function(x,y)
          return x;
        end 
        local infiniteLoop = function(_)
          return infiniteLoop(_);
        end 
        --[[ /* このテストは無限ループになるのでコメントアウトしている
         expect(
           left(1, infiniteLoop())
         ).to.eql(
           1
         )
         --]]
        -- /* #@range_end(strict_evaluation_in_javascript) */
      end)
      -- **リスト6.10** 条件文と遅延評価
      it('条件文と遅延評価', function()
        -- /* #@range_begin(conditional_is_nonstrict) */
        local infiniteLoop = function()
          return infiniteLoop();
        end

        local conditional = function(n)
          if(n == 1) then
            return true;
          else
            -- /* 条件文が真の場合には評価されない */
            return infiniteLoop();
          end 
        end 
        assert.are.equal(conditional(1), true)
        -- expect(
        --   conditional(1)
        -- ).to.eql(
        --   true -- 無限ループに陥ることなく計算に成功する
        -- );
        -- /* #@range_end(conditional_is_nonstrict) */
      end)
      it('乗算の遅延評価', function()
        local infiniteLoop = function()
          return infiniteLoop();
        end 
        -- **リスト6.11** 遅延評価で定義したmultiply関数
        -- /* #@range_begin(multiply_lazy_evaluation) */
        local lazyMultiply = function(funX,funY)
          local x = funX();

          if(x == 0) then
            return 0;          -- xが0ならば、funYは評価しない
          else
            return x * funY(); -- ここで初めてfunYを評価する
          end 
        end 
        -- /* #@range_end(multiply_lazy_evaluation) */
        -- **リスト6.12** 遅延評価で定義したmultiply関数のテスト
        -- /* #@range_begin(multiply_lazy_evaluation_test) */
        -- expect(
        --   lazyMultiply((_) => {    -- 値を関数でラッピングする
        --     return 0;
        --   }, (_) => {
        --     return infiniteLoop(); -- ここが評価されると無限ループに陥る
        --   })
        -- ).to.eql(
        --   0
        -- );
        -- /* #@range_end(multiply_lazy_evaluation_test) */
      end)
    end)
    -- #### サンクで無限を表現する
    describe('サンクで無限を表現する', function()
      -- **リスト6.14** サンクによるストリーム型の定義
      -- /* #@range_begin(stream_with_thunk) */
      local match = function(data, pattern)
        return data(pattern)
      end 
      
      local stream = {
        empty = function(_)
          return function(pattern)
            return pattern.empty()
          end
        end, 
        cons = function(head,tailThunk)
          return function(pattern)
            return pattern.cons(head,tailThunk);
          end 
        end, 
        -- /* head:: STREAM[T] => T */
        -- /* ストリーム型headの定義は、リスト型headと同じ */
        head = function(astream)
          return match(astream,{
            empty = function(_) 
              return nil
            end, 
            cons = function(value, tailThunk)
              return value
            end
          })
        end,
        -- /* tail:: STREAM[T] => STREAM[T] */
        tail = function(astream)
          return match(astream,{
            empty = function(_)
              return nil
            end, 
            cons = function(head, tailThunk)
              return tailThunk(); -- ここで初めてサンクを評価する
            end
          })
        end
      };
      -- /* #@range_end(stream_with_thunk) */
      -- **リスト6.16** ストリーム型のテスト
      it("ストリーム型のテスト", function()
        -- /* #@range_begin(stream_with_thunk_test) */
        local theStream = stream.cons(1, function(_) -- 第2引数にサンクを渡す
          return stream.cons(2, function(_)         -- 第2引数にサンクを渡す
            return stream.empty();
          end)
        end)
        assert.are.equal(stream.head(theStream) , 1)
        -- expect(
        --   stream.head(theStream)  -- ストリームの先頭要素を取り出す
        -- ).to.eql(
        --   1
        -- );
        -- /* #@range_end(stream_with_thunk_test) */
      end)
      describe("無限ストリームを作る", function()
        local match = function(data, pattern)
          return data(pattern);
        end
        local stream = {
          empty = function(_)
            return function(pattern)
              return pattern.empty();
            end 
          end, 
          cons = function(head,tailThunk)
            return function(pattern)
              return pattern.cons(head,tailThunk);
            end
          end,
          -- /* head:: STREAM[T] => T */
          -- /* ストリーム型headの定義は、リスト型headと同じ */
          head = function(astream)
            return match(astream,{
              empty = function(_) 
                return nil
              end, 
              cons = function(value, tailThunk)
                return value
              end
            })
          end,
          -- /* tail:: STREAM[T] => STREAM[T] */
          tail = function(astream)
            return match(astream,{
              empty = function(_)
                return nil
              end,
              cons = function(head, tailThunk)
                return tailThunk();  -- ここで初めてサンクを評価する
              end
            })
          end
        }
        it("無限の整数列を作る", function()
          pending("I should finish this test later")
          -- **リスト6.17** 無限に1が続く数列
          -- /* #@range_begin(infinite_ones) */
          -- /* ones = 1,1,1,1,... */
        --   local ones = stream.cons(1, function tailThunk(_)
        --     return ones; -- onesを再帰的に呼び出す
        --   end)
        --   -- /* #@range_end(infinite_ones) */
        --   -- /* #@range_begin(infinite_ones_test) */
        --   assert.are.equal(stream.head(ones) , 1)
        --   -- expect(
        --   --   stream.head(ones) -- 最初の要素を取りだす
        --   -- ).to.eql(
        --   --   1
        --   -- );
        --   assert.are.equal(stream.tail(ones) , 0)
        --   -- expect(
        --   --   stream.head(stream.tail(ones))  -- 2番目の要素を取りだす
        --   -- ).to.eql(
        --   --   1
        --   -- );
        --   -- /* #@range_end(infinite_ones_test) */
        --
        --   -- **リスト6.19** 無限に連続する整数列を生成するenumFrom関数
        --   -- /* #@range_begin(infinite_integer) */
        --   local enumFrom = function(n)
        --     return stream.cons(n, function(_)
        --       return enumFrom(n + 1)
        --     end )
        --   end 
        --   -- /* #@range_end(infinite_integer) */
        --   expect(
        --     stream.head(enumFrom(1)) -- 最初の要素を取りだす
        --   ).to.eql(
        --     1
        --   );
        --   expect(
        --     stream.head(stream.tail(enumFrom(1)))  -- 2番目の要素を取りだす
        --   ).to.eql(
        --     2
        --   );
        end)
        it("無限の整数列をテストする", function()
          -- this.timeout(3000);
          local function enumFrom(n)
            return stream.cons(n, function(_)
              return enumFrom(n + 1);
            end)
          end 
          local function match(data, pattern)
              return data(pattern)
          end
          local list = {
            empty = function(_)
              return function(pattern)
                return pattern.empty();
              end
            end,
            cons = function(value, list)
              return function(pattern)
                return pattern.cons(value, list);
              end 
            end,
            isEmpty = function(alist)
              return match(alist, { 
                empty = true,
                cons = function(head, tail)
                  return false;
                end
              })
            end,
            head = function(alist)
              return match(alist, {
                empty = nil, 
                cons =  function(head, tail)
                  return head;
                end
              })
            end,
            tail = function(alist) 
              return match(alist, {
                empty = nil,
                cons = function(head, tail)
                  return tail;
                end
              })
            end,
            -- **リスト6.22** リストのtoArray関数
            -- /* #@range_begin(list_toArray) */
            toArray = function(alist)
              local function toArrayHelper(alist,accumulator)
                return match(alist, {
                  empty = function(_)
                    return accumulator;
                  end,
                  cons = function(head, tail)

                    accumulator[#accumulator+1] = head
                    return toArrayHelper(tail, accumulator);
                    -- return toArrayHelper(tail,
                    --                      accumulator.concat(head));
                  end
                })
              end
              return toArrayHelper(alist, {});
            end
            -- /* #@range_end(list_toArray) */
          };
          -- **リスト6.21** ストリームのtake関数
          -- /* #@range_begin(stream_take) */
          -- /* take:: (STREAM[T], NUM) => LIST[T] */
          local function take(astream, n)
            return match(astream,{
              empty = function(_)              -- ストリームが空のケース
                return list.empty();
              end,
              cons = function(head,tailThunk)  -- ストリームが空でないケース 
                if(n == 0) then
                  return list.empty();
                else
                  -- print("head: " ..head)
                  -- リストを生成する
                  return list.cons(head, take(tailThunk(),(n - 1)))
                end 
              end
            })
          end
          -- /* take関数を定義するため、streamモジュールを再掲する */
          local stream = {
            empty = function(_)
              return function(pattern)
                return pattern.empty();
              end
            end,
            cons = function(head,tailThunk)
              return function(pattern)
                return pattern.cons(head,tailThunk);
              end
            end,
            head = function(astream)
              return match(astream,{
                empty = function(_)
                  return nil
                end,
                cons = function(value, tailThunk)
                 return value
               end
              })
            end,
            tail = function(astream)
              return match(astream,{
                empty = function(_)
                  return nil
                end,
                cons = function(head, tailThunk)
                  return tailThunk();  
                end 
              })
            end,
            -- **リスト6.21** ストリームのtake関数
            -- /* #@range_begin(stream_take) */
            -- /* take:: (STREAM[T], NUM) => LIST[T] */
            -- take = function(astream, n)
            --   return match(astream,{
            --     empty = function(_)              -- ストリームが空のケース
            --       return list.empty();
            --     end,
            --     cons = function(head,tailThunk)  -- ストリームが空でないケース 
            --       if(n == 0) then
            --         return list.empty();
            --       else
            --         return list.cons(head,   -- リストを生成する
            --                          stream.take(tailThunk(),(n -1)))
            --       end 
            --     end
            --   })
            -- end
          }
          -- /* #@range_end(stream_take) */
          assert.are.equal(stream.head(enumFrom(1)), 1)
          -- expect(
          --   stream.head(enumFrom(1))
          -- ).to.eql(
          --   1
          -- );
          assert.are.equal(stream.head(stream.tail(enumFrom(1))), 2)
          -- expect(
          --   stream.head(stream.tail(enumFrom(1)))
          -- ).to.eql(
          --   2
          -- );
          -- **リスト6.23** 無限の整数列をテストする
          -- /* #@range_begin(infinite_integer_test) */
          assert.are.same(
            list.toArray( -- ストリームを配列に変換する
              take(enumFrom(1),4) -- 無限の整数列から4個の要素を取り出す 
              ), {1, 2, 3, 4 })
             

          -- expect(
          --   list.toArray( -- ストリームを配列に変換する
          --     stream.take(enumFrom(1),4) -- 無限の整数列から4個の要素を取り出す 
          --   )
          -- ).to.eql(
          --   [1,2,3,4]
          -- );
          -- /* #@range_end(infinite_integer_test) */
          -- /* #@range_begin(stream_filter_test) */
          -- expect(
          --   -- /* 無限の整数列から最初の4つの要素を取り出し、それを配列に変換する */
          --   list.toArray(stream.take(enumFrom(1), 4))
          -- ).to.eql(
          --   [1,2,3,4]
          -- );
          -- /* #@range_end(stream_filter_test) */
        end)
      end)
    end)
  end) -- 関数の適用
end) -- 関数の基本

-- ## 6.2 <section id='function-and-referential-transparency'>関数と参照透過性</section>
describe('関数と参照透過性', function()
  -- ### <section id='purity-of-function'>関数の純粋性</section>
  -- **リスト6.25** succ関数は参照透過性を持つ
  it('succ関数は参照透過性を持つ', function()
    local succ = function(n)
      return n + 1
    end
    -- /* #@range_begin(succ_has_referential_transparency) */
    assert.are.equal(succ(1), succ(1))
    -- expect(
    --   succ(1)
    -- ).to.eql(
    --   succ(1)
    -- );
    -- /* #@range_end(succ_has_referential_transparency) */
  end)
  -- **リスト6.26** ファイル操作は参照透過性を破壊する
  it('ファイル操作は参照透過性を破壊する', function()
    pending("I should finish this test later")
    -- /* #@range_begin(fileio_destroys_referential_transparency) */
    -- -- /* fsモジュールを変数fsにバインドする */
    -- local fs = require('fs');
    -- --[[/* テストの実行前にあらかじめ "This is a test."
    --    という文字列をファイルに書き込んでおく */
    --    --]]
    -- fs.writeFileSync('test/resources/file.txt', "This is a test.");
    --
    -- --/* 第1回目のファイルの読み込み */
    -- local text = fs.readFileSync("test/resources/file.txt",'utf8');
    -- expect(
    --   fs.readFileSync("test/resources/file.txt", 'utf8')
    -- ).to.eql(
    --   "This is a test."
    -- );
    -- -- /* 途中でのファイルへの書き込み */
    -- fs.writeFileSync('test/resources/file.txt',
    --                  "This is another test.");
    --
    -- --/* 第2回目のファイルの読み込み */
    -- expect(
    --   fs.readFileSync("test/resources/file.txt", 'utf8')
    -- ).to.eql(-- /* 最初の readFileSync関数の結果と異なっている */
    --   "This is another test."
    -- );
    -- /* #@range_end(fileio_destroys_referential_transparency) */
  end)
  it('画面出力が参照透過性を損なうこと', function()
    pending("I should finish this test later")
    -- /* #@range_begin(log_destroys_referential_transparency) */
    -- expect(
    --   console.log("this is a test")
    -- ).to.eql(
    --   console.log("this is anoter test")
    -- );
    -- /* #@range_end(log_destroys_referential_transparency) */
  end)
  -- ### <section id='coping-sideeffect'>副作用への対処</section>
  describe('副作用への対処', function()
    describe('tap関数', function()
      -- **リスト6.27** tap関数
      -- /* #@range_begin(tap_combinator) */
      local tap = function(target,sideEffect)
        sideEffect(target); -- 副作用を実行する
        return target;
      end 
      --- /* #@range_end(tap_combinator) */
      -- **リスト6.28** tap関数によるconsole.logのテスト
      it('tap関数によるconsole.logのテスト', function()
        local succ = function(n)
          return n + 1
        end 
        -- /* #@range_begin(tap_combinator_test_in_console) */
        -- /* 画面出力という副作用を実行する関数 */
        local consoleSideEffect = function(any)
          print(any)
        end 
        assert.are.equal(tap(succ(1), consoleSideEffect), tap(succ(1), consoleSideEffect))
        -- expect(
        --   tap(succ(1), consoleSideEffect)
        -- ).to.eql(
        --   tap(succ(1), consoleSideEffect)
        -- );
        -- /* #@range_end(tap_combinator_test_in_console) */
      end)
      -- **リスト6.29** tap関数によるファイル入出力のテスト
      it('tap関数によるファイル入出力のテスト', function()
        -- local fs = require('fs'); -- fsモジュールを変数fsにバインドする
        -- -- /* #@range_begin(tap_combinator_test_in_fileio) */
        -- -- /* あらかじめ文字列をファイルに書き込んでおく */
        -- fs.writeFileSync('test/resources/file.txt', "This is a test.");

        -- /* ファイルからの読み込みという副作用を実行する */
        local IOSideEffect = function(_)
          local content = fs.readFileSync("test/resources/file.txt",
                                        'utf8');
          fs.writeFileSync('test/resources/file.txt',
                           "This is another test.");
          return content;
        end 

        -- expect(
        --   tap(fs.readFileSync("test/resources/file.txt", 'utf8'),
        --       IOSideEffect)
        -- ).not.to.eql( -- 同じ引数に適用しているのに両者は等しくない
        --   tap(fs.readFileSync("test/resources/file.txt", 'utf8'),
        --       IOSideEffect)
        -- );
        -- /* #@range_end(tap_combinator_test_in_fileio) */
      end)
    end)
  end)
end)

-- [目次に戻る](index.html) [次章に移る](chap07.spec.html) 
