class Crawler
  def initialize(url)
    @url = url
  end

  def get_json_data
    ctx = Faraday.get(@url)
    return 'No data from Api' unless ctx

    JSON.parse(ctx.body, symbolize_names: true)
  end
end