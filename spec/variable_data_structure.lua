--  変数とデータ構造

-- ## 4.4 <section id='variable-and-data'>変数とデータの関係</section>
describe('変数とデータの関係', function()
--   -- ### <section id='variable-binding'>変数のバインド</section>
--   -- > 変数boundはバインドされているが、変数unboundはバインドされていない
--   it('変数のバインド', (next) => {
--     -- **リスト4.21** バインド変数と自由変数
--     /* #@@range_begin(variable_binding_value) */
--     var bound = "我思うゆえに我あり";
--     expect(
--       bound
--     ).to.eql(
--       "我思うゆえに我あり"
--     );
--     expect(
--       (_) => { -- 例外をキャッチするにはexpectに関数を渡す
--         unbound -- 変数unboundは自由変数
--       }
--     ).to.throwException((exception)=> {
--       expect(exception).to.be.a(
--         ReferenceError
--       );
--     });
--     /* #@@range_end(variable_binding_value) */
--     next();
--   });
--   -- **リスト4.22** 関数本体でのバインド変数
--   it('関数本体でのバインド変数', (next) => {
--     /* #@@range_begin(bound_variable_in_function) */
--     var add = (x,y) => { -- xとyは引数
--       return x + y; -- それゆえに、xもyもバインド変数
--     };
--     /* #@@range_end(bound_variable_in_function) */
--     expect(
--       add(2,3)
--     ).to.eql(
--       5
--     );
--     expect(
--       add(2,3)
--     ).to.eql(
--       ((x,y) => {
--         return x + y;
--       })(2,3)
--     );
--     next();
end)
--   describe('環境と値', () => {
--     it('関数本体での自由変数', (next) => {
--       -- **リスト4.23** 関数本体での自由変数
--       /* #@@range_begin(free_variable_in_function) */
--       var addWithFreeVariable = (x) => {
--         return x + y;  -- xはバインド変数だが、yは自由変数
--       };
--       /* #@@range_end(free_variable_in_function) */
--       -- 関数本体での自由変数のテスト
--       -- 
--       -- 例外が発生する場合は、無名関数で包みこみ、発生した例外を以下のように捕捉する。
--       -- > to.throwException((exception)=> {
--       -- >   expect(exception).to.be.a(
--       -- >     ReferenceError
--       -- >   );
--       -- > })
--       /* #@@range_begin(free_variable_in_function_test) */
--       expect(
--         (_) => {
--           return addWithFreeVariable(1);
--         }
--       ).to.throwException((exception)=> {
--         expect(exception).to.be.a(
--           ReferenceError
--         );
--       });
--       /* #@@range_end(free_variable_in_function_test) */
--       next();
--     });
--   });
--   -- ### <section id='variable-scope'>変数のスコープ</section>
--   describe('変数のスコープ', () => {
--     -- **リスト4.25** 関数とローカルスコープ
--     it('関数とローカルスコープ', (next) => {
--       /* #@@range_begin(function_creates_scope) */
--       var createScope = (_) =>  { -- ローカルスコープを作る
--         var innerScope = "inner"; 
--         return innerScope; -- 変数innerScopeはcreateScopeのなかでのみ有効
--       };
--       expect(
--         (_) => {
--           innerScope -- ローカルスコープにある変数innerScopeにアクセスを試みる
--         }
--       ).to.throwException((e)=> {
--         expect(e).to.be.a(
--           ReferenceError -- 参照先が見つからないという例外エラーとなる
--         );
--       });
--       /* #@@range_end(function_creates_scope) */
--       expect(
--         createScope()
--       ).to.be(
--         "inner"
--       );
--       next();
--     });
--     -- **リスト4.26** 入れ子になった関数の変数バインド
--     it('入れ子になった関数の変数バインド', (next) => {
--       /* #@@range_begin(binding_in_closure) */
--       var adder = (y) => { -- 外側の関数
--         var addWithFreeVariable = (x) => { -- 内側の関数
--           return x + y; -- 変数yはadder関数の引数yを参照できる
--         };
--         return addWithFreeVariable;
--       };
--       /* #@@range_end(binding_in_closure) */
--       -- **リスト4.27** 入れ子になった関数の適用 
--       /* #@@range_begin(binding_in_closure_test) */
--       expect(
--         adder(2)(3)
--       ).to.eql(
--         5
--       );
--       /* #@@range_end(binding_in_closure_test) */
--       next();
--     });
--   });
-- });
-- -- ## 4.5 <section id='mechanism-of-referential-transparency'>参照透過性の仕組み</section>
-- describe('参照透過性の仕組み', () => {
--   -- ### <section id='mechanism-of-immutability'>不変なデータの仕組み</section>
--   describe('不変なデータの仕組み', () => {
--     -- **リスト4.28** 基本型は値としてのデータである
--     it('基本型は値としてのデータである', (next) => {
--       /* #@@range_begin(basic_type_is_value_type) */
--       var n = 1;
--       expect(
--         n
--       ).to.eql(
--         1
--       );
--       var s = "hello";
--       expect(
--         s
--       ).to.eql(
--         "hello"
--       );
--       /* #@@range_end(basic_type_is_value_type) */
--       expect(
--         n
--       ).to.eql(
--         1
--       );
--       expect(
--         s
--       ).to.eql(
--         "hello"
--       );
--       next();
--     });
--   });
--   -- ### <section id='mechanism-of-assingment'>代入の仕組みと効果</section>
--   describe('代入の仕組みと効果', () => {
--     -- **リスト4.29** 変数への代入
--     it('変数への代入', (next) => {
--       /* #@@range_begin(assign_to_variable) */
--       var age = 29;
--       expect(
--         age
--       ).to.eql(
--         29
--       );
--       /* この時点で誕生日を迎えた */
--       age = 30;
--       expect(
--         age
--       ).to.eql(
--         30
--       );
--       /* #@@range_end(assign_to_variable) */
--       next();
--     });
--     -- <a name="mechanism-of-assignment"> **代入の仕組み** </a>
--     -- ![代入の仕組み](images/mechanism-of-assignment.gif) 
--   });
-- });

describe('代数的データ構造', function()
  describe('式の代数的データ構造', function()
    --/* #@@range_begin(expression_algebraic_datatype) */
    local exp = {
      match = function(data, pattern)
        return data(pattern);
      end, 
      --/* 数値の式 */
      num = function(value)
        return function(pattern)
          return pattern.num(value);
        end;
      end,
      add = function(expL,expR)
        return function(pattern)
          return pattern.add(expL, expR);
        end 
      end,
      subtract = function(expL,expR)
        return function(pattern)
          return pattern.subtract(expL, expR);
        end 
      end,
      multiply = function(expL,expR)
        return function(pattern)
          return pattern.multiply(expL, expR);
        end 
      end,
      divide = function(expL,expR)
        return function(pattern)
          return pattern.divide(expL, expR);
        end 
      end
    };
      --/* #@@range_end(numerical_expression_as_algebraic_datatype) */
    describe('式をテストする', function()
      it("1+2", function()
        local expression = exp.add(exp.num(1), exp.num(2))
        return exp.match(expression, {
          add = function(left, right)
            exp.match(left, {
              num = function(value) 
                assert.are.equal( value , 1)
              end
            })
          end 
        });
      end);
    end);
  end);
end) -- end of 抽象構文木を作る




