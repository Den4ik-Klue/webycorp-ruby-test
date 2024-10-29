class Crawler
  BASE_URL = 'https://fakestoreapi.com'

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  def get_json_data(endpoint)
    log_request(endpoint)
    response = @connection.get(endpoint)
    handle_response(response)
  end

  private

  def log_request(endpoint)
    Application.logger.info("Request to FakeStoreAPI: #{BASE_URL}#{endpoint}")
  end

  def handle_response(response)
    if response.success?
      Application.logger.error("Request successful: #{response.status} - #{response.body}")
      JSON.parse(response.body, symbolize_names: true)
    else
      Application.logger.error("Error executing request: #{response.status} - #{response.body}")
      []
    end
  end
end