-- // 第5章 プログラムをコントロールする仕組み
-- // ============================
--
-- // ## 小目次
-- // <div class="toc">
-- // <ul class="toc">
-- //   <li><a href="http://akimichi.github.io/functionaljs/chap05.spec.html#conditional-statements">5.1 条文分岐の種類と特徴</a>
-- //      <ul>
-- //        <li><a href="http://akimichi.github.io/functionaljs/chap05.spec.html#if-statement">条件分岐としてのif文</a></li>
-- //        <li><a href="http://akimichi.github.io/functionaljs/chap05.spec.html#switch-statement">条件分岐としてのswitch文</a></li></ul>
-- //   </li>
-- //   <li><a href="http://akimichi.github.io/functionaljs/chap05.spec.html#loop-statements">5.2 反復処理の種類と特徴</a></li>
-- //   <li><a href="http://akimichi.github.io/functionaljs/chap05.spec.html#recursion">5.3 再帰による反復処理</a>
-- //      <ul>
-- //        <li><a href="http://akimichi.github.io/functionaljs/chap05.spec.html#requirements-of-recursion">再帰呼び出しの条件</a></li>
-- //        <li><a href="http://akimichi.github.io/functionaljs/chap05.spec.html#advantages-of-recursion">再帰呼び出しの利点</a></li>
-- //   </li>
-- // </ul>
-- // </div>


-- ## 5.1 <section id='conditional-statements'>条文分岐の種類と特徴</section>
describe('条文分岐の種類と特徴', function()
  -- ### <section id='if-statement'>条文分岐としてのif文</section>
  describe('条件分岐としてのif文', function()
    -- **リスト5.2** 偶数かどうかを判定する
    it('偶数かどうかを判定する', function()
      -- /* ##@range_begin(even_function)*/
      local even = function(n)
        if (n % 2) == 0 then -- 2で割った余りが0の場合
          return true;
        else             -- 2で割った余りが0でない場合
          return false;
        end
      end 
      -- /* ##@range_end(even_function)*/
      assert.are.equal(even(2), true)
      assert.are.equal(even(3), false)
      
      -- expect(
      --   even(2)
      -- ).to.eql(
      --   true
      -- );
      -- expect(
      --   even(3)
      -- ).to.eql(
      --   false
      -- );
    end)
    -- **リスト5.3** ネストされたif文
    it("ネストされたif文", function()
      -- /* #@range_begin(compare) */
      local compare =  function(n,m)
        if (n > m) then     -- nがmよりも大きなケース
          return 1;
        else
          if(n == m) then  -- ネストされたif文
            return 0;
          else
            return -1;
          end 
        end 
      end
      -- /* テスト */
      -- /* 3 は 2 よりも大きい */
      assert.are.equal(compare(3, 2), 1)
      -- expect(
      --   compare(3,2)
      -- ).to.eql(
      --   1
      -- );
      -- /* 2 は 3 よりも小さい */
      assert.are.equal(compare(2, 3), -1)
      -- expect(
      --   compare(2,3)
      -- ).to.eql(
      --     -1
      -- );
      -- /* #@range_end(compare) */
      -- /* 1 と 1 は等しい */
      assert.are.equal(compare(1, 1), 0)
      -- expect(
      --   compare(1,1)
      -- ).to.eql(
      --   0
      -- );
    end)
    -- **リスト5.4** else if文による3つ以上の条件分岐
    it("else if文による3つ以上の条件分岐", function()
      -- /* #@range_begin(elseif) */
      local compare =  function(n,m)
        if (n > m) then
          return 1;
        elseif (n == m) then -- elseにif文を続ける
          return 0;
        else
          return -1;
        end 
      end 
      -- /* #@range_end(elseif) */
      -- /* テスト */
      -- /* 3 は 2 よりも大きい */
      assert.are.equal(compare(3, 2), 1)
      -- expect(
      --   compare(3,2)
      -- ).to.eql(
      --   1
      -- );
      -- /* 1 と 1 は等しい */
      assert.are.equal(compare(1, 1), 0)
      -- expect(
      --   compare(1,1)
      -- ).to.eql(
      --   0
      -- );
      -- /* 2 は 3 よりも小さい */
      assert.are.equal(compare(2, 3), -1)
      -- expect(
      --   compare(2,3)
      -- ).to.eql(
      --     -1
      -- );
    end)
    -- #### if文の問題点
    --
    -- JavaScriptのifは、結果を返さない
    -- ~~~
    -- node> var resultStatement = console.log("This is a test")
    -- This is a test
    -- undefined
    -- node> resultStatement
    -- undefined
    -- node> var resultExpression = 1 + 2;
    -- undefined
    -- node> resultExpression
    -- 3
    -- ~~~
    describe('if文の問題点', function()
      -- **リスト5.7** returnで関数を抜ける
      it('returnで関数を抜ける', function()
        -- /* ##@range_begin(even_function_again) */
        local even = function(n)
          if((n % 2) == 0) then
            -- /* returnでeven関数を抜けてtrueを返す */
            return true;       
          else
            -- /* returnでeven関数を抜けてfalseを返す */
            return false;      
          end 
        end 
        -- /* ##@range_end(even_function_again) */
      end)
    end)
  end)
  -- ### <section id='switch-statement'>条件分岐としてのswitch文</section>
  -- > 参考資料: https:--developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Statements/switch
  describe('条件分岐としてのswitch文', function()
    -- #### switch文の問題点
    it("switch文の問題点", function()
      pending("I should finish this test later")
      
      -- **リスト5.10** 可変なデータとのマッチング
      -- /* #@range_begin(switch_for_mutable) */
      -- local match_for_mutable = function(array)
      --   switch(array){
      --   case [1,2,3]: -- [1,2,3] とマッチさせたい
      --     return true;   -- マッチすれば、trueを返す
      --     break;
      --   default:
      --     return false;  -- マッチしなければ、falseを返す
      --   }
      -- end 
      -- -- /* テスト */
      -- expect(
      --   match_for_mutable([1,2,3])
      -- ).to.eql(
      --   false  -- case [1,2,3] にはマッチしない
      -- );
      -- -- /* #@range_end(switch_for_mutable) */
      -- next();
    end)
  end)
  -- #### 代数的データ型とパターンマッチ
  -- > 参考資料: [代数的データ型](https:--ja.wikipedia.org/wiki/%E4%BB%A3%E6%95%B0%E7%9A%84%E3%83%87%E3%83%BC%E3%82%BF%E5%9E%8B)
   describe('代数的データ型とパターンマッチ', function()
     local match = function(data, pattern)
       return data(pattern, pattern)
     end
     -- **リスト5.12** 代数的データ構造によるリスト
     it('代数的データ構造によるリスト', function()
       -- /* #@range_begin(list_in_algebraic_datatype) */
       -- /* リストの代数的データ型 */
       local empty = function() -- 空のリスト
         return function(pattern)
           return pattern.empty()
         end  
       end 
       local cons = function(value, list)  -- 空でないリスト
         return function(pattern)
           return pattern.cons(value, list)
         end
       end 
       -- /* #@range_end(list_in_algebraic_datatype) */

       -- **リスト5.13** 代数的データ構造のmatch関数
       -- /* #@range_begin(match_in_algebraic_datatype) */
       -- /* 代数的データ型に対してパターンマッチを実現する関数 */
       local match = function(data, pattern)
         return data(pattern)
       end
       -- /* #@range_end(match_in_algebraic_datatype) */

       -- **リスト5.14** リストの関数定義
       -- /* #@range_begin(list_function_using_algebraic_datatype) */
       -- /* isEmpty関数は、引数alistに渡されたリストが空のリストかどうかを判定する */
       local isEmpty = function(alist)
         -- /* match関数で分岐する */
         return match(alist, { 
           -- /* emptyにマッチするケース */
           empty =  function(_)
             return true
           end, 
           -- /* consにマッチするケース */
           cons = function(head, tail) -- headとtailにそれぞれ先頭と後尾が入る
             return false
           end
         })
       end 
       -- /* head関数は、引数alistに渡されたリストの先頭の要素を返す */
       local head = function(alist)
         return match(alist, {
           -- /* 空のリストに先頭要素はない */
           empty = function(_)
             return null; 
           end,
           cons = function(head, tail) 
             return head;
           end 
         })
       end 
       -- /* tail関数は、引数alistに渡されたリストの後尾のリストを返す */
       local tail = function(alist)
         return match(alist, {
           -- /* 空のリストに後尾はない */
           empty = function(_)
             return null;  
           end,
           cons = function(head, tail)
             return tail
           end 
         })
       end 
       -- /* #@range_end(list_function_using_algebraic_datatype) */

       -- <a name="match_reduction_demo"> **head(cons(1, empty()))の簡約** </a>
       -- ![head(cons(1, empty()))の簡約](images/match-reduction.gif) 

       -- **リスト5.15** 代数的データ構造のリストの関数のテスト
       -- /* #@range_begin(list_in_algebraic_datatype_test) */
       -- /* emptyは空のリストか */
       assert.are.equal(isEmpty(empty()), true)
       -- expect(
       --   isEmpty(empty())                    
       -- ).to.eql(
       --   true
       -- );
       -- /* cons(1,empty())は空のリストか */
       assert.are.equal(isEmpty(cons(1, empty())), false)
       -- expect(
       --   isEmpty(cons(1,empty()))            
       -- ).to.eql(
       --   false
       -- );
       -- /* cons(1,empty())の先頭要素は1である */
       assert.are.equal(head(cons(1, empty())), 1)
       -- expect(
       --   head(cons(1,empty()))               
       -- ).to.eql(
       --   1
       -- );
       -- /* cons(1,cons(2,empty()))の2番目の要素は2である */
       assert.are.equal(head(tail(cons(1,cons(2,empty())))) , 2)
       -- expect(
       --   head(tail(cons(1,cons(2,empty())))) 
       -- ).to.eql(
       --   2
       -- );
       -- /* #@range_end(list_in_algebraic_datatype_test) */
       assert.are.equal(isEmpty(tail(cons(1,empty()))),  true)
       -- expect(
       --   isEmpty(tail(cons(1,empty())))     -- [1]の末尾要素は空のリストである
       -- ).to.be(
       --   true
       -- );
       -- assert.are.equal(tail(cons(1,cons(2,empty()))) , 2)
     end)
   end)
 end)

 -- ## 5.2 <section id='loop-statements'>反復処理の種類と特徴</section>
 describe("反復処理の種類と特徴", function()
   -- **リスト5.16** while文の例
   it("while文の例", function()
     -- /* #@range_begin(while_counter) */
     local counter = 0         -- 変数の初期化
     while (counter < 10) do   -- 反復の条件
       counter = counter + 1; -- 変数の更新
     end 
     -- /* テスト */
     assert.are.equal(counter, 10)
     -- expect(
     --   counter
     -- ).to.eql(
     --   10
     -- );
     -- /* #@range_end(while_counter) */
   end)
   -- **リスト5.17** for文の例
   it("for文の例", function()
     -- /* #@range_begin(for_example) */
     local counter =0
     for i = 0,  10,  1 do
        counter = i 
     end
     -- /* テスト */
     assert.are.equal(counter, 10)
     -- expect(
     --   counter
     -- ).to.eql(
     --   10
     -- );
     -- /* #@range_end(for_example) */
   end)
   -- **リスト5.18** forEachメソッドの例
   -- > 参考資料: https:--developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach 
  it("forEach文によるlength", function()
    pending("I should finish this test later")
    -- /* #@range_begin(forEach_length) */
    -- local length = function(array)
    --   local result = 0;
    --   array.forEach((element) => {
    --     result += 1;
    --   });
    --   return result;
    -- end 
    -- -- /* テスト */
    -- expect(
    --   length([1,2,3,4,5])
    -- ).to.eql(
    --   5
    -- );
    -- /* #@range_end(forEach_length) */
  end)
end)

-- ## 5.3 <section id='recursion'>再帰による反復処理</section>
describe('再帰による反復処理', function()
  -- ### 複利法 
  describe('複利法の例', function()
    -- [![IMAGE ALT TEXT](http:--img.youtube.com/vi/tviCjVufyTU/0.jpg)](https:--www.youtube.com/watch?v=tviCjVufyTU "複利計算の公式")

    -- **リスト5.19** 複利の計算
    it("複利の計算", function()
      -- /* #@range_begin(compound_interest) */
      function compoundInterest(a, r, n)
        if (n == 0) then -- 初年度は利率がつかないので元金がそのまま返る
          return a;
        else
          -- /* compoundInterestの再帰呼び出し */
          return compoundInterest(a, r, n - 1) * (1 + r); 
        end 
      end 
      -- /* #@range_end(compound_interest) */
      assert.are.equal(compoundInterest(100000, 0.02, 1), 102000)
      -- expect(
      --   compoundInterest(100000, 0.02, 1)
      -- ).to.eql(
      --   102000
      -- );
      assert.are.equal(compoundInterest(100000, 0.02, 2), 104040)
      -- expect(
      --   compoundInterest(100000, 0.02, 2)
      -- ).to.eql(
      --   104040  -- 10万円を預けてから2年後には10万4040円が銀行口座に入っている
      -- );
      assert.are.equal(compoundInterest(100000, 0.02, 25), 164060.59944647306111)

      -- expect(
      --   compoundInterest(100000, 0.02, 25)
      -- ).to.eql
      --   164060.59944647306
      -- );
    end)
  end)
  -- ### <section id='requirements-of-recursion'>再帰呼び出しの条件</section>
  describe('再帰呼び出しの条件', function()
    -- **リスト5.20** infiniteLoop関数
    -- /* ##@range_begin(infiniteLoop) */
    local infiniteLoop = function(_)
      return infiniteLoop(_);
    end 
    -- /* ##@range_end(infiniteLoop) */
    -- **リスト5.21** 再帰によるmap関数
    it('再帰によるmap関数', function()
      -- /* 第5章で紹介したリスト型 */
      local match = function(exp, pattern)
        return exp(pattern, pattern)
      end 
      local empty = function(_)
        return function(pattern)
          return pattern.empty(_);
        end 
      end 
      local cons = function(x, xs)
        return function(pattern)
          return pattern.cons(x, xs)
        end 
      end 
      -- /* #@range_begin(recursive_map) */
      function map(alist,transform)
        return match(alist,{
          empty = function(_) 
            return empty()  -- 終了条件で再帰を抜ける
          end, 
          cons = function(head,tail)
            return cons(transform(head),
                        map(tail,transform)) -- map関数の再帰呼び出し
          end 
        })
      end 
      local head = function(alist)
        return match(alist, {
          -- /* 空のリストに先頭要素はない */
          empty = function(_)
            return {}; 
          end,
          cons = function(head, tail) 
            return head;
          end 
        })
      end 
      -- /* tail関数は、引数alistに渡されたリストの後尾のリストを返す */
      local tail = function(alist)
        return match(alist, {
          -- /* 空のリストに後尾はない */
          empty = function(_)
            return {};  
          end,
          cons = function(head, tail)
            return tail
          end 
        })
      end 
      local log = function(array)
        for item in pairs(array) do
          print( item )
        end
      end
      -- /* #@range_end(recursive_map) */
      -- **リスト5.22** 再帰によるtoArray関数
      -- /* #@range_begin(recursive_toArray) */
      local toArray = function(alist)
        -- /* 補助関数 toArrayHelper */
        function toArrayHelper(alist,accumulator)
          return match(alist, {
            empty = function(_)
              -- print "accumulator"
              -- log(accumulator)
              return accumulator  -- 空のリストの場合は終了
            end, 
            cons =  function(head, tail)
              -- print("head= " ..head)
              -- print "accumulator"
              -- log(accumulator)

              if(#accumulator == 0) then
                return toArrayHelper(tail, {head})
              else
                accumulator[#accumulator+1] = head
                return toArrayHelper(tail, accumulator)
                -- return toArrayHelper(tail, {table.unpack(accumulator), head})
              end
              -- return toArrayHelper(tail, {head,  table.unpack(accumulator)})
            end 
          })
        end 
        return toArrayHelper(alist,{})
      end 
      -- /* #@range_end(recursive_toArray) */
      local succ = function(n)
        return n + 1;
      end 
      assert.are.same(toArray(empty()), {})
      assert.are.same(toArray(cons(1, empty())), {1})
      assert.are.same(toArray(cons(2, cons(1, empty()))), {2, 1})
      assert.are.same(toArray(cons(1, cons(2, empty()))), {1, 2})
      assert.are.same(head(cons(1,cons(2,cons(3,empty())))), 1)
      assert.are.same(toArray(tail(cons(1,cons(2,cons(3,empty()))))), {2, 3})
      assert.are.same(toArray(map(cons(1,cons(2,empty())),succ)), {2, 3})
      assert.are.same(toArray(cons(1,cons(2,cons(3,empty())))), {1, 2, 3})
      assert.are.same(toArray(map(cons(1,cons(2,cons(3,empty()))),succ)), {2,3,4})
      -- expect(
      --   toArray(map(cons(1,cons(2,cons(3,empty()))),succ))
      -- ).to.eql(
      --   {2,3,4}
      -- );
    end)
  end)
  -- ### <section id='advantages-of-recursion'>再帰処理の利点</section>
  describe('再帰処理の利点', function()
    -- #### 再帰処理と再帰的データ構造
    describe('再帰処理と再帰的データ構造', function()
      -- #### 再帰的データ構造としてのリスト
      local match = function(exp, pattern)
        return exp(pattern, pattern)
      end 
      local empty = function(_)
        return function(pattern)
          return pattern.empty(_);
        end
      end 
      local cons = function(x, xs)
        return function(pattern)
          return pattern.cons(x, xs)
        end 
      end 
      local isEmpty = function(list)
        return match(list, {
          empty = function(_)
            return true;
          end,
          cons = function(head, tail)
            return false;
          end 
        });
      end 
      local head = function(list)
        return match(list, {
          empty = function(_)
            return null;
          end,
          cons = function(head, tail)
            return head;
          end 
        });
      end 
      local tail = function(list)
        return match(list, {
          empty = function(_)
            return null;
          end,
          cons = function(head, tail)
            return tail;
          end 
        });
      end
      describe('再帰的データ構造としてのリスト', function()
        -- **リスト5.25** 再帰によるlength関数
        it('再帰によるlength関数', function()
          -- /* #@range_begin(recursive_length_without_accumulator) */
          function length(list) 
            return match(list, {
              -- /* emptyの場合は、終了条件となる */
              empty = function(_)
                return 0;
              end,
              -- /* consの場合は、length関数を再帰的に呼び出す */
              cons = function(head, tail)
                return 1 + length(tail);
              end 
            });
          end 
          -- /* #@range_end(recursive_length_without_accumulator) */
          -- /************************ テスト ************************/
          assert.are.equal(length(cons(1,cons(2,cons(3,empty())))),  3)
          -- expect(
          --   length(cons(1,cons(2,cons(3,empty())))) -- [1,2,3]の長さは 3
          -- ).to.eql(
          --   3
          -- );
        end)
        -- **リスト5.26** 再帰によるappend関数
        it('再帰によるappend関数', function()
          local toArray = function(seq,callback)
            function toArrayAux(seq,accumulator)
              return match(seq, {
                empty = function(_)
                  return accumulator;
                end,
                cons = function(head, tail)
                  accumulator[#accumulator+1] = head
                  return toArrayAux(tail, accumulator)
                  -- return toArrayAux(tail, accumulator.concat(head))
                end 
              });
            end 
            return toArrayAux(seq, {});
          end 
          -- /* append :: (LIST[T], LIST[T]) -> LIST[T] */
          -- /* #@range_begin(list_append) */
          function append(xs, ys)
            return match(xs,{
              -- /* emptyの場合は、終了条件 */
              empty = function(_)
                return ys; -- xsが空の場合は、ysを返す
              end,
              -- /* consの場合は、append関数を再帰的に呼び出す */
              cons = function(head, tail)
                -- /* xsとysを連結させる */
                return cons(head, append(tail,ys));
              end 
            });
          end 
          -- /* #@range_end(list_append) */
          
          -- /* #@range_begin(list_append_test) */
          local xs = cons(1,
                        cons(2,
                             empty()));
          local ys = cons(3,
                        cons(4,
                             empty()));
          assert.are.same(toArray(append(xs,  ys)), {1, 2, 3, 4})
          -- expect(
          --   toArray(append(xs,ys)) -- toArray関数でリストを配列に変換する
          -- ).to.eql(
          --   {1,2,3,4}
          -- );
          -- /* #@range_end(list_append_test) */
        end)
        -- **リスト5.27** 再帰によるreverse関数
        it('再帰によるreverse関数', function()
          -- /* #@range_begin(list_reverse) */
          local reverse = function(list)
            function reverseHelper(list, accumulator)
              return match(list, {
                empty = function(_)  -- emptyの場合は、終了条件
                  return accumulator;
                end,
                cons = function(head, tail) -- consの場合は、reverse関数を再帰的に呼び出す
                  return reverseHelper(tail, cons(head, accumulator));
                end
              })
            end
            return reverseHelper(list, empty());
          end 
          -- /* #@range_end(list_reverse) */
        end)
      end)
      -- #### 再帰的データ構造としての数式
      describe('再帰的データ構造としての数式', function()
        -- **リスト5.28** 代数的データ構造による数式
        -- /* #@range_begin(expression_algebraic_datatype) */
        local num = function(n)
          return function(pattern)
            return pattern.num(n)
          end 
        end 
        local add = function(exp1, exp2)
          return function(pattern)
            return pattern.add(exp1, exp2)
          end 
        end 
        local mul = function(exp1, exp2)
          return function(pattern)
            return pattern.mul(exp1, exp2);
          end 
        end 
        -- /* #@range_end(expression_algebraic_datatype) */
        -- **リスト5.30** 数式を再帰的に計算する
        -- /* #@range_begin(expression_algebraic_datatype_recursion) */
        function calculate(exp)
          return match(exp, { -- パターンマッチを実行する
            num = function(n)
              return n;
            end,
            add = function(expL, expR)
              -- /* calculateを再帰的に呼び出して足し算を実行する */
              return calculate(expL) + calculate(expR); 
            end,
            mul = function(expL, expR)
              -- /* calculateを再帰的に呼び出してかけ算を実行する */
              return calculate(expL) * calculate(expR); 
            end
          });
        end
        -- /**** テスト ****/
        -- /* 1 + (2 * 3) を計算する */
        local expression = add(num(1),
                             mul(num(2),
                                 num(3)));
        assert.are.equal(calculate(expression),  7)
        -- expect(
        --   calculate(expression)
        -- ).to.eql(
        --   7
        -- );
      -- /* #@range_end(expression_algebraic_datatype_recursion) */
      end)
    end)
  end)
  -- #### 再帰処理と帰納法
  -- [![IMAGE ALT TEXT](http:--img.youtube.com/vi/sIiHx5zfTnM/0.jpg)](https:--www.youtube.com/watch?v=sIiHx5zfTnM)
  describe('再帰処理と帰納法', function()
    local match = function(data, pattern)
      return data(pattern, pattern);
    end 
    local cons = function(head, tail)
      return function(pattern)
        return pattern.cons(head, tail);
      end 
    end 
    function length(list)
      return match(list, {
        empty = function(_)    -- リストが空のときが終了条件となる
          return 0;
        end,
        cons =  function(head, tail)
          return 1 + length(tail);
        end 
      })
    end 
    function append(xs, ys)
      return match(xs,{
        empty = function(_)
          return ys;
        end,
        cons = function(head, tail)
          return cons(head,
                      append(tail,ys))
        end 
      });
    end 
    -- ~~~
    -- 命題P  length(append(xs, ys)) === length(xs) + length(ys)
    -- ~~~
    it('リストの長さに関する命題P', function()
      local empty = function(_)
        return function(pattern)
          return pattern.empty(_)
        end;
      end;
      local cons = function(x, xs)
        return function(pattern)
          return pattern.cons(x, xs)
        end 
      end
      -- **リスト5.36** 命題Pの単体テスト
      -- > 命題Pの帰納法による証明は、本書を参照してください
      -- /* #@range_begin(statement_p_test) */
      local xs = cons(1,
                    cons(2,
                         empty()));
      local ys = cons(3,
                    cons(4,
                         empty()));
      assert.are.same(length(append(xs, ys)),  length(xs) + length(ys))
      -- expect(
      --   length(append(xs, ys))  -- 命題Pの左辺
      -- ).to.eql(
      --   length(xs) + length(ys) -- 命題Pの右辺
      -- );
      -- /* #@range_end(statement_p_test) */
    end)
  end)
end)

-- [目次に戻る](index.html) [次章に移る](chap06.spec.html) 
