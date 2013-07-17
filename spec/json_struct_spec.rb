require "json_struct"
require "json"

describe JsonStruct do
  let(:struct) {JsonStruct.new(json)}
  let(:json) { {a: 'b', c: {d: 'e', f: 'g'}, h: %w(i j k)} }

  describe 'with simple JSON' do
    let(:json) { {a: 'b', c: 'd'} }

    it 'creates a JsonStruct representing the JSON' do
      struct.a.should == 'b'
      struct.c.should == 'd'
    end

    it 'converts the object to a hash' do
      struct.as_json.should == json
    end
  end

  describe 'with nested JSON' do
    let(:json) do
      {
        name: 'foo',
        address: {
          street: '123 Main Street',
          zip: {
            five: 80301,
            plus4: 1234
          }
        }
      }
    end

    it 'creates nested JsonStructs for nested attributes' do
      struct.name.should == 'foo'
      struct.address.street.should == '123 Main Street'
      struct.address.zip.five.should == 80301
    end

    it 'converts the object to a hash' do
      struct.as_json.should == json
    end
  end

  describe 'with a list of JSON objects' do
    let(:json) do
      {
        people: [
          {
            name: 'foo',
            address: {
              street: '123 Main Street',
              zip: {
                five: 80301,
                plus4: 1234
              }
            }
          },
          {
            name: 'bar',
            address: {
              street: '456 Seldom Ave',
              zip: {
                five: 12345,
                plus4: 5678
              }
            }
          }
        ]
      }
    end

    it 'creates a JsonStruct representation of the list' do
      struct.people.should be_a Array
      struct.people.length.should == 2
      struct.people[0].name.should == 'foo'
      struct.people[0].address.street.should == '123 Main Street'
      struct.people[0].address.zip.five.should == 80301
      struct.people[1].name.should == 'bar'
      struct.people[1].address.street.should == '456 Seldom Ave'
      struct.people[1].address.zip.five.should == 12345
    end

    it 'converts the object to a hash' do
      struct.as_json.should == json
    end
  end

  describe 'with a list of primitive values' do
    let(:json) do
      {
        name: 'baz',
        list: %w{a b c}
      }
    end

    it 'returns the list' do
      struct.name.should == 'baz'
      struct.list.should == %w{a b c}
    end

    it 'converts the JsonStruct to a Hash' do
      struct.as_json.should == json
    end
  end

  describe 'filters' do
    it 'filters out excluded keys' do
      struct = JsonStruct.new(json, exclude: [:a, :f])
      struct.should_not respond_to(:a)
      struct.should_not respond_to(:f)
      struct.c.d.should == 'e'
      struct.h.should == %w{i j k}
      struct.as_json.should == {c: {d: 'e'}, h: %w(i j k)}
    end

    it 'filters keys not in the only filter' do
      struct = JsonStruct.new(json, only: [:a, :h])
      struct.a.should == 'b'
      struct.h.should == %w{i j k}
      struct.should_not respond_to(:c)
      struct.as_json.should == {a: 'b', h: %w(i j k)}

      struct2 = JsonStruct.new(json, only: [:c, :f])
      struct2.c.f.should == 'g'
      struct2.as_json.should == {c: {f: 'g'}}
    end

    it 'exclude filters take precedence over only filters' do
      struct = JsonStruct.new(json, exclude: [:a], only: [:a])
      struct.should_not respond_to(:a)
    end
  end

  describe 'renaming' do
    let(:struct) { JsonStruct.new(json, rename: {a: 'alpha', c: 'charlie'}) }

    it 'allows the caller to rename keys' do
      struct.should_not respond_to(:a)
      struct.should_not respond_to(:c)
      struct.alpha.should == 'b'
      struct.charlie.d.should == 'e'
    end

    it 'generates JSON with the renamed keys' do
      struct.as_json.should == {alpha: 'b', charlie: {d: 'e', f: 'g'}, h: %w(i j k)}
    end
  end
end