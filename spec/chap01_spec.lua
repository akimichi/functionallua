-- chap01_spec.lua
describe("命令型モデル", function()
  describe("チューリング機械 turing machine", function()
    -- **リスト 1.1 JavaScriptによるチューリング機械 **
    -- #@@range_begin(turing)
    local machine = function(program,tape,initState, endState)
      -- ヘッドの位置
      local position = 0
      -- 機械の状態
      local state = initState
      -- 実行する命令
      local currentInstruction = {}
      --[[
        以下のwhileループにて、
        現在の状態が最終状態に到達するまで命令を繰り返す
        ]] 
      while state ~= endState do
        local cell = tape[position]
        if (cell) then
          currentInstruction = program[state][cell]
        else
          currentInstruction = program[state].B
        end
        if not currentInstruction then
          return false
        else
          -- テープに印字する
          tape[String(position)] = currentInstruction.write 
          -- ヘッドを動かす
          position = position + currentInstruction.move                
          -- 次の状態に移る
          state = currentInstruction.next                    
        end 
      end
      return tape
    end
    -- #@@range_end(turing)
  end)
  -- **リスト 1.2 チューリング機械の実行例 **
  -- describe('チューリング機械の実行例', function()
  --   -- #### <a name="turing_demo"> **チューリング機械の挙動** </a>
  --   -- ![チューリング機械の挙動](images/turing_succ.gif) 
  --   it('チューリング機械でsucc関数を実装する', (next) => {
  --     --[[
  --      #@@range_begin(turing_example_succ)
  --      2進法で10、つまり10進法で2を表すテープ
  --     ]]
  --     var tape = { 
  --       '0':'1',
  --       '1':'0'
  --     };
  --     /* チューリング機械に与えるプログラム */
  --     var program = {
  --       'q0': {"1": {"write": "1", "move": 1, "next": 'q0'},
  --       "0": {"write": "0", "move": 1, "next": 'q0'},
  --       "B": {"write": "B", "move": -1, "next": 'q1'}},
  --       'q1': {"1": {"write": "0", "move": -1, "next": 'q1'},
  --       "0": {"write": "1", "move": -1, "next": 'q2'},
  --       "B": {"write": "1", "move": -1, "next": 'q3'}},
  --       'q2': {"1": {"write": "1", "move": -1, "next": 'q2'},
  --       "0": {"write": "0", "move": -1, "next": 'q2'},
  --       "B": {"write": "B", "move": 1, "next": 'q4'}},
  --       'q3': {"1": {"write": "1", "move": 1, "next": 'q4'},
  --       "0": {"write": "0", "move": 1, "next": 'q4'},
  --       "B": {"write": "B", "move": 1, "next": 'q4'}}
  --     };
  --     /* #@@range_end(turing_example_succ) */
  --     expect(
  --     -- **リスト 1.3 1を加えるチューリング機械の実行 **
  --     /* #@@range_begin(turing_example_succ_test) */
  --     machine(program,     -- プログラム
  --     tape,        -- テープ
  --     'q0',        -- 初期状態
  --     'q4')        -- 終了状態
  --     /* #@@range_end(turing_example_succ_test) */
  --     ).to.eql(
  --     /* #@@range_begin(turing_example_succ_test_result) */
  --     {
  --       '-1': 'B',
  --       '0': '1',
  --       '1': '1',
  --       '2': 'B'
  --     }
  --     /* #@@range_end(turing_example_succ_test_result) */
  --     );
  --     next();
  --   });
  -- end);
end)

-- ## 1.3 <section id='functional_model'>関数型モデル</section>
describe('関数型モデル', function()
  -- ###  <section id='substitution_model'>置換ルール</section>
  describe('置換ルール', function()
    it('単純なλ式の簡約', function()
      --/* #@@range_begin(succ) */
      local succ = function(n)
        return n + 1
      end
      --/* #@@range_end(succ) */
      assert.are.equal(succ(1), 2)
      -- expect(
      --   succ(1)
      -- ).to.eql(
      --   2
      -- );
    end);
    -- **リスト 1.5 add関数 **
    it('add関数', function()
      --/* #@@range_begin(recursive_add) */
      local succ = function(n)
        return n + 1;
      end;
      local prev = function(n)
        return n - 1;
      end 
      --/* add関数の定義 /
      local function add(x,y)
        if(y < 1) then
          return x;
        else
          --/* add関数の再帰呼び出し */
          return add(succ(x), prev(y)); 
        end 
      end;
      --/* #@@range_end(recursive_add) */
      -- <a name="add_reduction_demo"> add(3,2)の簡約 </a>
      -- ![add関数の簡約](images/add-reduction.gif) 
      assert.are.equal(add(3, 2), 5)
      -- expect(
      --   add(3,2)
      -- ).to.eql(
      --   5
      -- );
    end);
    -- #### コラム 再帰と漸化式
    it('再帰と漸化式', function()
      -- **リスト 1.6 漸化式の例 **
      -- 
      -- $$ a(n) = a(n-1) + 3$$
      -- 
      -- ただし、 $$ a(1) = 1 $$
      --/* #@@range_begin(recursion) */
      local function a(n)
        if(n == 1) then
          return 1; -- 初項は1
        else
          return a(n-1) + 3; -- 公差は3
        end 
      end 
      --/* #@@range_end(recursion) */
      assert.are.equal(a(1), 1)
      -- expect(
      --   a(1)
      -- ).to.eql(
      --   1
      -- );
      assert.are.equal(a(2), 4)
      -- expect(
      --   a(2)
      -- ).to.eql(
      --   4
      -- );
      assert.are.equal(a(3), 7)
      -- expect(
      --   a(3)
      -- ).to.eql(
      --   7
      -- );
    end);
    -- **リスト 1.7 while文を利用したadd関数 **
    it('while文を利用したadd関数', function()
      --/* add関数の定義 */
      --/* #@@range_begin(imperative_add) */
      local add = function(x,y)
        while(y > 0) do  -- yが0より大きい間、反復処理を実行する
          x = x + 1;    -- 変数xを更新する 
          y = y - 1;    -- 変数yを更新する
        end 
        return x;
      end 
      --/* #@@range_end(imperative_add) */
      assert.are.equal(add(1,2), 3)
      -- expect(
      --   add(1,2)
      -- ).to.eql(
      --   3
      -- );
      assert.are.equal(add(2,3), 5)
      -- expect(
      --   add(2,3)
      -- ).to.eql(
      --   5
      -- );
      assert.are.equal(add(0, 2), 2)
      -- expect(
      --   add(0,2)
      -- ).to.eql(
      --   2
      -- );
    end);
  end);
  -- ### <section id='function_definition'>関数の定義</section>
  describe('関数の定義', function()
    -- **リスト 1.8 かけ算の定義 **
    it('かけ算の定義', function()
      local succ = function(n)
        return n + 1;
      end
      local prev = function(n)
        return n - 1;
      end 
      local function add(x, y) -- add関数の定義
        if(y < 1) then
          return x;
        else
          return add(succ(x),prev(y)); -- add関数の再帰呼び出し
        end 
      end 
      --/* #@@range_begin(multiply) */
      local function times(count,fun,arg, memo)
        if(count > 1) then
          --/* times関数を再帰呼び出し */
          return times(count-1,fun,arg, fun(memo,arg)); 
        else
          return fun(memo,arg);
        end 
      end 
      local multiply = function(n,m)
        --/* 2番目の引数にadd関数を渡している */
        return times(m, add, n, 0); 
      end 
      --/* #@@range_end(multiply) */
      -- #### <a name="multiply_reduction_demo"> **multiply(2,3)の簡約** </a>
      -- ![multiply関数の簡約](images/multiply_reduction.gif) 
      assert.are.equal(add(2, 3), 5)
      -- expect(
      --   add(2,3)
      -- ).to.eql(
      --   5
      -- );
      assert.are.equal(multiply(2, 3), 6)
      -- expect(
      --   multiply(2,3)
      -- ).to.eql(
      --   6
      -- );
      assert.are.equal(multiply(4, 6), 24)
      -- expect(
      --   multiply(4,6)
      -- ).to.eql(
      --   24
      -- );
      assert.are.equal(multiply(1, 1), 1)
      -- expect(
      --   multiply(1,1)
      -- ).to.eql(
      --   1
      -- );
      assert.are.equal(multiply(0, 1), 0)
      -- expect(
      --   multiply(0,1)
      -- ).to.eql(
      --   0
      -- );
    end);
  end);
  -- ### <section id='advantages_of_functional_model'>関数型モデルを使うメリット</section>
  describe('関数型モデルを使うメリット', function()
    -- **リスト 1.9 べき乗の定義 **
    it('べき乗の定義', function()
      local succ = function(n)
        return n + 1;
      end 
      local prev = function(n)
        return n - 1;
      end 
      local function add(x, y)
        if(y < 1) then
          return x;
        else
          return add(succ(x),prev(y));
        end 
      end 

      local function times(count,fun,arg, memo)
        if(count > 1) then
          return times(count-1,fun,arg, fun(arg,memo));
        else
          return fun(arg,memo);
        end 
      end 
      local multiply = function(n,m)
        return times(m, add, n, 0);
      end 
      -- #@@range_begin(exponential) */
      local exponential = function(n,m)
        return times(m, multiply, n, 1);
      end 
      -- #@@range_end(exponential) */
      assert.are.equal(exponential(2, 3), 8)
      -- expect(
      --   exponential(2,3)
      -- ).to.eql(
      --   8
      -- );
    end);
  end);
end)

-- [目次に戻る](index.html) [次章に移る](chap02.spec.html) 

