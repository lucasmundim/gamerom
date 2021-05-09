class Mechanize
  include MechanizeProgressBarAPI # (1of7)a
  class HTTP
    class Agent
      def response_read response, request, uri = nil
        body_io = StringIO.new
        body_io.set_encoding Encoding::BINARY if body_io.respond_to? :set_encoding
        total = 0
        mpbar = MechanizeProgressBar.new(self.context, request, response) # (2of7)a

        begin
          response.read_body { |part|
            total += part.length
            body_io.write(part)
#           log.debug("Read #{part.length} bytes (#{total} total)") if log
            log.debug("Read #{part.length} bytes (#{total} total)") if log && !mpbar.suppress_logger? # (3of7)m
            mpbar.inc(part.length) # (4of7)a
          }
        rescue Net::HTTP::Persistent::Error => e
          body_io.rewind
          raise Mechanize::ResponseReadError.new(e, response, body_io)
        ensure # (5of7)a
          mpbar.finish # (6of7)a
        end

        body_io.rewind
        log.debug("Read #{total} bytes total") if log && !mpbar.suppress_logger? # (7of7)a

        raise Mechanize::ResponseCodeError, response if
          Net::HTTPUnknownResponse === response

        content_length = response.content_length

        unless Net::HTTP::Head === request or Net::HTTPRedirection === response then
          raise EOFError, "Content-Length (#{content_length}) does not match " \
          "response body length (#{body_io.length})" if
            content_length and content_length != body_io.length
        end

        body_io
      end
    end
  end
end
