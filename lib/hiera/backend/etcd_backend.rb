# Hiera backend for the etcd distributed configuration service
class Hiera
  module Backend
    class Etcd_backend

      def initialize
        require 'etcd'
        require 'json'
        @config = Config[:http]
        etcd_uri = "#{@config[:host]}:#{@config[:port]}"
        @client = Etcd::Client.new(uri: etcd_uri)
        @client.connect
      end

      def lookup(key, scope, order_override, resolution_type)

        answer = nil

        # Extract multiple etcd paths from the configuration file
        paths = @config[:paths].map { |p| Backend.parse_string(p, scope, { 'key' => key }) }
        paths.insert(0, order_override) if order_override

        paths.each do |path|
          Hiera.debug("[hiera-etcd]: Lookup #{path}/#{key} on #{@config[:host]}:#{@config[:port]}")
          result = @client.get("#{path}/#{key}")
          answer = self.parse_result(result, resolution_type)
          next unless answer
          break
        end
        answer
      end


      def parse_result(res, type)
        answer = nil
        case type
        when :array
          answer ||= []
          begin
            data = Backend.parse_answer(JSON[res], scope)
            answer << data
          rescue
            Hiera.warn("[hiera-etcd]: '#{res}' is not in json format, and array lookup is requested")
          end
        when :hash
          answer ||= {}
          begin
            data = Backend.parse_answer(JSON[res], scope)
            answer << data
          rescue
            Hiera.warn("[hiera-etcd]: '#{res}' is not in json format, and hash lookup is requested")
          end
        else
          answer = Backend.parse_answer(result, scope)
        end
        answer
      end
    end
  end
end
