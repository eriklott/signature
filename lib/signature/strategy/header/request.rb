module Signature
	module Strategy
		module Header
			class Request < ::Signature::Request
				AUTH_HEADER_PREFIX = "X-GY-"
				AUTH_HEADER_REGEX = /^#{AUTH_HEADER_PREFIX.downcase}(auth-.+)$/i

				def self.parse_headers headers={}
					headers.inject({}) do |memo,(k,v)|
						if match = k.match(AUTH_HEADER_REGEX)
							memo[match[1].downcase.gsub('-', '_')] = v
						end 
						memo
					end
				end

				def initialize method, path, query={}, headers={}
					raise ArgumentError, "Expected string" unless path.kind_of?(String)

					auth_hash = self.class.parse_headers(headers)
					super(method, path, query.merge(auth_hash))
				end

				def sign token
					auth_hash = super(token)
					auth_hash.inject({}) do |memo, (k,v)|
						header_key = "#{ AUTH_HEADER_PREFIX }#{ k.to_s.split('_').map(&:capitalize).join('-') }"
						memo[header_key] = v
						memo
					end
				end
			end
		end
	end
end