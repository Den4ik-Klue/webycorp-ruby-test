class InvoiceGenerator
  FAKE_STORE_API_PARTS = {
    carts: '/carts',
    user: '/users/',
    product: '/products/'
  }.freeze

  def initialize
    @api_key = begin
                 Settings.stripe.api_key
               rescue
                 'foo'
               end
    Stripe.api_key = @api_key == 'foo' ? ENV['STRIPE_SECRET_KEY'] : @api_key
    @logger = Application.logger
  end

  def call
    carts = Crawler.new.get_json_data(FAKE_STORE_API_PARTS[:carts])

    return 'No data from API!!!!' if carts.empty?

    carts.each do |cart|
      customer = load_to_stripe(opts: 'Customer', data: create_customer(cart[:userId].to_s))

      products_id = cart[:products]
      next if products_id.empty?

      create_invoice_items(cart[:products], customer)
      invoice = load_to_stripe(opts: 'Invoice', data: { customer: customer['id'], auto_advance: false })

      finalize_invoice(invoice)
    end
  end

  def create_api_url(opts:, id:)
    FAKE_STORE_API_PARTS[opts] + id
  end

  def create_customer(user_id)
    Parser.new(
      Crawler.new.get_json_data(create_api_url(
                                  opts: :user, id: user_id
                                ))
    ).parse_customer
  end

  def create_invoice_items(products_data, customer)
    products_data.each do |product_data|
      product_json = Crawler.new.get_json_data((create_api_url(opts: :product, id: product_data[:productId].to_s)))

      product = load_to_stripe(opts: 'Product', data: Parser.new(product_json).parse_product)

      price = load_to_stripe(opts: 'Price', data: {
        product: product['id'], **Parser.new(product_json).parse_price
      })

      load_to_stripe(opts: 'InvoiceItem', data: {
        customer: customer['id'],
        price: price['id'],
        quantity: product_data[:quantity]
      })
    end
  end

  def finalize_invoice(invoice)
    @logger.info "Finalizing invoice with ID: #{invoice['id']}"
    response = Stripe::Invoice.finalize_invoice(invoice['id'])
    @logger.info "Invoice finalized: #{response.inspect}"
    response
  end

  def load_to_stripe(opts:, data:)
    @logger.info "Loading to Stripe: #{opts} with data: #{data.inspect}"
    response = Object.const_get("Stripe::#{opts}").create(**data)
    @logger.info "#{opts} created with response ID: #{response['id']}"
    response
  end
end

InvoiceGenerator.new.call