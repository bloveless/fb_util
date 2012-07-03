class FBUtilError < Exception
  attr_accessor :error_code, :body, :object

  def initialize(error_code, body)
    @error_code = error_code
    @body = body
    begin
      @object = JSON.parse(body)
    rescue JSON::ParserError
      @object = {"error" => {"message" => "Response was not valid json. See the body for more information."}}
    end
  end

  def to_s
    "Response code: #{error_code} => #{body}"
  end
end
