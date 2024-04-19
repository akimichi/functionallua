-- 第7章 高階関数を活用する
-- =======

-- ## 小目次
-- <div class="toc">
-- <ul class="toc">
--   <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#currying">7.2 カリー化で関数を渡す</a></li>
--   <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#combinator">7.3 コンビネータで関数を組み合わせる</a>
--     <ul>
--       <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#combinator-creation">コンビネータの作り方</a></li>
--       <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#composing-function">関数を合成する</a></li></ul>
--   </li>
--   <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#closure">7.4 クロージャーを使う</a>
--      <ul>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#mechanism-of-closure">クロージャーの仕組み</a></li>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#encapsulation-with-closure">クロージャーで状態をカプセル化する</a></li>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#pure-closure">クロージャーの純粋性</a></li></ul>
--   </li>
--   <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#passing-function">7.5 関数を渡す</a>
--      <ul>
--         <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#callback">コールバックで処理をモジュール化する</a></li>
--         <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#folding">畳み込み関数に関数を渡す</a></li>
--         <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#asynchronous">非同期処理にコールバック関数を渡す</a></li>
--         <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#continuation">継続で未来を渡す</a></li></ul>
--   </li>
--   <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#monad">7.6 モナドを作る</a>
--     <ul>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#identity-monad">恒等モナド</a></li>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#maybe-monad">Maybeモナドでエラーを処理する</a></li>
--        <li><a href="http:--akimichi.github.io/functionaljs/chap07.spec.html#io-monad">IOモナドで副作用を閉じ込める</a></li></ul>
--   </li>
-- </ul>
-- </div>
package.path=package.path..';./?.lua'
List = require("./lib/list")
Stream = require("./lib/stream")

-- テストで利用されるlistモジュールとstreamモジュールを定義しておく

-- listモジュール
local list  = {
  match =  function(data, pattern)
    return data(pattern);
  end,
  empty = function(_)
    return function(pattern)
      return pattern.empty();
    end
  end,
  cons = function(value, alist)
    return function(pattern)
      return pattern.cons(value, alist);
    end
  end,
  -- head = function(alist)
  --   return list.match(alist, {
  --     empty = function(_)
  --       return nil;
  --     end, 
  --     cons = function(head, tail)
  --       return head;
  --     end 
  --   });
  -- end,
  tail = function(alist)
    return list.match(alist, {
      empty = function(_)
        return null;
      end,
      cons = function(head, tail)
        return tail;
      end 
    });
  end,  
  isEmpty = function(alist)
    return list.match(alist, {
      empty = function(_)
        return true;
      end,
      cons = function(head, tail)
        return false;
      end 
    });
  end,
  -- /* append:: LIST[T] -> LIST[T] -> LIST[T] */
  append = function(xs)
    return function(ys)
      return list.match(xs, {
        empty = function(_)
          return ys;
        end,
        cons = function(head, tail)
          return list.cons(head, list.append(tail)(ys)); 
        end 
      });
    end;
  end,
  -- /* map:: LIST[T] -> FUNC[T -> T] -> LIST[T] */
  map = function(alist)
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
  end,
  reverse = function(alist)
    local function reverseAux(alist, accumulator)
      return List.match(alist, {
        empty = function(_)
          return accumulator;  -- 空のリストの場合は終了
        end,
        cons = function(head, tail)
          return reverseAux(tail, List.cons(head, accumulator));
        end
      })
    end
    return reverseAux(alist, List.empty());
    -- return reverseAux(alist, list.empty());
  end,
  toArray = function(alist)
    local match =  function(data, pattern)
      return data(pattern)
    end
    local function toArrayAux(alist,accumulator)
      -- return list.match(alist, {
      return match(alist, {
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
  end,
  fromArray = function(array)
    return array.reduce(function(accumulator, item)
      return list.append(accumulator)(list.cons(item, list.empty()))
    end, list.empty());
  end 
};

-- streamモジュール
local stream = {
  match = function(data, pattern)
    return data(pattern);
  end,
  empty = function(_)
    return function(pattern)
      return pattern.empty();
    end;
  end,
  cons = function(head,tailThunk)
    return function(pattern)
      return pattern.cons(head,tailThunk);
    end
  end,
  -- /* head:: STREAM -> MAYBE[STREAM] */
  head = function(lazyList)
    return stream.match(lazyList,{
      empty = function(_)
        return null;
      end,
      cons = function(value, tailThunk)
        return value;
      end
    });
  end,
  -- /* tail:: STREAM -> MAYBE[STREAM] */
  tail = function(lazyList)
    return stream.match(lazyList,{
      empty = function(_)
        return nil;
      end,
      cons = function(head, tailThunk)
        return tailThunk();
      end
    });
  end,
  isEmpty = function(lazyList)
    return stream.match(lazyList,{
      empty = function(_)
        return true;
      end,
      cons = function(head,tailThunk)
        return false;
      end
    });
  end,
  -- /* take:: STREAM -> NUMBER -> STREAM */
  take = function(lazyList)
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
            end)
          end 
        end
      });
    end
  end,
  enumFrom = function(from)
    return stream.cons(from, function(_)
      return stream.enumFrom(from + 1);
    end);
  end,
  forAll = function(astream)
    return function(predicate)
      local function forAllHelper(astream)
        return stream.match(astream,{
          empty = function(_)
            return true; 
          end,
          cons = function(head,tailThunk)
            return predicate(head) and forAllHelper(tailThunk());
          end 
        });
      end
      return stream.match(astream,{
        empty = function(_)
          return false; -- 空のストリームの場合は、必ず false が返る
        end,
        cons = function(head,tailThunk)
          return forAllHelper(astream);   
        end 
      })
    end
  end
}; -- end of 'stream' module


-- ## 7.2 <section id='currying'>カリー化で関数を渡す</section>
describe('カリー化で関数を渡す', function()
  -- **リスト7.1** multipleOf関数の定義
  -- > multipleOf関数は、multipleOf(n,m)でnの倍数がmかどうかを判定する
  it('multipleOf関数の定義', function()
    -- /* #@@range_begin(multipleOf_uncurried) */
    local multipleOf = function(n,m)
      if(m % n == 0) then -- /* m / n の余りが 0 かどうか */
        return true;
      else
        return false;
      end 
    end;
    -- /* #@@range_end(multipleOf_uncurried) */
    -- **リスト7.2** multipleOf関数のテスト
    -- /* #@@range_begin(multipleOf_uncurried_test) */
    assert.are.equal(multipleOf(2,4), true)
    -- expect(
    --   multipleOf(2,4)     -- /* 4は、2の倍数である */
    -- ).to.eql(
    --   true
    -- );
    -- /* #@@range_end(multipleOf_uncurried_test) */
    assert.are.equal(multipleOf(3,4), false)
    -- expect(
    --   multipleOf(3,4)     -- /* 4は、3の倍数ではない */
    -- ).to.eql(
    --   false
    -- );
  end);
  -- **リスト7.3** カリー化されたmultipleOf関数の定義
  it('カリー化されたmultipleOf関数', function()
    -- /* #@@range_begin(multipleOf_curried) */
    local multipleOf = function(n) -- 外側の関数定義
      return function(m)          -- 内側の関数定義
        if(m % n == 0) then
          return true;
        else
          return false;
        end 
      end 
    end 
    -- /* #@@range_end(multipleOf_curried) */
    -- **リスト7.4** カリー化されたmultipleOf関数のテスト
    -- /* #@@range_begin(multipleOf_curried_test) */
    assert.are.equal(multipleOf(2)(4), true)
    -- expect(
    --   multipleOf(2)(4)   -- /* 関数適用を2回実行する */ 
    -- ).to.eql(
    --   true
    -- );
    -- /* #@@range_end(multipleOf_curried_test) */
    assert.are.equal(multipleOf(3)(4), false)
    -- expect(
    --   multipleOf(3)(4)    -- /* 4は、3の倍数ではない */
    -- ).to.eql(
    --   false
    -- );
    -- **リスト7.5** multipleOf関数のテスト
    -- /* #@@range_begin(multipleOf_curried_partilly_applied) */
    local twoFold = multipleOf(2);
    assert.are.equal(twoFold(4), true)
    -- expect(
    --   twoFold(4)    -- /* 4は、2の倍数である */
    -- ).to.eql(
    --   true
    -- );
    -- /* #@@range_end(multipleOf_curried_partilly_applied) */
  end);
  it('カリー化された指数関数', function()
    -- **リスト7.6** 指数関数の例
    -- > exponential関数は、exponential(b)(n)でbのn乗を計算する
    -- /* #@@range_begin(exponential_curried) */
    local function exponential(base)
      return function(index)
        if(index == 0) then
          return 1;
        else
          return base * exponential(base)(index - 1);
        end 
      end 
    end
    -- /****** テスト ******/
    assert.are.equal(exponential(2)(3), 8)
    -- expect(
    --   exponential(2)(3) -- 2の3乗を求める 
    -- ).to.eql(
    --   8
    -- );
    -- /* #@@range_end(exponential_curried) */
    assert.are.equal(exponential(2)(2), 4)
    -- expect(
    --   exponential(2)(2)
    -- ).to.eql(
    --   4
    -- );
    -- **リスト7.7** flip関数の定義
    -- > flip関数は、flip(fun)(x)(y)でfun(y)(x)を実行する
    -- /* #@@range_begin(flip_definition) */
    local flip = function(fun)
      return function(x)
        return function(y)
          return fun(y)(x); -- 適用する引数の順番を逆転させる
        end 
      end 
    end 
    -- /* #@@range_end(flip_definition) */

    -- **リスト7.8** flip関数でexponential関数の引数の順番を変更する
    -- /* #@@range_begin(flipped_exponential) */
    -- /* flipで引数を逆転させて、2乗を定義する */
    local square = flip(exponential)(2); 
    -- /* flipで引数を逆転させて、3乗を定義する */
    local cube = flip(exponential)(3);   
    -- /* #@@range_end(flipped_exponential) */
    -- /* #@@range_begin(flipped_exponential_test) */
    assert.are.equal(square(2), 4)
    -- expect(
    --   square(2)
    -- ).to.eql(
    --   4 -- /* 2 * 2 = 4 */
    -- );
    assert.are.equal(cube(2), 8)
    -- expect(
    --   cube(2)
    -- ).to.eql(
    --   8 -- /* 2 * 2 * 2 = 8 */
    -- );
    -- /* #@@range_end(flipped_exponential_test) */
  end);
  -- ### コラム： チャーチ数
  describe('コラム： チャーチ数', function()
    -- **リスト7.9** チャーチによる自然数の定義
    it('チャーチによる自然数の定義', function()
      -- /* #@@range_begin(church_numeral) */
      local zero = function(f)
        return function(x)
          return x;           -- 関数を0回適用する
        end 
      end 
      local one = function(f)
        return function(x)
          return f(x);        -- 関数を1回適用する
        end 
      end 
      local two = function(f)
        return function(x)
          return f(f(x));     -- 関数を2回適用する
        end 
      end 
      local three = function(f)
        return function(x)
          return f(f(f(x)));  -- 関数を3回適用する
        end 
      end 
      -- /*#@@range_end(church_numeral) */
      local add = function(m)
        return function(n)
          return function(f)
            return function(x)
              return m(f)(n(f)(x));
            end 
          end 
        end 
      end 
      local succ = function(n)
        return function(f)
          return function(x)
            return f(n(f)(x));
          end 
        end 
      end
      local counter = function(init)
        local _init = init;
        return function(_)
          _init = _init + 1;
          return _init;
        end 
      end 

      assert.are.equal(one(counter(0))(), 1)
      assert.are.equal(two(counter(0))(), 2)
      assert.are.equal(three(counter(0))(), 3)
      assert.are.equal(succ(one)(counter(0))(), 2)
      assert.are.equal(succ(two)(counter(0))(), 3)
      assert.are.equal(add(zero)(one)(counter(0))(), 1)
      assert.are.equal(add(one)(one)(counter(0))(), 2)
      assert.are.equal(add(one)(two)(counter(0))(), 3)
      assert.are.equal(add(two)(three)(counter(0))(), 5)
    end)
  end)
end)

-- ## 7.3 <section id='combinator'>コンビネータで関数を組み合わせる</section>
describe('コンビネータで関数を組み合わせる', function()
  -- ### <section id='combinator-creation'>コンビネータの作り方</section>
  describe('コンビネータの作り方', function()
    -- **リスト7.10** multipleOf関数の再利用
    it('multipleOf関数の再利用', function()
      local multipleOf = function(n)
        return function(m)
          if(m % n == 0) then
            return true;
          else
            return false;
          end 
        end 
      end
      -- /* #@@range_begin(multipleOf_combinator) */
      local even = multipleOf(2); -- /* カリー化されたmultipleOf関数を使う */
      
      assert.are.equal(even(2), true)
      -- /* #@@range_end(multipleOf_combinator) */
    end); 
    describe('論理コンビネータ', function()
      local multipleOf = function(n)
        return function(m)
          if(m % n == 0) then
            return true;
          else
            return false;
          end 
        end 
      end 
      local even = multipleOf(2);
      -- **リスト7.13** notコンビネータ
      it('negateコンビネータ', function()
        -- /* #@@range_begin(not_combinator) */
        -- /* negate:: FUN[NUM => BOOL] => FUN[NUM => BOOL] */
        local negate = function(predicate) -- predicateの型はFUN[NUM => BOOL]
          -- /* 全体として、FUN[NUM => BOOL]型を返す */
          return function(arg) -- argの型はNUM
            return not predicate(arg); -- !演算子で論理を反転させて、BOOLを返す
          end 
        end 
        -- /* #@@range_end(not_combinator) */
        -- **リスト7.15** notコンビネータによるodd関数の定義
        -- /* #@@range_begin(not_combinator_test) */
        local odd = negate(even); -- notコンビネータでodd関数を定義する
        -- /******** テスト ********/
        assert.are.equal(odd(3), true)
        assert.are.equal(odd(2), false)
        --/* #@@range_end(not_combinator_test) */
      end);
      -- /* 本書では割愛したが、論理和や論理積を実行するコンビネータも同様に定義できる */
      it('他の論理コンビネータ', function()
        local negate = function(predicate)
          return function(arg)
            return not predicate(arg); 
          end 
        end 
        -- /* 「もしくは」を表す論理和  */
        -- /* alternative:: (NUMBER->BOOL, NUMBER->BOOL) -> (NUMBER->BOOL) */
        local alternative = function(f,g)
          return function(arg)
            return f(arg) or g(arg);
          end 
        end 
        -- /* 「かつ」を表す論理積  */
        -- /* disjunction:: (NUMBER->BOOL, NUMBER->BOOL) -> (NUMBER->BOOL) */
        local disjunction = function(f,g)
          return function(arg)
            return f(arg) and g(arg);
          end 
        end 
        local positive = function(n)
          return n > 0;
        end 
        local zero = function(n)
          return n == 0;
        end
        -- /* negativeは、0より小さな数値かどうかを判定する */
        local negative = disjunction(negate(positive), negate(zero));
        assert.are.equal(negative(-3), true)
        -- expect(negative(-3)).to.eql(true);
        assert.are.equal(negative(3), false)
        -- expect(negative(3)).to.eql(false);
        assert.are.equal(negative(0), false)
        -- expect(negative(0)).to.eql(false);
      end);
    end);
  end);
  -- ### <section id='composing-function'>関数を合成する</section>
  -- $$ 
  --    (f \circ g) x = f(g(x))
  -- $$
  describe('関数を合成する', function()
    -- **リスト7.16** 関数合成の定義
    -- /* #@@range_begin(compose_definition) */
    local compose = function(f,g)
      return function(arg)
        return f(g(arg))
      end 
    end
    -- /* #@@range_end(compose_definition) */
    -- **リスト7.17** 関数合成のテスト
    -- /* #@@range_begin(compose_test) */
    local f = function(x)
      return x * x + 1; 
    end 
    local g = function(x)
      return x - 2;
    end 
    assert.are.equal(compose(f,g)(2) , f(g(2)))
    -- /* #@@range_end(compose_test) */
    -- #### 関数合成の条件
    describe('関数合成の条件', function()
      -- **リスト7.18** 反数関数の合成
      it('反数関数の合成', function()
        -- /* #@@range_begin(composition_example_opposite_twice) */
        -- /* 反数の定義 */
        local opposite = function(n)
          return - n;
        end 
        assert.are.equal(compose(opposite,opposite)(2) , 2)
        -- /* #@@range_end(composition_example_opposite_twice) */
      end);
      -- **リスト7.20** カリー化による合成
      it('カリー化による合成', function()
        -- /* #@@range_begin(compose_opposite_add_successful) */
        local opposite = function(x)
          return - x;
        end 
        local addCurried = function(x) -- カリー化されたadd関数
          return function(y)
            return x + y;
          end
        end 
        assert.are.equal(compose(opposite, addCurried(2))(3) , -5)
        -- /* #@@range_end(compose_opposite_add_successful) */
      end)
    end);
    local flip = function(fun)
      return function(f)
        return function(g)
          return fun(g)(f);
        end 
      end 
    end
    -- #### 関数合成による抽象化
    describe('関数合成による抽象化', function()
      -- **リスト7.21** 具体的なlast関数
      it('具体的なlast関数', function()
        -- /* #@@range_begin(list_last_recursive) */
        local function last(alist)
          return List.match(alist, {
            empty = function(_) -- alistが空の場合
              return nil
            end,   
            cons = function(head, tail) -- alistが空でない場合
              return List.match(tail, {
                empty = function(_)  -- alistの要素がただ1個の場合
                  return head;
                end,
                cons = function(_, __)
                  return last(tail);
                end
              });
            end 
          });
        end 
        -- /* #@@range_end(list_last_recursive) */
        local aList = list.cons(1,
                                list.cons(2,
                                          list.cons(3,
                                                    list.empty())));
        assert.are.equal(last(aList), 3)
      end);
      it('reverse関数', function()
        local sequence = list.cons(1,list.cons(2,list.empty()))
        assert.are.same(list.toArray(list.reverse(sequence)), {2, 1})
      end)
      -- ** リスト7.22** 抽象的なlast関数
      it('抽象的なlast関数', function()
        -- /* #@@range_begin(list_last_compose) */
        local last = function(alist)
          return compose(List.head,
                         List.reverse)(alist);
        end
        -- /* #@@range_end(list_last_compose) */
        local sequence = List.cons(1, 
                          List.cons(2,
                            List.cons(3,
                              List.cons(4,
                                List.empty()))));
        assert.are.equal(last(sequence), 4)
      end);
      -- **表7.1** 関数合成による様々な関数定義
      -- 
      -- |関数名	     |関数合成による定義	               |
      -- |:--------------|------------------------------:|
      -- |length         |sum . map(alwaysOne)             |
      -- |last           |head . reverse                   |
      -- |init           |reverse . tail . reverse            |
      -- |all(predicate) |and . map(predicate)          |
      -- |any(predicate) |or . map(predicate)           |
      -- |none(predicate)|and . map(not(predicate))     |
      describe('関数合成による様々な関数定義', function()
        local alwaysOne = function(x)
          return 1;
        end 
        local alist = List.cons(1,
                              List.cons(2,
                                        List.cons(3,
                                                  List.empty())));
        -- length関数の定義
        it('length関数の定義', function()
          local alwaysOne = function(x)
            return 1;
          end 
          local sum = function(alist)
            local function sumHelper(alist, accumulator)
              return List.match(alist,{
                empty = function(_)
                  return accumulator;
                end,
                cons =  function(head, tail)
                  return sumHelper(tail, accumulator + head);
                end 
              });
            end 
            return sumHelper(alist,0);
          end 
          local length = function(alist)
            return compose(sum,
                           flip(List.map)(alwaysOne))(alist);
          end 
          -- /****** テスト *******/
          assert.are.equal(length(alist), 3)
        end);
        -- last関数の定義
        it('last関数の定義', function()
          local last = function(alist)
            return compose(List.head,
                           List.reverse)(alist);
          end 
          assert.are.equal(last(alist), 3)
        end);
        -- init関数の定義
        it('init関数の義', function()
          -- /* init = reverse . tail . reverse  */
          local init = function(alist)
            return compose(List.reverse,
                           compose(List.tail,
                                   List.reverse)
                          )(alist);
          end 
          -- /****** テスト *******/
          assert.are.same(List.toArray(init(alist)), {1, 2})
        end);
        -- all関数の定義
        it('all関数の定義', function()
          local function disjunction(alist)
            return List.match(alist, {
              empty = function(_)
                return true;
              end, 
              cons = function(head, tail)
                return head and disjunction(tail);
              end 
            });
          end 
          local all = function(predicate)
            return function(alist)
              return compose(disjunction,
                             flip(List.map)(predicate))(alist);
            end 
          end 
          assert.are.equal(
            all(function(x)
              return x > 0;
            end)(alist)
          , true)
        end)
        -- any関数の定義
        it('any関数の定義', function()
          local function alternate(alist)
            return List.match(alist, {
              empty = function(_)
                return false;
              end,
              cons = function(head, tail)
                return head or alternate(tail);
              end
            });
          end
          local any = function(predicate)
            return function(alist)
              return compose(alternate,
                             flip(List.map)(predicate))(alist);
            end 
          end 
          assert.are.equal(
            any(function(x)
              return x < 2;
            end)(alist)
          , true)
          assert.are.equal(
            any(function(x)
              return x < 1;
            end)(alist)
          , false)
        end);
        -- none関数の定義
        it('none関数の定義', function()
          local function disjunction(alist)
            return List.match(alist, {
              empty = function(_)
                return true;
              end,
              cons = function(head, tail)
                return head and disjunction(tail);
              end
            });
          end 
          local function negate(predicate)  -- predicate::FUN[NUM => BOOL]
            return function(arg) -- FUN[NUM => BOOL]型を返す
              return not predicate(arg); -- !演算子で論理を反転させる
            end
          end 
          local none = function(predicate)
            return function(alist)
              return compose(disjunction,
                             flip(List.map)(negate(predicate)))(alist);
            end;
          end
          assert.are.equal(
            none(function(x)
              return x < 0;
            end)(alist)
          , true)
        end);
      end)
    end);
    -- ### コラム: Yコンビネータ
    -- [![IMAGE ALT TEXT](http:--img.youtube.com/vi/FITJMJjASUs/0.jpg)](https:--www.youtube.com/watch?v=FITJMJjASUs "Ruby Conf 12 - Y Not- Adventures in Functional Programming by Jim Weirich")
    it('Y combinator', function()
      -- /* #@@range_begin(Y_combinator) */
      local Y = function(F)
        return (function(x)
          return F(function(y)
            return x(x)(y);
          end)
        end)(function(x)
          return F(function(y)
            return x(x)(y);
          end)
        end)
      end
      -- /* #@@range_end(Y_combinator)  */
      -- **リスト7.24** Yコンビネータによるfactorial関数の実装
      -- /* #@@range_begin(Y_combinator_test) */
      local factorial = Y(function(fact)
        return function(n)
          if (n == 0) then
            return 1;
          else
            return n * fact(n - 1);
          end 
        end;
      end);
      assert.are.equal(
        factorial(3) -- 3 * 2 * 1 = 6
      , 6)
      -- /* #@@range_end(Y_combinator_test) */
    end);
  end); -- 関数を合成する
  describe('コンビネータパーサーの作り方', function()
        pending("I should finish this test later")

--     -- -- パーサーコンビネーターの定義
--     local parser = {}
--     -- パーサーの定義
--     function parser.number()
--       return function(input)
--         local num = tonumber(input:match("^%d+"))
--         if num then
--           return num, input:sub(#tostring(num) + 1)
--         else
--           return nil, input
--         end
--       end
--     end
--
--     function parser.char(expectedChar)
--       return function(input)
--         if input:sub(1, 1) == expectedChar then
--           return expectedChar, input:sub(2)
--         else
--           return nil, input
--         end
--       end
--     end
--
--     function parser.term()
--       return parser.number() + parser.char("(") * parser.expr() * parser.char(")")
--     end
--
--     function parser.factor()
--       return parser.term() + parser.char("-") * parser.factor() / function(n) return -n end
--     end
--
--     function parser.expr()
--       return parser.factor() * (parser.char("+") * parser.expr() + parser.char("-") * parser.expr()) ^ -1
--     end
-- --
--     -- パースを行う関数
--     function parse(input)
--       local result, remaining = parser.expr()(input)
--       if remaining == "" then
--         return result
--       else
--         return nil, "Failed to parse"
--       end
--     end
--
--     -- テスト
--     assert.are.equal(
--         parse("2 + 3 * (4 - 1)")
--     , 0)
--
--
  end) 

end); -- コンビネータ


-- ## <section id='closure'>7.4 クロージャーを使う</section>
-- > 参考資料: [Wikipediaでのクロージャーの解説](https:--ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AD%E3%83%BC%E3%82%B8%E3%83%A3)
describe('クロージャーを使う', function()
  local compose = function(f,g)
    return function(arg)
      return f(g(arg));
    end 
  end
  -- ### <section id='mechanism-of-closure'>クロージャーの仕組み</section>
  describe('クロージャーの仕組み', function()
    -- **リスト7.25** 環境における変数のバインディング
    it('環境における変数のバインディング', function()
      -- /* #@@range_begin(variable_binding_in_environment) */
      -- /* 変数fooに数値1をバインドする */
      local foo = 1;
      -- /* 変数bar に文字列 "a string" をバインドする */
      local bar = "a string"; 
      -- /* #@@range_end(variable_binding_in_environment) */

      -- **リスト7.26** 環境からバインディングを参照する
      -- /* #@@range_begin(variable_binding_in_environment_test) */
      -- /* 環境 <foo |-> 1, bar |-> "a string"> のもとで評価する */
      assert.are.equal(
       foo  -- 上記環境から変数fooの値を取り出す 
      , 1)
      -- /* #@@range_end(variable_binding_in_environment_test) */
    end);
    -- **リスト7.27** 部分適用と環境
    it('部分適用と環境', function()
      local multipleOf = function(n) -- 外側の関数定義
        return function(m)          -- 内側の関数定義
          if(m % n == 0) then 
            return true;
          else
            return false;
          end
        end
      end
      -- /* #@@range_begin(partial_application_with_environment) */
      local twoFold = multipleOf(2);
      assert.are.equal(
        twoFold(4)  
      , true)
      -- /* #@@range_end(partial_application_with_environment) */
    end);
    -- ### <section id='encapsulation-with-closure'>クロージャーで状態をカプセル化する</section>
    describe('クロージャーで状態をカプセル化する', function()
      -- **リスト7.28** クロージャーとしてのcounter関数
      it('クロージャーとしてのcounter関数', function()
        -- /* #@@range_begin(counter_as_closure) */
        local counter = function(init)
          local countingNumber =  init;
          -- /* countingNumberの環境を持つクロージャーを返す */
          return function(_)
            countingNumber = countingNumber + 1;
            return countingNumber ;
          end 
        end 
        -- /* #@@range_end(counter_as_closure) */
        -- **リスト7.29** counter関数の利用法
        -- /* #@@range_begin(counter_as_closure_test) */
        local counterFromZero = counter(0);
        assert.are.equal(
         counterFromZero() -- 1回目の実行 
        , 1)
        assert.are.equal(
         counterFromZero() -- 1回目の実行 
        , 2)
        -- /* #@@range_end(counter_as_closure_test) */
      end);
      -- #### クロージャーで不変なデータ型を作る
      describe('クロージャーで不変なデータ型を作る', function()
        -- **リスト7.31** カリー化された不変なオブジェクト型
        it('カリー化された不変なオブジェクト型', function()
          -- /* #@@range_begin(immutable_object_type_curried) */
          local object = {} -- objectモジュール
          -- /* empty:: STRING => Any */
          object.empty = function(key)
              return nil;
          end
          -- /* set:: (STRING,Any) => (STRING => Any) => STRING => Any */
          object.set = function(key, value)
            return function(obj)
              return function(queryKey)
                if(key == queryKey) then
                  return value;
                else
                  return object.get(queryKey)(obj);
                end 
              end
            end 
          end
          object.get = function(key)
            return function(obj)
              return obj(key);
            end 
          end 
          -- /* #@@range_end(immutable_object_type_curried) */
          -- **リスト7.32** カリー化された不変なオブジェクト型のテスト
          -- /* #@@range_begin(immutable_object_type_curried_test) */
          local robots = compose( -- object.setを合成する
            object.set("C3PO", "Star Wars"), -- (STRING => Any) => STRING => Any
            object.set("HAL9000","2001: a space odessay") -- (STRING => Any) => STRING => Any
          )(object.empty);
          -- /* )(object.empty()); これは適切でない */

          assert.are.equal(
           object.get("HAL9000")(robots)
          , "2001: a space odessay")
          assert.are.equal(
           object.get("C3PO")(robots)
          , "Star Wars")
          -- 該当するデータがなければ、nullが返る
          assert.are.equal(
           object.get("鉄腕アトム")(robots)
          , nil)
          -- /* #@@range_end(immutable_object_type_curried_test) */
        end);
      end);
      -- #### クロージャーでジェネレーターを作る
      describe('クロージャーでジェネレーターを作る', function()
        -- **リスト7.33** ストリームからジェネレータを作る
        describe('ストリームからジェネレータを作る', function()
          -- /* #@@range_begin(generator_from_stream) */
          local generate = function(aStream)
            -- /* いったんローカル変数にストリームを格納する */
            local _stream = aStream; 
            -- /* ジェネレータ関数が返る */
            return function(_)
              return Stream.match(_stream, {
                empty = function()
                  return nil;
                end,
                cons = function(head, tailThunk)
                  _stream = tailThunk();  -- ローカル変数を更新する
                  return head;  -- ストリームの先頭要素を返す
                end 
              });
            end 
          end
          -- /* #@@range_end(generator_from_stream) */
          -- **リスト7.34** 整数列のジェネレータ
          it('整数列のジェネレータ', function()
            local function enumFrom(from)
              return Stream.cons(from, function(_)
                return enumFrom(from + 1);
              end);
            end
            -- /* #@@range_begin(integer_generator) */
            -- /* 無限の整数列を生成する */
            local integers = enumFrom(0);            
            -- /* 無限ストリームからジェネレータを生成する */
            local intGenerator = generate(integers); 
            assert.are.equal(intGenerator(), 0)
            assert.are.equal(intGenerator(), 1)
            assert.are.equal(intGenerator(), 2)
            -- /* #@@range_end(integer_generator) */
          end);
          it('無限の素数列を作る', function()

            local negate = function(predicate)
              return function(arg)
                return not predicate(arg);
              end 
            end 

            local stream = {
              match = function(data, pattern)
                return data(pattern);
              end,
              empty = function(_)
                return function(pattern)
                  return pattern.empty();
                end 
              end,
              cons = function(head,tailThunk)
                return function(pattern)
                  return pattern.cons(head,tailThunk);
                end;
              end,
              head = function(lazyList)
                return stream.match(lazyList,{
                  empty = function(_)
                    return nil;
                  end,
                  cons = function(value, tailThunk)
                    return value;
                  end 
                });
              end,  
              tail = function(lazyList)
                return stream.match(lazyList,{
                  empty = function(_)
                    return null;
                  end,
                  cons = function(head, tailThunk)
                    return tailThunk();
                  end 
                });
              end,
              toArray = function(lazyList)
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
              end,
              take = function(lazyList)
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
              end,
              -- **リスト7.35** ストリームのfilter関数
              -- /* #@@range_begin(stream_filter) */
              -- /* filter:: FUN[T => BOOL] => STREAM[T] => STREAM[T] */
              filter = function(predicate)
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
              end,
              -- /* #@@range_end(stream_filter) */
              -- **リスト7.36** ストリームのremove関数
              -- /* #@@range_begin(stream_remove) */
              -- /* remove:: FUN[T => BOOL] => STREAM[T] => STREAM[T] */
              remove = function(predicate)
                return function(aStream)
                  return stream.filter(negate(predicate))(aStream);
                end
              end,
              -- /* #@@range_end(stream_remove) */
              enumFrom = function(from)
                return stream.cons(from, function(_)
                  return stream.enumFrom(from + 1);
                end);
              end,
              -- /* #@@range_begin(stream_generate) */
              generate = function(astream)
                local theStream = astream;
                return function(_)
                  return Stream.match(theStream,{
                    empty = function(_)
                      return nil; 
                    end,
                    cons = function(head,tailThunk)
                      theStream = tailThunk();
                      return head;
                    end 
                  });
                end 
              end
              -- /* #@@range_end(stream_generate) */
            }; -- end of 'stream' module

            local multipleOf = function(n)
              return function(m)
                if(n % m == 0) then
                  return true;
                else
                  return false;
                end 
              end
            end
            -- **リスト7.37** 素数列の生成 
            -- [![IMAGE ALT TEXT](http:--img.youtube.com/vi/1NzrrU8BawA/0.jpg)](http:--www.youtube.com/watch?v=1NzrrU8BawA "エラトステネスのふるいの動画")
            -- /* #@@range_begin(eratosthenes_sieve) */
            -- /* エラトステネスのふるい */
            local function sieve(aStream)
              return Stream.match(aStream, {
                empty = function()
                  return nil;
                end, 
                cons = function(head, tailThunk)
                  return Stream.cons(head, function(_)
                    return sieve(Stream.remove( -- 後尾を素数の倍数でふるいにかける
                      function(item)
                        return multipleOf(item)(head);  
                      end 
                    )(tailThunk()));
                  end); 
                end 
              });
            end 
            local primes = sieve(Stream.enumFrom(2)); -- 無限の素数列
            -- /* #@@range_end(eratosthenes_sieve) */
            -- /* #@@range_begin(eratosthenes_sieve_test) */
            assert.are.same(
              Stream.toArray(Stream.take(primes)(10)) 
            , { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29 })
            -- /* #@@range_end(eratosthenes_sieve_test) */

            -- **リスト7.39** 素数のジェネレータ
            -- /* #@@range_begin(prime_generator) */
            local primes = sieve(Stream.enumFrom(2)); -- 無限の素数列
            local primeGenerator = generate(primes);  -- 素数のジェネレータ
            -- /******* テスト ********/
            assert.are.equal(
              primeGenerator()
            , 2)
            assert.are.equal(
              primeGenerator()
            , 3)
            assert.are.equal(
              primeGenerator()
            , 5)
            -- /* #@@range_end(prime_generator) */
          end);
        end);
        -- #### コラム：ECMAScript2015（ES6）におけるジェネレータ
        -- > 参考資料: https:--developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Generator 
        -- it('ECMAScript2015（ES6）におけるジェネレータ', function()
        --   -- **リスト7.40** ECMAScript2015のジェネレータ
        --   -- /* #@@range_begin(es6_generator) */
        --   -- function* genCounter(){
        --   --   yield 1;
        --   --   yield 2;
        --   --   return 3;
        --   -- };
        --   -- local counter = genCounter();
        --   -- expect(
        --   --   counter.next().value
        --   -- ).to.eql(
        --   --   1
        --   -- );
        --   -- expect(
        --   --   counter.next().value
        --   -- ).to.eql(
        --   --   2
        --   -- );
        --   -- /* #@@range_end(es6_generator) */
        -- end);
      end);
    end); -- クロージャーで状態をカプセル化する
  end)
  -- ### <section id='pure-closure'>クロージャーの純粋性 </section>
  describe('クロージャーの純粋性', function()
    -- **リスト 7.41** multipleOf関数の参照透過性
    it('multipleOf関数の参照透過性', function()
      local multipleOf = function(n)
        return function(m)
          if(m % n == 0) then
            return true;
          else
            return false;
          end 
        end;
      end
      -- /* #@@range_begin(multipleOf_is_transparent) */
      assert.are.equal(
        multipleOf(2)(4) 
      , 
        true
      )
      assert.are.equal(
        multipleOf(3)(5) 
      , 
        false
      )
      -- /* #@@range_end(multipleOf_is_transparent) */
    end);
    -- **リスト7.42** 参照透過性のないクロージャーの例
    it('参照透過性のないクロージャーの例', function()
      local counter = function(init)
        local _init = init;
        return function(_)
          _init = _init + 1;
          return _init;
        end 
      end 
      -- /* #@@range_begin(counter_is_not_transparent) */
      local counterFromZero = counter(0);
      -- expect(
      --   counterFromZero()
      -- ).not.to.eql( -- notで一致しないことをテストしている
      --   counterFromZero()
      -- );
      -- /* #@@range_end(counter_is_not_transparent) */
    end);
    -- **リスト7.44** カウンターをクロージャーで定義する
    it('カウンターをクロージャーで定義する', function()
      -- /* チャーチ数 church numeral */
      local zero = function(f)
        return function(x)
          return x;
        end 
      end 
      -- **リスト7.45** チャーチ数のone関数
      -- /* #@@range_begin(church_one) */
      local one = function(f)
        return function(x)
          return f(x); -- f関数を1回適用する
        end 
      end 
      -- /* #@@range_end(church_one) */
      local two = function(f)
        return function(x)
          return f(f(x));
        end 
      end 
      local three = function(f)
        return function(x)
          return f(f(f(x)));
        end
      end
      local succ = function(n)
        return function(f)
          return function(x)
            return f(n(f)(x));
          end
        end 
      end 
      local add = function(m)
        return function(n)
          return function(f)
            return function(x)
              return m(f)(n(f)(x));
            end;
          end;
        end;
      end
      -- /* 関数適用の回数を数えるcounterクロージャー */
      local counter = function(init)
        local _init = init; -- 可変な変数
        return function(_)
          _init = _init + 1; -- 代入で変数_initを更新する
          return _init;
        end 
      end
      -- /***** counterクロージャーを用いたチャーチ数のテスト *****/
      -- /* #@@range_begin(church_numeral_counter) */
      assert.are.equal(
        one(counter(0))() -- oneはチャーチ数（@<list>{church_numeral}）の1 
      , 
        1)
      assert.are.equal(
        two(counter(0))() -- twoはチャーチ数（@<list>{church_numeral}）の2
      , 
        2)
      -- /* #@@range_end(church_numeral_counter) */
      assert.are.equal(
        add(one)(two)(counter(0))()
      , 
        3)
    end);
  end);
end);

-- ## 7.5 <section id='passing-function'>関数を渡す</section>
describe('関数を渡す', function()
  local compose = function(f,g)
    return function(arg)
      return f(g(arg));
    end 
  end
  -- ### <section id='callback'>コールバックで処理をモジュール化する</section>
  describe('コールバックで処理をモジュール化する', function()
    -- **リスト7.47** 直接的な呼び出しの例
    it('直接的な呼び出しの例', function()
      -- /* #@@range_begin(direct_call) */
      local succ = function(n)
        return n + 1;
      end 
      local doCall = function(arg)
        return succ(arg);  -- succ関数を直接呼び出す
      end 
      assert.are.equal(
       doCall(2) 
      , 3)
      -- /* #@@range_end(direct_call) */
    end);
    -- **リスト7.48** 単純なコールバックの例
    it('単純なコールバックの例', function()
      local succ = function(n)
        return n + 1;
      end 
      -- /* #@@range_begin(call_callback) */
      local setupCallback = function(callback)
        -- /* コールバック関数を実行する無名関数を返す */
        return function(arg)
          return callback(arg);
        end 
      end 
      -- /* コールバック関数を設定する */
      local doCallback = setupCallback(succ);  
      assert.are.equal(
        doCallback(2) -- 設定されたコールバック関数を実行する 
      , 3)
      -- /* #@@range_end(call_callback) */
    end);
    it('リストのmap関数', function()
      -- **リスト7.49** リストのmap関数の定義
      -- /* #@@range_begin(list_map) */
      -- /* map:: FUN[T => T] => LIST[T] =>  LIST[T] */
      local function map(callback)
        return function(alist)
          return List.match(alist,{
            empty = function(_)
              return List.empty();
            end,
            cons = function(head, tail)
              -- /* コールバック関数を実行する */
              return List.cons(callback(head),  
                               map(callback)(tail)); -- 再帰呼び出し
            end 
          });
        end 
      end 
      -- /* #@@range_end(list_map) */

      -- **リスト7.50** map関数のテスト
      -- /* #@@range_begin(list_map_test) */
      -- /* map処理の対象となる数値のリスト */
      local numbers = List.cons(1,
                              List.cons(2,
                                        List.cons(3,
                                                  List.empty())));
      -- /* 要素を2倍するmap処理 */
      local mapDouble = map(function(n)
        return n * 2;
      end);
      assert.are.same(
        compose(List.toArray,mapDouble)(numbers)
      , {2,4,6})
      -- /* 要素を2乗するmap処理 */
      local mapSquare = map(function(n)
        return n * n;
      end);
      assert.are.same(
        compose(List.toArray,mapSquare)(numbers) 
      , {1,4,9})
      -- /* #@@range_end(list_map_test) */
    end);
  end);
  -- ### <section id='folding'>畳み込み関数に関数を渡す</section>
  describe('畳み込み関数に関数を渡す', function()
    describe('コールバックによるリストの再帰関数', function()
      -- **リスト7.51** sum関数の定義
      it('sum関数の定義', function()
          -- /* #@@range_begin(list_sum) */
          local function sum(alist)
            return function(accumulator)
              return List.match(alist,{
                empty = function(_)
                  return accumulator;
                end,
                cons = function(head, tail)
                  return sum(tail)(accumulator + head);
                end 
              });
            end 
          end
          -- /* #@@range_end(list_sum) */
          -- **リスト7.52** コールバック関数を用いたsum関数の再定義
          -- /* #@@range_begin(list_sum_callback) */
          local function sumWithCallback(alist)
            return function(accumulator)
              return function(CALLBACK)  -- コールバック関数を受け取る
                return List.match(alist,{
                  empty = function(_)
                    return accumulator;
                  end,
                  cons = function(head, tail)
                    return CALLBACK(head)( -- コールバック関数を呼び出す
                      sumWithCallback(tail)(accumulator)(CALLBACK)
                    );
                  end 
                });
              end
            end
          end
          -- /* #@@range_end(list_sum_callback) */

        -- **リスト7.53** sumWithCallback関数のテスト
        -- /* #@@range_begin(list_sum_callback_test) */
        local numbers = List.cons(1, 
                                List.cons(2,
                                          List.cons(3,
                                                    List.empty())));
        -- /* sumWithCallback関数に渡すコールバック関数 */
        local callback = function(n)
          return function(m)
            return n + m;
          end 
        end 
        assert.are.equal(
          sumWithCallback(numbers)(0)(callback)
        , 6)
        -- /* #@@range_end(list_sum_callback_test) */
        assert.are.equal(
          sum(numbers)(0)
        , 6)
      end);
      -- **リスト7.54** length関数の定義
      it('length関数の定義', function()
          -- /* #@@range_begin(list_length) */
          local function length(alist)
            return function(accumulator)
              return List.match(alist,{
                empty = function(_)
                  return accumulator;
                end, 
                cons = function(head, tail)
                  return length(tail)(accumulator + 1);
                end
              });
            end
          end
          -- /* #@@range_end(list_length) */
          -- **リスト7.55** length関数の再定義
          -- /* #@@range_begin(list_length_callback) */
          local function lengthWithCallback(alist)
            return function(accumulator)
              return function(CALLBACK)  -- コールバック関数を受け取る
                return List.match(alist,{
                  empty = function(_)
                    return accumulator;
                  end,
                  cons = function(head, tail)
                    return CALLBACK(head)(
                      lengthWithCallback(tail)(accumulator)(CALLBACK)
                    );
                  end 
                });
              end
            end;
          end
          -- /* #@@range_end(list_length_callback) */
        -- };
        local numbers = List.cons(1, 
                                List.cons(2,
                                          List.cons(3,
                                                    List.empty())));
        assert.are.equal(
          length(numbers)(0) 
        , 3)
        -- **リスト7.56** lengthWithCallback関数でリストの長さをテストする
        -- /* #@@range_begin(list_length_callback_test) */
        -- /* lengthWithCallback関数に渡すコールバック関数 */
        local callback = function(n)
          return function(m)
            return 1 + m;
          end;
        end;
        assert.are.equal(
          lengthWithCallback(numbers)(0)(callback) 
        , 3)
        -- /* #@@range_end(list_length_callback_test) */
      end);
    end);
    describe('畳み込み関数', function()
      -- **リスト7.58** リストの畳み込み関数
      -- /* #@@range_begin(list_foldr) */
      local function foldr(alist)
        return function(accumulator)
          return function(callback)
            return List.match(alist,{
              empty = function(_)
                return accumulator;
              end,
              cons = function(head, tail)
                return callback(head)(foldr(tail)(accumulator)(callback));
              end 
            });
          end 
        end;
      end;
      -- /* #@@range_end(list_foldr) */
      -- ** リスト7.59** foldr関数によるsum関数とlength関数の定義
      -- /* foldr関数によるsum関数 */
      it("foldr関数によるsum関数", function()
        -- /* #@@range_begin(foldr_sum) */
        local sum = function(alist)
          return foldr(alist)(0)(function(item)
            return function(accumulator)
              return accumulator + item;
            end;
          end);
        end;
        -- /* #@@range_end(foldr_sum) */
        -- /* list = [1,2,3,4] */
        local seq = List.cons(1,List.cons(2,List.cons(3,List.cons(4,List.empty()))));
        assert.are.equal(
          sum(seq) 
        , 10)
      end);
      -- /* foldr関数によるlength関数 */
      it("foldrでlength関数を作る", function()
        -- /* #@@range_begin(foldr_length) */
        local length = function(alist)
          return foldr(alist)(0)(function(item)
            return function(accumulator)
              return accumulator + 1;
            end
          end);
        end
        -- /* #@@range_end(foldr_length) */
        -- /* list = [1,2,3,4] */
        local seq = List.cons(1,List.cons(2,List.cons(3,List.cons(4,List.empty()))));
        assert.are.equal(
         length(seq) 
        , 4)
      end);
      -- **表7.2** 反復処理における蓄積変数の初期値とコールバック関数の関係
      --
      -- |関数名	   |蓄積変数の初期値 | 関数合成による定義	                       |
      -- |:------------|:------------:|:--------------------------------------------|
      -- |sum          |0             |(n) => { return (m) => { return n + m;};}   |
      -- |length       |0             |(n) => { return (m) => { return 1 + m;};}   |
      -- |product      |1             |(n) => { return (m) => { return n ＊ m;};}   |
      -- |all          |true          |(n) => { return (m) => { return n ＆＆ m;};} |
      -- |any          |true          |(n) => { return (m) => { return n ｜｜ m;};} |
      --
      describe('反復処理における蓄積変数の初期値とコールバック関数の関係', function()
        it("foldrでproductを作る", function()
          -- /* #@@range_begin(foldr_product) */
          local product = function(alist)
            return foldr(alist)(1)(function(item)
              return function(accumulator)
                return accumulator * item;
              end 
            end);
          end 
          -- /********* テスト **********/
          -- /* list = [1,2,3] */
          local seq = List.cons(1,
                              List.cons(2,
                                        List.cons(3,
                                                  List.empty())));
          assert.are.equal(
           product(seq)
          , 6)
          -- /* #@@range_end(foldr_product) */
        end);
        it("foldrでallを作る", function()
          local all = function(alist)
            return foldr(alist)(true)(function(item)
              return function(accumulator)
                return accumulator and item;
              end 
            end);
          end 
          -- /********* テスト **********/
          local allTrueList = List.cons(true,
                                      List.cons(true,
                                                List.cons(true,
                                                          List.empty())));
          assert.are.equal(
            all(allTrueList) 
          , true)
          local someFalseList = List.cons(true,
                                        List.cons(false,
                                                  List.cons(true,
                                                            List.empty())));
          assert.are.equal(
            all(someFalseList) 
          , false)
        end);
        it("foldrでanyを作る", function()
          local any = function(alist)
            return foldr(alist)(false)(function(item)
              return function(accumulator)
                return accumulator or item;
              end;
            end);
          end 
          -- /********* テスト **********/
          local allTrueList = List.cons(true,
                                      List.cons(true,
                                                List.cons(true,
                                                          List.empty())));
          assert.are.equal(
           any(allTrueList) 
          , true)
          local someFalseList = List.cons(true,
                                        List.cons(false,
                                                  List.cons(true,
                                                            List.empty())));
          assert.are.equal(
            any(someFalseList) 
          , true)
        end);
      end);
      -- **リス7.60** foldr関数によるreverse関数の定義
      it("foldr関数によるreverse関数の定義", function()
        local list = {
          match = function(data, pattern)
            return data(pattern);
          end,
          empty = function(_)
            return function(pattern)
              return pattern.empty();
            end 
          end,
          cons = function(value, alist)
            return function(pattern)
              return pattern.cons(value, alist);
            end
          end,
          toArray = function(alist)
            local toArrayAux = function(alist,accumulator)
              return list.match(alist, {
                empty = function(_)
                  return accumulator;  
                end,
                cons = function(head, tail)
                  return toArrayAux(tail, accumulator.concat(head));
                end 
              });
            end 
            return toArrayAux(alist, {});
          end,
          -- /* #@@range_begin(foldr_reverse) */
          -- /* listのappend関数は、2つのリストを連結する */
          append = function(xs)
            return function(ys)
              return list.match(xs, {
                empty = function(_)
                  return ys;
                end,
                cons = function(head, tail)
                  return list.cons(head, list.append(tail)(ys)); 
                end
              });
            end;
          end,
          -- /* list.reverse関数は、リストを逆転する */
          reverse = function(alist)
            return foldr(alist)(list.empty(0))(function(item)
              return function(accumulator)
                return list.append(accumulator)(list.cons(item,
                                                          list.empty()));
              end;
            end);
          end
          -- /* #@@range_end(foldr_reverse) */
        };
        -- /* list = [1,2,3,4] */
        local seq = List.cons(1,
                            List.cons(2,
                                      List.cons(3,
                                                List.cons(4,
                                                          List.empty()))));
        assert.are.same(
         List.toArray(List.reverse(seq)) 
        , { 4, 3, 2, 1})
      end);
      -- **リスト7.61** foldr関数によるfind関数の定義
      it("foldr関数によるfind関数の定義", function()
        local even = function(n)
          return (n % 2) == 0;
        end 
        local list = {
          empty = function(_)
            return function(pattern)
              return pattern.empty();
            end 
          end,
          cons = function(value, alist)
            return function(pattern)
              return pattern.cons(value, alist);
            end 
          end,  
          -- /* #@@range_begin(foldr_find) */
          -- /* list.find関数は、条件に合致した要素をリストから探す */
          find = function(alist)
            return function(predicate) -- 要素を判定する述語関数
              return foldr(alist)(null)(function(item) -- foldrを利用する
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
          -- /* #@@range_end(foldr_find) */
        };
        -- /******** テスト *********/
        local numbers = List.cons(1,
                                List.cons(2,
                                          List.cons(3,
                                                    List.empty())));
        assert.are.same(
          List.find(numbers)(even) -- 最初に登場する偶数の要素を探す 
        , 2)
      end);
      it("foldrで map関数を作る", function()
        local double = function(number)
          return number * 2;
        end 
        -- /* #@@range_begin(foldr_map) */
        local function map(alist)
          return function(callback) -- 個々の要素を変換するコールバック関数
            return foldr(alist)(List.empty())(function(item)
              return function(accumulator)
                return List.cons(callback(item), accumulator);
              end
            end);
          end
        end 
        -- /****** テスト ******/
        -- /* list = [1,2,3] */
        local seq = List.cons(1,
                            List.cons(2,
                                      List.cons(3,
                                                List.empty())));
        assert.are.same(
          List.toArray(map(seq)(double))
        ,  
          { 2, 4, 6}
        )
        -- /* #@@range_end(foldr_map) */
      end);
    end);
    -- #### コラム：配列の畳み込み関数
    -- > 参考資料: https:--developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce
    describe("コラム：配列の畳み込み関数", function()
      -- **リスト7.62** reduceメソッドによるfromArray関数
      it("reduceメソッドの検証", function()
        local Array = require("lib/array")
        local anArray = {1,2,3}
        local function sum(anArray)
          return Array.reduce(anArray, function(item,  accumulator)
            return item + accumulator
          end,0)
        end
        assert.are.equal(
         sum({1,2,3})
        ,  
          6  
          )
      end)
      it("reduceメソッドによるfromArray関数", function()
        -- /* #@@range_begin(list_fromArray) */
        local Array = require("lib/array")
        local function fromArray(anArray)
          return Array.reduce(anArray, function(item,  accumulator)
            assert(item)
            return List.cons(item, accumulator)
          end, List.empty());
        end;
        -- /******* テスト *******/
        local theList = fromArray({0,1,2,3});
        assert.are.same(
         List.toArray(theList) 
        ,  
          {0,1,2,3}
        )
        -- /* #@@range_end(list_fromArray) */
      end);
    end);
  end);
  -- ### <section id='asynchronous'>非同期処理にコールバック関数を渡す</section>
  describe('非同期処理にコールバック関数を渡す', function()
    -- **リスト7.64** tarai関数の定義
    it("tarai関数の定義", function()
      -- /* #@@range_begin(tarai_function) */
      -- /* たらいまわし関数 */
      local function tarai(x,y,z)
        if(x > y) then
          return tarai(tarai(x - 1, y, z), 
                       tarai(y - 1, z, x), 
                       tarai(z - 1, x, y));
        else 
          return y;
        end 
      end 
      assert.are.equal(
        tarai(1 * 2, 1, 0) 
      ,  
        2
      )
      -- /* #@@range_end(tarai_function) */
    end);
    -- <a name="tarai_system"> taraiサーバークライアント</a>
    -- ![](images/tarai-system.gif) 
  end);
  -- ### <section id='continuation'>継続で未来を渡す</section>
  -- > 参考資料: [Wikipediaの記事](https:--ja.wikipedia.org/wiki/%E7%B6%99%E7%B6%9A)
  describe('継続で未来を渡す', function()
    -- #### 継続とは何か
    describe('継続とは何か', function()
      -- **リスト7.67** 継続渡しのsucc関数
      it("継続渡しのsucc関数", function()
        -- /* #@@range_begin(succ_cps) */
        -- /* continues関数は、succ(n)のあとに続く継続 */
        local succ = function(n, continues)
          return continues(n + 1);
        end 
        -- /* #@@range_end(succ_cps) */

        -- **リスト7.68** 継続渡しのsucc関数をテストする
        local identity = function(any)
          return any;
        end 

        -- /* #@@range_begin(succ_cps_test) */
        --[[ /* identity関数を継続として渡すことで、
           succ(1)の結果がそのまま返る */
           ]]
         assert.are.equal(
            succ(1, identity)  
         ,  
            2
         )
        -- expect(
        --   succ(1, identity) 
        -- ).to.eql(
        --   2
        -- );
        -- /* #@@range_end(succ_cps_test) */
      end);
      -- **リスト7.70** add(2, succ(3))の継続渡し
      it("add(2, succ(3))の継続渡し", function()
        pending("I should finish this test later")
        -- --[[
        -- local identity = function(any) -- 値をそのまま返すだけの継続
        --   return any;
        -- end
        -- -- /* #@@range_begin(continuation_in_arithmetic) */
        -- -- /* 継続渡しのsucc関数 */
        -- local succ = function(n, continues)
        --   return continues(n + 1);
        -- end
        -- -- /* 継続渡しのadd関数 */
        -- local add = function(n,m, continues)
        --   return continues(n + m);
        -- end
        -- --[[ /* 継続渡しのsucc関数とadd関数を使って 
        -- add(2, succ(3)) を計算する */
        -- ]]
        -- assert.are.equal(
        --   succ(3, function(succResult)
        --     return add(2, succResult, identity);
        --   end)
        -- ,  
        --   6
        -- )
        -- -- expect(
        -- --   succ(3, function(succResult)
        -- --     return add(2, succResult, identity);
        -- --   end)
        -- -- ).to.eql(
        -- --   6
        -- -- );
        -- -- /* #@@range_end(continuation_in_arithmetic) */
        -- ]]
      end);
    end);
    describe("継続で未来を選ぶ", function()
      -- **リスト7.71** 継続による反復処理からの脱出
      it("継続による反復処理からの脱出", function()
        pending("I should finish this test later")
        -- -- /* #@@range_begin(stream_find_cps) */
        -- local find = function(aStream,
        --             predicate, 
        --             continuesOnFailure, 
        --             continuesOnSuccess)
        --               return Stream.match(aStream, {
        --                 --[[/* リストの最末尾に到着した場合
        --                    成功継続で反復処理を抜ける */
        --                    --]]
        --                 empty = function()
        --                   return continuesOnSuccess(nil); 
        --                 end,
        --                 cons = function(head, tailThunk)
        --                   --[[/* 目的の要素を見つけた場合
        --                      成功継続で反復処理を脱出する */
        --                      --]]
        --                   if(predicate(head) == true) then
        --                     return continuesOnSuccess(head); 
        --                   else 
        --                     --[[/* 目的の要素を見つけられなった場合、
        --                        失敗継続で次の反復処理を続ける */
        --                        --]]
        --                     return continuesOnFailure(tailThunk(), 
        --                                               predicate,
        --                                               continuesOnFailure,
        --                                               continuesOnSuccess);
        --                   end 
        --                 end 
        --               });
        --             end;
        -- -- /* #@@range_end(stream_find_cps) */
        --
        -- -- find関数に渡す2つの継続
        -- local identity = function(any)
        --   return any;
        -- end
        -- -- **リスト7.72** find関数に渡す2つの継続
        -- --[[
        -- /* #@@range_begin(stream_find_continuations) */
        -- /* 成功継続では、反復処理を脱出する */
        -- ]]
        -- local continuesOnSuccess = identity; 
        --
        -- -- /* 失敗継続では、反復処理を続ける */
        -- local continuesOnFailure = function(aStream,
        --                           predicate, 
        --                           continuesOnRecursion, 
        --                           escapesFromRecursion)
        --                             -- /* find関数を再帰的に呼び出す */
        --                             return find( 
        --                               aStream, 
        --                               predicate, 
        --                               continuesOnRecursion, 
        --                               escapesFromRecursion
        --                             );  
        --                           end
        -- --/* #@@range_end(stream_find_continuations) */
        -- -- **リスト7.73** find関数のテスト
        -- -- /* upto3変数は、1から3までの有限ストリーム */
        -- local upto3 = Stream.cons(1, function(_)
        --   return Stream.cons(2, function(_)
        --     return Stream.cons(3, function(_)
        --       return Stream.empty();
        --     end);
        --   end);
        -- end);
        -- assert.are.equal(
        --   find(upto3, function(item)
        --     return (item == 4); -- 4を探します
        --   end, continuesOnFailure, continuesOnSuccess)
        -- ,  
        --   6
        -- )
        -- -- expect(
        -- --   find(upto3, function(item)
        -- --     return (item == 4); -- 4を探します
        -- --   end, continuesOnFailure, continuesOnSuccess)
        -- -- ).to.eql(
        -- --   nil -- リスト中に4の要素はないので、nullになります
        -- -- );
        -- -- /* #@@range_begin(stream_find_cps_test) */
        -- -- /* 変数integersは、無限の整数ストリーム */
        -- local integers = stream.enumFrom(0);
        -- 
        -- -- /* 無限の整数列のなかから100を探す */
        -- expect(
        --   find(integers, function(item)
        --     return (item == 100)
        --   end, continuesOnFailure, continuesOnSuccess)
        -- ).to.eql(
        --   100 -- 100を見つけて返ってくる
        -- );
        -- -- /* #@@range_end(stream_find_cps_test) */
      end); 
    end); 
    -- #### 非決定計算機を作る
    -- > 参考資料: [SICPの非決定計算の章](http:--sicp.iijlab.net/fulltext/x430.html)
    --
    -- **リスト7.74** 決定性計算機
    describe("決定計算機", function()
      -- 式の代数的データ構造
      local exp = {
        match = function(anExp, pattern)  -- 代数的データ構造のパターンマッチ
          return anExp(pattern);
        end,
        num = function(n)             -- 数値の式
          return function(pattern)
            return pattern.num(n);
          end 
        end, 
        add = function(exp1, exp2)    -- 足し算の式
          return function(pattern)
            return pattern.add(exp1, exp2);
          end;
        end
      };
      -- 式の評価関数
      local calculate = function(anExp)
        return match(anExp, { 
          num = function(n)           -- 数値を評価する
            return n;
          end, 
          add = function(exp1, exp2)  -- 足し算の式を評価する
            return calculate(exp1) + calculate(exp2); 
          end
        });
      end 
    end); 
    describe("非決定計算機を作る", function()
      -- local exp = {
      --   match = function(anExp, pattern)
      --     return anExp(pattern);
      --   end,
      --   -- **リスト7.75** 非決定計算機の式
      --   -- /* #@@range_begin(amb_expression) */
      --   amb =  function(alist)
      --     return function(pattern)
      --       return pattern.amb(alist);
      --     end
      --   end,
      --   -- /* #@@range_end(amb_expression) */
      --   num = function(n)
      --     return function(pattern)
      --       return pattern.num(n);
      --     end
      --   end,
      --   add = function(exp1, exp2)
      --     return function(pattern)
      --       return pattern.add(exp1, exp2);
      --     end;
      --   end 
      -- };
      -- -- /* #@@range_begin(amb_calculate) */
      -- -- <section id='amb_calculate'>非決定性計算機の評価関数</section>
      -- local calculate = function(anExp, 
      --                  continuesOnSuccess, 
      --                  continuesOnFailure)
      --                    -- /* 式に対してパターンマッチを実行する */
      --                    return exp.match(anExp, { 
      --                      -- **リスト7.79** 数値の評価
      --                      -- /* #@@range_begin(amb_calculate_num) */
      --                      -- /* 数値を評価する */
      --                      num = function(n)
      --                        return continuesOnSuccess(n, continuesOnFailure);
      --                      end,
      --                      -- /* #@@range_end(amb_calculate_num) */
      --                      -- **リスト7.80** 足し算の評価 
      --                      -- /* #@@range_begin(amb_calculate_add) */
      --                      -- /* 足し算の式を評価する */
      --                      add = function(x, y)
      --                        -- /* まず引数xを評価する */
      --                        return calculate(x, function(resultX, continuesOnFailureX) 
      --                          -- /* 次に引数yを評価する */
      --                          return calculate(y, function(resultY, continuesOnFailureY)
      --                            -- /* 引数xとyがともに成功すれば、両者の値で足し算を計算する */
      --                            return continuesOnSuccess(resultX + resultY, continuesOnFailureY); 
      --                          end, continuesOnFailureX); -- /* y の計算に失敗すれば、xの失敗継続を渡す */
      --                        end, continuesOnFailure);    -- /* x の計算に失敗すれば、おおもとの失敗継続を渡す */
      --                      end,
      --                      -- /* #@@range_end(amb_calculate_add) */
      --                      -- **リスト7.81** amb式の評価
      --                      -- /* #@@range_begin(amb_calculate_amb) */
      --                      -- /* amb式を評価する */
      --                      amb = function(choices)
      --                         local calculateAmb = function(choices)
      --                          return list.match(choices, {
      --                            --[[/* 
      --                               amb(list.empty()) の場合、
      --                               すなわち選択肢がなければ、失敗継続を実行する
      --                            */
      --                            --]]
      --                            empty = function()
      --                              return continuesOnFailure();
      --                            end,
      --                            --[[/* 
      --                               amb(list.cons(head, tail))の場合、
      --                               先頭要素を計算して、後尾は失敗継続に渡す
      --                            */
      --                            --]]
      --                            cons = function(head, tail)
      --                              return calculate(head, continuesOnSuccess, function(_)
      --                                -- /* 失敗継続で後尾を計算する */
      --                                return calculateAmb(tail);
      --                              end);
      --                            end
      --                          });
      --                        end;
      --                        return calculateAmb(choices);
      --                      end 
      --                      -- /* #@@range_end(amb_calculate_amb) */
      --                    });
      --                  end;
      -- -- /* #@@range_end(amb_calculate) */
      --
      -- -- **リスト7.82** 非決定計算機の駆動関数
      -- -- /* #@@range_begin(amb_driver) */
      -- local driver = function(expression)
      --   -- /* 中断された計算を継続として保存する変数 */
      --   local suspendedComputation = nil; 
      --   -- /* 成功継続 */
      --   local continuesOnSuccess = function(anyValue, 
      --                             continuesOnFailure)
      --                               -- /* 再開に備えて、失敗継続を保存しておく */
      --                               suspendedComputation = continuesOnFailure; 
      --                               return anyValue;
      --                             end;
      --   -- /* 失敗継続 */
      --   local continuesOnFailure = function()
      --     return nil;
      --   end;
      --
      --   -- /* 内部に可変な状態suspendedComputationを持つクロージャーを返す */
      --   return function()
      --     -- /* 中断された継続がなければ、最初から計算する */
      --     if(suspendedComputation == nil) then
      --       return calculate(expression, 
      --                        continuesOnSuccess, 
      --                        continuesOnFailure);
      --     else -- /* 中断された継続があれば、その継続を実行する */
      --       return suspendedComputation();
      --     end 
      --   end 
      -- end;
      -- -- /* #@@range_end(amb_driver) */
      -- it("amb[1,2] + 3  = amb[4, 5]", function()
      --   local ambExp = exp.add(exp.amb(list.cons(exp.num(1),list.cons(exp.num(2), list.empty()))), 
      --                        exp.num(3));
      --   local calculator = driver(ambExp);
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     4 -- 1 + 3 = 4
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     5 -- 2 + 3 = 5 
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     nil
      --   );
      -- end);
      -- -- **リスト7.83** 非決定計算機のテスト
      -- it("非決定計算機のテスト", function()
      --   -- /* amb[1,2] + amb[3,4] = amb[4, 5, 5, 6] */
      --   -- /* #@@range_begin(amb_test) */
      --   -- /* amb[1,2] + amb[3,4] = 4, 5, 5, 6 */
      --   local ambExp = exp.add(
      --     exp.amb(list.fromArray({exp.num(1),exp.num(2)})),
      --     exp.amb(list.fromArray({exp.num(3),exp.num(4)})));
      --   local calculator = driver(ambExp);
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     4 -- 1 + 3 = 4
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     5 -- 2 + 3 = 5
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     5 -- 1 + 4 = 5
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     6 -- 2 + 4 = 6
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     nil -- これ以上の候補はないので、計算は終了
      --   );
      --   -- /* #@@range_end(amb_test) */
      -- end);
      -- it("amb[1,2,3] + amb[10,20] = amb[11,21,12,22,13,23]", function()
      --   local ambExp = exp.add(
      --     exp.amb(list.fromArray({exp.num(1),exp.num(2),exp.num(3)})),
      --     exp.amb(list.fromArray({exp.num(10),exp.num(20)})));
      --   local calculator = driver(ambExp);
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     11 -- 1 + 10 = 11
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     21 -- 1 + 20 = 21
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     12 -- 2 + 10 = 12
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     22 -- 2 + 20 = 22
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     13 -- 3 + 10 = 13
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     23 -- 3 + 20 = 23
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     nil -- これ以上の候補はないので、計算は終了
      --   );
      -- end);
      -- it("amb[1,2] + amb[10,20,30] = amb[11,21,31,12,22,32]", function()
      --   local ambExp = exp.add(
      --     exp.amb(list.fromArray({exp.num(1),exp.num(2)})),
      --     exp.amb(list.fromArray({exp.num(10),exp.num(20),exp.num(30)})));
      --   local calculator = driver(ambExp);
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     11 -- 1 + 10 = 11
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     21 -- 1 + 20 = 21
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     31 -- 1 + 30 = 31
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     12 -- 2 + 10 = 12
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     22 -- 2 + 20 = 22
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     32 -- 2 + 30 = 32
      --   );
      --   expect(
      --     calculator()
      --   ).to.eql(
      --     null -- これ以上の候補はないので、計算は終了
      --   );
      -- end);
    end); 
  end); -- 継続を渡す
end); -- 関数を渡す

-- ## 7.6 <section id='monad'>モナドを作る</section>
describe('モナドを作る', function()
  local compose = function(f,g)
    return function(arg)
      return f(g(arg));
    end 
  end
  -- ### <section id='identity-monad'>恒等モナド</section>
  describe('恒等モナド', function()
    local ID = require("lib/monad/id")
    -- **リスト7.85** 恒等モナドの定義
    -- **リスト7.86** 恒等モナドunit関数のテスト
    it("恒等モナドunit関数のテスト", function()
      -- /* #@@range_begin(identity_monad_unit_test) */
      assert.are.equal(
        ID.new(1)
      , 
       1 
      )
      -- /* #@@range_end(identity_monad_unit_test) */
    end);
    -- **リスト7.87** 恒等モナドflatMap関数のテスト
    it("恒等モナドflatMap関数のテスト", function()
      local succ = function(n)
        return n + 1;
      end;
      -- /* #@@range_begin(identity_monad_flatMap_test) */
      assert.are.equal(
        ID.flatMap(ID.new(1))(function(one)
          return ID.new(succ(one));
        end)
      , 
        succ(1)
      )
      -- /* #@@range_end(identity_monad_flatMap_test) */
      local double = function(m)
        return m * 2;
      end
      -- **リスト7.88** flatMapと関数合成の類似性
      -- /* #@@range_begin(flatMap_and_composition) */
      assert.are.equal(
        ID.flatMap(ID.new(1))(function(one)
          -- /* succ関数を適用する */
          return ID.flatMap(ID.new(succ(one)))(function(two)
            -- /* double関数を適用する */
            return ID.new(double(two));  
          end);
        end)
      , 
        compose(double,succ)(1)
      )
      -- /* #@@range_end(flatMap_and_composition) */
    end);
    -- **リスト7.89**  恒等モナドのモナド則
    describe("恒等モナドのモナド則", function()
      -- /* #@@range_begin(identity_monad_laws) */
      it("flatMap(instanceM)(unit) === instanceM", function()
        -- /* flatMap(instanceM)(unit) === instanceM の一例 */
        local instanceM = ID.new(1);
        -- 右単位元則
        -- /* #@@range_begin(identity_monad_laws_right_unit_law) */
        assert.are.equal(
          ID.flatMap(instanceM)(ID.new)
        , 
          instanceM
        )
        -- /* #@@range_end(identity_monad_laws_right_unit_law) */
      end);
      it("flatMap(unit(value))(f) == f(value)", function()
        -- /* flatMap(unit(value))(f) === f(value) */
        local f = function(n)
          return ID.new(n + 1);
        end 
        -- 左単位元則
        -- /* #@@range_begin(identity_monad_laws_left_unit_law) */
        assert.are.equal(
          ID.flatMap(ID.new(1))(f)
        , 
          f(1)
        )
        -- /* #@@range_end(identity_monad_laws_left_unit_law) */
      end);
      it("flatMap(flatMap(instanceM)(f))(g) == flatMap(instanceM)((x) => flatMap(f(x))(g))", function()
        --[[/* 
           flatMap(flatMap(instanceM)(f))(g) 
           === 
           flatMap(instanceM)((x) => { 
              return flatMap(f(x))(g); } 
           } 
        */
        ]]
        local f = function(n)
          return ID.new(n + 1);
        end;
        local g = function(n)
          return ID.new(- n);
        end;
        local instanceM = ID.new(1);
        -- 結合法則
        -- /* #@@range_begin(identity_monad_laws_associative_law) */
        assert.are.equal(
          ID.flatMap(ID.flatMap(instanceM)(f))(g), 
          ID.flatMap(instanceM)(function(x)
            return ID.flatMap(f(x))(g);
          end)
        )

        -- /* #@@range_end(identity_monad_laws_associative_law) */
        -- /* #@@range_end(identity_monad_laws) */
      end);
    end);
  end);
  -- ### <section id='maybe-monad'>Maybeモナドでエラーを処理する</section>
  -- > 参考資料: https:--en.wikibooks.org/wiki/Haskell/Understanding_monads/Maybe
  describe('Maybeモナドでエラーを処理する', function()
    describe('Maybeモナドを作る', function()
      -- **リスト7.91** Maybeの代数的構造
      -- /* #@@range_begin(algebraic_type_maybe) */
      -- local maybe = {
      --   match = function(exp, pattern)
      --     return exp(pattern);
      --   end,
      --   just = function(value)
      --     return function(pattern)
      --       return pattern.just(value);
      --     end;
      --   end,
      --   nothing = function(_)
      --     return function(pattern)
      --       return pattern.nothing(_);
      --     end
      --   end 
      -- };
      -- /* #@@range_end(algebraic_type_maybe) */
      -- **リスト7.92** Maybeモナドの定義
      -- **リスト7.93** Maybeモナドの利用法
      it("Maybeモナドの利用法", function()
        local Maybe = require("lib/monad/maybe")
        -- /* #@@range_begin(maybe_monad_add_test) */
        -- /* 足し算を定義する */
        local add = function(maybeA,maybeB)
          return Maybe.flatMap(maybeA)(function(a)
            return Maybe.flatMap(maybeB)(function(b)
              return Maybe.new(a + b);
            end);
          end);
        end;
        local justOne = Maybe.just(1);
        local justTwo = Maybe.just(2);
        assert.are.equal(
           Maybe.getOrElse(add(justOne,justOne))(nil)
           , 2)

        assert.are.equal(
          Maybe.getOrElse(add(justOne,Maybe.nothing()))(nil) 
           , nil)
        -- /* #@@range_end(maybe_monad_add_test) */
      end);
    end);
  end);
  -- ### <section id='io-monad'>IOモナドで副作用を閉じ込める</section>
  -- > 参考資料: https:--en.wikibooks.org/wiki/Haskell/Understanding_monads/IO
  describe('IOモナドで副作用を閉じ込める', function()
    local IO = require("lib/monad/io")
    local match = function(data, pattern)
      return data(pattern);
    end 
    -- **リスト7.94** Pair型の定義
    -- /* #@@range_begin(pair_datatype) */
    local Pair = require("lib/pair")
    -- /* #@@range_end(pair_datatype) */
    -- **リスト7.95** 外界を明示したIOモナドの定義
    describe('外界を明示したIOモナドの定義', function()
      local IO = {
        -- /* #@@range_begin(io_monad_definition_with_world) */
        -- /* unit:: T => IO[T] */
        unit = function(any)
          return function(world)  -- worldは現在の外界
            return Pair.cons(any, world);
          end;
        end,
        -- /* flatMap:: IO[T] => FUN[T => IO[U]] => IO[U] */
        flatMap = function(instanceA)
          return function(actionAB)  -- actionAB:: FUN[T => IO[U]]
            return function(world)
              local newPair = instanceA(world); -- 現在の外界のなかで instanceAのIOアクションを実行する
              return Pair.match(newPair,{
                cons = function(value, newWorld)
                  return actionAB(value)(newWorld); -- 新しい外界のなかで、actionAB(value)で作られたIOアクションを実行する
                end
              });
            end;
          end;
        end,
        -- /* #@@range_end(io_monad_definition_with_world) */
        -- **リスト7.96** IOモナドの補助関数
        -- /* #@@range_begin(io_monad_definition_with_world_helper_function) */
        -- /* done:: T => IO[T] */
        done = function(any)
          return IO.unit();
        end,
        -- /* run:: IO[A] => A */
        run = function(instance)
          return function(world)
            local newPair = instance(world); -- IOモナドのインスタンス(アクション)を現在の外界に適用する
            return Pair.left(newPair);     -- 結果だけを返す
          end;
        end
        -- /* #@@range_end(io_monad_definition_with_world_helper_function) */
      }; -- IO monad
      IO.println = function(message)
        return function(world)  -- IOモナドを返す
          --console.log(message);
          print(message)
          return IO.unit(nil)(world);
        end;
      end 
      -- **リスト7.98** run関数の利用法
      -- /* #@@range_begin(run_println) */
      -- /* 初期の外界に null をバインドする */
      local initialWorld = nil; 
      assert.are.equal(
        IO.run(IO.println("我輩は猫である"))(initialWorld), 
        nil)
      --/* #@@range_end(run_println) */
    end);
    describe('外界を引数に持たないIOモナド', function()
      local IO = require("../lib/monad/io")
      -- **リスト7.99** 外界を明示しないIOモナドの定義
      -- **リスト7.100** run関数の利用法
      it('run関数の利用法', function()
        -- /* #@@range_begin(run_println_without_world) */
        assert.are.equal(
          -- /* 外界を指定する必要はありません */
          IO.run(IO.println("名前はまだない")) 
        , nil)
        -- /* #@@range_end(run_println_without_world) */
      end);
      -- #### IOアクションを合成する
      describe('IOアクションを合成する', function()
        -- /* #@@range_begin(io_monad_is_composable) */
        -- **リスト7.102** seq関数の定義
        -- /* IO.seq:: IO[a] => IO[b] => IO[b] */
        IO.seq = function(instanceA)
          return function(instanceB)
            return IO.flatMap(instanceA)(function(a)
              return instanceB;
            end);
          end;
        end;
        IO.seqs = function(alist)
          return list.foldr(alist)(list.empty())(IO.done());
        end;
        -- /* IO.putc:: CHAR => IO[] */
        IO.putc = function(character)
          return function(_)
            process.stdout.write(character);
            return nil;
          end;
        end;
        -- /* IO.puts:: LIST[CHAR] => IO[] */
        IO.puts = function(alist)
          return match(alist, {
            empty = function()
              return IO.done();
            end,
            cons = function(head, tail)
              return IO.seq(IO.putc(head))(IO.puts(tail));
            end
          });
        end
        -- /* IO.getc:: IO[CHAR] */
        IO.getc = function()
          local continuation = function()
            local chunk = process.stdin.read();
            return chunk;
          end 
          process.stdin.setEncoding('utf8');
          return process.stdin.on('readable', continuation);
        end;
        -- /* #@@range_end(io_monad_is_composable) */

        -- **リスト7.103** stringモジュール
        -- /* #@@range_begin(string_module) */
        local chars = {
          -- /* 先頭文字を取得する */
          head = function(str)
            return string.sub(str, 1, 1);
            -- return str[1];
          end,
          -- /* 後尾文字列を取得する */
          tail = function(str)
            return string.sub(str, 2);
            -- return str.substring(1);
          end,
          -- /* 空の文字列かどうかを判定する */
          isEmpty = function(str)
            return str.length == 0;
          end,
          -- /* 文字列を文字のリストに変換する */
          toList = function(str)
            if(string.isEmpty(str)) then
              return list.empty();
            else
              return list.cons(string.head(str), 
                               string.toList(string.tail(str)));
            end 
          end 
        };
        -- /* #@@range_end(string_module) */
        -- it('IO.putcのテスト', (next) => {
        --   expect(
        --     IO.putc('a')
        --   ).to.eql(
        --     IO.putc('a')
        --   );
        --   next();
        -- });
        it('charsのテスト', function()
          assert.are.equal(chars.head("abc"), "a")
          assert.are.equal(chars.tail("abc"), "bc")
        end);
      end);
    end);
  end); -- IOモナドで副作用を閉じ込める
end); -- モナド
-- end); -- モナド

-- [目次に戻る](index.html) [次章に移る](chap08.spec.html) 
