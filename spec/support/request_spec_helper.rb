module RequestSpecHelper
  def api_headers
    {
      'ACCEPT' => 'application/json',
      'Authorization' => "Token token=#{@credential.token}"
    }
  end
end
