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
          begin
            result = @client.get("#{path}/#{key}")
          rescue
            Hiera.debug("[hiera-etcd]: bad request key")
            next
          end
          answer = self.parse_result(result.value, resolution_type, scope)
          next unless answer
          break
        end
        answer
      end


      def parse_result(res, type, scope)
        answer = nil
        case type
        when :array
          answer ||= []
          begin
            data = Backend.parse_answer(JSON[res], scope)
          rescue
            Hiera.warn("[hiera-etcd]: '#{res}' is not in json format, and array lookup is requested")
          end

          if data.is_a?(Array)
            answer = data.clone
          else
            Hiera.error("Data is in json format, but this is not an array")
          end
        when :hash
          answer ||= {}
          begin
            data = Backend.parse_answer(JSON[res], scope)
          rescue
            Hiera.warn("[hiera-etcd]: '#{res}' is not in json format, and hash lookup is requested")
          end
          if data.is_a?(Hash)
            answer = data.clone
          else
            Hiera.error("Data is in json format, but this is not an hash")
          end
        else
          answer = Backend.parse_answer(res, scope)
        end
        answer
      end
    end
  end
end
