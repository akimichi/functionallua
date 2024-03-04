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
    it("'0' is truthy", function()
      assert.is_truthy(0)
    end)

    -- failed test
    it("'1' equal '1'", function()
      assert.is_equal(1, 1)
    end)
  end)

end)

