require 'ostruct'
require 'yaml'

module ConfigUtils

  class Config
    def self.load_file(file_path, env)
      ConfigUtils::NestedOpenStruct.new(
        YAML.load_file(file_path)[env]
      )
    end
  end
  
  class NestedOpenStruct
    def self.new(hash)
      OpenStruct.new(hash.inject({}){|r,p| r[p[0]] = p[1].kind_of?(Hash) ?
      NestedOpenStruct.new(p[1]) : p[1]; r })
    end
  end
end
