require File.expand_path('../../../spec_helper', __FILE__)

describe Signature::Strategy::Header::Request do
	let(:method)			{ 'GET' }
	let(:path)				{ '/test/path' }
	let(:params)			{{:param1 => 'param1', :param2 => 'param2'}}
	let(:auth_key)			{ 'key123456' }
	let(:secret)			{ 'secretabcdefg' }
	let(:timestamp)			{ Time.at(2345) }
	let(:auth_timestamp)	{ timestamp.to_i.to_s }
	let(:auth_version)		{ "1.0" }
	let(:auth_signature)	{ '2e02c2f05417c9fbef4df14abee0709f53ccf1bf36c2d487e0c3c06e3d11b177' }
	let(:auth_params)		{{ 'auth_signature' => auth_signature, 'auth_timestamp' => auth_timestamp, 'auth_key' => auth_key, 'auth_version' => auth_version }}
	let(:token)				{ Signature::Token.new auth_key, secret }
	let(:headers)			{{ 'HTTP_X_GY_AUTH_KEY' => auth_key, 'HTTP_X_GY_AUTH_SIGNATURE' => auth_signature, 'HTTP_X_GY_AUTH_TIMESTAMP' => auth_timestamp, 'HTTP_X_GY_AUTH_VERSION' => auth_version }}

	before do
		Time.stub!(:now).and_return(timestamp)
	end

	subject(:request){ Signature::Strategy::Header::Request.new method, path, params, headers }

	describe "#sign" do
		it "returns auth headers" do
			hash = request.sign token
			hash.should == {
				'X-GY-Auth-Signature' => auth_signature,
				'X-GY-Auth-Key' => auth_key,
				'X-GY-Auth-Timestamp' => auth_timestamp,
				'X-GY-Auth-Version' => auth_version,
			}
		end
	end

	describe "::parse_headers" do
		context "when auth headers exist" do
			it "returns auth hash" do
				hash = Signature::Strategy::Header::Request.parse_headers headers
				hash.should == {
					"auth_key" => auth_key, 
					"auth_signature" => auth_signature, 
					"auth_timestamp" => auth_timestamp, 
					"auth_version" => auth_version
				}
			end
		end

		context "when header are empty" do
			it "returns empty hash" do
				hash = Signature::Strategy::Header::Request.parse_headers {}
				hash.should == {}
			end
		end
	end
end