require "ostruct"

class JsonStruct < OpenStruct
  def initialize(hash = nil, options = nil)
    if hash
      exclude_filters = filters(options, :exclude)
      include_filters = filters(options, :only)

      hash_copy = Hash[hash]
      for k, v in hash_copy
        if (exclude_filters.include? k)
          hash_copy.delete(k)
          next
        end

        if (!include_filters.empty? && !include_filters.include?(k))
          hash_copy.delete(k)
          next
        end

        if v.is_a? Hash
          hash_copy[k] = JsonStruct.new(v, options)
        elsif v.is_a? Array
          hash_copy[k] = v.map { |item| item.is_a?(Hash) ? JsonStruct.new(item, options) : item }
        end
      end
      super(hash_copy)
    end
  end


  def as_json
    dump = marshal_dump
    for k, v in dump
      if v.is_a? JsonStruct
        dump[k] = v.as_json
      elsif v.is_a? Array
        dump[k] = v.map { |item| item.is_a?(JsonStruct) ? item.as_json : item }
      end
    end
    dump
  end

  private
  def filters(options, key)
    filter = []
    if options
      filter = options[key] || []
    end
    filter
  end
end
