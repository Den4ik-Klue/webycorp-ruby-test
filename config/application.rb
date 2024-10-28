# frozen_string_literal: true

# Basic application class
class Application
  class << self
    attr_accessor :logger

    # Absolute path to the root directory of the application
    def root
      File.expand_path('..', __dir__)
    end

    # Symbol with the current environment
    def environment
      ENV.fetch('RACK_ENV').to_sym
    end

    # Application loading method
    def load_app!
      init_config
      require_app
    end

    private

    # Load settings
    def init_config
      require_file 'config/initializers/config'
    end

    # Require application dependencies in the right sequence
    def require_app
      require_file 'config/initializers/logger'
      require_dir 'app/lib'
      require_dir 'app'
      require_dir 'config/initializers'
    end

    # Require file
    def require_file(path)
      require File.join(root, path)
    end

    # Require directory recursively
    def require_dir(path)
      path = File.join(root, path)
      Dir["#{path}/**/*.rb"].sort.each { |f| require f }
    end
  end
end
