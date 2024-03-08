-- chap01_spec.lua
describe("命令型モデル", function()
  describe("チューリング機械 turing machine", function()
    -- **リスト 1.1 JavaScriptによるチューリング機械 **
    -- #@range_begin(turing)
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
    -- #@range_end(turing)
  end)
  -- **リスト 1.2 チューリング機械の実行例 **
  describe('チューリング機械の実行例', () => {
    -- #### <a name="turing_demo"> **チューリング機械の挙動** </a>
    -- ![チューリング機械の挙動](images/turing_succ.gif) 
    it('チューリング機械でsucc関数を実装する', (next) => {
      --[[
       #@range_begin(turing_example_succ)
       2進法で10、つまり10進法で2を表すテープ
      ]]
      var tape = { 
        '0':'1',
        '1':'0'
      };
      /* チューリング機械に与えるプログラム */
      var program = {
        'q0': {"1": {"write": "1", "move": 1, "next": 'q0'},
        "0": {"write": "0", "move": 1, "next": 'q0'},
        "B": {"write": "B", "move": -1, "next": 'q1'}},
        'q1': {"1": {"write": "0", "move": -1, "next": 'q1'},
        "0": {"write": "1", "move": -1, "next": 'q2'},
        "B": {"write": "1", "move": -1, "next": 'q3'}},
        'q2': {"1": {"write": "1", "move": -1, "next": 'q2'},
        "0": {"write": "0", "move": -1, "next": 'q2'},
        "B": {"write": "B", "move": 1, "next": 'q4'}},
        'q3': {"1": {"write": "1", "move": 1, "next": 'q4'},
        "0": {"write": "0", "move": 1, "next": 'q4'},
        "B": {"write": "B", "move": 1, "next": 'q4'}}
      };
      /* #@range_end(turing_example_succ) */
      expect(
      -- **リスト 1.3 1を加えるチューリング機械の実行 **
      /* #@range_begin(turing_example_succ_test) */
      machine(program,     -- プログラム
      tape,        -- テープ
      'q0',        -- 初期状態
      'q4')        -- 終了状態
      /* #@range_end(turing_example_succ_test) */
      ).to.eql(
      /* #@range_begin(turing_example_succ_test_result) */
      {
        '-1': 'B',
        '0': '1',
        '1': '1',
        '2': 'B'
      }
      /* #@range_end(turing_example_succ_test_result) */
      );
      next();
    });
  });
end)

