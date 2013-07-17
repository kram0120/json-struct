require "ostruct"

class JsonStruct < OpenStruct
  def initialize(hash = nil, options = nil)
    if hash
      exclude_filters = extract_option(options, :exclude, [])
      include_filters = extract_option(options, :only, [])
      name_changes = extract_option(options, :rename, {})

      hash_copy = hash.each_with_object({}) do |(k, v), h|
        next if (exclude_filters.include? k)
        next if (!include_filters.empty? && !include_filters.include?(k))
        if name_changes[k]
          h[name_changes[k]] = v
        else
          h[k] = v
        end
      end

      for k, v in hash_copy
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
  def extract_option(options, key, default)
    return default if !options
    options.fetch(key, default)
  end
end
