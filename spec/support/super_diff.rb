require 'super_diff/rspec'

SuperDiff.configure do |config|
  config.diff_elision_enabled = true
  config.diff_elision_maximum = 5
end
