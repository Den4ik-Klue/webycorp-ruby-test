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
    Application.logger.info("Запрос к FakeStoreAPI: #{BASE_URL}#{endpoint}")
  end

  def handle_response(response)
    if response.success?
      JSON.parse(response.body, symbolize_names: true)
    else
      Application.logger.error("Ошибка при выполнении запроса: #{response.status} - #{response.body}")
      nil
    end
  end
end