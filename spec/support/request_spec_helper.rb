module RequestSpecHelper
  def test_api_headers
    {
      'ACCEPT' => 'application/json',
      'Authorization' => "Token token=#{@credential.token}"
    }
  end
end
