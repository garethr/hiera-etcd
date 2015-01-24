# Hiera backend for the etcd distributed configuration service
class Hiera
  module Backend
    class Etcd_backend

      def initialize
        require 'etcd'
        require 'json'
        @config = Config[:http]
        @client = Etcd.client(:host => @config[:host], :port => @config[:port])
      end

      def lookup(key, scope, order_override, resolution_type)

        answer = nil

        # Extract multiple etcd paths from the configuration file
        paths = @config[:paths].map { |p| Backend.parse_string(p, scope, { 'key' => key }) }
        paths.insert(0, order_override) if order_override

        paths.each do |path|
          Hiera.debug("[hiera-etcd]: Lookup #{path}/#{key} on #{@config[:host]}:#{@config[:port]}")
          if "#{path}/#{key}".match("//")
            Hiera.debug("[hiera-etcd]: The specified path #{path}/#{key} is malformed, skipping")
            next
          end
          begin
            result = @client.get("#{path}/#{key}").node
          rescue
            Hiera.debug("[hiera-etcd]: bad request key")
            next
          end
          answer = self.traverse_node(result, resolution_type, scope)
          next unless answer
          break
        end
        answer
      end

      def traverse_node(node, type, scope)
        if (node.dir == nil)
        then
          return parse_result(node.value, type, scope)
        else
          answer ||= {}

          node.children.each do|n|
            key = n.key
            # Normalize the key
            relative_key = key[key.rindex('/')+1..-1]
            answer[relative_key] = traverse_node(@client.get(key).node, type, scope)
          end
          return answer
        end
      end

      def parse_result(res, type, scope)
        answer = nil
        case type
        when :array
          # Called with hiera_array().
          answer ||= []
          begin
            data = Backend.parse_answer(JSON[res], scope)
          rescue
            Hiera.warn("[hiera-etcd]: '#{res}' is not in json format, and array lookup is requested")
            return answer
          end

          if data.is_a?(Array)
            answer = data.clone
          else
            Hiera.warn("Data is in json format, but this is not an array")
          end
        when :hash
          # Called with hiera_hash().
          answer ||= {}
          begin
            data = Backend.parse_answer(JSON[res], scope)
          rescue
            Hiera.warn("[hiera-etcd]: '#{res}' is not in json format, and hash lookup is requested")
            return answer
          end
          if data.is_a?(Hash)
            answer = data.clone
          else
            Hiera.warn("Data is in json format, but this is not an hash")
          end
        else
          # Called with hiera(), which can return an array, hash, or string.
          res = JSON[res] rescue res
          answer = Backend.parse_answer(res, scope)
        end
        answer
      end
    end
  end
end
