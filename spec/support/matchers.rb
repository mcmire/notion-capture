module Specs
  module Matchers
    extend RSpec::Matchers::DSL
  end
end

RSpec.configure do |config|
  config.include(Specs::Matchers)
end
