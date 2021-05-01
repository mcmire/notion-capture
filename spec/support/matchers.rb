module Specs
  module Matchers
    extend RSpec::Matchers::DSL
  end
end

RSpec.configure { |config| config.include(Specs::Matchers) }
