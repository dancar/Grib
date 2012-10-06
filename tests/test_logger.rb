require 'logger'
class TestLogger < Logger
  attr_accessor :last_log
  @@last_log = nil

  [:debug, :info, :warn, :error].each do |sevirity|
    define_method sevirity do |*args|
      @@last_log = sevirity
      super(*args) if ENV["BUBBLE_LOGS"]
    end
  end

  def clear()
    @@last_log = nil
  end

  def initialize(target = nil)
    super(target || STDOUT)
    self.clear()
  end

  def self.last_log
    @@last_log
  end
end

class Test::Unit::TestCase
  def assert_last_log (type)
    assert_equal(type, TestLogger.last_log)
  end
end