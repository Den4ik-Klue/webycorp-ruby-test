class Parser
  def initialize(ctx)
    @ctx = ctx
  end

  def parse_customer
    {
      email: @ctx[:email],
      name: "#{@ctx.dig(:name, :firstname)} #{@ctx.dig(:name, :lastname)}"
    }
  end

  def parse_product
    {
      name: @ctx[:title],
      description: @ctx[:description]
    }
  end

  def parse_price
    {
      unit_amount: (@ctx[:price] * 100).to_i,
      currency: 'usd'
    }
  end
end