class InvoiceGenerator
  FAKE_STORE_API_URLS = {
    carts: 'https://fakestoreapi.com/carts',
    user: 'https://fakestoreapi.com/users/',
    product: 'https://fakestoreapi.com/products/'
  }.freeze

  def initialize
    Stripe.api_key = Settings.stripe.api_key
    @logger = Logger.new(STDOUT)
  end

  def call
    carts = Crawler.new(FAKE_STORE_API_URLS[:carts]).get_json_data

    return 'No data from API!!!!' if carts.empty?

    carts.each do |cart|
      customer = load_to_stripe(opts: 'Customer', data: create_customer(cart[:userId].to_s))
      @logger.info "Customer created: name - #{customer['name']}, email - #{customer['email']}"

      products_id = cart[:products]
      next if products_id.empty?

      create_invoice_items(cart[:products], customer)
      invoice = load_to_stripe(opts: 'Invoice', data: { customer: customer['id'], auto_advance: false })
      @logger.info "Created a draft invoice"

      finalize_invoice(invoice)
      @logger.info "Finalized the Invoice for: customer_id - #{customer['id']} customer_name - #{customer['name']}"
    end
  end

  def create_api_url(opts:, id:)
    FAKE_STORE_API_URLS[opts] + id
  end

  def create_customer(user_id)
    Parser.new(
      Crawler.new(create_api_url(
                    opts: :user, id: user_id
                  )).get_json_data
    ).parse_customer
  end

  def create_invoice_items(products_data, customer)
    count = 1
    products_data.each do |product_data|
      product_json = Crawler.new(create_api_url(opts: :product, id: product_data[:productId].to_s)).get_json_data

      product = load_to_stripe(opts: 'Product', data: Parser.new(product_json).parse_product)

      price = load_to_stripe(opts: 'Price', data: {
        product: product['id'], **Parser.new(product_json).parse_price
      })

      load_to_stripe(opts: 'InvoiceItem', data: {
        customer: customer['id'],
        price: price['id'],
        quantity: product_data[:quantity]
      })

      @logger.info "Invoice item #{count} created"
      count += 1
    end
  end

  def finalize_invoice(invoice)
    Stripe::Invoice.finalize_invoice(invoice['id'])
  end

  def load_to_stripe(opts:, data:)
    Object.const_get("Stripe::#{opts}").create(**data)
  end
end

InvoiceGenerator.new.call