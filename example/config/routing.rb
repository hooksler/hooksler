Hooksler::Router.config do
  secret_code '123'

  endpoints do
    input  'in_1',  type: :dummy
    input  'in_2',  type: :dummy
    output 'out_1', type: :dummy, a:1 , b: 2
    output 'out_2', type: :dummy, c:1 , d: 2
  end

  route 'in_1' => 'out_1', a:1 , b: 2
  route 'in_2' => 'out_2', a:1 , c: 2
  route 'in_1' => 'out_2', filter: [ ->(m, p = {}) { m.message *= 2; m }]
end
