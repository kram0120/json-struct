JsonStruct
==========

A simple utility for converting JSON hashes to Ruby objects and back.

Usage
-----
Convert JSON hash to a struct

```ruby
json = {a: 'b', c: {d: 'e', f: 'g'}, h: ['i', 'j', 'k']}
=> {:a=>"b", :c=>{:d=>"e", :f=>"g"}, :h=>["i", "j", "k"]}
struct = JsonStruct.new(json)
=> #<JsonStruct a="b", c=#<JsonStruct d="e", f="g">, h=["i", "j", "k"]>
struct.a
=> "b"
struct.c.e
=> nil
struct.c.f
=> "g"
struct.h
=> ["i", "j", "k"]
```

Filter out unwanted keys

```ruby
struct = JsonStruct.new(json, exclude: [:h])
=> #<JsonStruct a="b", c=#<JsonStruct d="e", f="g">>

struct2 = JsonStruct.new(json, only: [:a, :h])
=> #<JsonStruct a="b", h=["i", "j", "k"]>
```
Convert from object to JSON

```ruby
struct = JsonStruct.new(json)
=> #<JsonStruct a="b", c=#<JsonStruct d="e", f="g">, h=["i", "j", "k"]>
struct.as_json
=> {:a=>"b", :c=>{:d=>"e", :f=>"g"}, :h=>["i", "j", "k"]}
```
