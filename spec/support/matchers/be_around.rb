module Specs
  module Matchers
    extend RSpec::Matchers::DSL

    def be_around(time)
      be_within(1.0).of(time)
    end
    alias_matcher :a_time_around, :be_around
  end
end
