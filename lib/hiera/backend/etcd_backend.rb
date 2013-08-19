# Hiera backend for the etcd distributed configuration service
class Hiera
  module Backend
    class Etcd_backend

      def initialize
        require 'net/http'
        require 'net/https'
        require 'json'
        @config = Config[:http]
        @http = Net::HTTP.new(@config[:host], @config[:port])
        @http.read_timeout = @config[:http_read_timeout] || 10
        @http.open_timeout = @config[:http_connect_timeout] || 10
      end

      def lookup(key, scope, order_override, resolution_type)

        answer = nil

        # Extract multiple etcd paths from the configuration file
        paths = @config[:paths].map { |p| Backend.parse_string(p, scope, { 'key' => key }) }
        paths.insert(0, order_override) if order_override

        paths.each do |path|
          Hiera.debug("[hiera-etcd]: Lookup #{@config[:host]}:#{@config[:port]}#{path}/#{key}")
          httpreq = Net::HTTP::Get.new("#{path}/#{key}")

          # If we can't connect to etcd at all we throw an exception and
          # block the run
          begin
            httpres = @http.request(httpreq)
          rescue Exception => e
            Hiera.warn("[hiera-etcd]: Net::HTTP threw exception #{e.message}")
            raise Exception, e.message
            next
          end

          # If we don't find any results in etcd we continue on to the
          # next path
          unless httpres.kind_of?(Net::HTTPSuccess)
            Hiera.debug("[hiera-etcd]: #{httpres.code} HTTP response from #{@config[:host]}:#{@config[:port]}#{path}/#{key}")
            next
          end

          # On to the next path if we don't have a response
          next unless httpres.body
          # Parse result from standard etcd JSON response
          result = JSON.parse(httpres.body)['value']
          parsed_result = Backend.parse_answer(result, scope)

          # Format response as specified type, either array, hash or text
          case resolution_type
          when :array
            answer ||= []
            answer << parsed_result
          when :hash
            answer ||= {}
            answer = parsed_result.merge answer
          else
            answer = parsed_result
            break
          end
        end
        answer
      end

    end
  end
end
