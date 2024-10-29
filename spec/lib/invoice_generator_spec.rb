require 'rspec'
require_relative '../../app/scripts/invoice_generator'

RSpec.describe InvoiceGenerator do
  describe '#call', vcr: true do
    it 'generates invoices correctly' do
      generator = InvoiceGenerator.new

      expect { generator.call }.not_to raise_error

    end
  end
end